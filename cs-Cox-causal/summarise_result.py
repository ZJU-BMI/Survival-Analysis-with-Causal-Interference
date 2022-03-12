import numpy as np
import pandas as pd
import tensorflow as tf
import os
from sklearn.model_selection import train_test_split, StratifiedKFold
from csCox_causal import csCox_Model
import utils

_EPSILON = 1e-8

data_mode = 'SEER'  # EICU, MIMIC
seed = 1234

# IMPORT DATASET
'''
    num_Category            = max event/censoring time * 1.2 (to make enough time horizon)
    num_Event               = number of events i.e. len(np.unique(label))-1
    max_length              = maximum number of measurements
    x_dim                   = data dimension including delta (num_features)
    mask1, mask2            = used for cause-specific network (FCNet structure)
'''

if data_mode == 'MIMIC':
    (x_dim, num_event, event_prob), (data, time, label, diags)  = utils.import_dataset_mimic('normal')
    eval_times = [5, 25, 50, 75]
elif data_mode == 'EICU':
    (x_dim, num_event, event_prob), (data, time, label, diags) \
         = utils.import_dataset_eicu('normal')
    eval_times = [20, 40, 60, 80]

elif data_mode == 'SEER':
    (x_dim, num_event, event_prob), (data, time, label, diags) = utils.import_dataset_seer(norm_mode='normal')
    eval_times = [12, 36, 60, 84]

else:
    (x_dim, num_event, event_prob), (data, time, label, diags) = utils.import_dataset_mimic('normal')
    eval_times = [5, 25, 50, 75]

cindex_respath = data_mode + '/cindex_result'
if not os.path.exists(cindex_respath):
    os.makedirs(cindex_respath)

pred_risk_path = data_mode + '/pred_risk'
if not os.path.exists(pred_risk_path):
    os.makedirs(pred_risk_path)

for out_itr in range(3):
    # MAIN SETTING
    OUT_ITERATION = 5
    in_path = data_mode + '/result{}'.format(out_itr + 1)

    in_hypfile = in_path + '/hyperparameters_log.txt'
    in_parser = utils.load_logging(in_hypfile)

    # HYPER-PARAMETERS
    mb_size = in_parser['mb_size']
    iteration = in_parser['iteration']
    lr_train = in_parser['lr_train']

    initial_W = tf.contrib.layers.xavier_initializer()

    # INPUT DIMENSIONS
    input_dims = {
        'mb_size': mb_size,
        'x_dim': x_dim,
        'num_event': num_event,
        'event_prob': event_prob
    }

    # NETWORK HYPER-PARAMETERS
    network_settings = {
        'initial_w': initial_W
    }

    N = len(data)
    n_times = int(np.max(time)) + 1
    pred_all = np.zeros([N, num_event, n_times])
    time_all = np.zeros([N])
    label_all = np.zeros([N])
    cur = 0
    # c-index result
    FINAL1 = np.zeros([len(eval_times), num_event, OUT_ITERATION])

    # get prediction from each fold
    n_fold = 1
    skf = StratifiedKFold(n_splits=5, random_state=seed, shuffle=True)
    for tr_idx, te_idx in skf.split(data, label):
        # TRAINING-TESTING SPLIT
        tr_data, te_data = data[tr_idx], data[te_idx]
        tr_time, te_time = time[tr_idx], time[te_idx]
        tr_label, te_label = label[tr_idx], label[te_idx]
        tr_diags, te_diags = diags[tr_idx], diags[te_idx]

        # CREATE NETWORK
        tf.reset_default_graph()

        config = tf.ConfigProto()
        config.gpu_options.allow_growth = True
        sess = tf.Session(config=config)

        model = csCox_Model(sess, "cs-Cox-causal", input_dims, network_settings)
        saver = tf.train.Saver()
        sess.run(tf.global_variables_initializer())
        # PREDICTION & EVALUATION
        saver.restore(sess, in_path + '/itr_' + str(n_fold) + '/models/model_itr_' + str(n_fold))

        # PREDICTION
        pred = model.predict(te_data, te_diags)

        # calculate CIF for each competing risk
        N_test = len(pred)
        risk_evs = np.zeros([N_test, num_event, n_times])
        for ev in range(num_event):
            risk_score = np.exp(pred[:, ev])
            cumu_hazard = utils.cumulative_hazard_function(risk_score, te_time, te_label, ev + 1, n_times=n_times)
            risk_ev = np.matmul(np.reshape(risk_score, [N_test, 1]), np.reshape(cumu_hazard, [1, n_times]))
            risk_evs[:, ev, :] = risk_ev

        # EVALUATION
        result_tmp = np.zeros([len(eval_times), num_event])
        for t, t_time in enumerate(eval_times):
            eval_horizon = int(t_time)
            # calculate F(t | x, Y, t >= t_M) = \sum_{t_M <= \tau < t} P(\tau | x, Y, \tau > t_M)
            risk = risk_evs[:, :, eval_horizon]  # risk score at EVAL_TIMES
            for k in range(num_event):
                # -1 for no event (not comparable)
                result_tmp[t, k] = utils.weighted_c_index(tr_time, (tr_label[:, 0] == k + 1).astype(int),
                                                          risk[:, k], te_time,
                                                          (te_label[:, 0] == k + 1).astype(int),
                                                          eval_horizon)

        FINAL1[:, :, n_fold - 1] = result_tmp
        # SAVE RESULTS
        pred_all[cur:cur + N_test, :, :] = risk_evs
        time_all[cur:cur + N_test] = np.reshape(te_time, [N_test])
        label_all[cur:cur + N_test] = np.reshape(te_label, [N_test])
        cur += N_test

        n_fold += 1

    # SAVE RESULTS
    col_header = []
    for t in range(num_event):
        col_header.append('event_' + str(t + 1))

    row_header = []
    for t in eval_times:
        row_header.append('eval_time ' + str(t))

    # c-index result
    print('--------------------------------------------------------')
    print('- C-INDEX: ')
    # FINAL MEAN/STD
    # c-index result
    df = pd.DataFrame(np.mean(FINAL1, axis=2), index=row_header, columns=col_header)
    df.to_csv(cindex_respath + '/cscox_cindex_causal_{}.csv'.format(out_itr + 1))
    print(df)
    print('mean: ')
    print(np.mean(FINAL1))
    # df1_std.to_csv(in_path + '/result_CINDEX_FINAL_STD.csv')
    np.save(pred_risk_path + '/pred_risk_causal_{}.npy'.format(out_itr + 1), pred_all)

