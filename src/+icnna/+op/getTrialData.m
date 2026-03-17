function [trialData] = getTrialData(sd,condTag,options)
%Extract the data corresponding to blocks or trial for one or more conditions
%
% [trialData] = getTrialData(sd,condTag,options)
%
%% Remarks
%
% Somewhat analogous to @structuredData.getBlock, but this function is
% lighter. Instead of retrieving a full structuredData object, this
% function concentrates on extracting the data subtensor only.
%
% In contrast to @structuredData.getBlock, this function extracts ALL
% trials at once, and can do so for more than 1 condition at a time. 
%
%% Input parameters
%
% sd - structuredData
%   A @structuredData from where the data will be extracted.
% condTag - Either Int[] or String{}.
%   The |id| or |name| of the conditions for which the trials will be
%   extracted.
%
% options - Struct. A struct of options
%   .unit - Char array. Default 'samples'
%       The unit in which the other options are expressed.
%   .timeUnitMultipler - int16. Default 0
%       The time unit multiplier exponent in base 10. i.e. interval
%       parameters would be in scale 10^0.
%           + If .unit is 'samples', it is ignored.
%           + If .unit is 'seconds', this represents fractional units,
%               e.g. -3 is equals to [ms].
%   .baseline - double. Default 50 samples
%       The duration of the baseline interval taken from data before
%       the event onset backwards. Note however that the number is
%       expressed positively. A negative baseline will go into the task
%       period so it is strongly discouraged!
%   .breakDelay - double. Default 15 samples.
%       The duration of the breakDelay interval taken from data 
%       immediately from the event onset (regardless of the baseline e.g.
%       in case the baseline value was negative).
%   .task - double. Default is 50 samples
%       ONLY ONE .wsTask OR .wsTaskExceed CAN BE SPECIFIED.
%       BY DEFAULT .wsTask is USED.
%       The (absolute) duration of the task interval taken from data 
%       after the breakDelay.
%       With this option, the task interval is fixed in length (to the
%       value of this option). Note that if this value is longer than
%       the event length, the retrieved interval will expand into
%       the "recovery" period (as if using a positive taskExceed).
%       If you want to only use until the end
%       of the event, then use parameter .taskExceed=0 instead.
%       The interval can still be truncated if there are no sufficient
%       samples to complete the interval.
%   .taskExceed - double. Default is 0.
%       ONLY ONE .wsTask OR .wsTaskExceed CAN BE SPECIFIED.
%       BY DEFAULT .wsTask is USED.
%       The (relative) duration of the task interval taken from data 
%       after the breakDelay.
%       With this option, the task interval depends on the duration
%       of the stimulus. The task end is taken as reference.
%       * A taskExceed equals 0 means the task interval last until
%       the event end.
%       * A negative taskExceed means that the task interval is cut
%       "short" of the event length. For instance a taskExceed of -3
%       samples, mean that the task interval will be truncated 3 samples
%       before the event end. This is particularly useful for experimental
%       designs with very long stimuli where saturation is likely.
%       * A positive taskExceed means that the task interval is allowed
%       to extend beyond the event end. For instance a taskExceed of 3
%       samples, mean that the task interval will be truncated 3 samples
%       after the event end. This is particularly useful for experimental
%       designs with short stimuli where the time to peak may happen
%       after the event end.
%   .recovery - double. Default 50 samples
%       The duration of the recovery interval taken from data immediately
%       after the task interval as determined from the task exceed.
%
%
% Below an example with a positive taskExceed is illustrated.
%
%                  Event    Break               Event        Task
%  baseline        onset    delay                end        exceed
%     |              |        |                   |           |
%   --+--------------+--------+-------------------+-----------+-----------
%     |   baseline   | break  |           Task                | Recovery
%     |   interval   | delay  |         interval              | interval
%                    |interval|                               |
%
%% Outputs
%
% trialData - An array of struct where each struct has the following
%   fields;
%       .condId      - Condition id.
%       .eventNumber - The event or trial number within the condition
%       .baseline    - The baseline interval subtensor
%       .breakDelay  - The breakDelay interval subtensor
%       .task        - The trial main interval subtensor
%       .recovery    - The recovery interval subtensor
%
%   trialData can be empty if the condition does not exist in the
%   structuredData or if it has no events (i.e. no blocks or trials).
%   In addition, each subtensor on its own may be empty or may be
%   truncated if there are no sufficient data to "complete" the required
%   intervals (no pading is attempted).
%   The different subtensors have ALL channels and signals.
%
%
% Copyright 2025-26
% @author Felipe Orihuela-Espina
% 
% See also @structuredData.getBlock
%

