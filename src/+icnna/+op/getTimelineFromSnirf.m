function [t] = getTimelineFromSnirf(aSnirf,options)
%Retrieves an ICNNA timeline from an iccna.data.snirf.snirf
%
% [t] = icnna.op.getTimelineFromSnirf(aSnirf)
%
% [t] = icnna.op.getTimelineFromSnirf(aSnirf,options)
%
% The way ICNNA and the .snirf standard stored the timelines are slightly
% different. The .snirf standard uses an array of stims (see
% @iccna.data.snirf.stim) plus timestamps are saved separately,
% whereas ICNNA as a combination of either;
%
%   @icnna.data.core.timeline and @icnna.data.core.condition - Newer
%   @timeline - Older
%
% This function reads the .snirf formatted timeline and "converts" it
% to an ICNNA formatted timeline.
%
%% Parameters
%
% aSnirf - iccna.data.snirf.snirf
%   The snirf object from where the stims and timestamps are to be
%   extracted.
%
% options - struct. A struct of options
%   .iNirs - Int. Default is 1. Index to the nirs dataset from where
%       to retrieve the timeline.
%   .outputFormat - Char[]. Choose between old (@timeline) or new
%       (@icnna.data.core.timeline) class output. Possible values are;
%       'icnna.data.core.timeline' - Default
%       'timeline' - "Old" ICNNA timeline for backward compatibility.
%   .outputUnit - Char[]. 'seconds' (default) or 'samples'
%   
%
%
%% Output
%
% t - A ICNNA timeline. Class depends on option .outputFormat
%
%
%
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also @rawData_Snirf.convert
%

%% Log
%
% 12-Feb-2025: FOE
%   + File created, but reused some code from @rawData_Snirf.convert
%
% 8-Jul-2025: FOE
%   + Added support for icnna.data.core.timeline which is now the
%   default output format.
%   + Added support for output in seconds (which is more natural for
%   snirf even if not favoured for ICNNA)
%
% 9-Jul-2025: FOE. 
%   + Adapted to reflect the new handle status of both
%   icnna.data.core.timeline and icnna.data.core.condition
%
% -- ICNNA v1.4.0
%
% 14-Dec-2025: FOE
%   + Revert back to regular value (non-handle) class of both
%   icnna.data.core.timeline and icnna.data.core.condition
%



%% Deal with options
opt.iNirs = 1;
opt.outputFormat = 'icnna.data.core.timeline';
opt.outputUnit   = 'seconds';
if exist('options','var')
    if isfield(options,'iNirs')
        opt.iNirs=options.iNirs;
    end
    if isfield(options,'outputFormat')
        opt.outputFormat=options.outputFormat;
    end
    if isfield(options,'outputUnit')
        opt.outputUnit=options.outputUnit;
    end
end



%% Main
t = icnna.data.core.timeline();
t.unit = 'seconds'; %snirf only work in 'seconds'

if isprop(aSnirf.nirs(opt.iNirs).metaDataTags,'timeUnit')
    switch (aSnirf.nirs(opt.iNirs).metaDataTags.timeUnit)
        case 's'
            t.timeUnitMultiplier = 0;
        case 'ms'
            t.timeUnitMultiplier = -3;
        case {'us','μs'}
            t.timeUnitMultiplier = -6;
        case 'ns'
            t.timeUnitMultiplier = -9;
        otherwise
            error('icnna:op:getTimelineFromSnirf:UnexpectedInputValue',...
                ['Unexpected value for property ' ...
                 '/nirs(i)/metaDataTags/timeUnit']);
    end
end


t.timestamps = aSnirf.nirs(opt.iNirs).data.time;
t.nominalSamplingRate = t.averageSamplingRate;
                        %snirf does not stored a nominal sampling rate.
                        %Assume the nominal sampling rate to be equal to
                        %the average sampling rate.
