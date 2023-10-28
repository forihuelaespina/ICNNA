function n=getTotalEvents(obj)
%TIMELINE/GETTOTALEVENTS DEPRECATED Get the total number of events across all conditions
%
% This method is now deprecated. Please use getNEvents(obj) instead.
%
% max = getTotalEvents(obj) DEPRECATED Get the total number of events
%   defined in the timeline across all defined conditions.
%   If no conditions have been defined
%   then this function returns an empty matrix. Note that
%   although conditions may exist there is still the
%   possibility that no events have been declared for any conditions
%   and hence a value 0 will be returned.
%
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also setConditionEvents, addConditionEvents, removeConditionEvents,
%   getNEvents, getMaxEvents
%


%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): 28-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   Bug fixing
%   + Method was still implementing the "whole" code. Instead, now
%   it truly calls obj.getNEvents()
%   + Slightly modified the deprecated warning message.
%

warning('ICNA:timeline:getTotalEvents:Deprecated',...
        ['DEPRECATED. Please use obj.getNEvents() instead.']);

n = obj.getNEvents();
% n=[];
% if ~isempty(obj.conditions)
%     n=0;
%     for ii=1:length(obj.conditions)
%         n=n+size(obj.conditions{ii}.events,1);
%     end
% end

