function n=getNDataSourceDefinitions(obj)
%EXPERIMENT/GETNDATASOURCEDEFINITIONS Gets the number of dataSource definitions
%
% n=getNDataSourceDefinitions(obj) Gets the number of dataSource
%	definitions defined in the experiment dataset.
%
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also getDataSourceDefinitionList
%

n=length(obj.dataSourceDefinitions);
