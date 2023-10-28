function obj=clearClusters(obj)
% ANALYSIS/CLEARCLUSTERS Removes all existing clusters
%
% obj=clearClusters(obj) Removes all existing clusters from the
%   analysis.
%
% Copyright 2008
% @date: 20-Jun-2008
% @author Felipe Orihuela-Espina
%
% See also addCluster, setCluster, removeCluster
%

obj.clusters=cell(1,0);
assertInvariants(obj);


end