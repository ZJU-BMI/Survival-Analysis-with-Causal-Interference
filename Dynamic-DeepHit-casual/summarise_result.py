import numpy as np
import tensorflow as tf
import os
from sklearn.model_selection import StratifiedKFold
import pandas as pd

from class_DeepLongitudinal import Model_Longitudinal_Attention
from import_data_mimic import import_dataset_mimic
from import_data_eicu import import_dataset_eicu

from utils_eval import weighted_c_index, _f_get_pred
from utils_log import load_logging

data_mode = 'EICU'
seed = 1234
_EPSILON = 1e-8

if data_mode == 'MIMIC':
    (x_dim, x_dim_cont, x_dim_bin, event_prob), (data, time, label, diags), (mask1, mask2, mask3), (
        data_mi) = import_dataset_mimic(norm_mode='normal')
    eval_time = [5, 25, 50, 70]
elif data_mode == 'EICU':
    (x_dim, x_dim_cont, x_dim_bin, event_prob), (data, time, label, diags), (mask1, mask2, mask3), (
        data_mi) = import_dataset_eicu(norm_mode='normal')
    eval_time = [20, 40, 60, 80]
else:
    (x_dim, x_dim_cont, x_dim_bin, event_prob), (data, time, label, diags), (mask1, mask2, mask3), (
        data_mi) = import_dataset_mimic(norm_mode='normal')
    eval_time = [5, 25, 50, 75]

pred_time = 5

# dim of mask1: [subj, Num_Event, Num_Category]
_, num_Event, num_Category = np.shape(mask1)
max_length = np.shape(data)[1]

cindex_respath = data_mode + '/cindex_result'
if not os.path.exists(cindex_respath):
    os.makedirs(cindex_respath)

pred_risk_path = data_mode + '/pred_risk'
if not os.path.exists(pred_risk_path):
    os.makedirs(pred_risk_path)

