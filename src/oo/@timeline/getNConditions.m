function n=getNConditions(obj)
%TIMELINE/GETNCONDITIONS DEPRECATED Get the number of defined conditions in the timeline
%
% n=getNConditions(obj) DEPRECATED Get the number of defined conditions in the
%   timeline
%
% This method is now deprecated. Please use get(obj,'nConditions') instead.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
%See also getCondition, getConditionTag, getConditionEvents
%



%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): 28-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%


warning('ICNA:timeline:getNConditions:Deprecated',...
        ['The use of getNConditions has now been deprecated. ' ...
         'Please use obj.nConditions instead.']);

n=obj.nConditions;

end