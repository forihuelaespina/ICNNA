function n=getNClusters(obj)
%ANALYSIS/GETNCLUSTERS Gets the number of clusters defined in the analysis
%
% n=getNClusters(obj) Gets the number of clusters defined in the analysis
%
%
% Copyright 2008
% @date: 26-May-2008
% @author Felipe Orihuela-Espina
%
% See also findCluster, getClusterList
%

n=length(obj.clusters);
