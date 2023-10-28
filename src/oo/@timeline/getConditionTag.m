function tag=getConditionTag(obj,c)
%TIMELINE/GETCONDITIONTAG Gets the tag for the condition referred by c
%
% tag=getConditionTag(obj,i) Gets the tag of the i-th defined
%   experimental condition or an empty string '' if the i-th
%   condition has not been defined.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also addCondition, getCondition, getConditionEvents, getNConditions
%


%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): 31-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%


tag='';
if ((c>0) && (c<=obj.nConditions))
        cond=obj.conditions{c};
        tag=cond.tag;
end
