import os
from sklearn.model_selection import StratifiedKFold, train_test_split
import utils
from train_fn import train
import numpy as np

seed = 1234
data_mode = 'SEER'

if not os.path.exists(data_mode):
    os.makedirs(data_mode)

if data_mode == 'MIMIC':
    (x_dim, num_event, event_prob), (data, time, label, diags) = utils.import_dataset_mimic(norm_mode='normal')
    eval_times = [5, 25, 50, 75]

elif data_mode == 'EICU':
    (x_dim, num_event, event_prob), (data, time, label, diags) = utils.import_dataset_eicu(norm_mode='normal')
    eval_times = [20, 40, 60, 80]

elif data_mode == 'SEER':
    (x_dim, num_event, event_prob), (data, time, label, diags) = utils.import_dataset_seer(norm_mode='normal')
    eval_times = [12, 36, 60, 84]

else:
    (x_dim, num_event, event_prob), (data, time, label, diags) = utils.import_dataset_mimic(norm_mode='normal')
    eval_times = [5, 25, 50, 75]

n_times = int(np.max(time)) + 1

# 5 fold cross validation
for itr in range(3):
    # result path: data_mode/result1/
    out_path = data_mode + '/result{}'.format(itr + 1)
    if not os.path.exists(out_path):
        os.makedirs(out_path)

    # hyper-parameters
    new_parser = {
        'mb_size': 32,
        'iteration': 30000,
        'lr_train': 1e-4,
        'num_event': num_event,
        'event_prob': event_prob,
        'out_path': out_path
    }
    # save hyper-parameters
    log_name = out_path + '/hyperparameters_log.txt'
    utils.save_logging(new_parser, log_name)
    # five fold cross validation
    n_fold = 1
    # 5 fold cross validations
    skf = StratifiedKFold(n_splits=5, random_state=seed, shuffle=True)
    for tr_idx, te_idx in skf.split(data, label):
        print('training fold {}'.format(n_fold))
        if not os.path.exists(out_path + '/itr_' + str(n_fold) + '/'):
            os.makedirs(out_path + '/itr_' + str(n_fold) + '/')
        # train test split
        tr_data, te_data = data[tr_idx], data[te_idx]
        tr_time, te_time = time[tr_idx], time[te_idx]
        tr_label, te_label = label[tr_idx], label[te_idx]
        tr_diags, te_diags = diags[tr_idx], diags[te_idx]
        # tr_mask, te_mask = mask[tr_idx][:, tr_idx, :], mask[te_idx][:, te_idx, :]
        DATA = (tr_data, tr_time, tr_label, tr_diags)
        # print(tr_mask.shape)
        # MASK = tr_mask
        # train and save the model
        train(DATA, new_parser, cur_itr=n_fold, eval_times=eval_times, n_times=n_times)
        n_fold += 1
