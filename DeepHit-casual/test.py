import tensorflow as tf
import numpy as np


# 2 * 3 * 5
a = tf.constant([[1, 0, 1], [1, 1, 0]])
b = tf.constant(np.arange(30).reshape([2, 3, 5]))

diag = tf.reshape(tf.tile(tf.reshape(a, [-1, 1]), [1, 5]), [2, 3, 5])

with tf.Session() as sess:
    print(sess.run(b))
    print(sess.run(diag))
