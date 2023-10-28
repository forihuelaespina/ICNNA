function idx=findDataSourceDefinition(obj,id)
%EXPERIMENT/FINDDATASOURCEDEFINITION Finds a dataSourceDefinition
%
% idx=findDataSourceDefinition(obj,id) returns the index of the
%       dataSourceDefinition. If the dataSourceDefinition has not
%       been defined for the experiment it returns an empty
%       matrix [].
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also experiment, dataSourceDefinition, assertInvariants


%% Log
%
% File created: 21-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 23-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to use get/set methods for struct like access.
%


nElements=length(obj.dataSourceDefinitions);
idx=[];
for ii=1:nElements
    tmp = obj.dataSourceDefinitions{ii};
    childID=tmp.id;
    if (id==childID)
        idx=ii;
        % Since the dataSourceDefinition id cannot be repeated
        %we can stop as soon as it is found.
        break
    end
end

end