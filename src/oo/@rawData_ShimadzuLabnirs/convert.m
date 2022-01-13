function nimg=convert(obj,varargin)
%RAWDATA_SHIMADZULABNIRS/CONVERT Convert raw data to a neuroimage
%
% obj=convert(obj) Convert raw data to a fNIRS neuroimage. 
%
% obj=convert(obj,optionName,optionValue) Convert raw data to a fNIRS neuroimage.
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
% @date: 20-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 20-Sep-2016
% 
%
% See also rawData_ShimadzuLabnirs, import, neuroimage, NIRS_neuroimage
%



opt.allowOverlappingConditions = 0; %Default. Non-overlapping conditions
while ~isempty(varargin) %Note that the object itself is not counted.
    optName = varargin{1};
    if length(varargin)<2
        error('ICNA:rawData_ShimadzuLabnirs:convert:InvalidOption', ...
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
                error('ICNA:rawData_ShimadzuLabnirs:convert:InvalidOption', ...
                     ['Option ' optName ': Unexpected value ' num2str(optValue) '.']);
            end
            
        otherwise
            error('ICNA:rawData_ShimadzuLabnirs:convert:InvalidOption', ...
                  ['Invalid option ' optName '.']);
    end
end


%fprintf('Converting intensities to Hb data ->  0%%');

if isempty(obj.rawData)
    %Can't do much more, can I? So just return the default neuroimage
    nimg=nirs_neuroimage(1);
    return
end


%Some basic initialization
nSamples=get(obj,'nSamples');
nSignals=nirs_neuroimage.TOTALHB;
nChannels = get(obj,'nChannels');
nWlengths=length(get(obj,'nominalWavelengthSet'));
nimg=nirs_neuroimage(1,[nSamples,nChannels,nSignals]);



c_hb=zeros(nSamples,nChannels,nirs_neuroimage.TOTALHB);
tmp = get(obj,'rawData');
oxyIdx = [1:3:3*nChannels];
c_hb(:,:,nirs_neuroimage.OXY)=tmp(:,oxyIdx);
c_hb(:,:,nirs_neuroimage.DEOXY)=tmp(:,oxyIdx+1);
c_hb(:,:,nirs_neuroimage.TOTALHB)=tmp(:,oxyIdx+2);
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
nimg=setSignalTag(nimg,nirs_neuroimage.TOTALHB,'HbT');

%% Extract the timeline
%waitbar(1,wwait,'Extracting timeline from marks...');
%fprintf('Extracting timeline from marks...\n');

theTimeline=timeline(nSamples);

%Decide on the number and codes of experimental conditions
condIDs = unique(obj.preTimeline);
%...and ignore the 0s
condIDs(condIDs==0)=[];
    %Condition IDs cannot be 0 or negative. So if such code exists,
    %then issue a warning ignore them.
    if any(condIDs<=0)
       condIDs(condIDs<=0)=[];
       warning('ICNA:rawData_ShimadzuLabnirs:convert:InvalidTimelineConditionID',...
           ['Invalid timeline condition ID found. ' ...
           'All condition codes lower or equal to 0 will be ignored.']);
    end        

nConds = length(condIDs);

%Preallocate some memory

for cc=1:nConds
    condNames(cc) = {num2str(condIDs(cc))};
end

condEvents = cell(max(condIDs),1);
condEventsInfo = cell(max(condIDs),1);
    %Allocating up to max(condIDs) instead of nConds is not memory
    %efficient, but makes my life easier by not needing to index
    %the conditions ID.
idx=find(obj.preTimeline~=0);
nEvents = length(idx);

for ee=1:nEvents
    theEvent = obj.preTimeline(idx(ee));
    
    condID = theEvent;
    
    %If condID<=0, skip this event
    if (condID > 0)
    
        condName = num2str(theEvent);
        Lia = ismember(condNames,condName);
        idxCC = find(Lia);
        if isempty(idxCC)
            condNames(end+1)={condName};
            Lia = ismember(condNames,condName); %...and refresh
            idxCC = find(Lia);
        elseif length(idxCC)>1 %Duplicate labels; fix
                error('ICNA:rawData_ShimadzuLabnirs:convert:UnexpectedConditionName',...
                    ['Possible duplicated label found during checking of event ' ...
                        num2str(ee) '.']);
        end
        %If it gets here, then it has found the label and the index
        %of the event in the list of condition names; but the index
        %is in the form of a list.
        idxCC = idxCC(1);
        
        %All events seem to be instantaneous
        onset = idx(ee);
        duration = 0;
        
        %Now, add the event to the condition
        cEvents = condEvents{idxCC};
        if isempty(cEvents)
            cEvents = [onset duration];
        else
            cEvents = [cEvents; onset duration];
        end
        condEvents(idxCC)= {cEvents};
        
        %Finally, add the eventInfo.
        cEventsInfo = condEventsInfo{idxCC};
        if isempty(cEventsInfo)
            cEventsInfo = cell(0,1);
            cEventsInfo(1) = {[]};
        else
            cEventsInfo(end+1) = {[]};
        end
        condEventsInfo(idxCC)= {cEventsInfo};
        
    end %if
end

%Now take all that information to the timeline
nConds = length(condIDs); %Refresh in case it has grown in the above loop through events
for cc=1:nConds
    theTimeline=addCondition(theTimeline,condNames{cc},...
                    condEvents{cc},condEventsInfo{cc},...
                    opt.allowOverlappingConditions);
end


%... and now the same with the timestamps
theTimeline=set(theTimeline,'Timestamps',get(obj,'Timestamps'));

theTimeline=set(theTimeline,'StartTime',get(obj,'Date'));
theTimeline=set(theTimeline,'NominalSamplingRate',get(obj,'SamplingRate'));

nimg=set(nimg,'Timeline',theTimeline);




%close (wwait);
