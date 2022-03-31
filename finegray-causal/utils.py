import os.path

import numpy as np
import pandas as pd
from lifelines import KaplanMeierFitter

EPSILON = 1e-8


def get_normalization(X, norm_mode='standard'):
    num_Patient, num_Feature = np.shape(X)
    if norm_mode is None:
        return X
    if norm_mode == 'standard':  # zero mean unit variance
        for j in range(num_Feature):
            if np.std(X[:, j]) != 0:
                X[:, j] = (X[:, j] - np.mean(X[:, j])) / np.std(X[:, j])
            else:
                X[:, j] = (X[:, j] - np.mean(X[:, j]))
    elif norm_mode == 'normal':  # min-max normalization
        for j in range(num_Feature):
            X[:, j] = (X[:, j] - np.min(X[:, j])) / (np.max(X[:, j]) - np.min(X[:, j]))
    else:
        print("INPUT MODE ERROR!")

    return X


def get_km_scores(times, labels, fail_code, sort=False):
    """
    # estimate KM survival rate
    :param sort:
    :param times: ndarray, shape(num_subject, ), event times or censoring times, shape,
                  must have been sorted in ascending order
    :param labels: ndarray, shape(num_subject, ), event labels
    :param fail_code: event_id
    :return:
    """
    N = len(times)
    # Sorting T and E in ascending order by T
    if sort:
        order = np.argsort(times)
        T = times[order]
        E = labels[order]
    else:
        T = times
        E = labels
    max_T = int(np.max(T)) + 1

    # calculate KM survival rate at time 0-T_max
    km_scores = np.ones(max_T)
    n_fail = 0
    n_rep = 0

    for i in range(N):

        if E[i] == fail_code:
            n_fail += 1

        if i < N - 1 and T[i] == T[i + 1]:
            n_rep += 1
            continue

        km_scores[int(T[i])] = 1. - n_fail / (N - i + n_rep)
        n_fail = 0
        n_rep = 0

    for i in range(1, max_T):
        km_scores[i] = km_scores[i - 1] * km_scores[i]

    return km_scores


def cumulative_hazard_function(risk_score, times, labels, fail_code, n_times=100):
    """
        This method provides the calculations to estimate
            the cumulative hazard function.
        h_0( T ) = |D(T)|/Sum( exp( <x_j, W> ), j in R(T) ) where:
            - T is a time of failure
            - |D(T)| is the number of failures at time T
            - R(T) is the set of at risk uites at time T
        :param beta_x: calculated <X, \beta>, ndarray, shape(num_subject, )
        :param times: ndarray, shape(num_subject, ), event times or censoring times, shape
        :param labels: ndarray, shape(num_subject, ), event labels
        :param fail_code: event id > 1， 0 for censored
        :return:
        """
    N = len(risk_score)
    # reshape time and label into 1-dimension
    times = np.reshape(times, [-1])
    labels = np.reshape(labels, [-1])
    # sort by event time in descending order
    order = np.argsort(-times)
    times = times[order]
    labels = labels[order]
    risk_score = risk_score[order, ]

    sum_risk_score = 0.
    n_fails = 0

    cumulative_hazard = np.zeros(shape=[n_times])

    km_score = get_km_scores(times, labels, fail_code, sort=True)

    for i in range(N):
        sum_risk_score += risk_score[i]

        if labels[i] == fail_code:
            n_fails += 1

        if i < N - 1 and times[i] == times[i + 1]:
            continue

        if n_fails == 0:
            continue

        sub_distrib_risk = sum_risk_score

        for j in range(i + 1, N):
            if labels[j] != fail_code and labels[j] > 0:
                # w_ij = P(T > t) / P(T > T_j)
                t_i = int(times[i])
                t_j = int(times[j])
                w_ij = km_score[t_i] / (km_score[t_j] + EPSILON)
                sub_distrib_risk += w_ij * risk_score[j]
        cumulative_hazard[int(times[i])] = n_fails * 1 / sub_distrib_risk
        n_fails = 0
    cumulative_hazard = np.cumsum(cumulative_hazard)
    return cumulative_hazard


