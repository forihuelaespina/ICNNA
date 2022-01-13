function [TCC,CC]=graph_clusteringCoefficient(A,...
                                flagGraphDirected,flagSelfConnections)
%Graph clustering coefficient
%
% [TCC,CC]=graph_clusteringCoefficient(A) Graph clustering coefficient
%
% [TCC,CC]=graph_clusteringCoefficient(A,...
%               flagGraphDirected,flagSelfConnections)
%       Graph clustering coefficient
%
%
%% Clustering Coefficient
%
% Source: [Watts, D. J.; 1998], [Wikipedia:ClusteringCoefficient]
%
% The clustering coefficient is a measure of degree to
%which nodes in a graph tend to cluster together.
%The local clustering coefficient of a vertex in a graph
%quantifies how close its neighbors are to being a clique
%(complete graph). The local clustering coefficient CC(i)
%for a vertex i is given by the proportion of links between
%the vertices within its neighbourhood divided by the
%number of links that could possibly exist between them.
%
%Thus, the local clustering coefficient for directed graphs
%is given as:
%
% CC(i) = n_i / (N_i*(N_i-1))
%
% where N_i is the total number of nodes in the neighbourhood
%of vertex i, and n_i is the total number of existing links
%in that neighbourhood.
% Note that this is the density of the subgraph of the vertex
%neighbourhood.
%
%
%For undirected graphs, the local clustering coefficient
%can be defined as:
%
% CC(i) = 2*n_i / (N_i*(N_i-1))
%
%Finally, the clustering coefficient for the whole network
%is given as the average of the local clustering coefficients
%of all the vertices in the graph:
%
% TCC = 1/n * sum_i CC(i)
% 
%
%% Functional interpretations of the degrees
%
% Source: [Watts, D. J.; 1998], [Wikipedia:ClusteringCoefficient]
%
%A graph is considered small-world, if its average
%clustering coefficient TCC is significantly higher
%than a random graph constructed on the same vertex
%set, and if the graph has a short mean-shortest path length l.
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
% flagGraphDirected - Set to 1 if the graph is directed (default),
%       or set to 0 if the graph is undirected.
%
% flagSelfConnections - Set to 1 if the graph is permits
%       self-connections, or set to 0 if the graph does not
%       permit self-connections (default).
%
%% Output
%
% TCC - Graph average clustering coefficient.
%
% CC - Graph clustering coefficient for each node, so that CC(i)
%   is the clustering coefficient for vertex i-th
%
%% References
%
% [Watts, D. J.; 1998] Duncan J. Watts and Steven H. Strogatz (1998)
%   "Collective dynamics of ‘small-world’ networks" NATURE
%   Vol. 393:440-442 JUNE 1998
%
% [Wikipedia:ClusteringCoefficient]
% http://en.wikipedia.org/wiki/Clustering_coefficient
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
%   graph_density, graph_numberOfEdges, graph_degrees,
%   graph_meanPathLength,
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

for vv=1:N
    %Extract sub-graph corresponding to the vertex neighbourhood
    tmpA=extractNeighbourhoodSubgraph(A,vv);
    %Now the CC(i) is the density of this subgraph
    CC(vv)=graph_density(tmpA,flagGraphDirected,flagSelfConnections);
end
%For some reason is storing it as a row vector...
%so just put it as a column vector
CC=reshape(CC,numel(CC),1);

TCC=nanmean(CC);


end

%%AUXILIAR FUNCTION
function tmpA=extractNeighbourhoodSubgraph(A,i)
%Extract sub-graph corresponding to the i-th vertex neighbourhood
%
% A - An adjacency matrix
% i - Vertex index

%The neighbourhood of vertex i-th is the subgraph
%composed by those nodes (and their associated edges)
%that are directly reachable (one jump only) from vertex i.
efferentNeighbours = find(A(i,:)==1); %Incoming
afferentNeighbours = find(A(:,i)==1)'; %Outgoing
neighbours = unique([efferentNeighbours afferentNeighbours]);
%Exclude this node from the subgraph (in case self-connections exist)
neighbours(neighbours==i)=[];

tmpA = A(neighbours,neighbours);
end