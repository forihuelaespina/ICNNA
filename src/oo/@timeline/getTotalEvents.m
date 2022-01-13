function n=getTotalEvents(obj)
%TIMELINE/GETTOTALEVENTS DEPRECATED Get the total number of events across all conditions
%
% max = getTotalEvents(obj) DEPRECATED Get the total number of events
%   defined in the timeline across all defined conditions.
%   If no conditions have been defined
%   then this function returns an empty matrix. Note that
%   although conditions may exist there is still the
%   possibility that no events have been declared for any conditions
%   and hence a value 0 will be returned.
%
% This method is now deprecated. Please use getNEvents(obj) instead.
%
%
%
% Copyright 2008-12
% @date: 18-Jun-2008
% @author Felipe Orihuela-Espina
% @modified: 28-Dec-2012
%
% See also setConditionEvents, addConditionEvents, removeConditionEvents,
%   getNEvents, getMaxEvents
%
n=[];
if ~isempty(obj.conditions)
    n=0;
    for ii=1:length(obj.conditions)
        n=n+size(obj.conditions{ii}.events,1);
    end
end

warning('ICNA:timeline:getTotalEvents:Deprecated',...
        ['The use of getTotalEvents has now been deprecated. ' ...
         'Please use getNEvents(obj) instead.']);
