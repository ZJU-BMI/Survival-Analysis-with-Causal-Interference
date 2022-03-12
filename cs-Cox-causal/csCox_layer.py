import tensorflow as tf
from tensorflow.contrib.layers import fully_connected as fc_net


def csCox_layer(inputs, num_outputs, w_init=None, w_reg=None):

    if w_init is None:
        # Xavier initialization
        w_init = tf.truncated_normal_initializer(stddev=0.01)

    beta_x = fc_net(inputs, num_outputs, activation_fn=None, weights_initializer=w_init,
                    weights_regularizer=w_reg, biases_initializer=None)

    return beta_x

