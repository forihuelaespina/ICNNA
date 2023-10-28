function obj=setExclusory(obj,tagA,tagB,exclusoryState)
%TIMELINE/SETEXCLUSORY Set the exclusory behaviour among conditions
%
% obj=setExclusory(obj,tagA,tagB) Sets the behaviour
%    among the two conditions to exclusory.
%
% obj=setExclusory(obj,tagA,tagB,exclusoryState) Sets the exclusory
%    behaviour among the two conditions to exclusoryState.
%	  exclusoryState=0 => Non exclusory behaviour
%	  exclusoryState=1 => Exclusory behaviour
%
% @li Both conditions must exist. If one or both tags correspond
%to a non defined condition nothing is done.
% @li Conditions must be different
% @li If provided exclusoryState is either 0 or 1, otherwise
%it is ignored and nothing is done.
%
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also switchExclusory, setAllExclusory
%



%% Log
%
% File created: 29-May-2008
% File last modified (before creation of this log): N/A. This method
%   had not been modified since creation.
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date.
%   Bug fixing
%   + 1 error was not yet using the "new" ICNNA error code 
%
%





if (strcmp(tagA,tagB))
    return;
end

idxA=findCondition(obj,tagA);
if (isempty(idxA))
    return;
end
idxB=findCondition(obj,tagB);
if (isempty(idxB))
    return;
end
if (idxA==idxB)
    error('ICNA:timeline:setExclusory:DuplicateTag',...
          'Duplicated Tag?');
end

if (~exist('exclusoryState','var'))
    exclusoryState=1;
end

if ((exclusoryState==1) || (exclusoryState==0))
    obj.exclusory(idxA,idxB)=exclusoryState;
    obj.exclusory(idxB,idxA)=exclusoryState;
else
    return;
end
assertInvariants(obj);

end
