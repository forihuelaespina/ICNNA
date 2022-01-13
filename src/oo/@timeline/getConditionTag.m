function tag=getConditionTag(obj,c)
%TIMELINE/GETCONDITIONTAG Gets the tag for the condition referred by c
%
% tag=getConditionTag(obj,i) Gets the tag of the i-th defined
%   experimental condition or an empty string '' if the i-th
%   condition has not been defined.
%
% Copyright 2008-12
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 31-Dec-2012
%
% See also addCondition, getCondition, getConditionEvents, getNConditions
%

tag='';
if ((c>0) && (c<=get(obj,'NConditions')))
        cond=obj.conditions{c};
        tag=cond.tag;
end
