import numpy as np
import tensorflow as tf
import os
from sklearn.model_selection import train_test_split, StratifiedKFold
from import_data_mimic import import_dataset_mimic
from import_data_eicu import import_dataset_eicu

from class_DeepLongitudinal import Model_Longitudinal_Attention

from utils_eval import c_index, f_get_risk_predictions2, weighted_c_index
from utils_log import save_logging, load_logging
from utils_helper import f_get_minibatch, f_get_boosted_trainset

_EPSILON = 1e-8

# 1. Import Dataset
# - Users must prepare dataset in csv format and modify 'import_data.py' following our exemplar 'PBC2'

data_mode = 'EICU'
seed = 1234

# IMPORT DATASET
'''
    num_Category            = max event/censoring time * 1.2
    num_Event               = number of events i.e. len(np.unique(label))-1
    max_length              = maximum number of measurements
    x_dim                   = data dimension including delta (1 + num_features)
    x_dim_cont              = dim of continuous features
    x_dim_bin               = dim of binary features
    mask1, mask2, mask3     = used for cause-specific network (FCNet structure)
'''
if data_mode == 'MIMIC':
    (x_dim, x_dim_cont, x_dim_bin, event_prob), (data, time, label, diags), (mask1, mask2, mask3), (
        data_mi) = import_dataset_mimic(norm_mode='normal')
elif data_mode == 'EICU':
    (x_dim, x_dim_cont, x_dim_bin, event_prob), (data, time, label, diags), (mask1, mask2, mask3), (
        data_mi) = import_dataset_eicu(norm_mode='normal')
else:
    (x_dim, x_dim_cont, x_dim_bin, event_prob), (data, time, label, diags), (mask1, mask2, mask3), (
        data_mi) = import_dataset_mimic(norm_mode='normal')

# This must be changed depending on the datasets, prediction/evaliation times of interest
pred_time = 5  # prediction time (in days)
eval_time = [20, 40, 60, 80]  # evaluation time (for C-index)

_, num_Event, num_Category = np.shape(mask1)  # dim of mask3: [subj, Num_Event, Num_Category]
max_length = np.shape(data)[1]

file_path = '{}'.format(data_mode)

if not os.path.exists(file_path):
    os.makedirs(file_path)


# Set Hyper-Parameters
burn_in_mode = 'ON'  # {'ON', 'OFF'}
boost_mode = 'ON'  # {'ON', 'OFF'}

# HYPER-PARAMETERS
new_parser = {
    'mb_size': 32,
    'iteration_burn_in': 3000,
    'iteration': 25000,

    'keep_prob': 0.6,
    'lr_train': 1e-4,

    'h_dim_RNN': 100,
    'h_dim_FC': 100,
    'num_layers_RNN': 2,
    'num_layers_ATT': 2,
    'num_layers_CS': 2,

    'RNN_type': 'LSTM',  # {'LSTM', 'GRU'}
    'FC_active_fn': tf.nn.relu,
    'RNN_active_fn': tf.nn.tanh,

    'reg_W': 1e-5,
    'reg_W_out': 0.,

    'alpha': 1.0,
    'beta': 0.1,
    'gamma': 1.0
}

# INPUT DIMENSIONS
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
    'h_dim_RNN': new_parser['h_dim_RNN'],
    'h_dim_FC': new_parser['h_dim_FC'],
    'num_layers_RNN': new_parser['num_layers_RNN'],
    'num_layers_ATT': new_parser['num_layers_ATT'],
    'num_layers_CS': new_parser['num_layers_CS'],
    'RNN_type': new_parser['RNN_type'],
    'FC_active_fn': new_parser['FC_active_fn'],
    'RNN_active_fn': new_parser['RNN_active_fn'],
    'initial_W': tf.contrib.layers.xavier_initializer(),
    'reg_W': new_parser['reg_W'],
    'reg_W_out': new_parser['reg_W_out']
}

mb_size = new_parser['mb_size']
iteration = new_parser['iteration']
iteration_burn_in = new_parser['iteration_burn_in']

keep_prob = new_parser['keep_prob']
lr_train = new_parser['lr_train']

alpha = new_parser['alpha']
beta = new_parser['beta']
gamma = new_parser['gamma']

