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
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getNDataSourceDefinitions, getDataSourceDefinition
%


%% Log
%
% File created: 21-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%



nElements=obj.nDataSourceDefinitions;
idList=zeros(1,nElements);
for ii=1:nElements
    tmp = obj.dataSourceDefinitions{ii};
    idList(ii)=tmp.id;
end
idList=sort(idList);

end