function [l]=graph_meanPathLength(D,flagWeighted)
%Graph mean path length
%
% [l]=graph_meanPathLength(A,0) Graph mean path length computed
%   from the adjacency matrix. Use this for unweighted graphs
%   (2nd parameter: flagWeighted = 0)
%
% [l]=graph_meanPathLength(D,1) Graph mean path length computed
%   from the shortest distances matrix. The shortest
%   distances matrix from any pairwise distance matrix can be
%   computed using Floyd(D). Use this for weighted graphs.
%   (2nd parameter: flagWeighted = 1)
%
%
%% Mean Path Length
%
% Source: [Sporns, O; 2002],[Wikipedia:Average path length]
%
% Paths are ordered sequences of distinct edges and vertices
%linking a source vertex j to a target vertex i. Distinctness
%means that no vertex or edge may be visited twice along the
%path.
%
%+ In an unweighted graph, the length of a path is defined
%as the number of distinct edges visited.
%
%The average path length in an unweighted graph is given by:
%
%         1
% l = --------- * sum_{i,j} d_ij
%      N*(N-1)
%
%   where N is the number of vertex in the graph, and d_ij is 0 if
%v_i = v_j, and d_ij is Inf/NaN if v_j cannot be reached from v_i.
%
%   * Note that this formulation is slightly
%   different from the one in Wikipedia, which
%   puts d_ij = 0 if v_j cannot be reached from
%   v_i.
%
%+ In an weighted graph, the length of a path is defined
%as the sum of the weigths of the distinct edges visited.
%
%The average path length in a weighted graph is given by:
%
%         1
% l = --------- * sum_{i,j} d_ij
%      N*(N-1)
%
%   where N is the number of vertex in the graph, and d_ij is
%the shortes path between nodes i and j (or Inf if they cannot
%be reached). Note the similarity with the unweighted formula.
%
%Average or Mean path length is a concept in network topology
%that is defined as the average length along the shortest
%paths for all possible pairs of network nodes. It is a measure
%of the efficiency of information or mass transport on a network.
%
%
%% Functional interpretations of the degrees
%
% Source: [Wikipedia:Average path length]
%
%Average path length is one of the three most robust measures
%of network topology, along with its clustering coefficient
%and its degree distribution. It should not be confused with
%the diameter of the network, which is defined as the maximal
%distance between any two nodes in the network.
%
%
%% Remarks
%
% No assumptions are made with regard to whether the graph is directed
%or undirected. Self-connections are ignored for computing
%the mean path length.
%
% An assumption is made in that no multiple edges are allowed
%between connections j and i (other than the bidirectional pair).
%
%% Parameters
%
% A - An adjacency matrix. An NxN binary matrix where:
%           a_ij=1 if there is an edge between nodes i (src) and j (dest)
%           a_ij=0 if there is not an edge between nodes i and j
%       where N is the number of nodes.
%       Use this for unweighted graphs.
% -- OR --
% D - Matrix of pairwise shortest distances. The shortest
%   distances matrix from any pairwise distance matrix can be
%   computed using Floyd(D). Unreachable/inexistent links
%   should be labelled as Inf.
%       Use this for weighted graphs.
%
%
% flagWeighted - Use 0 if you are providing the adjacency matrix
%   for an unweighted graph. Use 1 if you are providing the
%   shortest distances matrix for a weighted graph.
%
%% Output
%
% l - Graph mean path length.
%
%% References
%
% [Sporns, O; 2002] Sporns, Olaf (2002) "Graph theory methods
%for the analysis of neural connectivity patterns"
%
% [Wikipedia:Average path length]
% http://en.wikipedia.org/wiki/Average_path_length
%
%
% Copyright 2010
% @date: 22-Jun-2010
% @author: Felipe Orihuela-Espina
% @modified: 22-Jun-2010
%
% See also seriesLGCMC0004, getConnectivity, toPajek, Floyd,
%   graph_density, graph_numberOfEdges, graph_degrees,
%   graph_clusteringCoefficient,
%

if (flagWeighted)
    %D is a shortest distances matrix
    [N,M]=size(D);
    assert(N==M,'Shortest paths distance matrix D is expected to be square.');
    %Note that in the case of weighted graphs,
    %since I start from the shortest paths distances matrix,
    %no modification is required.
    
else
    %D is an adjacency matrix
    [N,M]=size(D);
    assert(N==M,'Adjacency matrix A is expected to be square.');
    idx = find(D~=0 & D~=1);
    if ~isempty(idx)
        error('Adjacency matrix A is expected to be binary.');
    end
    
    %I need to transform A into a kind of shortest path distance
    %matrix
    D(D==0)=Inf;
    D=Floyd(D);
    
end

%Exclude unreachable paths from computation
D(D==Inf)=NaN;
%Exclude self-connections
D(eye(N)==1)=NaN;

%Regardless of weighted or unweighted graphs,
%directed or undirected, and self-connections
%at this moment, the average path length is given by:
%
%         1
% l = --------- * sum_{i,j} d_ij
%      N*(N-1)
%
%   where N is the number of vertex in the graph.
l = (1/(N*(N-1))) * nansum(nansum(D));

