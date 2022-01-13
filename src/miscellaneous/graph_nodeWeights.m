function [TW,IW,OW]=graph_nodeWeights(W)
%Graph vertexes weights, inweights and outweights
%
% [TW,IW,OW]=graph_nodeWeights(W) Graph vertexes weights,
%   inweights and outweights
%
%
%% Weights, Inweights and Outweights
%
%In a weighted graph, the degree of the node may not be a
%good measure of the node absolute importance within the
%network, as not all links will have the same importance.
%
% A weighted measure of the node's importance can be established
%(Felipe's dixit), by extrapolating the definition of the
%weight of a path.
%
% Formally, the weight of the path is the sum of the selected
%edges. Hence, the weight of a node, will be the sum of the
%nodes' links weights. Analogous definitions can be made for
%the node's in-weights and out-weights.
%
%
%
%% Functional interpretations of the weights
%
%Inweights and outweights have functional interpretations.
%
% The definition of the node's weight given does not
%give meaning to the weights themselves. If the weights represents
%a metric (zero being closer) the importance
%of the node will be indirectly proportional
%to its weight, i.e. the smaller the weight
%the higher the node's importance in the network. 
%
%A higher importance (may be expressed as a low weight) 
%indicates that a neural unit works tighter with other
%active units.
%
%
%% Remarks
%
% No assumptions are made with regard to whether the graph is directed
%or undirected. Self-connections are ignored.
%
% An assumption is however made in that no multiple edges are allowed
%between connections j and i (other than the bidirectional pair).
%
%% Parameters
%
% W - The weights matrix. An NxN binary matrix where
%       N is the number of nodes and w_ij is the weight
%       of the link joining nodes i and j. If a link is
%       not present, w_ij should be labelled NaN.
%
%% Output
%
%   +=========================================+
%   | IMPORTANT: Self-connections are counted |
%   | twice; once as inweight and one as      |
%   | outweight.                              |
%   +=========================================+
%
%   +=========================================+
%   | IMPORTANT: Please refer to section on   |
%   | functional interpretations on the       |
%   | weights for extra information on using  |
%   | metric weights.                         |
%   +=========================================+
%
%   +=========================================+
%   | Absent nodes (having all NaN links) will|
%   | will actually have weight 0.            |
%   +=========================================+
%
%
% TW - Vector of weight, where TD(i) is the weight of the i-th vertex.
%   Note that TD(i)=ID(i)+OD(i);
%
% IW - Vector of inweight, where ID(i) is the inweight of the i-th vertex.
%
% OW - Vector of outweights, where OD(i) is the outweight of the i-th vertex.
%
%
%
% Copyright 2010
% @date: 28-Jun-2010
% @author: Felipe Orihuela-Espina
% @modified: 28-Jun-2010
%
% See also seriesLGCMC0004, getConnectivity, toPajek,
%   graph_density, graph_numberOfEdges, graph_meanPathLength,
%   graph_clusteringCoefficient, graph_degrees.
%

[N,M]=size(W);
if (N~=M)
    error('Weights'' matrix W is expected to be square.');
end

%Ignore self-connections
W(eye(N)==1)=NaN;

IW=nansum(W,2); %Do not make it nansum!
OW=nansum(W,1)'; %Do not make it nansum!
TW=IW+OW;