for out_itr in range(3, 5):
    # SAVE HYPER PARAMETERS
    out_path = file_path + '/result' + str(out_itr + 1)
    if not os.path.exists(out_path):
        os.makedirs(out_path)

    log_name = out_path + '/hyperparameters_log.txt'
    save_logging(new_parser, log_name)

    n_fold = 1
    # 5-fold cross validation
    skf = StratifiedKFold(n_splits=5, random_state=seed, shuffle=True)
    # Split Dataset into Train/Valid/Test Sets (5-fold)
    for train_index, test_index in skf.split(data, label):

        model_save_path = out_path + '/itr_' + str(n_fold)
        if not os.path.exists(model_save_path):
            os.makedirs(model_save_path)

        tr_data, te_data = data[train_index], data[test_index]
        tr_data_mi, te_data_mi = data_mi[train_index], data_mi[test_index]
        tr_time, te_time = time[train_index], time[test_index]
        tr_label, te_label = label[train_index], label[test_index]
        tr_diags, te_diags = diags[train_index], diags[test_index]
        tr_mask1, te_mask1 = mask1[train_index], mask1[test_index]
        tr_mask2, te_mask2 = mask2[train_index], mask2[test_index]
        tr_mask3, te_mask3 = mask3[train_index], mask3[test_index]

        (tr_data, va_data, tr_data_mi, va_data_mi,
         tr_time, va_time, tr_label, va_label,
         tr_diags, va_diags, tr_mask1, va_mask1,
         tr_mask2, va_mask2, tr_mask3, va_mask3) = train_test_split(tr_data, tr_data_mi, tr_time, tr_label,
                                                                    tr_diags, tr_mask1, tr_mask2, tr_mask3,
                                                                    test_size=0.2, random_state=seed)

        if boost_mode == 'ON':
            tr_data, tr_data_mi, tr_time, tr_label, tr_diags, \
            tr_mask1, tr_mask2, tr_mask3 = f_get_boosted_trainset(tr_data, tr_data_mi, tr_time, tr_label,
                                                                  tr_diags, tr_mask1, tr_mask2, tr_mask3)

        # 4. Train the Network
        # CREATE DYNAMIC-DEEPHIT NETWORK
        tf.reset_default_graph()

        config = tf.ConfigProto()
        config.gpu_options.allow_growth = True
        # config.gpu_options.per_process_gpu_memory_fraction = 0.333
        sess = tf.Session(config=config)

        model = Model_Longitudinal_Attention(sess, "Dynamic-DeepHit-Causal", input_dims, network_settings)
        saver = tf.train.Saver()

        sess.run(tf.global_variables_initializer())

        # TRAINING - BURN-IN
        print("Current training fold: {}".format(n_fold))
        if burn_in_mode == 'ON':
            print("BURN-IN TRAINING ...")
            for itr in range(iteration_burn_in):
                x_mb, x_mi_mb, k_mb, t_mb, \
                d_mb, m1_mb, m2_mb, m3_mb = f_get_minibatch(mb_size, tr_data, tr_data_mi,
                                                            tr_label, tr_time, tr_diags, tr_mask1,
                                                            tr_mask2, tr_mask3)
                DATA = (x_mb, k_mb, t_mb)
                MISSING = x_mi_mb

                _, loss_curr = model.train_burn_in(DATA, MISSING, keep_prob, lr_train)

                if (itr + 1) % 1000 == 0:
                    print('itr: {:04d} | loss: {:.4f}'.format(itr + 1, loss_curr))

        # TRAINING - MAIN
        print("MAIN TRAINING ...")
        min_valid = 0.

        for itr in range(iteration):
            x_mb, x_mi_mb, k_mb, t_mb, \
            d_mb, m1_mb, m2_mb, m3_mb = f_get_minibatch(mb_size, tr_data, tr_data_mi, tr_label,
                                                        tr_time, tr_diags, tr_mask1, tr_mask2,
                                                        tr_mask3)
            DATA = (x_mb, k_mb, t_mb, d_mb)
            MASK = (m1_mb, m2_mb, m3_mb)
            MISSING = x_mi_mb
            PARAMETERS = (alpha, beta, gamma)

            _, loss_curr = model.train(DATA, MASK, MISSING, PARAMETERS, keep_prob, lr_train)

            if (itr + 1) % 1000 == 0:
                print('itr: {:04d} | loss: {:.4f}'.format(itr + 1, loss_curr))

            # VALIDATION  (based on average C-index of our interest)
            if (itr + 1) % 1000 == 0:
                risk_all = f_get_risk_predictions2(sess, model, va_data, va_data_mi, va_diags,
                                                   pred_time=pred_time, eval_time=eval_time)

                pred_horizon = int(pred_time)
                val_result = np.zeros([num_Event, len(eval_time)])
                for t, t_time in enumerate(eval_time):
                    eval_horizon = int(t_time) + pred_horizon
                    for k in range(num_Event):
                        val_result[k, t] = weighted_c_index(tr_time, (tr_label[:, 0] == k + 1).astype(int),
                                                            risk_all[:, k, t], va_time,
                                                            (va_label[:, 0] == k + 1).astype(int),
                                                            eval_horizon)  # -1 for no event (not comparable)

                tmp_valid = np.mean(val_result)
                print(tmp_valid)
                # print(val_final1)
                if tmp_valid > min_valid:
                    min_valid = tmp_valid
                    saver.save(sess, model_save_path + '/model_itr_' + str(n_fold))
                    print('updated.... average c-index = ' + str('%.4f' % tmp_valid))

        n_fold += 1
