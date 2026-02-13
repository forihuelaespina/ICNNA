function [cevents] = getEvents(obj,id)
%Gets the events for the selected @icnna.data.core.condition(s) from the @icnna.data.core.timeline
%
% [cevents] = obj.getEvents() - Gets ALL events across all conditions
% [cevents] = obj.getEvents(id) - Gets the events for the conditions
%       identified by |id|
% [cevents] = obj.getEvents(name) - Gets the events for the the conditions
%       identified by |name|
% [cevents] = getEvents(obj,...)
%
%
%% Remarks
%
% Somewhat analogous to @timeline.getConditionEvents
%
% Note that [cevents] = obj.getEvents() is equal to obj.condEvents
%
%
%% Parameters
%
% id  - Int or Int[]. Default is empty (i.e. search for all conditions)
%   The |id| of the conditions being searched.
% name - String or String{}.
%   The |name| of the conditions being searched.
%   The search for the name is case sensitive.
%
%% Output
%
% [cevents] - struct[]. List of events.
%         Each struct is an event.
%         The list of events has AT LEAST the following columns;
%          + id - The condition id,
%          + name - The condition name,
%          + onsets - The rows of the table is ALWAYS sort by onsets,
%          + durations,
%          + amplitudes i.e. magnitude or strength.
%          + info - Event information. Whatever the user wants to
%                   store associated to the condition event.
%
%       Onsets and durations are store in the timeline |unit|. 
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
%
% See also icnna.data.core.timeline
%


%% Log
%
% File created: 11-Jul-2025
%
% -- ICNNA v1.3.1
%
% 11-Jul-2025: FOE 
%   + File created. Reused some comments from previous code on
%       timeline.addCondition
%
% -- ICNNA v1.4.0
%
% 10-Dec-2025: FOE
%   + Revert back to regular value (non-handle) class.
%	+ Change .conds to .conditions, and updated from a table to a
%   struct array of conditions.
%	+ Revert .cevents to a derived property (extracted on the fly from
%       .conditions) |condEvents|.
%   + Improved some comments.
%

if ~exist('id','var')
    [id,~] = obj.getConditionsList();
end

cevents = obj.condEvents;
cevents(~ismember(cevents.id,id)) = [];

end