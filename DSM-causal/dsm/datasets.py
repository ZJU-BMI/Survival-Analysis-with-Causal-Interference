import io
import pkgutil

import pandas as pd
import numpy as np

from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler

import torchvision


def f_get_Normalization(X, norm_mode):
    num_Patient, num_Feature = np.shape(X)
    if norm_mode is None:
        pass
    # zero mean unit variance
    elif norm_mode == 'standard':
        for j in range(num_Feature):
            if np.std(X[:, j]) != 0:
                X[:, j] = (X[:, j] - np.mean(X[:, j])) / np.std(X[:, j])
            else:
                X[:, j] = (X[:, j] - np.mean(X[:, j]))
    # min-max normalization
    elif norm_mode == 'normal':
        for j in range(num_Feature):
            X[:, j] = (X[:, j] - np.min(X[:, j])) / (np.max(X[:, j]) - np.min(X[:, j]))
    else:
        print("INPUT MODE ERROR!")

    return X


def import_dataset_eicu(norm_mode='normal'):
    in_filename = 'datasets/eicu_data_final2.csv'
    data = pkgutil.get_data(__name__, in_filename)
    df = pd.read_csv(io.BytesIO(data))

    # df['tte'] = df['tte'] - df['time']
    df = df.sort_values(by='tte', ascending=True)
    df = pd.get_dummies(df)
    df = df[df['tte'] > 0]
    # print(df.columns)
    label = np.asarray(df['label'])
    time = np.asarray(df['tte'])
    diags = np.asarray(df.iloc[:, 5:16])
    data = np.asarray(df.iloc[:, 16:])
    data = f_get_Normalization(data, norm_mode)

    x_dim = np.shape(data)[1]
    # only count the number of events (do not count censoring as an event)
    num_event = int(len(np.unique(label)) - 1)
    event_prob = np.sum(diags, axis=0) / len(diags)

    DIM = (x_dim, num_event, event_prob)
    DATA = (data, time, label, diags)
    eval_times = [20, 40, 60, 80]
    return DIM, DATA, eval_times


def import_dataset_mimic(norm_mode='normal'):
    in_filename = 'datasets/mimic_data_final2.csv'
    data = pkgutil.get_data(__name__, in_filename)
    df = pd.read_csv(io.BytesIO(data))

    # df['tte'] = df['tte'] - df['time']
    df = df.sort_values(by='tte', ascending=True)
    df = pd.get_dummies(df)
    df = df[df['tte'] > 0]
    # print(df.columns)
    label = np.asarray(df['label'])
    time = np.asarray(df['tte'])
    diags = np.asarray(df.iloc[:, 5:16])
    data = np.asarray(df.iloc[:, 16:])
    data = f_get_Normalization(data, norm_mode)

    x_dim = np.shape(data)[1]
    # only count the number of events (do not count censoring as an event)
    num_event = int(len(np.unique(label)) - 1)
    event_prob = np.sum(diags, axis=0) / len(diags)

    DIM = (x_dim, num_event, event_prob)
    DATA = (data, time, label, diags)
    eval_times = [5, 25, 50, 75]
    return DIM, DATA, eval_times


def import_dataset_seer(norm_mode='normal', loadmask=False):
    data_path = 'datasets/seer_data.csv'
    data = pkgutil.get_data(__name__, data_path)
    df = pd.read_csv(io.BytesIO(data))
    # one-hot category features
    df = pd.get_dummies(df, columns=['ethnicity', 'prim_site', 'laterality', 'hist_behavior',
                                     'cs_mets_at_dx', 'summary_stage'])
    # sort by tte
    df = df.sort_values(by='tte', ascending=True)
    df = df[df['tte'] > 0]
    # df.to_csv('datasets/eicu_data_final3.csv', index=False)
    # print(df.columns)
    label = np.asarray(df['label'])
    time = np.asarray(df['tte'])

    data = np.asarray(df.iloc[:, 3:])
    data = f_get_Normalization(data, norm_mode)

    # only count the number of events (do not count censoring as an event)
    num_event = int(len(np.unique(label)) - 1)
    diags = np.ones([len(label), num_event], dtype=np.int64)
    event_prob = np.sum(diags, axis=0) / len(diags)
    # print(mask.shape)
    x_dim = np.shape(data)[1]

    DIM = (x_dim, num_event, event_prob)
    DATA = (data, time, label, diags)
    eval_times = [12, 36, 60, 84]
    return DIM, DATA, eval_times


def load_dataset(dataset='SUPPORT', **kwargs):

    if dataset == 'MIMIC':
        return import_dataset_mimic('normal')
    elif dataset == 'EICU':
        return import_dataset_eicu('normal')
    elif dataset == 'SEER':
        return import_dataset_seer('normal')
    else:
        raise NotImplementedError('Dataset ' + dataset + ' not implemented.')
