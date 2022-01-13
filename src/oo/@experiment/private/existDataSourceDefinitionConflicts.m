function found=existDataSourceDefinitionConflicts(obj,def)
%EXPERIMENT/EXISTDATASOURCEDEFINITIONCONFLICTS
%Check conflicts between dataSource definitions.
%
% found=checkDataSourceDefinitionConflicts(obj,sessionDefinition)
%   Check conflicts between existing dataSource definitions in the
%   experiment, and those in the sessionDefinition.
%
% found=checkDataSourceDefinitionConflicts(obj,defs)
%   Check conflicts between existing dataSource definitions in the
%   experiment, and those in defs. Parameter defs can be single
%   dataSourceDefinition or a set of them in a cell array.
%   
%In all cases, the function return true if a conflict has been
%found or false if no conflicts has been found (free of conflicts).
%
%
%--------------------------------------
% A dataSource definition conflict
%--------------------------------------
%
% All data sources definitions must be unique within a single
%experiment. It is not allowed to declare two data sources with
%the same ID, but different specifications (e.g. type and/or
%device number). In trying to add a new session definition, the
%experiment, attempt to automatically catch all undefined
%dataSource definitions, as well as checking that no conflict
%with existing definitions exist. A conflict occur when the
%sessionDefinition holds a dataSource definition with an
%ID that matches one of the existing ones in the experiment,
%but for which the data source definition specifications
%differ from the one that is already defined.
%
%
%
%
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also experiment, sessionDefinition, dataSourceDefinition, assertInvariants

found=false; %true if a conflict has been found.
if isa(def,'dataSourceDefinition')
    id=get(def,'ID');
    expDef=getDataSourceDefinition(obj,id);
    if (~isempty(expDef))
        found = ~(def == expDef);
    end

elseif isa(def,'sessionDefinition')
    defs=collectDataSourceDefinitionsFromSessionDefinition(obj,def);
    found=existDataSourceDefinitionConflicts(obj,defs);

else %Must be a cell array of dataSourceDefinitions
    nDefs=length(def);
    for ss=1:nDefs
        found=existDataSourceDefinitionConflicts(obj,def{ss});
        if found
            break
        end
    end
end
    