import numpy as np
from lifelines import KaplanMeierFitter

_EPSILON = 1e-8


# C(t)-INDEX CALCULATION
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


# BRIER-SCORE
def brier_score(Prediction, Time_survival, Death, Time):
    N = len(Prediction)
    y_true = ((Time_survival <= Time) * Death).astype(float)

    return np.mean((Prediction - y_true) ** 2)

    # result2[k, t] = brier_score_loss(risk[:, k], ((te_time[:,0] <= eval_horizon) * (te_label[:,0] == k+1)).astype(int))


# WEIGHTED C-INDEX & BRIER-SCORE
def CensoringProb(Y, T):
    T = T.reshape([-1])  # (N,) - np array
    Y = Y.reshape([-1])  # (N,) - np array

    kmf = KaplanMeierFitter()
    kmf.fit(T, event_observed=(Y == 0).astype(int))  # censoring prob = survival probability of event "censoring"
    G = np.asarray(kmf.survival_function_.reset_index()).transpose()
    G[1, G[1, :] == 0] = G[1, G[1, :] != 0][-1]  # fill 0 with ZoH (to prevent nan values)

    return G


# C(t)-INDEX CALCULATION
def weighted_c_index(T_train, Y_train, Prediction, T_test, Y_test, Time):
    '''
        This is a cause-specific c(t)-index
        - Prediction      : risk at Time (higher --> more risky)
        - Time_survival   : survival/censoring time
        - Death           :
            > 1: death
            > 0: censored (including death from other cause)
        - Time            : time of evaluation (time-horizon when evaluating C-index)
    '''
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


def weighted_brier_score(T_train, Y_train, Prediction, T_test, Y_test, Time):
    G = CensoringProb(Y_train, T_train)
    N = len(Prediction)

    W = np.zeros(len(Y_test))
    Y_tilde = (T_test > Time).astype(float)

    for i in range(N):
        tmp_idx1 = np.where(G[0, :] >= T_test[i])[0]
        tmp_idx2 = np.where(G[0, :] >= Time)[0]

        if len(tmp_idx1) == 0:
            G1 = G[1, -1]
        else:
            G1 = G[1, tmp_idx1[0]]

        if len(tmp_idx2) == 0:
            G2 = G[1, -1]
        else:
            G2 = G[1, tmp_idx2[0]]
        W[i] = (1. - Y_tilde[i]) * float(Y_test[i]) / G1 + Y_tilde[i] / G2

    y_true = ((T_test <= Time) * Y_test).astype(float)

    return np.mean(W * (Y_tilde - (1. - Prediction)) ** 2)


def _f_get_pred(sess, model, data, data_mi, diags_, pred_horizon):
    """
        predictions based on the prediction time.
        create new_data and new_mask2 that are available previous or equal to the prediction time
        (no future measurements are used)
    """
    new_data = np.zeros(np.shape(data))
    new_data_mi = np.zeros(np.shape(data_mi))

    meas_time = np.concatenate([np.zeros([np.shape(data)[0], 1]), np.cumsum(data[:, :, 0], axis=1)[:, :-1]], axis=1)

    for i in range(np.shape(data)[0]):
        last_meas = np.sum(meas_time[i, :] <= pred_horizon)

        new_data[i, :last_meas, :] = data[i, :last_meas, :]
        new_data_mi[i, :last_meas, :] = data_mi[i, :last_meas, :]

    return model.predict(new_data, new_data_mi, diags_)


def f_get_risk_predictions(sess, model, data_, data_mi_, diags_, pred_time, eval_time):
    pred = _f_get_pred(sess, model, data_[[0]], data_mi_[[0]], diags_[[0]], 0)
    _, num_Event, num_Category = np.shape(pred)

    risk_all = {}
    for k in range(num_Event):
        risk_all[k] = np.zeros([np.shape(data_)[0], len(pred_time), len(eval_time)])

    for p, p_time in enumerate(pred_time):
        # PREDICTION
        pred_horizon = int(p_time)
        pred = _f_get_pred(sess, model, data_, data_mi_, diags_, pred_horizon)

        for t, t_time in enumerate(eval_time):
            eval_horizon = int(t_time) + pred_horizon  # if eval_horizon >= num_Category, output the maximum...

            # calculate F(t | x, Y, t >= t_M) = \sum_{t_M <= \tau < t} P(\tau | x, Y, \tau > t_M)
            risk = np.sum(pred[:, :, pred_horizon:(eval_horizon + 1)], axis=2)  # risk score until eval_time
            risk = risk / (np.sum(np.sum(pred[:, :, pred_horizon:], axis=2), axis=1,
                                  keepdims=True) + _EPSILON)  # conditioning on t > t_pred

            for k in range(num_Event):
                risk_all[k][:, p, t] = risk[:, k]

    return risk_all


def f_get_risk_predictions2(sess, model, data_, data_mi_, diags_, pred_time=0, eval_time=None):

    pred = _f_get_pred(sess, model, data_[[0]], data_mi_[[0]], diags_[[0]], 0)
    _, num_Event, num_Category = np.shape(pred)
    # PREDICTION
    pred_horizon = int(pred_time)
    pred = _f_get_pred(sess, model, data_, data_mi_, diags_, pred_horizon)

    risk_all = np.zeros([np.shape(data_)[0], num_Event, len(eval_time)])
    for t, t_time in enumerate(eval_time):
        eval_horizon = int(t_time) + pred_horizon  # if eval_horizon >= num_Category, output the maximum...

        # calculate F(t | x, Y, t >= t_M) = \sum_{t_M <= \tau < t} P(\tau | x, Y, \tau > t_M)
        risk = np.sum(pred[:, :, pred_horizon:(eval_horizon + 1)], axis=2)  # risk score until eval_time
        # conditioning on t > t_pred
        risk = risk / (np.sum(np.sum(pred[:, :, pred_horizon:], axis=2), axis=1, keepdims=True) + _EPSILON)

        for k in range(num_Event):
            risk_all[:, k, t] = risk[:, k]

    return risk_all



