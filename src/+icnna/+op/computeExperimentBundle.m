function [S]=computeExperimentBundle(theExperiment,options)
%Compute an @icnna.data.core.experimentBundle
%
% [S]=computeExperimentBundle(E)
% [S]=computeExperimentBundle(E,options)
%
%
% Somewhat analogous to method @experimentSpace.compute
% but for @icnna.data.core.experimentBundle.
%
%
%   +===========================================================+
%   | At the time of writing this, the place holder for Group   |
%   | is ready in the experimentBundle but not yet available    |
%   | in the experiment. Hence, by the time being, the group    |
%   | in the base space is fixed to id=1 and a default name.    |
%   +===========================================================+
%   | At the time of writing this, the integrity code for the   |
%   | sampling site is being proxied as if it was an individual |
%   | channel, which is incorrect for sampling sites such as a  |
%   | ROI.                                                      |
%   +===========================================================+
%
%
%% Remarks
%
% Contrary to method @experimentSpace.compute where the
%@experimentSpace had all the information necessary to
%compute the space, in the case of the @icnna.data.core.experimentBundle
%this class has no knowledge of the generating pipeline.
% In this sense, here the "pipeline" to compute the bundle
%has to be given in the form of options.
%
%
%% Parameters
%
% E - An @experiment
%
% options - Struct. A struct of options
%   -- Window Selection parameters
%   .wsUnit - Char array. Default 'samples'
%       The unit in which the other options are expressed.
%   .wsTimeUnitMultipler - Int. Default 0
%       The time unit multiplier exponent in base 10. i.e. interval
%       parameters would be in scale 10^0.
%           + If .unit is 'samples', it is ignored.
%           + If .unit is 'seconds', this represents fractional units,
%               e.g. -3 is equals to [ms].
%   .wsBaseline - double. Default 50 samples
%       The duration of the baseline interval taken from data before
%       the event onset backwards. Note however that the number is
%       expressed positively. A negative baseline will go into the task
%       period so it is strongly discouraged!
%   .wsBreakDelay - double. Default 15 samples.
%       The duration of the breakDelay interval taken from data 
%       immediately from the event onset (regardless of the baseline e.g.
%       in case the baseline value was negative).
%   .wsTask - double. Default is 50 samples
%       ONLY ONE .wsTask OR .wsTaskExceed CAN BE SPECIFIED.
%       BY DEFAULT .wsTask is USED.
%       The (absolute) duration of the task interval taken from data 
%       after the breakDelay.
%       With this option, the task interval is fixed in length (to the
%       value of this option).
%   .wsTaskExceed - double. Default is 0.
%       ONLY ONE .wsTask OR .wsTaskExceed CAN BE SPECIFIED.
%       BY DEFAULT .wsTask is USED.
%       The (relative) duration of the task interval taken from data 
%       after the breakDelay.
%       With this option, the task interval depends on the duration
%       of the stimulus. The task end is taken as reference.
%       * A taskExceed equals 0 means the task interval last from
%       the end of the breakDelay until the event end.
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
%   .wsRecovery - double. Default 50 samples
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
%
%
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
% 
% See also icnna.op.getTrialData, icnna.data.core.experimentBundle
%

%% Log
%
%
% File created: 30-Jun-2025
%
%   + Available since v1.3.1
%
% 30-Apr-2025: FOE. 
%   + File created. Unfinished.
%
% 7-Jul-2025: FOE. 
%   + Continue working on this function.
%
% 8-Jul-2025: FOE. 
%   + Added option .wsTask to select an "absolute" length of interval.
%
% 8-Aug-2025: FOE. 
%   + Bug fixed: Data subtensors per case were not being split by sampling
%   site and signal.
%
% 29-Aug-2025: FOE. 
%   + Bug fixed: The indexing of the base cases was adding an extra entry
%   per experimental unit.
%
% 30-Aug-2025: FOE. 
%   + Added a nominal 3D location to the sampling sites.
%


%% TO DO
%
% + Currently the extraction of the integrity code is proxied as for
%individual channels and will not work for more complex sampling sites
%e.g. ROIs
%



%% Deal with options
flagTask = true; %NOT an option. Keeps track of which task option to use.
             % True  - Use option opt.wsTask
             % False - Use option opt.wsTaskExceed