nStims = length(aSnirf.nirs(opt.iNirs).stim);
for iStim = 1:nStims
    tmpStim = aSnirf.nirs(opt.iNirs).stim(iStim);
    cTag    = tmpStim.name;


    col.onset     = 1;
    col.duration  = 2;
    col.amplitude = 3;
    if isproperty(tmpStim,'dataLabels')
        idx = find(strcmpi(tmpStim.dataLabels,'starttime')  | ...
                   strcmpi(tmpStim.dataLabels,'onsets')  | ...
                   strcmpi(tmpStim.dataLabels,'onset'));
        if ~isempty(idx)
            col.onset = idx(1);
        end
        idx = find(strcmpi(tmpStim.dataLabels,'durations') | ...
                   strcmpi(tmpStim.dataLabels,'duration'));
        if ~isempty(idx)
            col.duration = idx(1);
        end
        idx = find(strcmpi(tmpStim.dataLabels,'amplitude') | ...
                   strcmpi(tmpStim.dataLabels,'magnitude'));
        if ~isempty(idx)
            col.amplitude = idx(1);
        end
    end 

    %%DEPRECATED CODE
    %Convert from time to samples
    %onsets   = round(tmpStim.data(:,col.onset)*t.nominalSamplingRate);
    %durations= round(tmpStim.data(:,2)*t.nominalSamplingRate);
    
    onsets   = tmpStim.data(:,col.onset);
    durations= tmpStim.data(:,col.duration);
    
    % Saves amplitudes
    amplitudes = ones(numel(onsets),1);
    if size(tmpStim.data,2)>2
        amplitudes = tmpStim.data(:,col.amplitude);
    end

    % Events that start beyond the last sample are truncated.
    if strcmp(t.unit,'samples')
        onsets = max(0,min(onsets, t.length));
    

        % Onsets at 0 are "shifted" to sample 1.
        onsets(onsets == 0) = 1; %Shift to 1st sample.
        % 20-Feb-2024: FOE
        %   + Bug fixed. If the stimulus timeline have events of the same stimulus
        %   that overlap, when setting up the timeline this was causing an error.
        %   Now, the events are merged into a single event whereby I take the
        %   earliest onset and the latest offset of the "group" (if there are more
        %   than two; for instance:
        %       [30 15;
        %       [35 15;   ==> max offset 40+15=65 ==> [30 35]
        %       [40 15]
        tmpcevents = unique([onsets durations amplitudes],'rows'); %merge events if required
        jj=1;
        while (jj < length(tmpcevents(:,1)))
            currentOnset  = tmpcevents(jj,1);
            currentOffset = tmpcevents(jj,1)+tmpcevents(jj,2);
            nextOnset     = tmpcevents(jj+1,1);
            nextOffset    = tmpcevents(jj+1,1)+tmpcevents(jj+1,2);
            if  (currentOffset >= nextOnset)
                latestOffset = max(currentOffset,nextOffset);
                tmpcevents(jj,2)   = latestOffset - currentOnset; %New duration
                tmpcevents(jj+1,:) = [];
            else
                jj = jj+1;
            end
        end

        % The .snirf file format does NOT check whether stimulus
        % event last beyond the last sample e.g. starttime+duration may be
        % bigger than the timestamp of the last sample. However, ICNNA
        % asserts that no conditon event lasts beyond the last sample.
        % Events that last beyond the last sample are truncated.

        %%%DEPRECATED CODE
        tmpcevents(:,2) = max(0,min(tmpcevents(:,2), t.length-tmpcevents(:,1)));
        

    else %strcmp(t.unit,'seconds')
        onsets = max(0,min(onsets, t.timestamps(end)));

        % Onsets at 0 are "shifted" to sample 1.
        onsets(onsets == 0) = t.timestamps(1); %Shift to 1st sample.
        % 20-Feb-2024: FOE
        %   + Bug fixed. If the stimulus timeline have events of the same stimulus
        %   that overlap, when setting up the timeline this was causing an error.
        %   Now, the events are merged into a single event whereby I take the
        %   earliest onset and the latest offset of the "group" (if there are more
        %   than two; for instance:
        %       [30 15;
        %       [35 15;   ==> max offset 40+15=65 ==> [30 35]
        %       [40 15]

        %To check for events to be merged, calling unique directly
        % will fail because of the natural time progress. Instead,
        % I can:
        %
        %   Opt 1) Transiently convert to samples, call unique and then
        %   convert back. Straight forward but with a potential loss in
        %   resolution due to rounding errors.
        %
        %   Opt 2) Operate directly in time units and seek for anything
        %   within the tolerance of a sample according to the sampling
        %   rate. Unfortunaly, what's the tolerance might have an impact
        %   on the outcome.
        %
        % I therefore by now shall rely on the first option
        % So three steps below;
        %
        % Step 1: convert to samples
        transientEvents = [onsets durations];
        transientEvents = round(transientEvents * ...
                        t.nominalSamplingRate * 10^double(t.timeUnitMultiplier));
        % Step 2: call unique
        tmpcevents = unique([transientEvents amplitudes],'rows'); %merge events if required
        % Step 3: convert back to seconds
        transientEvents = tmpcevents(:,1:2); 
        transientEvents = transientEvents ./ ...
                        (t.nominalSamplingRate * 10^double(t.timeUnitMultiplier));
        tmpcevents = [transientEvents tmpcevents(:,3)];

        jj=1;
        while (jj < length(tmpcevents(:,1)))
            currentOnset  = tmpcevents(jj,1);
            currentOffset = tmpcevents(jj,1)+tmpcevents(jj,2);
            nextOnset     = tmpcevents(jj+1,1);
            nextOffset    = tmpcevents(jj+1,1)+tmpcevents(jj+1,2);
            if  (currentOffset >= nextOnset)
                latestOffset = max(currentOffset,nextOffset);
                tmpcevents(jj,2)   = latestOffset - currentOnset; %New duration
                tmpcevents(jj+1,:) = [];
            else
                jj = jj+1;
            end
        end




        % The .snirf file format does NOT check whether stimulus
        % event last beyond the last sample e.g. starttime+duration may be
        % bigger than the timestamp of the last sample. However, ICNNA
        % asserts that no conditon event lasts beyond the last sample.
        % Events that last beyond the last sample are truncated.

        %%%DEPRECATED CODE
        %tmpcevents(:,2) = max(0,min(tmpcevents(:,2), t.length-tmpcevents(:,1)));
        tmpcevents(:,2)  = max(0,min(tmpcevents(:,2), t.timestamps(end)-tmpcevents(:,1)));
    end


    tmpCondition = icnna.data.core.condition();
    tmpCondition.id   = iStim;
    tmpCondition.name = cTag;
    tmpCondition.unit = t.unit;
    tmpCondition.nominalSamplingRate = t.nominalSamplingRate;
    tmpCondition.timeUnitMultiplier  = t.timeUnitMultiplier;

        %Ignore the data labels;
        %snirf favours "starttime" whereas ICNNA enforces "onset"
        %Note, notwithstanding, that the dataLabels are accounted above
        %to identify the most likely columns for onsets, durations
        %and amplitudes.
    if icnna.util.compareVersions(classVersion(tmpCondition),'1.1','<=')
        tmpCondition.addEvents(tmpcevents);
    elseif icnna.util.compareVersions(classVersion(tmpCondition),'1.2','>=')
        tmpCondition = addEvents(tmpCondition,tmpcevents);
    end

    [idList,namesList] = getConditionsList(t);
    cIdx = find(ismember(cTag,namesList));
    if isempty(cIdx)
        if icnna.util.compareVersions(classVersion(t),'1.1','<=')
            t.addConditions(tmpCondition,0);
        elseif icnna.util.compareVersions(classVersion(t),'1.2','>=')
            t = addConditions(t,tmpCondition,0);
        end
    else
        %try to add the events
        theId = idList(cIdx);
        if icnna.util.compareVersions(classVersion(t),'1.1','<=')
            t.addEvents([double(theId)*ones(size(tmpcevents,1),1) ...
                     tmpcevents]);
        elseif icnna.util.compareVersions(classVersion(t),'1.2','>=')
            t = addEvents(t,[double(theId)*ones(size(tmpcevents,1),1) ...
                     tmpcevents]);
        end
    end
    clear tmpCondition
end

if strcmp(opt.outputUnit,'samples')
    t.unit = 'samples'; %Note that this will update all events accordingly.
end

if strcmpi(opt.outputFormat,'timeline')
    %Convert to 'timeline'
    t = timeline(t);
end

end