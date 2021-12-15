import os

import numpy as np
import pandas as pd
from sklearn.model_selection import StratifiedKFold
from finegray_casual import fit


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


seed = 1234
data_mode = 'EICU'

result_path = data_mode + '/result'
if not os.path.exists(result_path):
    os.makedirs(result_path)

if data_mode == "EICU":
    df = pd.read_csv('./datasets/eicu_data_cleaned.csv')
    x = np.asarray(df.iloc[:, 7:])
    y = np.asarray(df['death_reason'])
    t = np.asarray(df['icu_stay'])
    diags = np.asarray(df.iloc[:, 1:4], dtype='float32')
    event_prob = [0.875, 0.583, 0.708]
else:
    df = pd.read_csv('./datasets/mimic_data_cleaned.csv')
    df['survive_time'] = df['ett'] + df['time']
    x = np.asarray(df.iloc[:, 6:46])
    y = np.asarray(df['death_reason'])
    t = np.asarray(df['survive_time'])
    diags = np.asarray(df.iloc[:, 1:6], dtype='float32')
    event_prob = [0.29, 0.09, 0.89, 0.27, 0.82]

num_event = int(len(np.unique(y)) - 1)

for i in range(5):
    n_fold = 1
    skf = StratifiedKFold(n_splits=5, shuffle=True, random_state=seed)
    results = []

    for tr_index, te_index in skf.split(x, y):

        tr_cov, te_cov = x[tr_index], x[te_index]
        tr_labels, te_labels = y[tr_index], y[te_index]
        tr_times, te_times = t[tr_index], t[te_index]
        tr_diags, te_diags = diags[tr_index], diags[te_index]

        print('Training Fold {}...'.format(n_fold))

        result = fit(tr_cov, tr_times, tr_labels, tr_diags,
                     te_cov, te_times, te_labels, te_diags,
                     num_event, event_prob, eval_time=25, n_fold=n_fold, lr=2e-2, epochs=100)

        results.append(result)
        n_fold += 1

    df = pd.DataFrame(results)
    df.to_csv(result_path + '/result_causal_{}.csv'.format(i + 1), index=False)
