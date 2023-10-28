function D=mena_geodesic(H, n_fcn, n_size)
%DEPRECATED. Pairwise geodesic distances between points
%
% D=mena_geodesic(H, n_fcn, n_size))
%
%Pairwise geodesic distances between points, based on
%Tenenbaum's algorithm for calculating the Geodesic
%distance between two points along a manifold. This involves
%basically three steps:
%
%   1.- Compute pairwise Euclidean distances between all points
%   2.- Prune non-neighbours distances according to
%       neighbourhood criterium
%   3.- Recompute shortest path using Floyd's algorithm [Floyd, 1962].
%
%There are two ways to indicate a neighbourhood [Belkin, 2003],
%[Tenenbaum, 2000]:
%
%   (a) Epsilon-neighbourhoods: Nodes are neighbours if the distance
%           between them is smaller than epsilon
%   (b) keep k nearest neighbours.
%
%
%% References
%
%  J. B. Tenenbaum, V. de Silva, J. C. Langford (2000).  A global
%  geometric framework for nonlinear dimensionality reduction.  
%  Science 290 (5500): 2319-2323, 22 December 2000.
%
%  M. Belkin and P. Niyogi (2003). Laplacian Eigenmaps for
%   Dimensionality Reduction and Data Representation.
%   Neural Computation 15, 1373–1396
%
%  R. W. Floyd (1962). ALGORITHM 97 SHORTEST PATH.
%  Communications ef the ACM , pg 345
%
%% Parameters
%
% H - A MxN feature space matrix. M is the number of patterns and
%   N is the number of features.
% n_fcn - neighborhood function ('epsilon' or 'k') 
% n_size - neighborhood size (value for epsilon or k) 
% 
%% Output
%
% D - A (symmetric) pairwise geodesic distance's matrix
%
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
% 
% See also analysis, run, getFeatureSpace, mena_metric, ic_pdist
%   geodesic, Floyd, pruneDistances 
%




%% Log
%
% File created: 4-Feb-2008
% File last modified (before creation of this log): N/A. This method had
%   probably been updated at some point (because it was already DEPRECATED,
%   but I failed to keep track of those changes.
%
% 11-Jun-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Although the method was deprecated already I have now added a
%   warning message.
%   + Method moved from folder private/ to main class folder and explictly
%   declared as static in the class definition.
%


warning('ICNNA:analysis:mena_geodesic:Deprecated','DEPRECATED. Use geodesic instead.'); 

D=geodesic(H,n_fcn, n_size);

% %   1.- Compute pairwise distances between all points
% %%These two should actually produce (virtually) the same matrix
% %%of distances (subject to small rounding errors)...
% %D=L2_distance(H',H',1); %Isomap package (meant to be faster)
% D=squareform(pdist(H)); %MATLAB's
% 
% %   2.- Prune non-neighbours distances according to
% %       neighbourhood criterium
% D=pruneDistances(D, n_fcn, n_size);
% 
% %   3.- Recompute shortest path using Floyd's algorithm (or
% %       Dijkstra's if available).
% D=Floyd(D);



end