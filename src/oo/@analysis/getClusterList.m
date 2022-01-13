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
% Copyright 2008
% @date: 26-May-2008
% @author Felipe Orihuela-Espina
%
% See also findCluster, getCluster
%

nElements=getNClusters(obj);
idList=zeros(1,nElements);
for ii=1:nElements
    idList(ii)=get(obj.clusters{ii},'ID');
end