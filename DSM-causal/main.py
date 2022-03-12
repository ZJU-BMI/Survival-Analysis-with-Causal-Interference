import os.path

import numpy as np

from dsm import datasets
from dsm import DeepSurvivalMachines
import pandas as pd
from sklearn.model_selection import StratifiedKFold
from dsm import c_index, weighted_c_index

dataset = 'MIMIC'
seed = 1234
n_split = 5

cindex_res_path = dataset + '/cindex_result'
if not os.path.exists(cindex_res_path):
    os.makedirs(cindex_res_path)
pred_risk_path = dataset + '/pred_risk'
if not os.path.exists(pred_risk_path):
    os.makedirs(pred_risk_path)

(x_dim, num_event, event_prob), (data, time, label, diags), \
    eval_times = datasets.load_dataset(dataset=dataset)

# data = data[0:1000]
# time = time[0:1000]
# label = label[0:1000]
# diags = diags[0:1000]


skf = StratifiedKFold(n_splits=n_split, shuffle=True, random_state=seed)
cur = 0
n_fold = 0
maxtime = 100

true_times = np.zeros([len(data)])
true_labels = np.zeros([len(data)])
c_index_final = np.zeros([len(eval_times), num_event, n_split])
pred_risks = np.zeros([len(data), num_event, maxtime])

for tr_idx, te_idx in skf.split(data, label):
    tr_data, te_data = data[tr_idx], data[te_idx]
    tr_time, te_time = time[tr_idx], time[te_idx]
    tr_label, te_label = label[tr_idx], label[te_idx]
    tr_diag, te_diag = diags[tr_idx], diags[te_idx]
    model = DeepSurvivalMachines()
    model.fit(x=tr_data, t=tr_time, e=tr_label, d=tr_diag, event_prob=event_prob,
              num_risks=num_event, iters=1000)

    c_index_res = np.zeros([len(eval_times), num_event])
    N_test = len(te_data)
    # pred_risk_fold = np.zeros([N_test, num_event, len(eval_times)])
    predictions = np.zeros([N_test, num_event, maxtime])
    # predictions in 100 days
    for ev in range(num_event):
        pred_risk_ev = model.predict_risk(te_data, te_diag, [i for i in range(maxtime)], risk=ev + 1)
        predictions[:, ev, :] = pred_risk_ev

    pred_risks[cur:cur + N_test, :, :] = predictions

    for i, eval_time in enumerate(eval_times):
        for ev in range(num_event):
            c_index_res[i, ev] = c_index(predictions[:, ev, eval_time], te_time,
                                         np.cast['int32'](te_label == ev + 1), eval_time)
            # pred_risk_fold[:, ev, i] = np.reshape(pred_risk_ev, [-1])

    print("mean cindex:")
    print(np.mean(c_index_res))

    # SAVE RESULTS
    col_header = []
    for ev in range(num_event):
        col_header.append('event_' + str(ev + 1))

    row_header = []
    for t in eval_times:
        row_header.append('eval_time ' + str(t))

    df_cindex = pd.DataFrame(c_index_res, index=row_header, columns=col_header)
    df_cindex.to_csv(cindex_res_path + '/dsm_cindex_causal{}.csv'.format(n_fold), index=False)

    pred_risks[cur:cur + N_test, :, :] = predictions
    true_times[cur:cur + N_test] = te_time
    true_labels[cur:cur + N_test] = te_label
    c_index_final[:, :, n_fold - 1] = c_index_res
    cur += N_test
    n_fold += 1


# SAVE RESULTS
col_header = []
for ev in range(num_event):
    col_header.append('event_' + str(ev + 1))

row_header = []
for t in eval_times:
    row_header.append('eval_time ' + str(t))

# c-index result
# PRINT RESULTS
print('--------------------------------------------------------')
print('- C-INDEX: ')
# FINAL MEAN/STD
# c-index result
df_mean = pd.DataFrame(np.mean(c_index_final, axis=2), index=row_header, columns=col_header)
# df_std = pd.DataFrame(np.std(FINAL1, axis=2), index=row_header, columns=col_header)
df_mean.to_csv(cindex_res_path + '/dsm_cindex.csv', index=False)

print('========================================================')
print('- FINAL C-INDEX: ')
print(df_mean)
print('Mean Total:')
print(np.mean(c_index_final))

np.save(pred_risk_path + '/pred_risk', pred_risks)

pred_risk = pd.DataFrame({
    'true_time': true_times,
    'true_label': true_labels
})

pred_risk.to_csv(pred_risk_path + '/true_label.csv', index=False)