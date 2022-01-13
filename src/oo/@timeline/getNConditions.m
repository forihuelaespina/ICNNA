function n=getNConditions(obj)
%TIMELINE/GETNCONDITIONS DEPRECATED Get the number of defined conditions in the timeline
%
% n=getNConditions(obj) DEPRECATED Get the number of defined conditions in the
%   timeline
%
% This method is now deprecated. Please use get(obj,'nConditions') instead.
%
%
% Copyright 2008-12
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 28-Dec-2012
%
%See also get, getCondition, getConditionTag, getConditionEvents
%

%n=length(obj.conditions); DEPRECATED CODE
n=get(obj,'nConditions');

warning('ICNA:timeline:getNConditions:Deprecated',...
        ['The use of getNConditions has now been deprecated. ' ...
         'Please use get(obj,''nConditions'') instead.']);

