function [n]=graph_getNConnectedComponents(A)
%Computes the number of connected components in a graph
%
%   [n]=graph_getNConnectedComponents(A) Computes the number of
%       connected components in a graph
%
%% REMARKS
% Uses matlab_bgl toolbox 4.0.1
%
%% Parameters
%
% A - An adjacency matrix. An NxN binary matrix where:
%           a_ij=1 if there is an edge between nodes i and j
%           a_ij=0 if there is not an edge between nodes i and j
%       where N is the number of nodes.
%
%% Output
%
% kd - Graph average connection density.
%
%% References
%
% [Hopcroft, J; 1973] Hopcroft, J and Tarjan, R (1973) "Efficient
%   algorithms for graph manipulation" Communications of the ACM
%   16(6):372-378
%
%
%
% Copyright 2011
% @date: 13-Sep-2011
% @author: Felipe Orihuela-Espina
% @modified: 13-Sep-2011
%
% See also: graph_degrees, graph_numberOfEdges, graph_meanPathLength,
%   graph_clusteringCoefficient,
%

n=max(components(sparse(A)));