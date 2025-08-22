function cropOrRemoveEvents(obj)
%Crops or remove events exceeding the timeline length.
%
% obj.cropOrRemoveEvents()
% cropOrRemoveEvents(obj)
%
% Crops or remove events exceeding the timeline length (if in samples)
% or the last timestamp (if in seconds).
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

flagCrop   = false;
flagRemove = false;


%Events may be expressed in samples or seconds (scaled by a unit
%multiplier).
if strcmpi(obj.unit,'samples')
    %Remove even|ts that initiate "after" the end of the timeline.
    idx = find(obj.cevents.onsets > obj.length);
    obj.cevents(idx,:) = [];
    if ~isempty(idx)
        flagRemove = true;
    end

    %Crop events lasting "beyond" the end of the timeline.
    tmpEnds = obj.cevents.onsets + obj.cevents.durations;
    idx = find(tmpEnds > obj.length);
    obj.cevents.durations(idx) = obj.length - obj.cevents.onsets(idx);
    if ~isempty(idx)
        flagCropped = true;
    end


else %Expressed in seconds (scaled by a unit multiplier).

    %Note that the conditions share the same timeUnitMultiplier
    %than the timeline itself.

    %Remove events that initiate "after" the end of the timeline.
    idx = find(obj.cevents.onsets > obj.timestamps(end));
    obj.cevents(idx,:) = [];
    if ~isempty(idx)
        flagRemove = true;
    end

    %Crop events lasting "beyond" the end of the timeline.
    tmpEnds = obj.cevents.onsets + obj.cevents.durations;
    idx = find(tmpEnds > obj.timestamps(end));
    obj.cevents.durations(idx) = obj.timestamps(end) - obj.cevents.onsets(idx);
    if ~isempty(idx)
        flagCropped = true;
    end

end




if (flagCrop || flagRemove)
    warning('icnna:data:core:timeline:cropOrRemoveEvents:EventsCropOrRemoved',...
        'Events may have been crop or removed.')
end

end
