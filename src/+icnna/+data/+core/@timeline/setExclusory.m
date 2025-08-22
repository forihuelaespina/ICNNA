function setExclusory(obj,tag,exclusoryState,reflexiveState)
%Sets the exclusory behaviour among conditions
%
% setExclusory(obj,ids,exclusoryState)
% setExclusory(obj,names,exclusoryState)
% setExclusory(...,reflexiveState)
% obj.setExclusory(...)
%
% @li Conditions must exist. If one or both tags correspond to a non
%   defined condition nothing is done.
%
%   
%% Parameters
%
% ids  - Int or Int[]. The |id| of the conditions being acted upon.
% names- String or String{}. The |name| of the conditions being acted upon
%       The search for the name is case sensitive.
%   
% exclusoryState - Logical/Bool
%   True for exclusory behaviour (no events overlap allowed) between
%       conditions.
%   False for non exclusory behaviour (events overlap allowed) between
%       conditions.
%   
% reflexiveState - Optional. Logical/Bool
%   True for self-exclusory behaviour (no events overlap allowed)
%   False for self-exclusory behaviour (events overlap allowed)
%   If not provided, self-exclusory behaviours will be set as per
%   the exclusoryState.
%
%
%
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
%
% See also icnna.data.core.timeline
%


%% Log
%
% File created: 27-Jun-2025
%
% -- ICNNA v1.3.1
%
% 27-Jun-2025: FOE 
%   + File created. Reused some comments from previous code on
%       timeline.setExclusory
%
% 9-Jul-2025: FOE. 
%   + Adapted to reflect the new handle status e.g. no object return.
%
%

idx=findConditions(obj,tag);

tmp = obj.exclusory;
tmp(idx,idx)=exclusoryState;
if exist('reflexiveState','var')
    tmp(sub2ind([obj.nConditions obj.nConditions], idx, idx))=reflexiveState;
end
obj.exclusory = tmp;


end