function idList=getDataSourceDefinitionList(obj)
%EXPERIMENT/GETDATASOURCEDEFINITIONLIST Get a list of IDs of defined dataSource definitions
%
% idList=getDataSourceDefinitionList(obj) Get a list of IDs of
%     defined dataSource definitions or an
%     empty list if no dataSourceDefinitions have been defined.
%
% It is possible to navigate through the dataSource definitions
%using the idList
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also getNDataSourceDefinitions, getDataSourceDefinition
%

nElements=getNDataSourceDefinitions(obj);
idList=zeros(1,nElements);
for ii=1:nElements
    idList(ii)=get(obj.dataSourceDefinitions{ii},'ID');
end
idList=sort(idList);