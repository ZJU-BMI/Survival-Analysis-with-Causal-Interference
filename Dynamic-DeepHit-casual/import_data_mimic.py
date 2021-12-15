import pandas as pd
import numpy as np


# USER-DEFINED FUNCTIONS
def f_get_Normalization(X, norm_mode=None):
    num_Patient, num_Feature = np.shape(X)

    if norm_mode is None:
        print("No normalization needed.")
    elif norm_mode == 'standard':  # zero mean unit variance
        for j in range(num_Feature):
            if np.nanstd(X[:, j]) != 0:
                X[:, j] = (X[:, j] - np.nanmean(X[:, j])) / np.nanstd(X[:, j])
            else:
                X[:, j] = (X[:, j] - np.nanmean(X[:, j]))
    elif norm_mode == 'normal':  # min-max normalization
        for j in range(num_Feature):
            X[:, j] = (X[:, j] - np.nanmin(X[:, j])) / (np.nanmax(X[:, j]) - np.nanmin(X[:, j]))
    else:
        print("INPUT MODE ERROR!")

    return X


def f_get_fc_mask1(meas_time, num_Event, num_Category):
    """
        mask3 is required to get the conditional probability (to calculate the denominator part)
        mask3 size is [N, num_Event, num_Category]. 1's until the last measurement time
    """
    mask = np.zeros([np.shape(meas_time)[0], num_Event, num_Category])  # for denominator
    for i in range(np.shape(meas_time)[0]):
        mask[i, :, :int(meas_time[i, 0] + 1)] = 1  # last measurement time

    return mask


def f_get_fc_mask2(time, label, num_Event, num_Category):
    """
        mask4 is required to get the log-likelihood loss
        mask4 size is [N, num_Event, num_Category]
            if not censored : one element = 1 (0 elsewhere)
            if censored     : fill elements with 1 after the censoring time (for all events)
    """
    mask = np.zeros([np.shape(time)[0], num_Event, num_Category])  # for the first loss function
    for i in range(np.shape(time)[0]):
        if label[i, 0] != 0:  # not censored
            mask[i, int(label[i, 0] - 1), int(time[i, 0])] = 1
        else:  # label[i,2]==0: censored
            mask[i, :, int(time[i, 0] + 1):] = 1  # fill 1 until from the censoring time (to get 1 - \sum F)
    return mask


def f_get_fc_mask3(time, meas_time, num_Category):
    """
        mask5 is required calculate the ranking loss (for pair-wise comparision)
        mask5 size is [N, num_Category].
        - For longitudinal measurements:
             1's from the last measurement to the event time (exclusive and inclusive, respectively)
             denom is not needed since comparing is done over the same denom
        - For single measurement:
             1's from start to the event time(inclusive)
    """
    mask = np.zeros([np.shape(time)[0], num_Category])  # for the first loss function
    if np.shape(meas_time):  # longitudinal measurements
        for i in range(np.shape(time)[0]):
            t1 = int(meas_time[i, 0])  # last measurement time
            t2 = int(time[i, 0])  # censoring/event time
            mask[i, (t1 + 1):(t2 + 1)] = 1  # this excludes the last measurement time and includes the event time
    else:  # single measurement
        for i in range(np.shape(time)[0]):
            t = int(time[i, 0])  # censoring/event time
            mask[i, :(t + 1)] = 1  # this excludes the last measurement time and includes the event time
    return mask


