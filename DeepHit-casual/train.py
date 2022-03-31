import tensorflow as tf
import numpy as np
import pandas as pd
import os
from get_main import get_valid_performance
from sklearn.model_selection import StratifiedKFold
import import_data as impt
import utils_eval as utils

seed = 1234
data_mode = 'SEER'

if not os.path.exists(data_mode):
    os.makedirs(data_mode)

# import data from MIMIC/EICU datasets
if data_mode == 'MIMIC':
    (x_dim, num_event, event_prob), (data, time, label, diags) \
        , (mask1, mask2) = impt.import_dataset_mimic('normal')
    eval_times = [5, 25, 50, 75]

elif data_mode == 'EICU':
    (x_dim, num_event, event_prob), (data, time, label, diags) \
        , (mask1, mask2) = impt.import_dataset_eicu('normal')
    eval_times = [20, 40, 60, 80]

elif data_mode == 'SEER':
    (x_dim, num_event, event_prob), (data, time, label, diags) \
        , (mask1, mask2) = impt.import_dataset_seer('normal')
    eval_times = [12, 36, 60, 84]
else:
    (x_dim, num_event, event_prob), (data, time, label, diags) \
        , (mask1, mask2) = impt.import_dataset_mimic('normal')
    eval_times = [5, 25, 50, 75]

for itr in range(3):
    out_path = data_mode + '/result{}'.format(itr + 1)
    if not os.path.exists(out_path):
        os.makedirs(out_path)

    in_parser = {
        'mb_size': 32,
        'iteration': 30000,
        'keep_prob': 0.6,
        'lr_train': 1e-4,
        'h_dim_shared': 100,
        'h_dim_CS': 100,
        'num_layers_shared': 2,
        'num_layers_CS': 2,
        'active_fn': 'relu',
        'event_prob': event_prob,
        'alpha': 1.0,  # default (set alpha = 1.0 and change beta and gamma)
        'beta': 1.0,
        'gamma': 0,  # default (no calibration loss)
        'out_path': out_path
    }
    log_name = out_path + '/hyperparameters_log.txt'
    utils.save_logging(in_parser, log_name)

    n_fold = 1
    skf = StratifiedKFold(n_splits=5, random_state=seed, shuffle=True)
    for tr_idx, te_idx in skf.split(data, label):
        print('training fold {}'.format(n_fold))

        if not os.path.exists(out_path + '/itr_' + str(n_fold) + '/'):
            os.makedirs(out_path + '/itr_' + str(n_fold) + '/')

        tr_data, te_data = data[tr_idx], data[te_idx]
        tr_time, te_time = time[tr_idx], time[te_idx]
        tr_label, te_label = label[tr_idx], label[te_idx]
        tr_diags, te_diags = diags[tr_idx], diags[te_idx]
        tr_mask1, te_mask1 = mask1[tr_idx], mask1[te_idx]
        tr_mask2, te_mask2 = mask2[tr_idx], mask2[te_idx]

        DATA = (tr_data, tr_time, tr_label, tr_diags)
        MASK = (tr_mask1, tr_mask2)

        get_valid_performance(DATA, MASK, in_parser, out_itr=n_fold, eval_time=eval_times)
        n_fold += 1


