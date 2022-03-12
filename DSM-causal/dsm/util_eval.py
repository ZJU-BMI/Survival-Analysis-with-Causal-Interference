import numpy as np
import pandas as pd
from lifelines import KaplanMeierFitter


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
