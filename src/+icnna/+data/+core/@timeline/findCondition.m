function idx=findCondition(obj,tag)
%Retrieves the position index of a condition with the given |id| or |tag|
%
% idx = obj.findCondition(id) - Search for a condition by |id|
% idx = obj.findCondition(tag) - Search for a condition by |tag|
%
%
%% Parameters
%
% obj - An icnna.data.core.timeline
% id  - Int. The |id| of the condition being searched.
% tag - String. The |tag| of the condition being searched.
%   The search for the tag is case sensitive.
%
%% Output
% idx - Returns the index to the condition with the given |tag|
%     or empty if there are no matching condition.
%     Since conditions tags cannot be repeated within a timeline,
%     idx has at most length 1.
%
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.timeline
%



%% Log
%
% 12-Apr-2025: FOE
%   + File created.
%

idx = [];
if ischar(tag) %tag provided
    for iCond = 1:obj.nConditions
        if strcmp(obj.conditions(iCond).tag,tag)
            idx = iCond;
            break
        end
    end

else %id provided
    id = tag;
    for iCond = 1:obj.nConditions
        if (obj.conditions(iCond).id == id)
            idx = iCond;
            break
        end
    end
end

end

