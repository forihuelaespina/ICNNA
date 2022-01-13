function [Mall,Min,Mout]=graph_connectivityMatchingIndex(A)
%Graph connectivity matchnig index
%
% [Mall,Min,Mout]=graph_connectivityMatchingIndex(A) Graph
%   connectivity matching index
%
%% Connectivity Matching Index
%
% Source: [Sporns, O; 2002]
%
% The connectivty matching index m_ij between two vertices
%i and j (i~=j) can be defined as the amount of overlap in
%their connection patterns. All entries m_ij form the
%connectivity matching matrix M(G). It is possible to
%distinguish between Min(G), Mout(G) and Mall(G), for
%afferent, efferent and all connections respectively.
%
%
%
%
%% Functional interpretations of the degrees
%
% Source: [Sporns, O; 2002]
%
%This measure provides an indication of the extent to which the
%connectivity patterns (afferent, efferent, both) of two neuronal
%units conincide. High m_ij indicates that both units maintain
%similar anatomical and functional connections with other units
%within the system. Strong overlap in the structural relations
%may be predictive of an overall similarity in their functional
%contributions.
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
%   +=========================================+
%   | IMPORTANT: Self-connections are counted |
%   | twice; once as indegree and one as      |
%   | outdegree.                              |
%   +=========================================+
%
% Mall - Connectivity matching matrix. m_ij is the connectivity
%   matching index between vertexes i and j.
%
% Min - Afferent connectivity matching matrix
%
% Mout - Efferent connectivity matching matrix
%
%% References
%
% [Sporns, O; 2002] Sporns, Olaf (2002) "Graph theory methods
%for the analysis of neural connectivity patterns"
%
%
%
% Copyright 2010
% @date: 22-Jun-2010
% @author: Felipe Orihuela-Espina
% @modified: 22-Jun-2010
%
% See also seriesLGCMC0004, getConnectivity, toPajek,
%   graph_density, graph_degrees, graph_meanPathLength
%   graph_clusteringCoefficient,
%

[N,M]=size(A);
assert(N==M,'Adjacency matrix A is expected to be square.');
idx = find(A~=0 & A~=1);
if ~isempty(idx)
    error('Adjacency matrix A is expected to be binary.');
end

disp('Connectivity Matching Index not yet available');
%See [Sporns, O; 2002, pg. 173]