function c=getCluster(obj,id)
%ANALYSIS/GETCLUSTER Get the cluster identified by id
%
% c=getCluster(obj,id) gets the cluster identified by id or an empty
%   matrix if the cluster has not been defined.
%
% Copyright 2008
% @date: 26-May-2008
% @author Felipe Orihuela-Espina
%
% See also findCluster, getClusterList
%

i=findCluster(obj,id);
if (~isempty(i))
    c=obj.clusters{i};
else
    c=[];
end




end