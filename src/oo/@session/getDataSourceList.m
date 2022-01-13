function idList=getDataSourceList(obj)
%SESSION/GETDATASOURCELIST Get a list of IDs of defined dataSources
%
% idList=getDataSourceList(obj) Get a list of IDs of defined 
%     dataSources or an empty list if no dataSources have been defined.
%
% It is possible to navigate through the dataSources using the idList
%
% Copyright 2008
% @date: 25-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also getNDataSources, getDataSource
%

nElements=getNDataSources(obj);
idList=zeros(1,nElements);
for ii=1:nElements
    idList(ii)=get(obj.sources{ii},'ID');
end
idList=sort(idList);