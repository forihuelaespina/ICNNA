function obj=compute(obj,e)
%EXPERIMENTSPACE/COMPUTE Compute the space with current configuration
%
% obj=compute(obj,e) Compute the space with current configuration
%   on experiment e with the current analysis parameters.
%   It sets the computing status to true.
%
%
%% Remarks
%
% The experiment space is computed over active data and only
%for those channels for which the integrity code is
%integrityStatus.FINE. This means that computing the experiment
%Space from a experimental dataset e for which integrity
%has not been checked, result in an empty experimental
%space, as all data will be labelled as integrityStatus.UNCHECKED.
%
%
% See note about the breakDelay in experimentSpace. This function
%does NOT currently apply the breakDelay. Instead this is applied
%later in generateDB_withBreakDelay. While correct, but this is
%certainly confusing and at some point I need to change this behavior
%and apply the breakDelay here.
%
%% Parameters
%
% e - An experiment
%
%
% Copyright 2008-25
% @author: Felipe Orihuela-Espina
%
% See also experimentSpace, analysis, getConnectivity
%


%% Log
%
% File created: 27-Jun-2008
% File last modified (before creation of this log): 10-Abr-2013
%
% 24-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%
% 7-Jun-2023: FOE
%   + Continue updating calls to get attributes using the struct like syntax
%
% 23-Feb-2024: FOE
%   + Enriched functionality of fwDuration with potential values
%   -1 (whole block) and -2 (until block offset).
%   + Bug fixed. Improved treatment of empty blocks.
%
% 17-Apr-2025: FOE
%   + Improved some comments.
%



subjIDs=getSubjectList(e);
nSubjects=length(subjIDs);
step=1/nSubjects;
x=0;
h=waitbar(x,['Constructing Experiment Space - Subject 1/' ...
            num2str(nSubjects) ' : 0%']);

%Reset the data, in case it is re-computing...
obj.Fvectors=cell(0,1);
obj.Findex=zeros(0,8);
        
posSubj=1;
pos=1;
for sID=subjIDs
    %disp(['Subject ' num2str(sID)])
    subj=getSubject(e,sID);
    sessIDs=getSessionList(subj);
    substep=step/length(sessIDs);
    for ssID=sessIDs
        %disp([' * Session ' num2str(ssID)])
        ss=getSession(subj,ssID);
        dsIDs=getDataSourceList(ss);
        for dsID=dsIDs
            %disp(['   * Data source ' num2str(dsID)])
            ds = getDataSource(ss,dsID);
            sdID = ds.activeStructured;
            sd = getStructuredData(ds,sdID);

            t = sd.timeline;
            integrityCodes = sd.integrity;
            %%TO DO: Still need to check whether timelines are compatible
            nChannels = sd.nChannels;
            nSignals = sd.nSignals;
            nStim = t.nConditions;
            for stim=1:nStim
                stimTag=getConditionTag(t,stim);
                %disp(['     * Stim ' num2str(stim) ': ' stimTag])
                                
                %% Stage 1: Block Splitting                
                nBlocks=getNEvents(t,stimTag);
                %Temporarily collect the blocks for this condition
                tmpBlocks = cell(nBlocks,1);
                bSamples  = obj.baselineSamples;
                rSamples  = obj.restSamples;
                for bl=1:nBlocks
                    if (rSamples < 0)
                        tmpBlocks(bl)=...
                            {getBlock(sd,stimTag,bl,...
                                'NBaselineSamples',bSamples)};
                    else
                        tmpBlocks(bl)=...
                            {getBlock(sd,stimTag,bl,...
                                'NBaselineSamples',bSamples,...
                                'NRestSamples',rSamples)};
                    end
                end
                
                %% Stage 2: Resampling
                if (obj.resampled)
                    nRSSamples=[obj.rs_baseline obj.rs_task obj.rs_rest];
                    for bl=1:nBlocks
                        s=warning('query','ICNNA:timeline:set:EventsCropped');
                        warning('off','ICNNA:timeline:set:EventsCropped');
                        tmpBlocks(bl)={blockResample(...
                            tmpBlocks{bl},nRSSamples)};
                        warning(s.state,'ICNNA:timeline:set:EventsCropped');
                            %Leave the warning state as it was
                    end
                end
                
                %% Stage 3: Block Averaging
                if (obj.averaged)
                    nBlocks=1;
                    avgBlock=blocksTemporalAverage(tmpBlocks);
                    clear tmpBlocks
                    tmpBlocks={avgBlock};
                    clear avgBlock
                end
                
                %% Stage XX: Normalization
                    %See below
                
                %% Stage 4: Window Selection
                %if (get(obj,'Windowed'))
                    for bl=1:nBlocks
                        theBlock = tmpBlocks{bl};
                        if ~isempty(theBlock)
                            t2=theBlock.timeline;
    
    
                            s=warning('query','ICNNA:timeline:set:EventsCropped');
                            warning('off','ICNNA:timeline:set:EventsCropped');
                            if obj.ws_duration >= 0
                                tmpBlocks(bl)={windowSelection(theBlock,...
                                getConditionTag(t2,1),1,...
                                obj.ws_onset,...
                                obj.ws_duration)};
                            elseif obj.ws_duration == -1
                                %Take however much is needed until the block
                                %end
                                tmpBlocks(bl)={windowSelection(theBlock,...
                                getConditionTag(t2,1),1,...
                                obj.ws_onset,...
                                t2.length)};                            
                            elseif obj.ws_duration == -2
                                %Take until the block offset
                                %Note that this may result in different
                                %lengths per event!
                                tmpTag = t2.getConditionTag(1);
                                tmpCEvents = t2.getConditionEvents(tmpTag);
                                tmpBlocks(bl)={windowSelection(theBlock,...
                                tmpTag,1,...
                                obj.ws_onset,...
                                tmpCEvents(:,1)+tmpCEvents(:,2))};                            
                            end
                            warning(s.state,'ICNNA:timeline:set:EventsCropped');
                                %Leave the warning state as it was

                        else
                            tmpBlocks(bl)={[]};
                        end
                    end
                %end

                
                
                %% Stage X: Adding points to the Experiment Space
                %Add the point or points depending on
                %analysis parameters
                for bl=1:nBlocks
                    %Now go through clean channels
                    for chID=1:nChannels
                        % disp(['Channel ' num2str(chID) ': ' ...
                        %      num2str(getStatus(integrityCodes,chID))]);


                        if (getStatus(integrityCodes,chID)==integrityStatus.FINE)
                            if isempty(tmpBlocks{bl})
                                channelData=[];
                            else
                                channelData=getChannel(tmpBlocks{bl},chID);
                            end
                            for signID=1:nSignals

