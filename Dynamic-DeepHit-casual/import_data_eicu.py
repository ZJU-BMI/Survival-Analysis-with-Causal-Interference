import pandas as pd
import numpy as np


# USER-DEFINED FUNCTIONS
def f_get_Normalization(X, norm_mode='normal'):
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
    pat_info = np.zeros([len(id_list), 16])

    for i, tmp_id in enumerate(id_list):
        tmp = grouped.get_group(tmp_id).reset_index(drop=True)

        pat_info[i, 15] = tmp['arenf'][0]  # acute kidney failure
        pat_info[i, 14] = tmp['mi'][0]  # cirrhosis of liver
        pat_info[i, 13] = tmp['ard'][0]  # subarachnoid hemorrhage
        pat_info[i, 12] = tmp['hf'][0]  # cerebral infarction
        pat_info[i, 11] = tmp['gib'][0]  # pneumonia
        pat_info[i, 10] = tmp['pneu'][0]  # heart failure
        pat_info[i, 9] = tmp['stk'][0]  # myocardial infarction
        pat_info[i, 8] = tmp['ss'][0]  # acute resp. failure
        pat_info[i, 7] = tmp['arf'][0]  # cerebral hemorrhage
        pat_info[i, 6] = tmp['seps'][0]  # neoplasm
        pat_info[i, 5] = tmp['ca'][0]  # septicemia
        pat_info[i, 4] = tmp.shape[0]  # number of measurement
        pat_info[i, 3] = np.max(tmp['time'])  # last measurement time
        pat_info[i, 2] = tmp['label'][0]  # cause
        pat_info[i, 1] = tmp['tte'][0]  # time_to_event or time to censored
        pat_info[i, 0] = tmp['id'][0]

        data[i, :int(pat_info[i, 4]), 1:] = tmp[feat_list]
        data[i, :int(pat_info[i, 4] - 1), 0] = np.diff(tmp['time'])

    return pat_info, data


def import_dataset_eicu(norm_mode=None):
    df_ = pd.read_csv('data/eicu_data_final.csv')
    df_ = pd.get_dummies(df_)
    # print(df_.columns)

    bin_list = ['gender', 'ra', 'respa', 'suhe', 'copd', 'vt', 'pe',
                'ethnicity_African American', 'ethnicity_Asian', 'ethnicity_Caucasian',
                'ethnicity_Hispanic', 'ethnicity_Native American', 'ethnicity_OTHER']

    cont_list = ['age', 'weight', 'height', 'bmi',
                 'heart_rate', 'resp_rate', 'sao2', 'sbp', 'dbp', 'mbp', 'temperature',
                 'gcs_total', 'hgb', 'hct', 'mch', 'mchc', 'mcv', 'mpv', 'platelets',
                 'rbc', 'rdw', 'wbc', 'lymp', 'mono', 'albumin', 'total_protein',
                 'aniongap', 'bicarbonate', 'bun', 'calcium', 'chloride', 'creatinine',
                 'glucose', 'sodium', 'potassium', 'magnesium', 'alt', 'bil_total']

    feat_list = cont_list + bin_list
    df_ = df_[['id', 'tte', 'time', 'label', 'ca', 'seps', 'arf', 'ss', 'stk', 'pneu',
               'gib', 'hf', 'ard', 'mi', 'arenf'] + feat_list]

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
    time = pat_info[:, [1]]  # time when event occurred
    diags = pat_info[:, 5:16]  # diag info

    num_Category = int(np.max(pat_info[:, 1]) * 1.2)  # or specifically define larger than the max tte
    num_Event = len(np.unique(label)) - 1
    event_prob = np.sum(diags, axis=0) / len(diags)
    # make single risk
    if num_Event == 1:
        label[np.where(label != 0)] = 1

    mask1 = f_get_fc_mask1(last_meas, num_Event, num_Category)
    mask2 = f_get_fc_mask2(time, label, num_Event, num_Category)
    mask3 = f_get_fc_mask3(time, -1, num_Category)

    DIM = (x_dim, x_dim_cont, x_dim_bin, event_prob)
    DATA = (data, time, label, diags)
    MASK = (mask1, mask2, mask3)

    return DIM, DATA, MASK, data_mi


if __name__ == '__main__':
    (x_dim, x_dim_cont, x_dim_bin, event_prob), (data, time, label, diags), \
    (mask1, mask2, mask3), data_mi = import_dataset_eicu('normal')

    # print(data[[0]].shape)
    print(event_prob)
