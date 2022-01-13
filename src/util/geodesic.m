function D=geodesic(H, n_fcn, n_size, baseMetric)
%Cmopute the pairwise geodesic distances along the manifold between points
%
% D=geodesic(H, n_fcn, n_size) Computes the pairwise geodesic 
%   distances along the manifold between sample points. It uses
%   the Euclidean distance as the base metric.
%
% D=geodesic(H, n_fcn, n_size, baseMetric) Computes the pairwise
%   geodesic distances along the manifold between sample points.
%   It uses the indicated base metric.
%
% D=geodesic(H, n_fcn, n_size, D) Computes the pairwise geodesic
%   distances along the manifold between sample points. D is the
%   matrix of pairwise distance points in the ambient space (i.e.
%   not along the manifold), and can be computed externally using
%   any criteria.
%   
%
%
%% Algorithm
%
%This function uses Tenenbaum's algorithm for estimating the Geodesic
%distance between two points along a manifold. This involves
%basically three steps:
%
%   1.- Compute pairwise distances between all points, using
%       a given base metric (Euclidean by default). This step
%       is not necessary if base distances are already provided.
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
%
% n_fcn - Neighborhood function ('epsilon' or 'k'). See above
%
% n_size - Neighbourhood size (value for epsilon or k)
%
% baseMetric - Optional. Base metric. By default (and currently
%   the only one available) is Euclidean. Indicate the base metric
%   as a string:
%       'euclidean' - Euclidean metric.
%
% D - Optional. A (symmetric) matrix of pairwise base distances
%   in the ambient space.
% 
%% Output
%
% D - A (symmetric) matrix of pairwise geodesic distances along
%   the manifold.
%
%
%
% Copyright 2008-9
% @date: 4-Feb-2008
% @author Felipe Orihuela-Espina
% 
% See also pdist, ic_pdist, Floyd, pruneDistances
%


%   1.- Compute pairwise distances between all points
%%These two should actually produce (virtually) the same matrix
%%of distances (subject to small rounding errors)...
if ~exist('baseMetric','var')
    baseMetric='euclidean';
end

if ischar(baseMetric)
    %Currently only Eulidean is permitted
    switch lower(baseMetric)
        case 'euclidean' %Euclidean
            %D=L2_distance(H',H',1); %Isomap package (meant to be faster)
            D=squareform(pdist(H)); %MATLAB's
        otherwise %Default Euclidean
            error('Invalid base metric.');
    end
else %Matrix of base distances provided
    D=baseMetric;
end

%   2.- Prune non-neighbours distances according to
%       neighbourhood criterium
D=pruneDistances(D, n_fcn, n_size);

%   3.- Recompute shortest path using Floyd's algorithm (or
%       Dijkstra's if available).
D=Floyd(D);