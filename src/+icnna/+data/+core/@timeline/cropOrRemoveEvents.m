function obj = cropOrRemoveEvents(obj)
%Crops or remove events exceeding the timeline length.
%
% obj = cropOrRemoveEvents(obj)
%
%
%% Parameters
%
% obj - An icnna.data.core.timeline
%
%% Output
%
% obj - An icnna.data.core.timeline
%   The timeline with no events lasting beyond the length of the timeline.
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



for iCond = 1:obj.nConditions

    tmpCond = obj.conditions(iCond);
    cevents = tmpCond.cevents;

    %Conditions may be expressed in samples or seconds (scaled by a unit
    %multiplier).
    if strcmpi(tmpCond.unit,'samples')
        %Remove events that initiate "after" the end of the timeline.
        idx = find(cevents(:,'onsets') > obj.length);
        cevents(idx,:) = [];

        %Crop events lasting "beyond" the end of the timeline.
        idx = find(tmpCond.ends > obj.length);
        cevents(idx,'durations') = obj.length - cevents(idx,'onsets');
            

    else %Expressed in seconds (scaled by a unit multiplier).

        cevents = cevents / 10^tmpCond.timeUnitMultiplier;
        %Remove events that initiate "after" the end of the timeline.
        idx = find(cevents(:,'onsets') > obj.timestamps(end));
        cevents(idx,:) = [];

        %Crop events lasting "beyond" the end of the timeline.
        idx = find(tmpCond.ends > obj.timestamps(end));
        cevents(idx,'durations') = obj.timestamps(end) - cevents(idx,'onsets');
            
        cevents = cevents * 10^tmpCond.timeUnitMultiplier;

    
    end
    

    tmpCond.cevents = cevents;
    obj.conditions(iCond) = tmpCond;
end

end