%                                 disp([num2str(sID) ' ' num2str(ssID) ' ' ...
%                                      num2str(dsID) ' ' num2str(sdID) ' ' ...
%                                      num2str(chID) ' ' num2str(signID) ' ' ...
%                                      num2str(stim) ' ' num2str(bl) ' ']);


                                obj.Findex(pos,obj.DIM_SUBJECT)=sID;
                                obj.Findex(pos,obj.DIM_SESSION)=ssID;
                                obj.Findex(pos,obj.DIM_DATASOURCE)=dsID;
                                obj.Findex(pos,obj.DIM_STRUCTUREDDATA)=sdID;
                                obj.Findex(pos,obj.DIM_CHANNEL)=chID;
                                obj.Findex(pos,obj.DIM_SIGNAL)=signID;
                                obj.Findex(pos,obj.DIM_STIMULUS)=stim;
                                obj.Findex(pos,obj.DIM_BLOCK)=bl;

                                if isempty(channelData)
                                    obj.Fvectors(pos)={nan(0,1)};
                                else
                                    obj.Fvectors(pos)={channelData(:,signID)};
                                end

                                pos=pos+1;
                            end %of signals
                        end %if empty channel
                    end %of channels
                end %of blocks
            end %of stimulus
        end %of dataSource
        x=x+substep;
        waitbar(x,h,['Constructing Experiment Space - Subject ' ...
            num2str(posSubj) '/' num2str(nSubjects) ' : ' ...
            num2str(x*100,'%10.1f') '%']);
    end %of session
    posSubj=posSubj+1;
end %of subject


%% Stage 5: Normalization
if (obj.normalized)
    obj = obj.normalize();
end


%% Capture session names
sessions=getSessionDefinitionList(e);
sessNames=struct('sessID',{},'name',{});
pos=1;
for ss=sessions
    sessDef=getSessionDefinition(e,ss);
    sessNames(pos).sessID = ss;
    sessNames(pos).name = sessDef.name;
    pos=pos+1;
end
obj.sessionNames = sessNames;

obj.runStatus=true;

waitbar(1,h,'Constructing Experiment Space : 100%');
close(h);


assertInvariants(obj);



end