def c_index(Prediction, Time_survival, Death, Time):
    """
        This is a cause-specific c(t)-index
        - Prediction      : risk at Time (higher --> more risky)
        - Time_survival   : survival/censoring time
        - Death           :
            > 1: death
            > 0: censored (including death from other cause)
        - Time            : time of evaluation (time-horizon when evaluating C-index)
    """
    N = len(Prediction)
    A = np.zeros((N, N))
    Q = np.zeros((N, N))
    N_t = np.zeros((N, N))
    Num = 0
    Den = 0
    for i in range(N):
        A[i, np.where(Time_survival[i] < Time_survival)] = 1
        Q[i, np.where(Prediction[i] > Prediction)] = 1

        if Time_survival[i] <= Time and Death[i] == 1:
            N_t[i, :] = 1

    Num = np.sum((A * N_t) * Q)
    Den = np.sum(A * N_t)

    if Num == 0 and Den == 0:
        result = -1  # not able to compute c-index!
    else:
        result = float(Num / Den)

    return result


# WEIGHTED C-INDEX & BRIER-SCORE
def CensoringProb(Y, T):
    T = T.reshape([-1])  # (N,) - np array
    Y = Y.reshape([-1])  # (N,) - np array

    kmf = KaplanMeierFitter()
    kmf.fit(T, event_observed=(Y == 0).astype(int))  # censoring prob = survival probability of event "censoring"
    G = np.asarray(kmf.survival_function_.reset_index()).transpose()
    G[1, G[1, :] == 0] = G[1, G[1, :] != 0][-1]  # fill 0 with ZoH (to prevent nan values)

    return G


# C(t)-INDEX CALCULATION: this account for the weighted average for unbaised estimation
def weighted_c_index(T_train, Y_train, Prediction, T_test, Y_test, Time):
    """
        This is a cause-specific c(t)-index
        - Prediction      : risk at Time (higher --> more risky)
        - Time_survival   : survival/censoring time
        - Death           :
            > 1: death
            > 0: censored (including death from other cause)
        - Time            : time of evaluation (time-horizon when evaluating C-index)
    """
    G = CensoringProb(Y_train, T_train)

    N = len(Prediction)
    A = np.zeros((N, N))
    Q = np.zeros((N, N))
    N_t = np.zeros((N, N))
    Num = 0
    Den = 0
    for i in range(N):
        tmp_idx = np.where(G[0, :] >= T_test[i])[0]

        if len(tmp_idx) == 0:
            W = (1. / G[1, -1]) ** 2
        else:
            W = (1. / G[1, tmp_idx[0]]) ** 2

        A[i, np.where(T_test[i] < T_test)] = 1. * W
        Q[i, np.where(Prediction[i] > Prediction)] = 1.  # give weights

        if T_test[i] <= Time and Y_test[i] == 1:
            N_t[i, :] = 1.

    Num = np.sum(((A) * N_t) * Q)
    Den = np.sum((A) * N_t)

    if Num == 0 and Den == 0:
        result = -1  # not able to compute c-index!
    else:
        result = float(Num / Den)

    return result


# this saves the current hyperparameters
def save_logging(dictionary, log_name):
    with open(log_name, 'w') as f:
        for key, value in dictionary.items():
            f.write('%s:%s\n' % (key, value))


# this open can calls the saved hyperparameters
def load_logging(filename):
    data = dict()
    with open(filename) as f:
        def is_float(input):
            try:
                num = float(input)
            except ValueError:
                return False
            return True

        for line in f.readlines():
            if ':' in line:
                key, value = line.strip().split(':', 1)
                if value.isdigit():
                    data[key] = int(value)
                elif is_float(value):
                    data[key] = float(value)
                elif value == 'None':
                    data[key] = None
                else:
                    data[key] = value
            else:
                pass  # deal with bad lines of text here
    return data


