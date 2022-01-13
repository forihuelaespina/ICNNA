function obj=detrend(obj)
%NIRS_NEUROIMAGE/DETREND Apply a linear detrending to the image
%
%   obj2 = detrend(obj,r) Apply a signal linear detrending
%       based on the rest periods (i.e. baseline).
%
%Detrend uses the timeline of the image in order to look
%for resting periods but does not need to adjust the timeline
%at all.
%
%% Remarks
%
%This method is basically a wrap for detrend applied to all
%picture elements and signals.
%
%
% Copyright 2007-2008
% Author: Felipe Orihuela-Espina
% Date: 29-May-2008
%
% See also decimate, rawData.convert, timeline
%
%

%Temporarily create a fictitious timeline with only
%one condition including all the real events
tline=get(obj,'Timeline');
nCond=get(tline,'NConditions');
events=zeros(0,2);
for ii=1:nCond
    tag=getConditionTag(tline,ii);
    events=[events; getConditionEvents(tline,tag)];
end
%Ignore a number of seconds after the end of the block to allow
%for baseline stabilization.
nSecondsRestInitAfterEndOfStimulus=5;
events(:,2)=events(:,2)+nSecondsRestInitAfterEndOfStimulus;
events=mergeEvents(events);

%Look for the rest periods only
nEvents=size(events,1);
nextInit=1;
restSamplesIdx=zeros(1,0);
for ii=1:nEvents
    startIdx=nextInit; %This rest period init
    nextStart=(events(ii,1)+events(ii,2))+1; %Next rest period init
    finishIdx=events(ii,1)-1; %This rest period end
    restSamplesIdx=[restSamplesIdx startIdx:finishIdx];
end
restSamplesIdx=[restSamplesIdx nextInit:get(tline,'Length')];

data=get(obj,'Data');
[nSamples,nChannels,nSignals]=size(data);
%h=waitbar(0,'Detrending nirs\_neuroimage... 0%');
for ss=1:nSignals
    for pe=1:nChannels
        %waitbar((pe+nChannels*ss-nChannels)/(nSignals*nChannels), ...
        %    h,['Detrending nirs\_neuroimage...',...
        %    sprintf('%2.0f',(pe+nChannels*ss-nChannels)/(nSignals*nChannels)*100),'%']);
        restSamples(:,pe,ss)=data(restSamplesIdx',pe,ss);
        %Linear order fitting of the rest samples
        p0(:,pe,ss)=polyfit(restSamplesIdx',restSamples(:,pe,ss),1);
        baseline(:,pe,ss)=polyval(p0(:,pe,ss),1:nSamples);

        %Correction
        tempData(:,pe,ss)=data(:,pe,ss)-baseline(:,pe,ss);
    end
end
obj=set(obj,'Data',tempData);

assertInvariants(obj);
%close(h);


%% Auxiliar funtion
%%====================================
function events=mergeEvents(events)
%Removes unnecessary events and merge overlapping events
%Merge those events that might overlap
if(~isempty(events))
    events=sortrows(events,1);
end
nEvents=size(events,1);
for ee=nEvents-1:-1:1
    if (events(ee,1)+events(ee,2)>=events(ee+1,1))
        if (events(ee,1)+events(ee,2)>events(ee+1,1)+events(ee+1,2))
            %%%In this case, the "first" episode starts earlier and last
            %%%for longer than the second one. Moreover, the second one
            %%%finished before the first. Therefore
            %do nothing, as the duration of the first episode already
            %points to the last sample of the episode
        else %the first episode finished first
            %the new merged episode, will start where the first start
            %but will last until the end of the second
            events(ee,2)=(events(ee+1,1)-events(ee,1))+events(ee+1,2);
        end
        events(ee+1,:)=[];
    end
end
