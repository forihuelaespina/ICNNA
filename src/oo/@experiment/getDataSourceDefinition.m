function s=getDataSourceDefinition(obj,id)
%EXPERIMENT/GETDATASOURCEDEFINITION Get the indicated dataSource definition
%
% s=getDataSourceDefinition(obj,id) gets the dataSource definition
%	identified by id or an empty matrix if the dataSource
%	definition has not been defined.
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also getNDataSourceDefinitions, getDataSourceDefinitionList
%

i=findDataSourceDefinition(obj,id);
if (~isempty(i))
    s=obj.dataSourceDefinitions{i};
else
    s=[];
end
