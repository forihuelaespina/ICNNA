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
% [cevents] - Table. List of events.
%         Each row is an event.
%         The list of events has AT LEAST the following columns;
%          + id - The condition id,
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

if ~exist('id','var')
    [id,~] = obj.getConditionsList();
end

cevents = obj.cevents(ismember(obj.cevents.id,id),:);

end