import torch
import torch.nn as nn
import numpy as np


def create_representation(inputdim, layers, activation):

    if activation == 'ReLU6':
        act = nn.ReLU6()
    elif activation == 'ReLU':
        act = nn.ReLU()
    elif activation == 'SeLU':
        act = nn.SELU()
    else:
        act = nn.ReLU()

    modules = []
    prevdim = inputdim

    for hidden in layers:
        modules.append(nn.Linear(prevdim, hidden, bias=False))
        modules.append(act)
        prevdim = hidden

    return nn.Sequential(*modules)


class DeepSurvivalMachinesTorch(nn.Module):
    def _init_dsm_layers(self, lastdim):

        self.act = nn.SELU()
        # beta^r_k, eta^r_k
        self.shape = nn.ParameterDict({str(r + 1): nn.Parameter(-torch.ones(self.k, self.risks))
                                       for r in range(self.risks)})
        self.scale = nn.ParameterDict({str(r + 1): nn.Parameter(-torch.ones(self.k, self.risks))
                                       for r in range(self.risks)})

        self.gate = nn.ModuleDict({str(r + 1): nn.Sequential(
            nn.Linear(lastdim, self.k, bias=False)
        ) for r in range(self.risks)})

        self.scaleg = nn.ModuleDict({str(r + 1): nn.Sequential(
            nn.Linear(lastdim, self.k, bias=True)
        ) for r in range(self.risks)})

        self.shapeg = nn.ModuleDict({str(r + 1): nn.Sequential(
            nn.Linear(lastdim, self.k, bias=True)
        ) for r in range(self.risks)})

    def __init__(self, inputdim, k, layers=None, dist='Weibull',
                 temp=1000., discount=1.0, optimizer='Adam',
                 risks=1, event_prob=None):
        super(DeepSurvivalMachinesTorch, self).__init__()

        self.k = k
        self.dist = dist
        self.temp = float(temp)
        self.discount = float(discount)
        self.optimizer = optimizer
        self.risks = risks
        if event_prob is None:
            self.event_prob = torch.ones(self.risks)
        self.event_prob = event_prob

        if layers is None:
            layers = []
        self.layers = layers

        if len(layers) == 0:
            lastdim = inputdim
        else:
            lastdim = layers[-1]

        self._init_dsm_layers(lastdim)
        self.embedding = create_representation(inputdim, layers, 'ReLU6')

    def forward(self, x, diags=None, risk=1):
        """
            The forward function that is called when data is passed through DSM.
            :param x: a torch.tensor of the input features
            :param risk: competing risk index, default 1
        """
        xrep = self.embedding(x)
        dim = x.shape[0]
        if diags is None:
            diags = torch.ones(dim, self.risks, dtype=torch.double)
        # beta_k = \sum_(r in R_i) beta^r_k + act(...)
        shape_risk = torch.zeros(self.k, self.risks, dtype=torch.double)
        scale_risk = torch.zeros(self.k, self.risks, dtype=torch.double)
        for ev in range(self.risks):
            shape_risk[:, ev] = self.shape[str(ev + 1)][:, risk - 1]
            scale_risk[:, ev] = self.scale[str(ev + 1)][:, risk - 1]
        diags = diags.repeat(1, self.k).reshape(dim, self.k, self.risks)
        shape_k = shape_risk.repeat(dim, 1, 1)
        scale_k = scale_risk.repeat(dim, 1, 1)
        shape = torch.sum(diags * shape_k, dim=2)
        scale = torch.sum(diags * scale_k, dim=2)

        return (self.act(self.shapeg[str(risk)](xrep)) + shape,
                self.act(self.scaleg[str(risk)](xrep)) + scale,
                self.gate[str(risk)](xrep) / self.temp)

    def get_shape_scale(self, diags, risk=1):
        dim = diags.shape[0]

        shape_risk = torch.zeros(self.k, self.risks, dtype=torch.double)
        scale_risk = torch.zeros(self.k, self.risks, dtype=torch.double)

        for ev in range(self.risks):
            shape_risk[:, ev] = self.shape[str(ev + 1)][:, risk - 1]
            scale_risk[:, ev] = self.scale[str(ev + 1)][:, risk - 1]

        diags = diags.repeat(1, self.k).reshape(dim, self.k, self.risks)

        shape_k = shape_risk.repeat(dim, 1, 1)
        scale_k = scale_risk.repeat(dim, 1, 1)

        shape = torch.sum(diags * shape_k, dim=2)
        scale = torch.sum(diags * scale_k, dim=2)
        return shape, scale