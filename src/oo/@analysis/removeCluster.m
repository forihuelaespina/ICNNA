function obj=removeCluster(obj,id)
% ANALYSIS/REMOVECLSUTER Removes a cluster from the analysis
%
% obj=removeCluster(obj,id) Removes clusters whose ID==id from the
%   analysis. If the clusters does not exist, nothing is done.
%
% Copyright 2008
% @date: 26-May-2008
% @author Felipe Orihuela-Espina
%
% See also addCluster, setCluster
%

idx=findCluster(obj,id);
if (~isempty(idx))
    obj.clusters(idx)=[];
end
assertInvariants(obj);