%% Log
%
%
% File created: 24-Jun-2025
%
%   + Available since v1.3.1
%
% 25-Apr-2025: FOE. 
%   + File created.
%
% 8-Jul-2025: FOE. 
%   + Added option .task to select an "absolute" length of interval.
%
% 8-Aug-2025: FOE. 
%   + Improved some comments.
%
% -- ICNNA v1.4.0
%
% 14-Mar-2026: FOE
%   + Bug fixed: type for *.timeUnitMultiplier is now correctly set to
%   int16 (instead of double) and whenever typecastings are needed these
%   are now explicit.
%   + Added support for icnna.data.core.timeline class version 1.2
%
%



%% Deal with options
flagTask = true; %NOT an option. Keeps track of which task option to use.
             % True  - Use option opt.wsTask
             % False - Use option opt.wsTaskExceed
opt.unit = 'samples';
opt.timeUnitMultiplier = int16(0);
opt.baseline   = 50;
opt.breakDelay = 15;
opt.task       = 50; %Absolute task interval duration
opt.taskExceed = 0;  %Relative (to stimulus' end) task interval duration
opt.recovery   = 50;
if exist('options','var')
    if isfield(options,'unit')
        opt.unit = options.unit;
    end
    if isfield(options,'timeUnitMultiplier')
        opt.timeUnitMultiplier = int16(options.timeUnitMultiplier);
    end
    if isfield(options,'baseline')
        opt.baseline = options.baseline;
    end
    if isfield(options,'breakDelay')
        opt.breakDelay = options.breakDelay;
    end
    if isfield(options,'task')
        opt.task = options.task;
    end
    if isfield(options,'taskExceed')
        opt.taskExceed = options.taskExceed;
    end
    if isfield(options,'recovery')
        opt.recovery = options.recovery;
    end
end


if isfield(options,'wsTaskExceed')
    if isfield(options,'wsTask')
        warning('icnna.op.computeExperimentBundle:IncompatibleOption',...
                ['Options .wsTask and .wsTaskExceed are incompatible. ' ...
                 'Ignoring option .wsTaskEceed.']);
    else
        flagTask = false; %Use .wsTaskExceed
    end
end





t = icnna.data.core.timeline(sd.timeline);
tmpData = sd.data;


if isa(t,'icnna.data.core.timeline')
    theSamplingRate = t.averageSamplingRate;
else %old timeline
    theSamplingRate = t.samplingRate;
end



%Conciliate timeline and parameters units
tmpIntervalParams = [opt.baseline opt.breakDelay opt.task opt.taskExceed opt.recovery];
if strcmpi(t.unit,'samples') && strcmpi(opt.unit,'samples') 
    %Do nothing
elseif strcmpi(t.unit,'seconds') && strcmpi(opt.unit,'seconds') 
    %Update according to the timeUnitMultipliers
    tmpIntervalParams = tmpIntervalParams * 10^(double(t.timeUnitMultiplier-opt.timeUnitMultiplier));
elseif strcmpi(t.unit,'samples') && strcmpi(opt.unit,'seconds') 
    %Update according to the sampling rate
    tmpIntervalParams = round(tmpIntervalParams * theSamplingRate);
elseif strcmpi(t.unit,'seconds') && strcmpi(opt.unit,'samples') 
    %Update according to the sampling rate
    tmpIntervalParams = tmpIntervalParams / theSamplingRate;
else
    error('icnna:op:getTrialData:InvalidParameterValue',...
          'Invalid parameter value .unit.');
end
opt.baseline   = tmpIntervalParams(1);
opt.breakDelay = tmpIntervalParams(2);
opt.task       = tmpIntervalParams(3);
opt.taskExceed = tmpIntervalParams(4);
opt.recovery   = tmpIntervalParams(5);

%Avoid the overlap sample between intervals
if strcmpi(t.unit,'samples')
    tmpShift = 1; %1 sample shift between contiguous intervals
else %seconds
    tmpShift = (1/theSamplingRate)-2*eps; %1 sample shift between contiguous intervals
end    


%Retrieve the events
tmpConds  = t.getConditions(condTag);
if icnna.util.compareVersions(classVersion(t),'1.2','>=')
    tmpEvents = t.condEvents(ismember([t.condEvents.id]',[tmpConds.id]));

    tmpCurrentConditionEvent = dictionary; %Cond.id -> Num of visited events
    for iCond = 1:length(tmpConds)
        theCond = tmpConds(iCond);
        tmpCurrentConditionEvent = tmpCurrentConditionEvent.insert(theCond.id,0);
    end
    
    
    %Main loop: Visit every event
    trialData = struct('condId',    {}, 'eventNumber', {}, ...
                        'baseline', {}, 'breakDelay',  {}, ...
                        'task',     {}, 'recovery',    {});
    k = 1;
    for iEv = 1:t.nTotalEvents
        tmpCondId   = tmpEvents(iEv).id; % Condition id.
        tmpCurrentConditionEvent(tmpCondId) = tmpCurrentConditionEvent(tmpCondId) + 1;
            %Increase the number of visited events for this condition.
    
        ev_onset    = tmpEvents(iEv).onsets;
        ev_duration = tmpEvents(iEv).durations;
        ev_end      = ev_onset + ev_duration;
    
        %Establish the interval periods
        if flagTask %Absolute from breakDelay - Uses .task
            wsBaselineOnset  = ev_onset-opt.baseline;
            wsBaselineEnd    = ev_onset-tmpShift;
            wsBreakOnset     = ev_onset;
            wsBreakEnd       = ev_onset+opt.breakDelay-tmpShift;
            wsTaskOnset      = ev_onset+opt.breakDelay;
            wsTaskEnd        = ev_onset+opt.breakDelay+opt.task-tmpShift;
            wsRecoveryOnset  = ev_onset+opt.breakDelay+opt.task;
            wsRecoveryEnd    = ev_onset+opt.breakDelay+opt.task+opt.recovery-tmpShift;
    
        else %Relative (to stimulus' end) - Uses .taskExceed
            wsBaselineOnset  = ev_onset-opt.baseline;
            wsBaselineEnd    = ev_onset-tmpShift;
            wsBreakOnset     = ev_onset;
            wsBreakEnd       = ev_onset+opt.breakDelay-tmpShift;
            wsTaskOnset      = ev_onset+opt.breakDelay;
            wsTaskEnd        = ev_end+opt.taskExceed-tmpShift;
            wsRecoveryOnset  = ev_end+opt.taskExceed;
            wsRecoveryEnd    = ev_end+opt.taskExceed+opt.recovery-tmpShift;
        end
    
        tmpIntervalPeriods = [wsBaselineOnset wsBaselineEnd; ...
                              wsBreakOnset    wsBreakEnd; ...
                              wsTaskOnset     wsTaskEnd; ...
                              wsRecoveryOnset wsRecoveryEnd];
    
    
        %Crop the intervals if needed.
        if strcmpi(t.unit,'samples')
            idx = find(tmpIntervalPeriods  < 1);
            tmpIntervalPeriods(idx) = 1;
    
            idx = find(tmpIntervalPeriods  > t.length);
            tmpIntervalPeriods(idx) = t.length;
        else
            idx = find(tmpIntervalPeriods  < 0);
            tmpIntervalPeriods(idx) = 0;
    
            idx = find(tmpIntervalPeriods  > t.timestamps(end));
            tmpIntervalPeriods(idx) = t.timestamps(end);
    
    
            %Note that regardless if whether the chosen units are seconds
            %instead of samples, for the extraction itself, the samples
            %indexes rather than the time is what it is needed since
            %MATLAB needs integer to index the tensor e.g. one
            %can retrieve tmpData(k:k+n,:,:) with k and n being number of
            %samples but cannot retrieve tmpData(k:k+n,:,:) with k and n
            %being seconds.
            tmpIntervalPeriods = round(tmpIntervalPeriods * ...
                            theSamplingRate * 10^double(t.timeUnitMultiplier));
        end
    
    
        %Finally, extract the subtensors
        tmpTrial.condId      = tmpCondId; % Condition id.
    
        nEv = tmpCurrentConditionEvent(tmpEvents(iEv).id);
        tmpTrial.eventNumber = nEv; % The event or trial number within the condition
    
        tmpTrial.baseline    = tmpData(tmpIntervalPeriods(1,1):tmpIntervalPeriods(1,2),:,:);
        % The baseline period subtensor
        tmpTrial.breakDelay  = tmpData(tmpIntervalPeriods(2,1):tmpIntervalPeriods(2,2),:,:);
        % The breakDelay period subtensor
        tmpTrial.task        = tmpData(tmpIntervalPeriods(3,1):tmpIntervalPeriods(3,2),:,:);
        % The trial main period subtensor
        tmpTrial.recovery    = tmpData(tmpIntervalPeriods(4,1):tmpIntervalPeriods(4,2),:,:);
        % The recovery period subtensor
        trialData(k) = tmpTrial;
        clear tmpTrial
        k = k+1;
    end





else % classVersion(t) <= '1.1'
    tmpEvents = t.condEvents(ismember([t.condEvents.id]',[tmpConds.id]),:);


    tmpCurrentConditionEvent = dictionary; %Cond.id -> Num of visited events
    for iCond = 1:length(tmpConds)
        theCond = tmpConds(iCond);
        tmpCurrentConditionEvent = tmpCurrentConditionEvent.insert(theCond.id,0);
    end
    
    
    %Main loop: Visit every event
    trialData = struct('condId',    {}, 'eventNumber', {}, ...
                        'baseline', {}, 'breakDelay',  {}, ...
                        'task',     {}, 'recovery',    {});
    k = 1;
    for iEv = 1:t.nTotalEvents
        tmpCondId   = tmpEvents{iEv,'id'}; % Condition id.
        tmpCurrentConditionEvent(tmpCondId) = tmpCurrentConditionEvent(tmpCondId) + 1;
            %Increase the number of visited events for this condition.
    
        ev_onset    = tmpEvents{iEv,'onsets'};
        ev_duration = tmpEvents{iEv,'durations'};
        ev_end      = ev_onset + ev_duration;
    
        %Establish the interval periods
        if flagTask %Absolute from breakDelay - Uses .task
            wsBaselineOnset  = ev_onset-opt.baseline;
            wsBaselineEnd    = ev_onset-tmpShift;
            wsBreakOnset     = ev_onset;
            wsBreakEnd       = ev_onset+opt.breakDelay-tmpShift;
            wsTaskOnset      = ev_onset+opt.breakDelay;
            wsTaskEnd        = ev_onset+opt.breakDelay+opt.task-tmpShift;
            wsRecoveryOnset  = ev_onset+opt.breakDelay+opt.task;
            wsRecoveryEnd    = ev_onset+opt.breakDelay+opt.task+opt.recovery-tmpShift;
    
        else %Relative (to stimulus' end) - Uses .taskExceed
            wsBaselineOnset  = ev_onset-opt.baseline;
            wsBaselineEnd    = ev_onset-tmpShift;
            wsBreakOnset     = ev_onset;
            wsBreakEnd       = ev_onset+opt.breakDelay-tmpShift;
            wsTaskOnset      = ev_onset+opt.breakDelay;
            wsTaskEnd        = ev_end+opt.taskExceed-tmpShift;
            wsRecoveryOnset  = ev_end+opt.taskExceed;
            wsRecoveryEnd    = ev_end+opt.taskExceed+opt.recovery-tmpShift;
        end
    
        tmpIntervalPeriods = [wsBaselineOnset wsBaselineEnd; ...
                              wsBreakOnset    wsBreakEnd; ...
                              wsTaskOnset     wsTaskEnd; ...
                              wsRecoveryOnset wsRecoveryEnd];
    
    
        %Crop the intervals if needed.
        if strcmpi(t.unit,'samples')
            idx = find(tmpIntervalPeriods  < 1);
            tmpIntervalPeriods(idx) = 1;
    
            idx = find(tmpIntervalPeriods  > t.length);
            tmpIntervalPeriods(idx) = t.length;
        else
            idx = find(tmpIntervalPeriods  < 0);
            tmpIntervalPeriods(idx) = 0;
    
            idx = find(tmpIntervalPeriods  > t.timestamps(end));
            tmpIntervalPeriods(idx) = t.timestamps(end);
    
    
            %Note that regardless if whether the chosen units are seconds
            %instead of samples, for the extraction itself, the samples
            %indexes rather than the time is what it is needed since
            %MATLAB needs integer to index the tensor e.g. one
            %can retrieve tmpData(k:k+n,:,:) with k and n being number of
            %samples but cannot retrieve tmpData(k:k+n,:,:) with k and n
            %being seconds.
            tmpIntervalPeriods = round(tmpIntervalPeriods * ...
                            theSamplingRate * 10^double(t.timeUnitMultiplier));
        end
    
    
        %Finally, extract the subtensors
        tmpTrial.condId      = tmpCondId; % Condition id.
    
        nEv = tmpCurrentConditionEvent(tmpEvents{iEv,'id'});
        tmpTrial.eventNumber = nEv; % The event or trial number within the condition
    
        tmpTrial.baseline    = tmpData(tmpIntervalPeriods(1,1):tmpIntervalPeriods(1,2),:,:);
        % The baseline period subtensor
        tmpTrial.breakDelay  = tmpData(tmpIntervalPeriods(2,1):tmpIntervalPeriods(2,2),:,:);
        % The breakDelay period subtensor
        tmpTrial.task        = tmpData(tmpIntervalPeriods(3,1):tmpIntervalPeriods(3,2),:,:);
        % The trial main period subtensor
        tmpTrial.recovery    = tmpData(tmpIntervalPeriods(4,1):tmpIntervalPeriods(4,2),:,:);
        % The recovery period subtensor
        trialData(k) = tmpTrial;
        clear tmpTrial
        k = k+1;
    end

end



end