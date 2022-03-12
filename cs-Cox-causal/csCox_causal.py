
import tensorflow as tf
from csCox_layer import csCox_layer


_EPSILON = 1e-8


# USER-DEFINED FUNCTIONS
def log(x):
    return tf.log(x + 1e-8)


def div(x, y):
    return tf.div(x, (y + 1e-8))


class csCox_Model:
    def __init__(self, sess, name, input_dims, network_settings):
        self.sess = sess
        self.name = name
        self.mb_size = input_dims['mb_size']
        self.x_dim = input_dims['x_dim']
        self.num_events = input_dims['num_event']
        self.event_prob = input_dims['event_prob']

        self.initial_w = network_settings['initial_w']
        self.reg_w = tf.contrib.layers.l2_regularizer(scale=1e-4)
        self.reg_W_out = tf.contrib.layers.l1_regularizer(scale=1e-4)

        self._build_net()

    def _build_net(self):
        with tf.variable_scope(self.name):
            self.lr_rate = tf.placeholder(tf.float32, [], name='learning_rate')
            self.x = tf.placeholder(tf.float32, shape=[None, self.x_dim], name='inputs')
            # event/censoring label (censoring:0)
            self.k = tf.placeholder(tf.float32, shape=[None, 1], name='labels')
            # time to event
            self.t = tf.placeholder(tf.float32, shape=[None, 1], name='timetoevents')
            # diagnosis
            self.d = tf.placeholder(tf.float32, shape=[None, self.num_events], name='diagnosis')
            self.mask = tf.placeholder(tf.float32, shape=[self.mb_size, self.mb_size, self.num_events], name='mask')
            out = []
            for i in range(self.num_events):
                beta_x_out = csCox_layer(self.x, self.num_events, w_init=self.initial_w,
                                            w_reg=self.reg_w)
                out.append(beta_x_out)

            out = tf.stack(out, axis=1)
            out = tf.transpose(out, [0, 2, 1])
            # out [N, num_ev, num_ev]
            diag = self.d * self.event_prob
            diag = diag / (tf.reshape(tf.reduce_sum(diag, axis=1), [-1, 1]) + _EPSILON)
            tr_diags_tensor = tf.reshape(tf.tile(diag, [1, self.num_events]),
                                         [-1, self.num_events, self.num_events])
            out = tf.reduce_sum(tf.multiply(out, tr_diags_tensor), axis=2)
            self.out = out

            self.loss_log_likelihood()
            self.loss_total = self.Loss1
            self.solver = tf.train.AdamOptimizer(learning_rate=self.lr_rate).minimize(self.loss_total)

    def loss_log_likelihood(self):
        neg_likelihood_loss = 0.
        for i in range(self.num_events):
            I_1 = tf.reshape(tf.cast(tf.equal(self.k, i + 1), dtype=tf.float32), shape=[-1])
            tmp1 = tf.reshape(tf.slice(self.out, [0, i], [-1, 1]), shape=[-1])
            sum_beta_x = tf.multiply(I_1, tmp1)
            # w_ij * exp(beta_j)
            w_ij = tf.reshape(tf.slice(self.mask, [0, 0, i], [-1, -1, 1]), shape=[self.mb_size, self.mb_size])
            # sum_log_x = tf.math.log(tf.reduce_sum(w_ij * tf.math.exp(tmp1), axis=1) + 1)
            tmp2 = tf.reduce_sum(w_ij * tf.math.exp(tmp1), axis=1)
            # exclude values = 0 to calculate log
            # value = 0 mean that the subject is not in the risk set, just exclude it
            sum_log_x = tf.math.log(tf.gather_nd(tmp2, tf.where(tmp2 > 0)))
            sum_cause_spec = tf.reduce_sum(sum_beta_x) - tf.reduce_sum(sum_log_x)
            neg_likelihood_loss += sum_cause_spec

        self.Loss1 = -neg_likelihood_loss

    def train(self, DATA, MASK, lr_train):
        (x, k, t, d) = DATA
        mask = MASK
        return self.sess.run([self.solver, self.loss_total],
                             feed_dict={self.x: x, self.k: k, self.t: t,
                                        self.d: d, self.mask: mask, self.lr_rate: lr_train})

    def predict(self, x_test, d_test):
        return self.sess.run(self.out,
                             feed_dict={self.x: x_test, self.d: d_test})


