import tensorflow as tf
from tensorflow.keras import layers


class FineGrayLayer(tf.keras.Model):
    def __init__(self, output_dim, num_features):
        super(FineGrayLayer, self).__init__()
        self.output_dim = output_dim
        self.num_features = num_features
        self.beta = layers.Dense(units=output_dim, input_shape=(num_features, ),
                                 use_bias=False)

    def call(self, inputs, training=None, mask=None):
        y = self.beta(inputs)
        return y
