import numpy as np
import pandas as pd
import random


# DEFINE USER-FUNCTIONS
def f_get_Normalization(X, norm_mode):
    num_Patient, num_Feature = np.shape(X)
    if norm_mode is None:
        pass
    # zero mean unit variance
    elif norm_mode == 'standard':
        for j in range(num_Feature):
            if np.std(X[:, j]) != 0:
                X[:, j] = (X[:, j] - np.mean(X[:, j])) / np.std(X[:, j])
            else:
                X[:, j] = (X[:, j] - np.mean(X[:, j]))
    # min-max normalization
    elif norm_mode == 'normal':
        for j in range(num_Feature):
            X[:, j] = (X[:, j] - np.min(X[:, j])) / (np.max(X[:, j]) - np.min(X[:, j]))
    else:
        print("INPUT MODE ERROR!")

    return X


# MASK FUNCTIONS
'''
    fc_mask2      : To calculate LOSS_1 (log-likelihood loss)
    fc_mask3      : To calculate LOSS_2 (ranking loss)
'''


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


def import_dataset_eicu(norm_mode='normal'):
    in_filename = './datasets/eicu_data_final2.csv'
    df = pd.read_csv(in_filename, sep=',')
    df = df.sort_values(by='tte', ascending=True)
    df = pd.get_dummies(df)
    # print(df.columns)
    label = np.asarray(df[['label']])
    time = np.asarray(df[['tte']])
    diags = np.asarray(df.iloc[:, 5:16])
    data = np.asarray(df.iloc[:, 16:])
    data = f_get_Normalization(data, norm_mode)

    x_dim = np.shape(data)[1]
    # only count the number of events (do not count censoring as an event)
    num_event = int(len(np.unique(label)) - 1)
    event_prob = np.sum(diags, axis=0) / len(diags)

    num_category = int(np.max(time) * 1.2)  # to have enough time-horizon
    print(num_category)
    mask1 = f_get_fc_mask2(time, label, num_event, num_category)
    mask2 = f_get_fc_mask3(time, -1, num_category)

    DIM = (x_dim, num_event, event_prob)
    DATA = (data, time, label, diags)
    MASK = (mask1, mask2)

    return DIM, DATA, MASK


def import_dataset_mimic(norm_mode='normal'):
    in_filename = './datasets/mimic_data_final4.csv'
    df = pd.read_csv(in_filename, sep=',')

    df = df.sort_values(by='tte', ascending=True)
    df = pd.get_dummies(df)
    # print(df.columns)
    label = np.asarray(df[['label']])
    time = np.asarray(df[['tte']])
    diags = np.asarray(df.iloc[:, 5:16])
    data = np.asarray(df.iloc[:, 16:])
    data = f_get_Normalization(data, norm_mode)
    print(len(time))
    x_dim = np.shape(data)[1]
    # only count the number of events (do not count censoring as an event)
    num_event = int(len(np.unique(label)) - 1)
    event_prob = np.sum(diags, axis=0) / len(diags)

    num_category = int(np.max(time) * 1.2)  # to have enough time-horizon
    print(num_category)
    mask1 = f_get_fc_mask2(time, label, num_event, num_category)
    mask2 = f_get_fc_mask3(time, -1, num_category)

    DIM = (x_dim, num_event, event_prob)
    DATA = (data, time, label, diags)
    MASK = (mask1, mask2)

    return DIM, DATA, MASK


def import_dataset_seer(norm_mode='normal', loadmask=False):
    data_path = 'datasets/seer_data.csv'
    df = pd.read_csv(data_path, sep=',')
    # one-hot category features
    df = pd.get_dummies(df, columns=['ethnicity', 'prim_site', 'laterality', 'hist_behavior',
                                     'cs_mets_at_dx', 'summary_stage'])
    # sort by tte
    df = df.sort_values(by='tte', ascending=True)
    # df.to_csv('datasets/eicu_data_final3.csv', index=False)
    # print(df.columns)
    label = np.asarray(df[['label']])
    time = np.asarray(df[['tte']])

    data = np.asarray(df.iloc[:, 3:])
    data = f_get_Normalization(data, norm_mode)

    # only count the number of events (do not count censoring as an event)
    num_event = int(len(np.unique(label)) - 1)
    diags = np.ones([len(label), num_event])
    event_prob = np.sum(diags, axis=0) / len(diags)
    # print(mask.shape)
    x_dim = np.shape(data)[1]

    num_category = int(np.max(time) * 1.2)  # to have enough time-horizon
    print(num_category)
    mask1 = f_get_fc_mask2(time, label, num_event, num_category)
    mask2 = f_get_fc_mask3(time, -1, num_category)

    DIM = (x_dim, num_event, event_prob)
    DATA = (data, time, label, diags)
    MASK = (mask1, mask2)
    return DIM, DATA, MASK