# TRANSFORMING DATA
def f_construct_dataset(df, feat_list):
    """
        id   : patient indicator
        ett  : time-to-event or time-to-censoring
            - must be synchronized based on the reference time
        times: time at which observations are measured
            - must be synchronized based on the reference time (i.e., times start from 0)
        label: event/censoring information
            - 0: censoring
            - 1: event type 1
            - 2: event type 2
            ...
    """

    grouped = df.groupby(['id'])
    id_list = pd.unique(df['id'])
    max_meas = np.max(grouped.count())[0]

    data = np.zeros([len(id_list), max_meas, len(feat_list) + 1])
    pat_info = np.zeros([len(id_list), 10])

    for i, tmp_id in enumerate(id_list):
        tmp = grouped.get_group(tmp_id).reset_index(drop=True)

        pat_info[i, 9] = tmp['pneu'][0]         # pneumonia
        pat_info[i, 8] = tmp['my_inf'][0]       # myocardial infarction
        pat_info[i, 7] = tmp['aresp_fail'][0]   # acute respiratory failure
        pat_info[i, 6] = tmp['cere_hemo'][0]    # cerebral hemorrhage
        pat_info[i, 5] = tmp['sept'][0]         # septicemia
        pat_info[i, 4] = tmp.shape[0]           # number of measurement
        pat_info[i, 3] = np.max(tmp['time'])    # last measurement time
        pat_info[i, 2] = tmp['death_reason'][0]          # cause
        pat_info[i, 1] = tmp['ett'][4] + tmp['time'][4]  # time_to_event or time to censored
        pat_info[i, 0] = tmp['id'][0]

        data[i, :int(pat_info[i, 4]), 1:] = tmp[feat_list]
        data[i, :int(pat_info[i, 4] - 1), 0] = np.diff(tmp['time'])

    return pat_info, data


def import_dataset_mimic(norm_mode=None):
    df_ = pd.read_csv('./data/mimic_data_cleaned.csv')

    bin_list = ['gender']
    cont_list = ['age', 'hosp_stay', 'height', 'hematocrit', 'hemoglobin', 'mch',
                 'mchc', 'mcv', 'platelet', 'rbc', 'rdw', 'wbc', 'total_co2', 'pco2',
                 'po2', 'base_excess', 'aniongap', 'bicarbonate', 'bun', 'calcium',
                 'chloride', 'creatinine', 'glucose', 'sodium', 'potassium', 'magnesium',
                 'phosphate', 'ph', 'inr', 'pt', 'ptt', 'heart_rate', 'sbp', 'dbp',
                 'mbp', 'resp_rate', 'temperature', 'spo2', 'weight']

    feat_list = cont_list + bin_list
    df_ = df_[['id', 'ett', 'time', 'death_reason', 'sept', 'cere_hemo', 'aresp_fail', 'my_inf', 'pneu'] + feat_list]
    df_org_ = df_.copy(deep=True)

    df_[cont_list] = f_get_Normalization(np.asarray(df_[cont_list]).astype(float), norm_mode)

    pat_info, data = f_construct_dataset(df_, feat_list)
    _, data_org = f_construct_dataset(df_org_, feat_list)

    data_mi = np.zeros(np.shape(data))
    data_mi[np.isnan(data)] = 1
    data_org[np.isnan(data)] = 0
    data[np.isnan(data)] = 0

    x_dim = np.shape(data)[2]  # 1 + x_dim_cont + x_dim_bin (including delta)
    x_dim_cont = len(cont_list)
    x_dim_bin = len(bin_list)

    last_meas = pat_info[:, [3]]  # pat_info[:, 3] contains age at the last measurement
    label = pat_info[:, [2]]  # two competing risks
    time = pat_info[:, [1]]  # age when event occurred
    diags = pat_info[:, 5:10]

    num_Category = int(np.max(pat_info[:, 1]) * 1.1)  # or specifically define larger than the max tte
    num_Event = len(np.unique(label)) - 1

    if num_Event == 1:
        label[np.where(label != 0)] = 1  # make single risk

    mask1 = f_get_fc_mask1(last_meas, num_Event, num_Category)
    mask2 = f_get_fc_mask2(time, label, num_Event, num_Category)
    mask3 = f_get_fc_mask3(time, -1, num_Category)

    DIM = (x_dim, x_dim_cont, x_dim_bin)
    DATA = (data, time, label, diags)
    # DATA = (data, data_org, time, label)
    MASK = (mask1, mask2, mask3)

    return DIM, DATA, MASK, data_mi


if __name__ == '__main__':
    (x_dim, x_dim_cont, x_dim_bin), (data, time, label, diags), \
        (mask1, mask2, mask3), data_mi = import_dataset_mimic(None)

    # print(data[[0]].shape)
    print(mask1.shape)
