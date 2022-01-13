function [TD,ID,OD]=graph_degrees(A)
%Graph vertexes degrees, indegress and outdegrees
%
% [TD,ID,OD]=graph_degrees(A) Graph vertexes degrees,
%   indegress and outdegrees
%
%
%% Degrees, Indegrees and Outdegrees
%
% Source: [Sporns, O; 2002]
%
% For a given vertex v, the indegree id(v) and outdegree od(v)
%of the vertex is defined as the number of incoming (afferent)
%or outgoing (efferent) edges, respectively. The degree of a vertex
%is the sum of its indegree id(v) and outdegree od(v).
%
%In dividual vertices may show inbalances in their indegree
%and outdegree. These imbalances are recorded in the joint degree
%distribution matrix of the graph J(G), whose entries J_tu
%corresponds to the number of vertices with an indegree id(v)=u and
%outdegree od(v)=t. Entries of J_tu far away from the main diagonal
%correspond to vertices with a high imbalance in incoming and
%outgoing degrees. Vertices above the main diagonal have an
%excess of outgoing edges, while vertices below the main diagonal
%have an excess of incoming edges.
%
%% Functional interpretations of the degrees
%
% Source: [Sporns, O; 2002]
%
%Indegrees and outdegrees have functional interpretations.
%A high indegree indicates that a neural unit is influenced
%by a large number of other units, while a high outdegree
%indicates a high potential of functional targets.
%
% For most neural structures, indegrees and outdegrees of
%neural units are subject to constraints due to growth,
%tissue volume and metabolic limitations.
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
% TD - Vector of degrees, where TD(i) is the degree of the i-th vertex.
%   Note that TD(i)=ID(i)+OD(i);
%
% ID - Vector of indegrees, where ID(i) is the indegree of the i-th vertex.
%
% OD - Vector of outdegrees, where OD(i) is the outdegree of the i-th vertex.
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
% @modified: 28-Jun-2010
%
% See also seriesLGCMC0004, getConnectivity, toPajek,
%   graph_density, graph_numberOfEdges, graph_meanPathLength,
%   graph_clusteringCoefficient, graph_nodeWeights
%

[N,M]=size(A);
assert(N==M,'Adjacency matrix A is expected to be square.');
idx = find(A~=0 & A~=1);
if ~isempty(idx)
    error('Adjacency matrix A is expected to be binary.');
end

ID=nansum(A,2);
OD=nansum(A,1)';
TD=ID+OD;
