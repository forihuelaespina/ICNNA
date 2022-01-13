function idx=findSessionDefinition(obj,id)
%EXPERIMENT/FINDSESSIONDEFINITION Finds a sessionDefinition
%
% idx=findSessionDefinition(obj,id) returns the index of the
%       sessionDefinition. If the sessionDefinition has not
%       been defined for the experiment it returns an empty
%       matrix [].
%
% Copyright 2008
% @date: 20-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also experiment, sessionDefinition, assertInvariants

nElements=length(obj.sessionDefinitions);
idx=[];
for ii=1:nElements
    childID=get(obj.sessionDefinitions{ii},'ID');
    if (id==childID)
        idx=ii;
        % Since the sessionDefinition id cannot be repeated
        %we can stop as soon as it is found.
        break
    end
end