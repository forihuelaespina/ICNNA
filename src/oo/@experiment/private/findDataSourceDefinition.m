function idx=findDataSourceDefinition(obj,id)
%EXPERIMENT/FINDDATASOURCEDEFINITION Finds a dataSourceDefinition
%
% idx=findDataSourceDefinition(obj,id) returns the index of the
%       dataSourceDefinition. If the dataSourceDefinition has not
%       been defined for the experiment it returns an empty
%       matrix [].
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also experiment, dataSourceDefinition, assertInvariants

nElements=length(obj.dataSourceDefinitions);
idx=[];
for ii=1:nElements
    childID=get(obj.dataSourceDefinitions{ii},'ID');
    if (id==childID)
        idx=ii;
        % Since the dataSourceDefinition id cannot be repeated
        %we can stop as soon as it is found.
        break
    end
end