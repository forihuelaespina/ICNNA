function [N]=graph_numberOfEdges(A)
%Graph number of edges
%
% [N]=graph_numberOfEdges(A) Graph number of edges
%
%
%% Number of edges
%
% The (total) number of edges is the absolute count of links
%existing in the graph.
%
% Please see also density.
%
%% Remarks
%
% No assumptions are made with regard to whether the graph is directed
%or undirected, and whether there are self connections.
%
% An assumption is however made in that no multiple edges are allowed
%between connections j and i (other than the bidirectional pair).
%
%% Parameters
%
% A - An adjacency matrix. An NxN binary matrix where:
%           a_ij=1 if there is an edge between nodes i (src) and j (dest)
%           a_ij=0 if there is not an edge between nodes i and j
%       where N is the number of nodes.
%
%% Output
%
% N - Graph absolute total number of edges
%
%
%
% Copyright 2010
% @date: 22-Jun-2010
% @author: Felipe Orihuela-Espina
% @modified: 22-Jun-2010
%
% See also seriesLGCMC0004, getConnectivity, toPajek,
%   graph_density, graph_degrees, graph_meanPathLength,
%   graph_clusteringCoefficient,
%

[N,M]=size(A);
assert(N==M,'Adjacency matrix A is expected to be square.');
idx = find(A~=0 & A~=1);
if ~isempty(idx)
    error('Adjacency matrix A is expected to be binary.');
end

N=nansum(nansum(A));