for out_itr in range(3, 5):
    ITERATION = 5
    in_path = data_mode + '/result{}'.format(out_itr + 1)

    in_hypfile = in_path + '/hyperparameters_log.txt'
    in_parser = load_logging(in_hypfile)

    # load and setup hyper-parameters
    input_dims = {
        'x_dim': x_dim,
        'x_dim_cont': x_dim_cont,
        'x_dim_bin': x_dim_bin,

        'num_Event': num_Event,
        'num_Category': num_Category,
        'max_length': max_length,

        'event_prob': event_prob
    }

    # NETWORK HYPER-PARAMETERS
    network_settings = {
        'h_dim_RNN': in_parser['h_dim_RNN'],
        'h_dim_FC': in_parser['h_dim_FC'],

        'num_layers_RNN': in_parser['num_layers_RNN'],
        'num_layers_ATT': in_parser['num_layers_ATT'],
        'num_layers_CS': in_parser['num_layers_CS'],

        'RNN_type': in_parser['RNN_type'],
        'FC_active_fn': tf.nn.relu,
        'RNN_active_fn': tf.nn.tanh,

        'initial_W': tf.contrib.layers.xavier_initializer(),
        'reg_W': in_parser['reg_W'],
        'reg_W_out': in_parser['reg_W_out']
    }

    mb_size = in_parser['mb_size']
    iteration = in_parser['iteration']
    iteration_burn_in = in_parser['iteration_burn_in']

    keep_prob = in_parser['keep_prob']
    lr_train = in_parser['lr_train']

    alpha = in_parser['alpha']
    beta = in_parser['beta']
    gamma = in_parser['gamma']

    N = len(data)
    pred_all = np.zeros([N, num_Event, num_Category])
    time_all = np.zeros([N])
    label_all = np.zeros([N])
    cur = 0
    # c-index result
    FINAL1 = np.zeros([len(eval_time), num_Event, ITERATION])

    n_fold = 1
    skf = StratifiedKFold(n_splits=5, random_state=seed, shuffle=True)
    for train_index, test_index in skf.split(data, label):
        tr_data, te_data = data[train_index], data[test_index]
        tr_data_mi, te_data_mi = data_mi[train_index], data_mi[test_index]
        tr_time, te_time = time[train_index], time[test_index]
        tr_label, te_label = label[train_index], label[test_index]
        tr_diags, te_diags = diags[train_index], diags[test_index]
        tr_mask1, te_mask1 = mask1[train_index], mask1[test_index]
        tr_mask2, te_mask2 = mask2[train_index], mask2[test_index]
        tr_mask3, te_mask3 = mask3[train_index], mask3[test_index]

        tf.reset_default_graph()
        config = tf.ConfigProto()
        config.gpu_options.allow_growth = True
        sess = tf.Session(config=config)

        model = Model_Longitudinal_Attention(sess, "Dynamic-DeepHit-Causal", input_dims, network_settings)
        saver = tf.train.Saver()
        sess.run(tf.global_variables_initializer())
        # PREDICTION & EVALUATION
        saver.restore(sess, in_path + '/itr_' + str(n_fold) + '/model_itr_' + str(n_fold))

        pred = _f_get_pred(sess, model, te_data, te_data_mi, te_diags, pred_horizon=0)
        N_fold = len(pred)
        pred_all[cur:cur + N_fold, :, :] = pred
        time_all[cur:cur + N_fold] = np.reshape(te_time, [N_fold])
        label_all[cur:cur + N_fold] = np.reshape(te_label, [N_fold])
        cur += N_fold

        # risk_all = f_get_risk_predictions2(sess, model, te_data, te_data_mi, te_diags,
        #                                    pred_time=0, eval_time=eval_time)

        te_result = np.zeros([len(eval_time), num_Event])
        for t, t_time in enumerate(eval_time):
            eval_horizon = int(t_time)
            if eval_horizon >= num_Category:
                print('ERROR: evaluation horizon is out of range')
                te_result[t, :] = -1
            else:
                # calculate F(t | x, Y, t >= t_M) = \sum_{t_M <= \tau < t} P(\tau | x, Y, \tau > t_M)
                risk = np.sum(pred[:, :, pred_time:(eval_horizon + 1)], axis=2)  # risk score until eval_time
                # conditioning on t > t_pred
                risk = risk / (np.sum(np.sum(pred[:, :, pred_time:], axis=2), axis=1, keepdims=True) + _EPSILON)
                for k in range(num_Event):
                    # -1 for no event (not comparable)
                    te_result[t, k] = weighted_c_index(tr_time, (tr_label[:, 0] == k + 1).astype(int),
                                                       risk[:, k], te_time, (te_label[:, 0] == k + 1).astype(int),
                                                       eval_horizon)
        FINAL1[:, :, n_fold - 1] = te_result
        n_fold += 1

    # SAVE RESULTS
    col_header = []
    for t in range(num_Event):
        col_header.append('Event_' + str(t + 1))

    row_header = []
    for t in eval_time:
        row_header.append('eval_time ' + str(t))

    # c-index result

    # PRINT RESULTS
    print('--------------------------------------------------------')
    print('- C-INDEX: ')
    # FINAL MEAN/STD
    # c-index result
    df_mean = pd.DataFrame(np.mean(FINAL1, axis=2), index=row_header, columns=col_header)
    df_std = pd.DataFrame(np.std(FINAL1, axis=2), index=row_header, columns=col_header)
    df_mean.to_csv(cindex_respath + '/ddh_cindex_causal_{}.csv'.format(out_itr + 1))
    # df1_std.to_csv(in_path + '/result_CINDEX_FINAL_STD.csv')

    # PRINT RESULTS
    print('========================================================')
    print('- FINAL C-INDEX: ')
    print(df_mean)
    print('Mean Total:')
    print(np.mean(FINAL1))

    # risk_sum = np.cumsum(pred_all, axis=2)
    np.save(pred_risk_path + '/pred_risk_causal_{}.npy'.format(out_itr + 2), pred_all)
    true_labels = pd.DataFrame({
        'true_label': label_all,
        'true_time': time_all
    })
    true_labels.to_csv(pred_risk_path + '/true_label_{}.csv'.format(out_itr + 1), index=False)
    # survival curve
    # pred_risk = pd.DataFrame({
    #     'true_time': time_all,
    #     'true_label': label_all
    # })
    # pred_times = np.zeros(shape=[N])
    # pred_labels = np.zeros(shape=[N])
    # for i in range(N):
    #     # if label_all[i] == 0:
    #     #     pred_times[i] = time_all[i]
    #     #     pred_labels[i] = 0
    #     #     continue
    #     for t in range(num_Category):
    #         pred_surv = 1 - np.sum(risk_sum[i, :, t])
    #         max_pred_ev = np.argmax(risk_sum[i, :, t])
    #         if risk_sum[i, max_pred_ev, t] > pred_surv:
    #             pred_times[i] = t
    #             pred_labels[i] = max_pred_ev + 1
    #             break
    #
    # pred_risk['pred_time'] = pred_times
    # pred_risk['pred_label'] = pred_labels
    # pred_risk.to_csv(pred_risk_path + '/pred_label_causal{}.csv'.format(out_itr + 1), index=False)