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
% options - struct. A Struct of options
%   .iNirs - Int. Default is 1. Index to the nirs dataset from where
%       to retrieve the timeline.
%   .outputFormat - String. Choose between old (@timeline) or new
%       (@icnna.data.core.timeline) class output. Possible values are;
%       'timeline' - Default.
%       'icnna.data.core.timeline' - Not yet working. Reserved for future use.
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



%% Deal with options
opt.iNirs = 1;
opt.outputFormat = 'timeline';
if exist('options','var')
    if isfield(options,'iNirs')
        opt.iNirs=options.iNirs;
    end
    if isfield(options,'outputFormat')
        opt.outputFormat=options.outputFormat;
    end
end


if strcmp(opt.outputFormat,'icnna.data.core.timeline')
    warning('ICNNA:op:getTimelineFromSnirf:OptionReserved',...
        ['Option outputFormat value icnna.data.core.timeline ' ...
         'reserved for future use. Output t will be returned' ...
         'as @timeline.']);
end





%% Main
nSamples = length(aSnirf.nirs(opt.iNirs).data.time);
t = timeline(nSamples);
t.timestamps = aSnirf.nirs(opt.iNirs).data.time;
t.nominalSamplingRate = t.samplingRate;
                        %snirf does not stored a nominal sampling rate.
                        %Assume the nominal sampling rate to be equal to
                        %the average sampling rate.
nStims = length(aSnirf.nirs(opt.iNirs).stim);
for iStim = 1:nStims
    tmpStim = aSnirf.nirs(opt.iNirs).stim(iStim);
    cTag = tmpStim.name;
    %Convert from time to samples
    onsets   = round(tmpStim.data(:,1)*t.nominalSamplingRate);
    durations= round(tmpStim.data(:,2)*t.nominalSamplingRate);
    % Saves amplitudes
    amplitudes = ones(numel(onsets),1);
    if size(tmpStim.data,2)>2
        amplitudes = tmpStim.data(:,3);
    end

    % Events that start beyond the last sample are truncated.
    onsets = max(0,min(onsets, nSamples));
    

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
    tmpcevents(:,2) = max(0,min(tmpcevents(:,2), nSamples-tmpcevents(:,1)));

    if isempty(t.getCondition(cTag))
        % Up to timeline class version '1.0', ICNNA does NOT have
        % anything equivalent to snirf dataLabels, so the information on the
        % dataLabels was getting lost. I have now added some rudimentary 
        % support in the timeline class but this is likely not a good solution...
        if isproperty(tmpStim,'dataLabels')
            t = t.addCondition(cTag,tmpcevents,tmpStim.dataLabels,0);
        else
            t = t.addCondition(cTag,tmpcevents,0);
        end
    else
        t = t.addConditionEvents(cTag,tmpcevents);
    end
end

end