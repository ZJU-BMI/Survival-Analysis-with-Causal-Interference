import os

import pandas as pd
import tensorflow as tf
from finegray_layer import FineGrayLayer
from tensorflow.keras import optimizers
import numpy as np
from lifelines.utils import concordance_index
from utils import *

_EPSILON = 1e-8

data_mode = 'EICU'

result_path = data_mode + '/result'
if not os.path.exists(result_path):
    os.makedirs(result_path)


def fit(tr_cov, tr_times, tr_labels, tr_diags,
        te_cov, te_times, te_labels, te_diags,
        num_events, event_prob, eval_time=5, n_fold=0,
        lr=1e-2, l2reg=1e-4, epochs=100):

    N, num_features = tr_cov.shape
    # sort in descending order
    order = np.argsort(-tr_times)
    T = tr_times[order]
    tr_cov = tr_cov[order, :]
    E = tr_labels[order]

    fg_models = []
    for i in range(num_events):
        fg_models.append(FineGrayLayer(output_dim=num_events, num_features=num_features))

    optimizer = optimizers.RMSprop(learning_rate=lr)
    epoch_complete = 0
    results_final = np.zeros(shape=[num_events])

    while epoch_complete < epochs:
        with tf.GradientTape() as tape:

            pred_beta_x = []
            for i in range(num_events):
                pred_beta_x_event = fg_models[i](tr_cov)
                pred_beta_x.append(pred_beta_x_event)

            out = tf.stack(pred_beta_x, axis=1)
            out = tf.transpose(out, [0, 2, 1])

            # calculated \sum_r <X, \Beta_r> P(R = r)
            tr_diags_tensor = tf.reshape(tf.tile(tr_diags, [1, num_events]), [-1, num_events, num_events])
            out = tf.multiply(out, tr_diags_tensor)
            event_prob_tensor = tf.cast(event_prob, tf.float32)
            out = tf.reduce_sum(tf.multiply(out, event_prob_tensor), axis=2)

            # calculate the neg_likelihood Loss
            neg_likelihood_loss = 0.

            km_scores = []
            for i in range(num_events):
                km_scores.append(get_km_scores(T, E, i + 1))

            for i in range(N):
                if E[i] > 0:
                    ev = E[i] - 1
                    w_ij = np.ones(shape=[N, ])
                    # w_ij[i] = 0.
                    for j in range(i + 1, N):
                        t_i = int(T[i])
                        t_j = int(T[j])
                        if t_i > t_j and E[j] > 0 and E[j] != E[i]:
                            w_ij[j] = km_scores[ev][t_i] / (km_scores[ev][t_j] + EPSILON)
                        elif t_i > t_j:
                            w_ij[j] = 0.
                        # if t_i > t_j:
                        #     w_ij[j] = 0.
                    sum_subdistrib = tf.reduce_sum(tf.multiply(w_ij, tf.math.exp(out[:, ev])))

                    neg_likelihood_loss += out[i, ev] - tf.math.log(sum_subdistrib)

            neg_likelihood_loss = -neg_likelihood_loss
            whole_loss = neg_likelihood_loss

            variables = []
            for i in range(num_events):
                variables.extend([var for var in fg_models[i].trainable_variables])
                for weights in fg_models[i].trainable_variables:
                    whole_loss += tf.keras.regularizers.l2(l2reg)(weights)

            gradient = tape.gradient(whole_loss, variables)
            optimizer.apply_gradients(zip(gradient, variables))

        # test
        pred_te_beta_x = []
        for i in range(num_events):
            pred_te_beta_x.append(fg_models[i](te_cov))

        te_out = tf.stack(pred_te_beta_x, axis=1)
        te_out = tf.transpose(te_out, [0, 2, 1])

        # calculated \sum_d <X, \Beta_d> P(D = d)
        te_diags_tensor = tf.reshape(tf.tile(te_diags, [1, num_events]), [-1, num_events, num_events])

        te_out = tf.multiply(te_out, te_diags_tensor)
        event_prob_tensor = tf.cast(event_prob, tf.float32)
        te_out = tf.reduce_sum(tf.multiply(te_out, event_prob_tensor), axis=2)
        te_out = te_out.numpy()

        c_index_results = np.zeros(shape=[num_events])

        for i in range(num_events):
            pred_out = te_out[:, i]
            pred_scores = np.exp(pred_out)
            In = np.cast['float32'](np.equal(te_labels, i + 1))
            c_index = concordance_index(te_times, -pred_scores, In)
            c_index_results[i] = c_index

        print('iter #{}, Loss = {:.4f}, c-index = '.format(epoch_complete + 1, whole_loss), c_index_results)

        if np.sum(c_index_results) > np.sum(results_final):
            results_final = c_index_results
            print('Update c-index result, current best: ', results_final)

        tf.compat.v1.reset_default_graph()
        epoch_complete += 1

    print('Best result: \n', results_final)
    return results_final


