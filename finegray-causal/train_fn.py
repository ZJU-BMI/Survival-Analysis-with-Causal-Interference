import os
import random

import numpy as np
from sklearn.model_selection import train_test_split
import tensorflow as tf

import utils
from finegray_causal import FG_Model


def f_get_minibatch(mb_size, x, label, time, diags, num_event=3):
    idx = range(np.shape(x)[0])
    idx = random.sample(idx, mb_size)
    x_mb = x[idx, :].astype(np.float32)  # covariates
    k_mb = label[idx, :].astype(np.float32)  # censoring(0)/event(1,2,..) label
    t_mb = time[idx, :].astype(np.float32)  # time to event
    d_mb = diags[idx, :].astype(np.float32)     # diagnosis
    m1_mb = utils.get_bh_mask(t_mb, k_mb, num_event)
    return x_mb, k_mb, t_mb, d_mb, m1_mb


def train(DATA, in_parser, cur_itr=0, MAX_VALUE=-99, seed=1234, eval_times=None, n_times=100):
    (data, time, label, diags) = DATA
    # mask = MASK
    n_subjects, x_dim = np.shape(data)
    mb_size = in_parser['mb_size']
    iteration = in_parser['iteration']
    lr_train = in_parser['lr_train']
    initial_w = tf.truncated_normal_initializer(stddev=0.01)
    event_prob = in_parser['event_prob']
    num_event = in_parser['num_event']

    if eval_times is None:
        eval_times = [5, 25, 50, 75]

    input_dims = {
        'mb_size': mb_size,
        'x_dim': x_dim,
        'num_event': num_event,
        'event_prob': event_prob,
    }

    network_settings = {
        'initial_w': initial_w
    }

    # save paths
    file_path_final = in_parser['out_path'] + '/itr_' + str(cur_itr)
    print(file_path_final)
    tf.reset_default_graph()
    config = tf.ConfigProto()
    config.gpu_options.allow_growth = True
    sess = tf.Session(config=config)

    model = FG_Model(sess, "FineGray", input_dims, network_settings)
    saver = tf.train.Saver()
    sess.run(tf.global_variables_initializer())

    max_valid = -99
    stop_flag = 0

    print("MAIN TRAINING ...")
    avg_loss = 0

    # create model save path
    model_save_path = file_path_final + '/models'
    if not os.path.exists(model_save_path):
        os.makedirs(model_save_path)

    # 20% of training set for validation
    tr_index, va_index = train_test_split(np.arange(n_subjects), test_size=0.2, random_state=seed)
    tr_data, va_data = data[tr_index], data[va_index]
    tr_time, va_time = time[tr_index], time[va_index]
    tr_label, va_label = label[tr_index], label[va_index]
    tr_diags, va_diags = diags[tr_index], diags[va_index]

    for itr in range(iteration):
        if stop_flag > 10:
            break

        x_mb, k_mb, t_mb, d_mb, m_mb = f_get_minibatch(mb_size, tr_data, tr_label,
                                                       tr_time, tr_diags, num_event=num_event)
        data_train = (x_mb, k_mb, t_mb, d_mb)
        mask_train = m_mb
        _, loss_cur = model.train(data_train, mask_train, lr_train=lr_train)
        avg_loss += loss_cur / 1000
        if (itr + 1) % 1000 == 0:
            print('|| ITR: ' + str('%04d' % (itr + 1)) + ' | Loss: ' +
                  str('%.4f' % avg_loss))
            avg_loss = 0

        if (itr + 1) % 1000 == 0:
            pred = model.predict(va_data, va_diags)
            # calculate CIF over time
            n_va = len(va_data)
            risk_evs = np.zeros([n_va, num_event, n_times])
            for ev in range(num_event):
                risk_score = np.exp(pred[:, ev])
                cumu_hazard = utils.cumulative_hazard_function(risk_score, va_time, va_label,
                                                               ev + 1, n_times=n_times)
                risk_ev = np.matmul(np.reshape(risk_score, [n_va, 1]), np.reshape(cumu_hazard, [1, n_times]))
                risk_evs[:, ev, :] = risk_ev

            va_result = np.zeros([len(eval_times), num_event])
            for t, t_time in enumerate(eval_times):
                eval_horizon = int(t_time)
                # calculate F(t | x, Y, t >= t_M) = \sum_{t_M <= \tau < t} P(\tau | x, Y, \tau > t_M)
                risk = risk_evs[:, :, eval_horizon]  # risk score at EVAL_TIMES
                for k in range(num_event):
                    # -1 for no event (not comparable)
                    va_result[t, k] = utils.weighted_c_index(tr_time, (tr_label[:, 0] == k + 1).astype(int),
                                                             risk[:, k], va_time,
                                                             (va_label[:, 0] == k + 1).astype(int),
                                                             eval_horizon)

            tmp_valid = np.mean(va_result)

            if tmp_valid > max_valid:
                stop_flag = 0
                max_valid = tmp_valid
                print('updated.... average c-index = ' + str('%.4f' % tmp_valid))

                if max_valid > MAX_VALUE:
                    saver.save(sess, model_save_path + '/model_itr_' + str(cur_itr))
            else:
                stop_flag += 1

    return max_valid
