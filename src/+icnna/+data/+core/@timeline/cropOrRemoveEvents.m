function obj = cropOrRemoveEvents(obj)
%Crops or remove events exceeding the timeline length.
%
% obj = cropOrRemoveEvents(obj)
%
% Crops or remove events exceeding the timeline length (if in samples)
% or the last timestamp (if in seconds).
%
%% Parameters
%
% obj - @icnna.data.core.timeline
%   The timeline to which the condition events are to be crop or removed.
%  
%% Output
%
% obj - @icnna.data.core.timeline
%   The timeline with conditions updated.
%
%
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.timeline
%



%% Log
%
% 12-Apr-2025: FOE
%   + File created.
%
% 8-Jul-2025: FOE
%   + Warning for crop or removed events "moved" here from
%   icnna.data.core.timeline.set_timestamps.
%
% 9-Jul-2025: FOE. 
%   + Adapted to reflect the new handle status e.g. no object return.
%
%
% -- ICNNA v1.4.0 (Class version 1.2)
%
% 9-Dec-2025: FOE
%   + Refactored to value (non-handle) class.
%   + Adapted to re-implementation using array of
%   @icnna.data.core.condition objects.
%

flagCrop   = false;
flagRemove = false;


for iCond = 1:obj.nConditions
    %Events may be expressed in samples or seconds (scaled by a unit
    %multiplier).
    if strcmpi(obj.unit,'samples')
        %Remove events that initiate "after" the end of the timeline.
        idx = find(obj.conditions(iCond).onsets > obj.length);
        if ~isempty(idx)
            obj.conditions(iCond).cevents(idx) = [];
            flagRemove = true;
        end

        %Crop events lasting "beyond" the end of the timeline.
        idx = find(obj.conditions(iCond).ends > obj.length);
        if ~isempty(idx)
            obj.conditions(iCond).cevents(idx).durations = ...
                            obj.length - obj.conditions(iCond).onsets(idx);
            flagCrop = true;
        end


    else %Expressed in seconds (scaled by a unit multiplier).

        %Note that the conditions share the same timeUnitMultiplier
        %than the timeline itself.

        %Remove events that initiate "after" the end of the timeline.
        idx = find(obj.conditions(iCond).onsets > obj.timestamps(end));
        if ~isempty(idx)
            obj.conditions(iCond).cevents(idx) = [];
            flagRemove = true;
        end

        %Crop events lasting "beyond" the end of the timeline.
        idx = find(obj.conditions(iCond).ends > obj.timestamps(end));
        if ~isempty(idx)
            obj.conditions(iCond).durations(idx) = ...
                        obj.timestamps(end) - obj.conditions(iCond).onsets(idx);
            flagCrop = true;
        end

    end

end


if (flagCrop || flagRemove)
    warning('icnna:data:core:timeline:cropOrRemoveEvents:EventsCropOrRemoved',...
        'Events may have been crop or removed.')
end

end
