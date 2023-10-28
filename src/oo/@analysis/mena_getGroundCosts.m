function DD=mena_getGroundCosts(D,cluster1Idx,cluster2Idx)
%Extract pairwise distances of interest between two clusters
%
% DD=mena_getGroundCosts(D,cluster1Idx,cluster2Idx)
%
%Extract pairwise distances of interest between two clusters from
%a full matrix of pairwise distances between all points in the
%manifold
%
%This function is a simple "filter" over the complete matrix
%of pairwise distances D. This function does not know anything
%about how D has been obtained. This means not only that it is
%unaware of the underlying metric, but also whether the distances
%were calculated on the Feature Space or the Projection Space.
%
%
%% Parameters:
%
% D - A square matrix of distances between all points in the manifold.
%   This can be calculated using mena_metricv2
%
% cluster1Idx and cluster2Idx - Indexes to the points of both
%   clusters
%
%% Output
%
% A subset of D containing pairwise distances
%but only between the points in the clusters. This output
%should be directly usable as input to the metric of cluster
%similarity (e.g. EMD)
%
%           | YY1 | YY2 | ... | YYn |
%      -----+-----+-----+-----+-----+
%       XX1 | d11 | d12 | ... | d1n |       XXi: i-th point in cluster 1
%      -----+-----+-----+-----+-----+       YYj: j-th point in cluster 2
%       XX2 | d21 | d12 | ... | d2n |
%      -----+-----+-----+-----+-----+
%       ... | ... | ... | ... | ... |
%      -----+-----+-----+-----+-----+
%       XXm | dm1 | dm2 | ... | dmn |
%
%Note that this matrix may not be square as the number of points 
%in set or cluster 1 might not be the same number of points in
%set or cluster 2.
%
%
%% References:
%
% [Rubner, 1998] Rubner, Yossi; Tomasi, Carlo and Guibas, Leonidas J.
%   "A Metric for Distributions with Applications to Image Databases"
%   Sixth International Conference on Computer Vision (1998). pgs 59-66
%   4-7 Jan Bombay India, DOI: 10.1109/ICCV.1998.710701
%
% Copyright 2008-23
% Author: Felipe Orihuela-Espina
%
%
% See also mena_metricv2, emd_calculateCosts




%% Log
%
% File created: 4-Feb-2008
% File last modified (before creation of this log): N/A. This method had
%   probably been updated at some point but I failed to keep track of
%   those changes.
%
% 11-Jun-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Method moved from folder private/ to main class folder and explictly
%   declared as static in the class definition.
%



DD=D(cluster1Idx,cluster2Idx);



end