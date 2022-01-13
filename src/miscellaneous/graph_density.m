function kd=graph_density(A,flagGraphDirected,flagSelfConnections)
%Graph average connection density
%
% kd=graph_density(A) Graph average connection density assuming
%   a directed grpah with no self connections.
%
% kd=graph_density(A,flagGraphDirected,flagSelfConnections) Graph
%   average connection density for directed/undirected graphs
%   with or without self-connections.
%
%
%% Average connection density
%
% Source: [Sporns, O; 2002]
%
% The average connection density kd of an adjacency matrix A(G)
%is the number of all its non-zero entries, divided by the maximal
%number of connection, i.e.
%
%   + (n^2-n)/2 for a undirected graph, excluding self-connections
%   + (n^2)/2 for a undirected graph, including self-connections
%   + (n^2-n) for a directed graph, excluding self-connections
%   + (n^2) for a directed graph, including self-connections
%
%The average connection density kd is bounded: 0<= kd <= 1
%
%The sparser the graph, the lower its kd.
%
% See also graph_numberOfEdges
%
%% Remarks
%
% No assumptions are made with regard to whether the graph is directed
%or undirected, and whether there are self connections. Please use
%the flags provided.
%
% An assumption is however made in that no multiple edges are allowed
%between connections j and i (other than the bidirectional pair).
%
%% Parameters
%
% A - An adjacency matrix. An NxN binary matrix where:
%           a_ij=1 if there is an edge between nodes i and j
%           a_ij=0 if there is not an edge between nodes i and j
%       where N is the number of nodes.
%
% flagGraphDirected - Set to 1 if the graph is directed (default),
%       or set to 0 if the graph is undirected.
%
% flagSelfConnections - Set to 1 if the graph is permits
%       self-connections, or set to 0 if the graph does not
%       permit self-connections (default).
%
%
%% Output
%
% kd - Graph average connection density.
%
%   +===========================================+
%   | IMPORTANT: The density of an empty graph  |
%   | is not defined. Thus this function will   |
%   | return NaN for empty graphs.              |
%   +===========================================+
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
% @modified: 23-Jun-2010
%
% See also seriesLGCMC0004, getConnectivity, toPajek,
%   graph_degrees, graph_numberOfEdges, graph_meanPathLength,
%   graph_clusteringCoefficient,
%

if ~exist('flagGraphDirected','var')
    flagGraphDirected = 1; %Directed graph by default
end
if ~exist('flagSelfConnections','var')
    flagSelfConnections = 0; %Self-connections not allowed by default
end

[N,M]=size(A);
assert(N==M,'Adjacency matrix A is expected to be square.');
idx = find(A~=0 & A~=1);
if ~isempty(idx)
    error('Adjacency matrix A is expected to be binary.');
end

denom = 1;
if (flagGraphDirected==0 && flagSelfConnections==0)
    denom = (N^2-N)/2;
elseif (flagGraphDirected==0 && flagSelfConnections==1)
    denom = (N^2)/2;
elseif (flagGraphDirected==1 && flagSelfConnections==0)
    denom = (N^2-N);
else %if (flagGraphDirected==1 && flagSelfConnections==1)
    denom = N^2;
end

kd=sum(sum(A))/denom;
%This formula below will naturally yield NaN when the graph is empty.