%Window Selection (Trial/Block extraction) parameters
opt.wsUnit       = 'samples';
opt.wsTimeUnitMultiplier = 0;
opt.wsBaseline   = 50; %Samples baseline
opt.wsBreakDelay = 15;
opt.wsTask       = 50; %Absolute task interval duration
opt.wsTaskExceed = 0;  %Relative (to stimulus' end) task interval duration
opt.wsRecovery   = 50; %i.e. 10 samples baseline
if exist('options','var')
    if isfield(options,'wsUnit')
        opt.wsUnit = options.wsUnit;
    end
    if isfield(options,'wsTimeUnitMultiplier')
        opt.wsTimeUnitMultiplier = options.wsTimeUnitMultiplier;
    end
    if isfield(options,'wsBaseline')
        opt.wsBaseline = options.wsBaseline;
    end
    if isfield(options,'wsBreakDelay')
        opt.wsBreakDelay = options.wsBreakDelay;
    end
    if isfield(options,'wsTask')
        opt.wsTask = options.wsTask;
    end
    if isfield(options,'wsTaskExceed')
        opt.wsTaskExceed = options.wsTaskExceed;
    end
    if isfield(options,'wsRecovery')
        opt.wsRecovery = options.wsRecovery;
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

%% Preliminaries
B = table('Size',[0 14],...
                        'VariableTypes',{'uint32','string',...
                                         'uint32','string',...
                                         'uint32','string',...
                                         'uint32','string',...
                                         'uint32','string',...
                                         'uint32',...
                                         'uint32','string',...
                                         'double'},...
                        'VariableNames',{'ExperimentalUnit.id','ExperimentalUnit.name',...
                                         'Group.id','Group.name',...
                                         'Session.id','Session.name',...
                                         'SamplingSite.id','SamplingSite.name',...
                                         'Condition.id','Condition.name',...
                                         'Trial',...
                                         'Signal.id','Signal.name',...
                                         'IntegrityFlag'}); %The base space
E = table(); %The total space




%For the time being, make as many sampling sites as channels
%but this needs changing to support ROIs
flagSites = true;
samplingSites = table('Size',[0 6],...
    'VariableTypes',{'uint32','string','double','double','double','cell'},...
    'VariableNames',{'Site.id','Site.name','ChannelNumber',...
                     'Source','Detector','Nominal3DLocation'});



%% Main loop
expUnitIDs=getSubjectList(theExperiment);
nExpUnits=length(expUnitIDs);
for euID=expUnitIDs
    disp(['Processing experimental Unit (Subject) ' num2str(euID)])
    expUnit = getSubject(theExperiment,euID);

    %At the time of writing this, the place holder for Group
    %is ready in the experimentBundle but not yet available
    %in the experiment. Hence, by the time being, the group
    %is fixed to id=1 and a default name.
    group.id   = 1;
    group.name = 'GroupDefault';

    sessIDs = getSessionList(expUnit);
    for ssID=sessIDs
        %disp([' * Session ' num2str(ssID)])
        sess=getSession(expUnit,ssID);
        dsIDs=getDataSourceList(sess);
        for dsID=dsIDs
            %disp(['   * Data source ' num2str(dsID)])
            ds = getDataSource(sess,dsID);
            sdID = ds.activeStructured;
            sd = getStructuredData(ds,sdID);



            %For the time being, make as many sampling sites as channels
            %but this needs changing to support ROIs
            nChannels = sd.chLocationMap.nChannels;

            if flagSites 
                warning('off')
                for iCh = 1:nChannels
                    samplingSites(iCh,'Site.id')   = {iCh};
                    src = sd.chLocationMap.pairings(iCh,1);
                    det = sd.chLocationMap.pairings(iCh,2);
                    samplingSites(iCh,'Site.name') = {['ch' num2str(iCh,'%02d') ...
                                               ':Src' num2str(src,'%02d') ...
                                               '-Det' num2str(det,'%02d')]};
                    samplingSites(iCh,'ChannelNumber')     = {iCh};
                    samplingSites(iCh,'Source')            = {src};
                    samplingSites(iCh,'Detector')          = {det};
                    samplingSites{iCh,'Nominal3DLocation'} = ...
                                      {sd.chLocationMap.chLocations(iCh,:)};
                end
                warning('on')
                flagSites = false;
            end

    

            t = icnna.data.core.timeline(sd.timeline); %Typecast if necessary
            integrityCodes = sd.integrity;


            signalTags = sd.signalTags;
            nSignals   = sd.nSignals;
            nSites     = size(samplingSites,1);




            %Window splitting: Extract the trials/blocks subinterval tensors
            [idList,~]               = t.getConditionsList();
            optWS.unit               = opt.wsUnit; 
            optWS.timeUnitMultiplier = opt.wsTimeUnitMultiplier; 
            optWS.baseline           = opt.wsBaseline; 
            optWS.breakDelay         = opt.wsBreakDelay; 
            if flagTask
                optWS.task           = opt.wsTask;
            else
                optWS.taskExceed     = opt.wsTaskExceed; 
            end
            optWS.recovery           = opt.wsRecovery; 
            [trialData] = icnna.op.getTrialData(sd,idList,optWS);
            clear optWS

            tmpNCases = numel(trialData);
            tmpE = table('Size',[tmpNCases*nSites*nSignals 4],...
                        'VariableTypes',{'cell','cell','cell','cell'},...
                        'VariableNames',{'Baseline','BreakDelay',...
                                         'Task','Recovery'}); %The total space
            
            tmpB = table('Size',[tmpNCases*nSites*nSignals 14],...
                        'VariableTypes',{'uint32','string',...
                                         'uint32','string',...
                                         'uint32','string',...
                                         'uint32','string',...
                                         'uint32','string',...
                                         'uint32',...
                                         'uint32','string',...
                                         'double'},...
                        'VariableNames',{'ExperimentalUnit.id','ExperimentalUnit.name',...
                                         'Group.id','Group.name',...
                                         'Session.id','Session.name',...
                                         'SamplingSite.id','SamplingSite.name',...
                                         'Condition.id','Condition.name',...
                                         'Trial',...
                                         'Signal.id','Signal.name',...
                                         'IntegrityFlag'}); %The base space

            jEntry = 1;
            for iCase = 1:tmpNCases
                warning('off')
                tmpB(jEntry:jEntry+(nSites*nSignals)-1,'ExperimentalUnit.id') ...
                        = {expUnit.id};
                tmpB(jEntry:jEntry+(nSites*nSignals)-1,'ExperimentalUnit.name') ...
                        = {expUnit.name};
                tmpB(jEntry:jEntry+(nSites*nSignals)-1,'Group.id') ...
                        = {group.id};
                tmpB(jEntry:jEntry+(nSites*nSignals)-1,'Group.name') ...
                        = {group.name};
                tmpB(jEntry:jEntry+(nSites*nSignals)-1,'Session.id') ...
                        = {sess.definition.id};
                tmpB(jEntry:jEntry+(nSites*nSignals)-1,'Session.name') ...
                        = {sess.definition.name};
                warning('on')

                %"Move" the trials subinterval tensors to the bundle.
                %Note that the trial data still have to be split
                %by sampling site and signal.
                baselineData   = trialData(iCase).baseline;
                breakDelayData = trialData(iCase).breakDelay;
                taskData       = trialData(iCase).task;
                recoveryData   = trialData(iCase).recovery;



                %Split subtensors according to sampling site
                for iSampSite = 1:nSites

                    for kSignal = 1:nSignals
    
                        tmpB{jEntry,'SamplingSite.id'}    = samplingSites{iSampSite,'Site.id'};
                        tmpB{jEntry,'SamplingSite.name'}  = samplingSites{iSampSite,'Site.name'};
                        
                        tmpB{jEntry,'Condition.id'}       = trialData(iCase).condId;
                        tmpCondName = t.getConditions(trialData(iCase).condId);
                        tmpB{jEntry,'Condition.name'}     = string(tmpCondName.name);
                        tmpB{jEntry,'Trial'}              = trialData(iCase).eventNumber;
                    
                        tmpB{jEntry,'Signal.id'}          = kSignal;
                        tmpB{jEntry,'Signal.name'}        = string(signalTags{kSignal});

                        tmpB{jEntry,'IntegrityFlag'}      = integrityCodes.getStatus(iSampSite);
                            %WATCH OUT! This line above contains an
                            %uncorrected bug right now. It is accessing
                            %the sampling site as a proxi of an individual
                            %channel. To be correct, this needs to be
                            %replaced for a function that truly calculates
                            %an overall integrity status for the whole
                            %sampling site.


                        siteIdx = samplingSites{iSampSite,'ChannelNumber'}; 

                        %Silly as it is, MATLAB cannot simply "assign" a
                        %vector to a single table cell directly as
                        %it interprets that vector as attempting to 
                        %assign values to different columns or rows. That
                        %is, if V is a vector, something like 
                        % tmpE{i,j} = V fails
                        %The way to circumvent this is to tell MATLAB
                        %that you are indeed interested in treating a
                        %column vector as a single entity, i.e.
                        % tmpE{i,j} = {V}
                        %but of course this creates a cell nesting and
                        %to retrieve the vector from the table, now
                        %you need a double unpacking;
                        % tmpE{i,j}{:}
                        %...to get back to V.
                        %
                        % Alternatives such as;
                        % tmpE(i,j) = {V}
                        %won't create the nested cells, but they are not
                        %robust. For instance, if V is a vector of length 1
                        %then MATLAB will interpret it as a single scalar
                        %rather than a vector and hence it cannot be
                        %converted to cell. In other words, tmpE(i,j) = {V}
                        %won't work for the specific case of V with length
                        %1.
                        %
                        % In principle, the use of cell2table also leads
                        % to the nesting, e.g. following
                        % silly  = {[1 2];[3]}
                        % silly2 = cell2table(silly)
                        % ...one still to double unpacking
                        % silly2{1,1}{:}
                        %
                        % As far as I can tell (and genAI can tell me),
                        %there is no way to circumvent the nesting; A table
                        %cannot have a column for which the content is
                        %a vector. It does have a column of cell whose
                        %content is in turn a vector...
                        %
                        % So just BEWARE during the retrieval!

                        tmpE{jEntry,'Baseline'}   = {baselineData(:,siteIdx,kSignal)};
                        tmpE{jEntry,'BreakDelay'} = {breakDelayData(:,siteIdx,kSignal)};
                        tmpE{jEntry,'Task'}       = {taskData(:,siteIdx,kSignal)};
                        tmpE{jEntry,'Recovery'}   = {recoveryData(:,siteIdx,kSignal)};

                        jEntry = jEntry + 1;
                    end %for signal

                end %for sampling site

            end %for case

            E = [E; tmpE];
            
            B = [B; tmpB];

        end %for data source

    end %for session

end %for experimental unit


%Finally, put everything in place...
S = icnna.data.core.experimentBundle();
S.setSites(samplingSites);
S.setBundle(E,B); %Use the implicit bijective projection p


end
