function idx=findSessionDefinition(obj,id)
%EXPERIMENT/FINDSESSIONDEFINITION Finds a sessionDefinition
%
% idx=findSessionDefinition(obj,id) returns the index of the
%       sessionDefinition. If the sessionDefinition has not
%       been defined for the experiment it returns an empty
%       matrix [].
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also experiment, sessionDefinition, assertInvariants


%% Log
%
% File created: 20-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 23-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%



nElements=length(obj.sessionDefinitions);
idx=[];
for ii=1:nElements
    tmp = obj.sessionDefinitions{ii};
    childID=tmp.id;
    if (id==childID)
        idx=ii;
        % Since the sessionDefinition id cannot be repeated
        %we can stop as soon as it is found.
        break
    end
end


end