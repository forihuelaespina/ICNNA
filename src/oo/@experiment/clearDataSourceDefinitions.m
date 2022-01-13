function obj=clearDataSourceDefinitions(obj)
% EXPERIMENT/CLEARDATASOURCEDEFINITIONS Removes all existing data source definitions
%
% obj=clearDataSourceDefinitions(obj) Removes all existing data source
%   definitions from the dataset.
%
%   +==================================================+
%   | WARNING! All sessionDefinitions with dataSources |
%   | defined will also be removed! All subjects with  |
%   | affected sessions will be also removed.          |
%   +==================================================+
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also addDataSourceDefinition, setDataSourceDefinition,
%   removeDataSourceDefinition
%

obj.dataSourceDefinitions=cell(1,0);
%Remove affected sessionDefinitions
nElements=length(obj.sessionDefinitions);
for ii=nElements:-1:1
    if (getNSessions(obj.sessionDefinitions{ii})>0)
        removeSessionDefinition(obj,get(obj.sessionDefinitions{ii},'ID'));
    end
end

assertInvariants(obj);