function cond=getCondition(obj,c)
%TIMELINE/GETCONDITION Gets the condition referred by tag
%
% cond=getCondition(obj,tag) Gets the experimental condition referred
%   by tag or an empty matrix if the condition has not been defined.
%
% cond=getCondition(obj,i) Gets the i-th defined experimental condition 
%   or an empty matrix if the i-th condition has not been defined.
%   This form of the function is useful for iterating through different
%   conditions.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also addCondition, removeCondition, setConditionTag,
% getConditionEvents, setConditionEvents, addConditionEvents,
% removeConditionEvents
%


%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): 10-Feb-2013
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%


cond=[];

if (ischar(c))
    tag=c;
    idx=findCondition(obj,tag);
    if (~isempty(idx))
        cond=obj.conditions{idx};
    end

else
    if ((c>0) && (c<=obj.nConditions))
        cond=obj.conditions{c};
    end
end



end