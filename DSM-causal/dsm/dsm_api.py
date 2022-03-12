from sklearn.model_selection import train_test_split

from dsm.dsm_torch import DeepSurvivalMachinesTorch

import dsm.losses as losses

from dsm.utilities import train_dsm
from dsm.utilities import _reshape_tensor_with_nans

import torch
import numpy as np


class DSMBase:
    """Base Class for all DSM models"""

    def __init__(self, k=3, layers=None, distribution="Weibull",
                 temp=1000., discount=1.0):
        self.k = k
        self.layers = layers
        self.dist = distribution
        self.temp = temp
        self.discount = discount
        self.fitted = False

    def _gen_torch_model(self, inputdim, optimizer, risks):
        """Helper function to return a torch model."""
        return DeepSurvivalMachinesTorch(inputdim,
                                         k=self.k,
                                         layers=self.layers,
                                         dist=self.dist,
                                         temp=self.temp,
                                         discount=self.discount,
                                         optimizer=optimizer,
                                         risks=risks)

    def fit(self, x, t, e, d, event_prob=None, vsize=0.15, num_risks=1, val_data=None,
            iters=1000, learning_rate=1e-4, batch_size=100,
            elbo=True, optimizer="Adam", random_state=1234):

        """This method is used to train an instance of the DSM model.

            Parameters
            ----------
            x: np.ndarray
                A numpy array of the input features, \( x \).
            t: np.ndarray
                A numpy array of the event/censoring times, \( t \).
            e: np.ndarray
                A numpy array of the event/censoring indicators, \( \delta \).
                \( \delta = 1 \) means the event took place.
            vsize: float
                Amount of data to set aside as the validation set.
            val_data: tuple
                A tuple of the validation dataset. If passed vsize is ignored.
            iters: int
                The maximum number of training iterations on the training dataset.
            learning_rate: float
                The learning rate for the `Adam` optimizer.
            batch_size: int
                learning is performed on mini-batches of input data. this parameter
                specifies the size of each mini-batch.
            elbo: bool
                Whether to use the Evidence Lower Bound for optimization.
                Default is True.
            optimizer: str
                The choice of the gradient based optimization method. One of
                'Adam', 'RMSProp' or 'SGD'.
            random_state: float
                random seed that determines how the validation set is chosen.
        """

        processed_data = self._preprocess_training_data(x, t, e, d,
                                                        vsize, val_data,
                                                        random_state)
        x_train, t_train, e_train, d_train, x_val, t_val, e_val, d_val = processed_data
        event_prob = torch.from_numpy(np.array(event_prob))
        # Todo: Change this somehow. The base design shouldn't depend on child
        # if type(self).__name__ in ["DeepConvolutionalSurvivalMachines",
        #                            "DeepCNNRNNSurvivalMachines"]:
        #     inputdim = tuple(x_train.shape)[-2:]
        # else:
        inputdim = x_train.shape[-1]

        num_risk = num_risks
        model = self._gen_torch_model(inputdim, optimizer, risks=num_risk)
        model, _ = train_dsm(model,
                             x_train, t_train, e_train, d_train,
                             x_val, t_val, e_val, d_val, event_prob=event_prob,
                             n_iter=iters,
                             lr=learning_rate,
                             elbo=elbo,
                             bs=batch_size)

        self.torch_model = model.eval()
        self.fitted = True
        # print(model.shape[str(1)])
        return self

    def compute_nll(self, x, t, e, d):
        """
        This function computes the negative log likelihood of the given data.
        In case of competing risks, the negative log likelihoods are summed over
        the different events' type.

        Parameters
        ----------
        x: np.ndarray
            A numpy array of the input features, \( x \).
        t: np.ndarray
            A numpy array of the event/censoring times, \( t \).
        e: np.ndarray
            A numpy array of the event/censoring indicators, \( \delta \).
            \( \delta = r \) means the event r took place.

        Returns:
          float: Negative log likelihood.
        """
        if not self.fitted:
            raise Exception("The model has not been fitted yet. Please fit the " +
                            "model using the `fit` method on some training data " +
                            "before calling `_eval_nll`.")
        processed_data = self._preprocess_training_data(x, t, e, d, 0, None, 0)
        _, _, _, _, x_val, t_val, e_val, d_val = processed_data
        loss = 0
        for r in range(self.torch_model.risks):
            loss += float(losses.conditional_loss(self.torch_model,
                                                  x_val, t_val, e_val, d_val, elbo=False,
                                                  risk=r + 1).detach().numpy())
        return loss

    def _preprocess_test_data(self, x):
        return torch.from_numpy(x)

    def _preprocess_training_data(self, x, t, e, d, vsize, val_data, random_state):

        x_train, x_val, t_train, \
        t_val, e_train, e_val, d_train, d_val = train_test_split(x, t, e, d,
                                                        test_size=vsize, random_state=random_state)

        x_train = torch.from_numpy(x_train).double()
        t_train = torch.from_numpy(t_train).double()
        e_train = torch.from_numpy(e_train).double()
        d_train = torch.from_numpy(d_train).double()

        x_val = torch.from_numpy(x_val).double()
        t_val = torch.from_numpy(t_val).double()
        e_val = torch.from_numpy(e_val).double()
        d_val = torch.from_numpy(d_val).double()

        return x_train, t_train, e_train, d_train, x_val, t_val, e_val, d_val

    def predict_mean(self, x, d, risk=1):
        """Returns the mean Time-to-Event \( t \)
        Parameters
        ----------
        x: np.ndarray
            A numpy array of the input features, \( x \).
        Returns:
          np.array: numpy array of the mean time to event.
        """

        if self.fitted:
            x = self._preprocess_test_data(x)
            scores = losses.predict_mean(self.torch_model, x, d, risk=risk)
            return scores
        else:
            raise Exception("The model has not been fitted yet. Please fit the " +
                            "model using the `fit` method on some training data " +
                            "before calling `predict_mean`.")

    def predict_risk(self, x, d, eval_times, risk=1):
        """Returns the estimated risk of an event occuring before time \( t \)
        \( \widehat{\mathbb{P}}(T\leq t|X) \) for some input data \( x \).
        Parameters
        ----------
        x: np.ndarray
            A numpy array of the input features, \( x \).
        t: list or float
            a list or float of the times at which survival probability is
            to be computed
        Returns:
          np.array: numpy array of the risks at each time in t.

        """

        if self.fitted:
            return 1 - self.predict_survival(x, d, eval_times, risk=risk)
        else:
            raise Exception("The model has not been fitted yet. Please fit the " +
                            "model using the `fit` method on some training data " +
                            "before calling `predict_risk`.")

    def predict_survival(self, x,  d, eval_times, risk=1):
        r"""Returns the estimated survival probability at time \( t \),
      \( \widehat{\mathbb{P}}(T > t|X) \) for some input data \( x \).

    Parameters
    ----------
    x: np.ndarray
        A numpy array of the input features, \( x \).
    t: list or float
        a list or float of the times at which survival probability is
        to be computed
    Returns:
      np.array: numpy array of the survival probabilites at each time in t.
    """
        x = self._preprocess_test_data(x)
        d = self._preprocess_test_data(d)
        x = x.double()
        d = d.double()
        if not isinstance(eval_times, list):
            eval_times = [eval_times]
        if self.fitted:
            scores = losses.predict_cdf(self.torch_model, x, d, eval_times, risk=risk)
            return np.exp(np.array(scores)).T
        else:
            raise Exception("The model has not been fitted yet. Please fit the " +
                            "model using the `fit` method on some training data " +
                            "before calling `predict_survival`.")

    def predict_pdf(self, x, t, d, risk=1):
        """Returns the estimated pdf at time \( t \),
        \( \widehat{\mathbb{P}}(T = t|X) \) for some input data \( x \).
        Parameters
        ----------
        x: np.ndarray
            A numpy array of the input features, \( x \).
        t: list or float
            a list or float of the times at which pdf is
            to be computed
        Returns:
          np.array: numpy array of the estimated pdf at each time in t.
        """
        x = self._preprocess_test_data(x)
        if not isinstance(t, list):
            t = [t]
        if self.fitted:
            scores = losses.predict_pdf(self.torch_model, x, t, d, risk=risk)
            return np.exp(np.array(scores)).T
        else:
            raise Exception("The model has not been fitted yet. Please fit the " +
                            "model using the `fit` method on some training data " +
                            "before calling `predict_survival`.")


class DeepSurvivalMachines(DSMBase):
    """A Deep Survival Machines model.

      This is the main interface to a Deep Survival Machines model.
      A model is instantiated with approporiate set of hyperparameters and
      fit on numpy arrays consisting of the features, event/censoring times
      and the event/censoring indicators.
      Parameters
      ----------
      k: int
          The number of underlying parametric distributions.
      layers: list
          A list of integers consisting of the number of neurons in each
          hidden layer.
      distribution: str
          Choice of the underlying survival distributions.
          One of 'Weibull', 'LogNormal'.
          Default is 'Weibull'.
      temp: float
          The logits for the gate are rescaled with this value.
          Default is 1000.
      discount: float
          a float in [0,1] that determines how to discount the tail bias
          from the uncensored instances.
          Default is 1.
      """

    def __call__(self):
        if self.fitted:
            print("A fitted instance of the Deep Survival Machines model")
        else:
            print("An unfitted instance of the Deep Survival Machines model")

        print("Number of underlying distributions (k):", self.k)
        print("Hidden Layers:", self.layers)
        print("Distribution Choice:", self.dist)
