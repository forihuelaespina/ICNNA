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
% Copyright 2008-13
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 10-Feb-2013
%
% See also addCondition, removeCondition, setConditionTag,
% getConditionEvents, setConditionEvents, addConditionEvents,
% removeConditionEvents
%

cond=[];

if (ischar(c))
    tag=c;
    idx=findCondition(obj,tag);
    if (~isempty(idx))
        cond=obj.conditions{idx};
    end

else
    if ((c>0) && (c<=get(obj,'NConditions')))
        cond=obj.conditions{c};
    end
end
