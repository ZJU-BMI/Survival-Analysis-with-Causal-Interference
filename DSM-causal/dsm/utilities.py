from dsm.dsm_torch import DeepSurvivalMachinesTorch
from dsm.losses import unconditional_loss, conditional_loss

from tqdm import tqdm
from copy import deepcopy

import torch
import numpy as np

import gc
import logging


def get_optimizer(model, lr):
    return torch.optim.Adam(model.parameters(), lr=lr)


def pretrain_dsm(model, t_train, e_train, d_train,
                 t_valid, e_valid, d_valid, event_prob,
                 n_iter=10, lr=1e-4, thres=1e-4):
    premodel = DeepSurvivalMachinesTorch(1, 3, dist=model.dist, risks=model.risks,
                                         optimizer=model.optimizer, event_prob=event_prob)
    premodel.double()

    optimizer = get_optimizer(premodel, lr)

    oldcost = float('inf')
    patience = 0
    costs = []
    for _ in tqdm(range(n_iter)):

        optimizer.zero_grad()
        loss = 0
        for r in range(model.risks):
            loss += unconditional_loss(premodel, t_train, e_train, d_train, r + 1)
        loss.backward()
        optimizer.step()

        valid_loss = 0
        for r in range(model.risks):
            valid_loss += unconditional_loss(premodel, t_valid, e_valid, d_valid, r + 1)
        valid_loss = valid_loss.detach().cpu().numpy()
        costs.append(valid_loss)
        # print(valid_loss)
        if np.abs(costs[-1] - oldcost) < thres:
            patience += 1
            if patience == 3:
                break
        oldcost = costs[-1]

    return premodel


def _reshape_tensor_with_nans(data):
    """Helper function to unroll padded RNN inputs."""
    data = data.reshape(-1)
    return data[~torch.isnan(data)]


def train_dsm(model, x_train, t_train, e_train, d_train,
              x_valid, t_valid, e_valid, d_valid, event_prob,
              n_iter=10000, lr=1e-3, elbo=True,
              bs=100):
    """Function to train the torch instance of the model."""

    logging.info('Pretraining the Underlying Distributions...')
    # For padded variable length sequences we first unroll the input and
    # mask out the padded nans.
    # t_train_ = _reshape_tensor_with_nans(t_train)
    # e_train_ = _reshape_tensor_with_nans(e_train)
    # t_valid_ = _reshape_tensor_with_nans(t_valid)
    # e_valid_ = _reshape_tensor_with_nans(e_valid)

    premodel = pretrain_dsm(model, t_train, e_train, d_train, t_valid, e_valid, d_valid,
                            event_prob=event_prob, n_iter=1000, lr=1e-4, thres=1e-4)

    for r in range(model.risks):
        # print(model.shape[str(r + 1)])
        # print(premodel.shape[str(r + 1)])
        model.shape[str(r + 1)] = premodel.shape[str(r + 1)]
        model.scale[str(r + 1)] = premodel.scale[str(r + 1)]
        # model.shape[str(r + 1)] = float(premodel.shape[str(r + 1)])
        # model.scale[str(r + 1)] = float(premodel.scale[str(r + 1)])

    model.double()
    optimizer = get_optimizer(model, lr)

    patience = 0
    oldcost = float('inf')

    nbatches = int(x_train.shape[0] / bs) + 1

    dics = []
    costs = []
    i = 0
    for i in tqdm(range(n_iter)):
        for j in range(nbatches):

            xb = x_train[j * bs:(j + 1) * bs]
            tb = t_train[j * bs:(j + 1) * bs]
            eb = e_train[j * bs:(j + 1) * bs]
            db = d_train[j * bs:(j + 1) * bs]

            if xb.shape[0] == 0:
                continue

            optimizer.zero_grad()
            loss = 0
            for r in range(model.risks):
                loss += conditional_loss(model, xb, tb, eb, db, elbo=elbo, risk=r + 1)
            # print ("Train Loss:", float(loss))
            loss.backward()
            optimizer.step()

        valid_loss = 0
        for r in range(model.risks):
            valid_loss += conditional_loss(model, x_valid, t_valid, e_valid, d_valid, elbo=False, risk=r + 1)

        valid_loss = valid_loss.detach().cpu().numpy()
        costs.append(float(valid_loss))
        dics.append(deepcopy(model.state_dict()))

        if costs[-1] >= oldcost:
            if patience == 5 and i > n_iter * 0.2:
                minm = np.argmin(costs)
                model.load_state_dict(dics[minm])

                del dics
                gc.collect()

                return model, i
            else:
                patience += 1
        else:
            patience = 0

        oldcost = costs[-1]

    minm = np.argmin(costs)
    model.load_state_dict(dics[minm])

    del dics
    gc.collect()

    return model, i
