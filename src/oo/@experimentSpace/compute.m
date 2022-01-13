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
%% Parameters
%
% e - An experiment
%
%
% Copyright 2008-13
% @date: 27-Jun-2008
% @author: Felipe Orihuela-Espina
% @modified: 10-Abr-2013
%
% See also experimentSpace, analysis, getConnectivity
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
    subj=getSubject(e,sID);
    sessIDs=getSessionList(subj);
    substep=step/length(sessIDs);
    for ssID=sessIDs
        ss=getSession(subj,ssID);
        dsIDs=getDataSourceList(ss);
        for dsID=dsIDs
            ds=getDataSource(ss,dsID);
            sdID=get(ds,'ActiveStructured');
            sd=getStructuredData(ds,sdID);

            t=get(sd,'Timeline');
            integrityCodes=get(sd,'Integrity');
            %%TO DO: Still need to check whether timelines are compatible
            nChannels=get(sd,'NChannels');
            nSignals=get(sd,'NSignals');
            nStim=get(t,'NConditions');
            for stim=1:nStim
                stimTag=getConditionTag(t,stim);
                                
                %% Stage 1: Block Splitting                
                nBlocks=getNEvents(t,stimTag);
                %Temporarily collect the blocks for this condition
                tmpBlocks=cell(nBlocks,1);
                bSamples=get(obj,'BaselineSamples');
                rSamples=get(obj,'RestSamples');
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
                if (get(obj,'Resampled'))
                    nRSSamples=[get(obj,'RS_Baseline') ...
                        get(obj,'RS_Task') ...
                        get(obj,'RS_Rest')];
                    for bl=1:nBlocks
                        s=warning('query','ICNA:timeline:set:EventsCropped');
                        warning('off','ICNA:timeline:set:EventsCropped');
                        tmpBlocks(bl)={blockResample(...
                            tmpBlocks{bl},nRSSamples)};
                        warning(s.state,'ICNA:timeline:set:EventsCropped');
                            %Leave the warning state as it was
                    end
                end
                
                %% Stage 3: Block Averaging
                if (get(obj,'Averaged'))
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
                        t2=get(tmpBlocks{bl},'Timeline');
                        
                        s=warning('query','ICNA:timeline:set:EventsCropped');
                        warning('off','ICNA:timeline:set:EventsCropped');
                            tmpBlocks(bl)={windowSelection(tmpBlocks{bl},...
                            getConditionTag(t2,1),1,...
                            get(obj,'WS_Onset'),...
                            get(obj,'WS_Duration'))};
                        warning(s.state,'ICNA:timeline:set:EventsCropped');
                            %Leave the warning state as it was
                    end
                %end

                
                
                %% Stage X: Adding points to the Experiment Space
                %Add the point or points depending on
                %analysis parameters
                for bl=1:nBlocks
                    %Now go through clean channels
                    for chID=1:nChannels
%                         disp(['Channel ' num2str(chID) ': ' ...
%                              num2str(getStatus(integrityCodes,chID))]);
                        if (getStatus(integrityCodes,chID)==integrityStatus.FINE)
                            channelData=getChannel(tmpBlocks{bl},chID);
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

                                obj.Fvectors(pos)={channelData(:,signID)};

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
if (get(obj,'Normalized'))
    obj=normalize(obj);
end


%% Capture session names
sessions=getSessionDefinitionList(e);
sessNames=struct('sessID',{},'name',{});
pos=1;
for ss=sessions
    sessDef=getSessionDefinition(e,ss);
    sessNames(pos).sessID = ss;
    sessNames(pos).name = get(sessDef,'Name');
    pos=pos+1;
end
obj=set(obj,'SessionNames',sessNames);

obj.runStatus=true;

waitbar(1,h,'Constructing Experiment Space : 100%');
close(h);


assertInvariants(obj);