def get_bh_mask(time, label, num_event):
    N = len(time)
    T = np.reshape(time, [N])
    E = np.reshape(label, [N])
    mask = np.zeros([N, N, num_event])
    km_scores = []
    for i in range(num_event):
        km_scores.append(get_km_scores(T, E, i + 1))
    for i in range(N):
        if E[i] > 0:
            ev = int(E[i] - 1)
            w_ij = np.ones(shape=[N, ])
            idx = np.where(T[i] > T)[0]
            for j in idx:
                t_i = int(T[i])
                t_j = int(T[j])
                if E[j] > 0 and E[j] != E[i]:
                    w_ij[j] = km_scores[ev][t_i] / (km_scores[ev][t_j] + EPSILON)
                else:
                    w_ij[j] = 0
            mask[i, :, ev] = w_ij
    return mask


def get_mask(data_mode, time, label, num_event):
    if data_mode == '' or data_mode is None:
        return None

    mask_path = data_mode + '/mask.npy'
    if os.path.isfile(mask_path):
        print('load mask from local disk')
        mask = np.load(mask_path)
    else:
        print('Mask not found, constructing mask...')
        # must sort time in ascending order
        N = len(time)
        T = np.reshape(time, [N])
        E = np.reshape(label, [N])
        mask = np.zeros([N, N, num_event])
        km_scores = []
        for i in range(num_event):
            km_scores.append(get_km_scores(T, E, i + 1))
        for i in range(N):
            if E[i] > 0:
                ev = E[i] - 1
                w_ij = np.ones(shape=[N, ])
                for j in range(i):
                    t_i = int(T[i])
                    t_j = int(T[j])
                    if t_i > t_j and E[j] > 0 and E[j] != E[i]:
                        w_ij[j] = km_scores[ev][t_i] / (km_scores[ev][t_j] + EPSILON)
                    elif t_i > t_j:
                        w_ij[j] = 0
                mask[i, :, ev] = w_ij
        np.save(mask_path, mask)
        print('mask construction complete...')
    print('load mask complete...')
    return mask


def import_dataset_mimic(norm_mode='normal', loadmask=True):
    data_path = 'datasets/mimic_data_final4.csv'
    df = pd.read_csv(data_path, sep=',')
    # one-hot ethenity
    df = pd.get_dummies(df)
    # sort by tte
    df = df.sort_values(by='tte', ascending=True)
    # print(df.columns)

    label = np.asarray(df[['label']])
    time = np.asarray(df[['tte']])
    print(len(time))
    diags = np.asarray(df.iloc[:, 5:16])
    data = np.asarray(df.iloc[:, 16:])
    data = get_normalization(data, norm_mode=norm_mode)

    num_event = int(len(np.unique(label)) - 1)

    event_prob = np.sum(diags, axis=0) / len(diags)
    # print(event_prob)
    # print(mask.shape)
    x_dim = np.shape(data)[1]

    DIM = (x_dim, num_event, event_prob)
    DATA = (data, time, label, diags)
    # MASK = mask
    return DIM, DATA


def import_dataset_eicu(norm_mode='standard', loadmask=True):
    data_path = 'datasets/eicu_data_final2.csv'
    df = pd.read_csv(data_path, sep=',')
    # one-hot ethenity
    df = pd.get_dummies(df)
    # sort by tte
    df = df.sort_values(by='tte', ascending=True)
    # print(df.columns)
    label = np.asarray(df[['label']])
    time = np.asarray(df[['tte']])
    diags = np.asarray(df.iloc[:, 5:16])
    data = np.asarray(df.iloc[:, 16:])
    data = get_normalization(data, norm_mode)

    # only count the number of events (do not count censoring as an event)
    num_event = int(len(np.unique(label)) - 1)

    event_prob = np.sum(diags, axis=0) / len(diags)
    x_dim = np.shape(data)[1]

    DIM = (x_dim, num_event, event_prob)
    DATA = (data, time, label, diags)
    # MASK = mask
    return DIM, DATA


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
    data = get_normalization(data, norm_mode)

    # only count the number of events (do not count censoring as an event)
    num_event = int(len(np.unique(label)) - 1)
    diags = np.ones([len(label), num_event])
    # print(mask.shape)
    x_dim = np.shape(data)[1]
    event_prob = np.sum(diags, axis=0) / len(diags)

    DIM = (x_dim, num_event, event_prob)
    DATA = (data, time, label, diags)
    return DIM, DATA
