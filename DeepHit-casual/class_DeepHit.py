import numpy as np
import tensorflow as tf
import random

from tensorflow.contrib.layers import fully_connected as FC_Net

# user-defined functions
import utils_network as utils

_EPSILON = 1e-08


# USER-DEFINED FUNCTIONS
def log(x):
    return tf.log(x + _EPSILON)


def div(x, y):
    return tf.div(x, (y + _EPSILON))


class Model_DeepHit:
    def __init__(self, sess, name, input_dims, network_settings):
        self.sess = sess
        self.name = name

        # INPUT DIMENSIONS
        self.x_dim = input_dims['x_dim']

        self.num_Event = input_dims['num_Event']
        self.num_Category = input_dims['num_Category']

        self.event_prob = input_dims['event_prob']
        # NETWORK HYPER-PARAMETERS
        self.h_dim_shared = network_settings['h_dim_shared']
        self.h_dim_CS = network_settings['h_dim_CS']
        self.num_layers_shared = network_settings['num_layers_shared']
        self.num_layers_CS = network_settings['num_layers_CS']

        self.active_fn = network_settings['active_fn']
        self.initial_W = network_settings['initial_W']
        self.reg_W = tf.contrib.layers.l2_regularizer(scale=1e-4)
        self.reg_W_out = tf.contrib.layers.l1_regularizer(scale=1e-4)

        self._build_net()

    def _build_net(self):
        with tf.variable_scope(self.name):
            # PLACEHOLDER DECLARATION
            self.mb_size = tf.placeholder(tf.int32, [], name='batch_size')
            self.lr_rate = tf.placeholder(tf.float32, [], name='learning_rate')
            self.keep_prob = tf.placeholder(tf.float32, [], name='keep_probability')  # keeping rate
            self.a = tf.placeholder(tf.float32, [], name='alpha')
            self.b = tf.placeholder(tf.float32, [], name='beta')
            self.c = tf.placeholder(tf.float32, [], name='gamma')

            self.x = tf.placeholder(tf.float32, shape=[None, self.x_dim], name='inputs')
            self.k = tf.placeholder(tf.float32, shape=[None, 1], name='labels')  # event/censoring label (censoring:0)
            self.t = tf.placeholder(tf.float32, shape=[None, 1], name='timetoevents')
            self.d = tf.placeholder(tf.float32, shape=[None, self.num_Event], name='diagnosis')

            self.fc_mask1 = tf.placeholder(tf.float32, shape=[None, self.num_Event, self.num_Category],
                                           name='mask1')  # for Loss 1
            self.fc_mask2 = tf.placeholder(tf.float32, shape=[None, self.num_Category],
                                           name='mask2')  # for Loss 2 / Loss 3

            # SHARED SUBNETWORK w/ FC NETS
            shared_out = utils.create_FCNet(self.x, self.num_layers_shared, self.h_dim_shared, self.active_fn,
                                            self.h_dim_shared, self.active_fn, self.initial_W, self.keep_prob,
                                            self.reg_W)
            last_x = self.x  # for residual connection

            h = tf.concat([last_x, shared_out], axis=1)

            # (num_layers_CS) layers for cause-specific (num_Event subNets)
            out = []
            for _ in range(self.num_Event):
                cs_out = utils.create_FCNet(h, self.num_layers_CS, self.h_dim_CS, self.active_fn,
                                            self.h_dim_CS * self.num_Event, self.active_fn,
                                            self.initial_W, self.keep_prob, self.reg_W)
                cs_out = tf.nn.dropout(cs_out, keep_prob=self.keep_prob)
                # softmax output layer
                cs_out = FC_Net(cs_out, self.num_Event * self.num_Category, activation_fn=tf.nn.softmax,
                                weights_initializer=self.initial_W, weights_regularizer=self.reg_W_out)
                cs_out = tf.reshape(cs_out, shape=[-1, self.num_Event, self.num_Category])
                out.append(cs_out)

            # stack referenced on subject
            out = tf.stack(out, axis=1)
            out = tf.transpose(out, [0, 2, 1, 3])

            # calculate \sum_d p_(k,t)^d * p(D = d), e.g.,P(K,T|do(X))
            out = tf.reshape(out, [-1, self.num_Event, self.num_Event, self.num_Category])
            # P(R = r) normalize to 1
            diag = self.d * self.event_prob
            diag = diag / (tf.reshape(tf.reduce_sum(diag, axis=1), [-1, 1]) + _EPSILON)
            # diagnosis label, specify to every subject
            # expand to the same dim size as the out shape: [num_subject, num_event, num_event, num_category]
            diags = tf.reshape(tf.tile(tf.reshape(diag, [-1, 1]), [1, self.num_Category]),
                               [-1, self.num_Event, self.num_Category])
            diags = tf.reshape(tf.tile(diags, [1, self.num_Event, 1]),
                               [-1, self.num_Event, self.num_Event, self.num_Category])
            # final out: P(Y, t|do(X))
            out = tf.reduce_sum(tf.multiply(out, diags), axis=2)
            self.out = out

            # GET LOSS FUNCTIONS
            self.loss_Log_Likelihood()  # get loss1: Log-Likelihood loss
            self.loss_Ranking()  # get loss2: Ranking loss
            self.loss_Calibration()  # get loss3: Calibration loss

            self.LOSS_TOTAL = self.a * self.LOSS_1 + self.b * self.LOSS_2 + self.c * self.LOSS_3 + tf.losses.get_regularization_loss()
            self.solver = tf.train.AdamOptimizer(learning_rate=self.lr_rate).minimize(self.LOSS_TOTAL)

    # LOSS-FUNCTION 1 -- Log-likelihood loss
    def loss_Log_Likelihood(self):
        I_1 = tf.sign(self.k)

        # for uncensored: log P(T=t,K=k|x)
        tmp1 = tf.reduce_sum(tf.reduce_sum(self.fc_mask1 * self.out, reduction_indices=2), reduction_indices=1,
                             keep_dims=True)
        tmp1 = I_1 * log(tmp1)

        # for censored: log \sum P(T>t|x)
        tmp2 = tf.reduce_sum(tf.reduce_sum(self.fc_mask1 * self.out, reduction_indices=2), reduction_indices=1,
                             keep_dims=True)
        tmp2 = (1. - I_1) * log(tmp2)

        self.LOSS_1 = - tf.reduce_mean(tmp1 + 1.0 * tmp2)

    # LOSS-FUNCTION 2 -- Ranking loss
    def loss_Ranking(self):
        sigma1 = tf.constant(0.1, dtype=tf.float32)

        eta = []
        for e in range(self.num_Event):
            one_vector = tf.ones_like(self.t, dtype=tf.float32)
            I_2 = tf.cast(tf.equal(self.k, e + 1), dtype=tf.float32)  # indicator for event
            I_2 = tf.diag(tf.squeeze(I_2))
            tmp_e = tf.reshape(tf.slice(self.out, [0, e, 0], [-1, 1, -1]),
                               [-1, self.num_Category])  # event specific joint prob.

            R = tf.matmul(tmp_e, tf.transpose(self.fc_mask2))  # no need to divide by each individual dominator
            # r_{ij} = risk of i-th pat based on j-th time-condition (last meas. time ~ event time) , i.e. r_i(T_{j})

            diag_R = tf.reshape(tf.diag_part(R), [-1, 1])
            R = tf.matmul(one_vector, tf.transpose(diag_R)) - R  # R_{ij} = r_{j}(T_{j}) - r_{i}(T_{j})
            R = tf.transpose(R)  # Now, R_{ij} (i-th row j-th column) = r_{i}(T_{i}) - r_{j}(T_{i})

            T = tf.nn.relu(
                tf.sign(tf.matmul(one_vector, tf.transpose(self.t)) - tf.matmul(self.t, tf.transpose(one_vector))))
            # T_{ij}=1 if t_i < t_j  and T_{ij}=0 if t_i >= t_j

            T = tf.matmul(I_2, T)  # only remains T_{ij}=1 when event occured for subject i

            tmp_eta = tf.reduce_mean(T * tf.exp(-R / sigma1), reduction_indices=1, keep_dims=True)

            eta.append(tmp_eta)
        eta = tf.stack(eta, axis=1)  # stack referenced on subjects
        eta = tf.reduce_mean(tf.reshape(eta, [-1, self.num_Event]), reduction_indices=1, keep_dims=True)

        self.LOSS_2 = tf.reduce_sum(eta)  # sum over num_Events

    # LOSS-FUNCTION 3 -- Calibration Loss
    def loss_Calibration(self):
        eta = []
        for e in range(self.num_Event):
            one_vector = tf.ones_like(self.t, dtype=tf.float32)
            I_2 = tf.cast(tf.equal(self.k, e + 1), dtype=tf.float32)  # indicator for event
            tmp_e = tf.reshape(tf.slice(self.out, [0, e, 0], [-1, 1, -1]),
                               [-1, self.num_Category])  # event specific joint prob.

            r = tf.reduce_sum(tmp_e * self.fc_mask2, axis=0)  # no need to divide by each individual dominator
            tmp_eta = tf.reduce_mean((r - I_2) ** 2, reduction_indices=1, keep_dims=True)

            eta.append(tmp_eta)
        eta = tf.stack(eta, axis=1)  # stack referenced on subjects
        eta = tf.reduce_mean(tf.reshape(eta, [-1, self.num_Event]), reduction_indices=1, keep_dims=True)

        self.LOSS_3 = tf.reduce_sum(eta)  # sum over num_Events

    def get_cost(self, DATA, MASK, PARAMETERS, keep_prob, lr_train):
        (x_mb, k_mb, t_mb, d_mb) = DATA
        (m1_mb, m2_mb) = MASK
        (alpha, beta, gamma) = PARAMETERS
        return self.sess.run(self.LOSS_TOTAL,
                             feed_dict={self.x: x_mb, self.k: k_mb, self.t: t_mb, self.d: d_mb,
                                        self.fc_mask1: m1_mb,
                                        self.fc_mask2: m2_mb,
                                        self.a: alpha, self.b: beta, self.c: gamma,
                                        self.mb_size: np.shape(x_mb)[0], self.keep_prob: keep_prob,
                                        self.lr_rate: lr_train})

    def train(self, DATA, MASK, PARAMETERS, keep_prob, lr_train):
        (x_mb, k_mb, t_mb, d_mb) = DATA
        (m1_mb, m2_mb) = MASK
        (alpha, beta, gamma) = PARAMETERS
        return self.sess.run([self.solver, self.LOSS_TOTAL],
                             feed_dict={self.x: x_mb, self.k: k_mb, self.t: t_mb, self.d: d_mb,
                                        self.fc_mask1: m1_mb,
                                        self.fc_mask2: m2_mb,
                                        self.a: alpha, self.b: beta, self.c: gamma,
                                        self.mb_size: np.shape(x_mb)[0], self.keep_prob: keep_prob,
                                        self.lr_rate: lr_train})

    def predict(self, x_test, d_test, keep_prob=1.0):
        return self.sess.run(self.out,
                             feed_dict={self.x: x_test, self.d: d_test,
                                        self.mb_size: np.shape(x_test)[0],
                                        self.keep_prob: keep_prob})

