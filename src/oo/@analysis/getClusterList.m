function idList=getClusterList(obj)
%ANALYSIS/GETCLUSTERLIST Get a list of IDs of defined clusters
%
% idList=getClusterList(obj) Get a list of IDs of defined clusters or an
%     empty list if no clusters have been defined.
%
% It is possible to navigate through the clusters using the idList.
%
% Note that the list include all declared clusters regardless of their
%visibility status.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also findCluster, getCluster
%



%% Log
%
% File created: 26-May-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 7-Jun-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to use get/set methods for struct like access.
%



nElements=obj.nClusters;
idList=zeros(1,nElements);
for ii=1:nElements
    tmp = obj.clusters{ii};
    idList(ii) = tmp.id;
end


end