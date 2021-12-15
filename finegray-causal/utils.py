import numpy as np
from sklearn.metrics import roc_auc_score, roc_curve, precision_score, recall_score, f1_score, accuracy_score

EPSILON = 1e-8


def get_km_scores(times, labels, fail_code):
    """
    # estimate KM survival rate
    :param times: ndarray, shape(num_subject, ), event times or censoring times, shape
    :param labels: ndarray, shape(num_subject, ), event labels
    :param fail_code: event_id
    :return:
    """
    N = len(times)
    # Sorting T and E in ascending order by T
    order = np.argsort(times)
    T = times[order]
    E = labels[order]
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


def baseline_hazard_function(beta_x, times, labels, fail_code):
    """
    This method provides the calculations to estimate
        the baseline survival function.
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
    N = len(beta_x)
    # sort by event time in descending order
    order = np.argsort(-times)
    times = times[order]
    labels = labels[order]
    beta_x = beta_x[order,]
    scores = np.exp(beta_x)

    sum_risk_score = 0.
    n_fails = 0
    baseline_hazard = []
    fail_times = []

    km_score = get_km_scores(times, labels, fail_code)

    for i in range(N):
        sum_risk_score += scores[i]

        if labels[i] == fail_code:
            n_fails += 1

        if i < N - 1 and times[i] == times[i + 1]:
            continue

        if n_fails == 0:
            continue

        sub_distrib_risk = sum_risk_score

        for j in range(i + 1, N):
            if labels[j] != fail_code and labels[j] != 0:
                # w_ij = P(T > t) / P(T > T_j)
                t_i = int(times[i])
                t_j = int(times[j])
                w_ij = km_score[t_i] / (km_score[t_j] + EPSILON)
                sub_distrib_risk += w_ij * scores[j]
        baseline_hazard.append(n_fails * 1 / sub_distrib_risk)
        fail_times.append(times[i])

    fail_times.reverse()
    baseline_hazard.reverse()
    baseline_cumulative_hazard = np.cumsum(baseline_hazard)

    return fail_times, baseline_hazard, baseline_cumulative_hazard


def cumulative_hazard_function(risk_score, times, labels, fail_code):
    N = len(risk_score)
    # sort by event time in descending order
    order = np.argsort(-times)
    times = times[order]
    labels = labels[order]
    risk_score = risk_score[order, ]

    sum_risk_score = 0.
    n_fails = 0
    baseline_hazard = []
    fail_times = []
    max_time = int(np.max(times)) + 1
    cumulative_hazard = np.zeros(shape=[max_time])

    km_score = get_km_scores(times, labels, fail_code)

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
        # baseline_hazard.append(n_fails * 1 / sub_distrib_risk)
        # fail_times.append(times[i])
        cumulative_hazard[int(times[i])] = n_fails * 1 / sub_distrib_risk

    cumulative_hazard = np.cumsum(cumulative_hazard)

    return cumulative_hazard
