function nimg=convert(obj,varargin)
%RAWDATA_UCLWIRELESS/CONVERT Convert raw data concentrations to a neuroimage
%
% obj=convert(obj) Convert raw data concentrations to a fNIRS
%   neuroimage. 
%
% obj=convert(obj,optionName,optionValue) Convert raw light
%   intensities to a fNIRS neuroimage.
%
%
% Since raw data here is already reconstructed, the task is limited to
%reformat the information to the format demanded by class
%structuredData->nirs_neuroimage
%
%
%% Parameters
%
% obj - The rawData_UCLWireless object to be converted to a nirs_neuroimage
%
% Options - optionName, optionValue pair arguments
%   'AllowOverlappingConditions' - Permit adding conditions to the
%       timeline with an events overlapping behaviour.
%           0 - (Default) Overlapping conditions
%           1 - Non-overlapping conditions
%
% 
% Copyright 2016
% @date: 1-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 1-Sep-2016
% 
%
% See also rawData_UCLWireless, import, neuroimage, NIRS_neuroimage
%



opt.allowOverlappingConditions = 0; %Default. Non-overlapping conditions
while ~isempty(varargin) %Note that the object itself is not counted.
    optName = varargin{1};
    if length(varargin)<2
        error('ICNA:rawData_UCLWireless:convert:InvalidOption', ...
            ['Option ' optName ': Missing option value.']);
    end
    optValue = varargin{2};
    varargin(1:2)=[];
    
    switch lower(optName)
        case 'allowoverlappingconditions'
            %Check that the value is acceptable
            %   0 - Overlapping conditions
            %   1 - Non-overlapping conditions
            if (optValue==0 || optValue==1)
                opt.allowOverlappingConditions = optValue;
            else
                error('ICNA:rawData_UCLWireless:convert:InvalidOption', ...
                     ['Option ' optName ': Unexpected value ' num2str(optValue) '.']);
            end
            
        otherwise
            error('ICNA:rawData_UCLWireless:convert:InvalidOption', ...
                  ['Invalid option ' optName '.']);
    end
end


%fprintf('Converting intensities to Hb data ->  0%%');

if isempty(obj.oxyRawData)
    %Can't do much more, can I? So just return the default neuroimage
    nimg=nirs_neuroimage(1);
    return
end


%Some basic initialization
nSamples=get(obj,'nSamples');
nSignals=2;
nChannels = get(obj,'nChannels');
nWlengths=length(get(obj,'nominalWavelengthSet'));
nimg=nirs_neuroimage(1,[nSamples,nChannels,nSignals]);



c_hb=zeros(nSamples,nChannels,2);
c_hb(:,:,nirs_neuroimage.OXY)=get(obj,'oxyRawData');
c_hb(:,:,nirs_neuroimage.DEOXY)=get(obj,'deoxyRawData');
nimg=set(nimg,'Data',c_hb);

%fprintf('\n');

%Now update the channel location map information
%waitbar(1,wwait,'Updating channel location map...');
%fprintf('Updating channel location map...\n');
clm = get(nimg,'ChannelLocationMap');
clm = setChannelProbeSets(clm,1:nChannels,ones(nChannels,1));
    %Only one probe set, so all channels are linked to that probeSet
clm = setChannelOptodeArrays(clm,1:nChannels,ones(nChannels,1));
    %Only one optode array, so all channels are linked to that probeSet
%clm = setOptodeArraysInfo(clm,1:length(oaInfo),oaInfo);
    %At this point, neither, the channel 3D locations, the stereotactic
    %positions nor the surface positions are known.
    %Neither is known anything about the optodes.
nimg = set(nimg,'ChannelLocationMap',clm);


%% Set signal tags
nimg=setSignalTag(nimg,nirs_neuroimage.OXY,'HbO_2');
nimg=setSignalTag(nimg,nirs_neuroimage.DEOXY,'HHb');

%% Extract the timeline
%waitbar(1,wwait,'Extracting timeline from marks...');
%fprintf('Extracting timeline from marks...\n');

theTimeline=timeline(nSamples);

%Decide on the number and codes of experimental conditions
condIDs = unique([obj.preTimeline.code]);
    %Condition IDs cannot be 0 or negative. So if such code exists,
    %then issue a warning ignore them.
    if any(condIDs<=0)
       condIDs(condIDs<=0)=[];
       warning('ICNA:rawData_UCLWireless:convert:InvalidTimelineConditionID',...
           ['Invalid timeline condition ID found. ' ...
           'All condition codes lower or equal to 0 will be ignored.']);
    end        

%nConds = length(condsID);

%Preallocate some memory

%condNames = unique({obj.preTimeline.label});
%Note that there may be spelling mistakes...so the number of conditions
%labels may not match the number of codes. Since I have no way to know
%which spelling is correct, I will simple assume that the first
%spelling is ok, and then check the rest against this first spelling

condNames = cell(max(condIDs),1);    
condEvents = cell(max(condIDs),1);
condEventsInfo = cell(max(condIDs),1);
    %Allocating up to max(condIDs) instead of nConds is not memory
    %efficient, but makes my life easier by not needing to index
    %the conditions ID.
nEvents = length(obj.preTimeline);

for ee=1:nEvents
    theEvent = obj.preTimeline(ee);
    
    condID = theEvent.code;
    
    %If condID<=0, skip this event
    if (condID > 0)
    
        condName = theEvent.label;
        if isempty(condNames{condID})
            condNames(condID)={condName};
        else
            if ~strcmp(condNames{condID}, condName)
                warning('ICNA:rawData_UCLWireless:convert:UnexpectedConditionName',...
                    ['Unexpected condition label for event ' num2str(ee) '. ' ...
                    'Using default condition name (first spelling found).']);
                
            end
        end
        
        %Translate starttime and endtime to onset and duration
        t = datetime(theEvent.starttime,'InputFormat','HH:mm:ss.SSS');
        onsetTime = 3600*t.Hour + 60*t.Minute + t.Second ;%Convert to secs
        t = datetime(theEvent.endtime,'InputFormat','HH:mm:ss.SSS');
        endTime = 3600*t.Hour + 60*t.Minute + t.Second ;%Convert to secs
        %...and convert to samples
        onset = floor(onsetTime * get(obj,'SamplingRate'));
        theEndTime = floor(endTime * get(obj,'SamplingRate'));
        duration = theEndTime - onset;
        
        %Now, add the event to the condition
        cEvents = condEvents{condID};
        if isempty(cEvents)
            cEvents = [onset duration];
        else
            cEvents = [cEvents; onset duration];
        end
        condEvents(condID)= {cEvents};
        
        %Finally, add the reminderas eventInfo.
        cEventsInfo = condEventsInfo{condID};
        if isempty(cEventsInfo)
            cEventsInfo = {theEvent.remainder};
        else
            cEventsInfo(end+1) = {theEvent.remainder};
        end
        condEventsInfo(condID)= {cEventsInfo};
        
    end %if
end

%Now take all that information to the timeline
for cc=condIDs
    theTimeline=addCondition(theTimeline,condNames{cc},...
                    condEvents{cc},condEventsInfo{cc},...
                    opt.allowOverlappingConditions);
end


%... and now the same with the timestamps
theTimeline=set(theTimeline,'Timestamps',obj.timestamps);

theTimeline=set(theTimeline,'StartTime',get(obj,'Date'));
theTimeline=set(theTimeline,'NominalSamplingRate',get(obj,'SamplingRate'));

nimg=set(nimg,'Timeline',theTimeline);




%close (wwait);
