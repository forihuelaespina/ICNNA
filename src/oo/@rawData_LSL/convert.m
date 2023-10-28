function structData=convert(obj,varargin)
%RAWDATA_LSL/CONVERT Convert raw stream data to a structuredData
%
% structData=convert(obj) Convert the first data stream to a
%   structuredData.
%
% structData=convert(obj,k) Convert the k-th data stream to a
%   structuredData.
%
%
%% Remarks
%
% The type of structuredData (e.g. eyeTrack, neuroimage, etc) depends
%on the stream.
%
% NOTE: CURRENTLY IT ONLY SUPPORT IMPORTING EYETRACKING DATA. I will
%   add more as needed.
%
%% Parameters
%
% obj - The rawData_LSL object to be converted to a structuredData
%
% varargin - Reserved for future usage
%
% 
% Copyright 2021-23
% @author: Felipe Orihuela-Espina
%
% See also import, structuredData,
%





%% Log
%
% File created: 23-Aug-2021
% File last modified (before creation of this log): N/A
%
% 23-Aug-2021 (FOE): 
%	File created.
%
% 12-Oct-2021 (FOE): 
%   + Got rid of old labels @date and @modified.
%   + Migrated for struct like access to attributes.
%

k=1;
if nargin>1
    tmp = varargin{1};
    if ischar(tmp)
        tmp = str2double(tmp);
    end
    k = round(tmp);
end

if ~(k>0)
    error(['@rawData_LSL:convert: ' ...
           'Stream index k must be a positive integer ' ...
           '(k=' num2str(k) ').']);
end


nStreams = length(obj.data);
assert(k<=nStreams,...
    '@rawData_LSL:convert: Unexpected stream index k.');


theStream = getStream(obj,k);

%Check type and try to convert accordinly or attempt a "generic"
%recover.

streamDataType = theStream.info.type;
switch(streamDataType)
    case 'eye_tracker'
        %structData=convertEyeTracker(theStream); %See aux function below.
        structData=convertGenericStream(theStream); %See aux function below.
    otherwise
        warning(['@rawData_LSL:convert: Unrecognized stream data type. ' ...
                'Attempting generic conversion. Loss of meta-data information is likely.']);
        structData=convertGenericStream(theStream); %See aux function below.
end

end




%% AUXILIAR FUNCTIONS
function structData=convertGenericStream(theStream)
%Converts a LSL data stream to a generic @structuredData object
%
%% Input parameters
%
% theStream - A single LSL data stream
%
%% Output parameters
%
% structData - A structuredData
%

% 
% Copyright 2021
% @date: 23-Aug-2021
% @author: Felipe Orihuela-Espina
%
% See also convert,
%


%% Log
%
% 23-Aug-2021 (FOE): 
%	Function created as auxiliary to method @rawData_LSL.convert
%


timestamps=theStream.time_stamps;
rawData=theStream.time_series;
nSamples = size(rawData,2);
nChannels=size(rawData,1); %Make no assumption of the channels information 
nSignals=1;
tmpData=nan(nSamples,nChannels,nSignals);
tmpData(:,:,1)=rawData';

% Now proceed with conversion
structData=structuredData(1,[nSamples,nChannels,nSignals]);
structData.data = tmpData;

end

function structData=convertEyeTracker(theStream)
%Converts a LSL data stream to an @eyeTrack object


%frames=get(obj,'Frames');
timestamps=theStream.time_stamps;
rawData=theStream.time_series;
nSamples = size(rawData,2);
nChannels=7; %Gazepoint X, Gazepoint Y,
nSignals=2; %Eyes
%7 Cols per eye: Gazepoint X, Gazepoint Y,
%Cam X, Cam Y, Distance, Pupil, Validity
tmpData=nan(nSamples,nChannels,nSignals);


theFileVersion = obj.fileversion;
%Get only the "numerical" part
idx=find(theFileVersion==' ');
theFileVersion(1:idx)=[];


%% Now proceed with conversion
structData=eyeTrack(1,[nSamples,nChannels,nSignals]);
return

if nSamples>0
    %Gaze X and Y
    tmpData(:,eyeTrack.GAZEX,eyeTrack.LEFTEYE)=...
        rawData(:,rawData_BeGazeEyeTracker.DATA_LEFTEYE_GAZE_X);
    tmpData(:,eyeTrack.GAZEY,eyeTrack.LEFTEYE)=...
        rawData(:,rawData_BeGazeEyeTracker.DATA_LEFTEYE_GAZE_Y);
    tmpData(:,eyeTrack.GAZEX,eyeTrack.RIGHTEYE)=...
        rawData(:,rawData_BeGazeEyeTracker.DATA_RIGHTEYE_GAZE_X);
    tmpData(:,eyeTrack.GAZEY,eyeTrack.RIGHTEYE)=...
        rawData(:,rawData_BeGazeEyeTracker.DATA_RIGHTEYE_GAZE_Y);
    
    %Cam X and Y
    tmpData(:,eyeTrack.CAMX,eyeTrack.LEFTEYE)=...
        rawData(:,rawData_BeGazeEyeTracker.DATA_LEFTEYE_POSITION_X);
    tmpData(:,eyeTrack.CAMY,eyeTrack.LEFTEYE)=...
        rawData(:,rawData_BeGazeEyeTracker.DATA_LEFTEYE_POSITION_Y);
    tmpData(:,eyeTrack.CAMX,eyeTrack.RIGHTEYE)=...
        rawData(:,rawData_BeGazeEyeTracker.DATA_RIGHTEYE_POSITION_X);
    tmpData(:,eyeTrack.CAMY,eyeTrack.RIGHTEYE)=...
        rawData(:,rawData_BeGazeEyeTracker.DATA_RIGHTEYE_POSITION_Y);
    
    %   .DISTANCE - Channel Distance (from eye tracker to eye)
    %This will be left undetermined (i.e. nans).
    %   .PUPIL - Channel Pupil size
    if version_IsHigherOrEqual(theFileVersion,'3.5')
        tmpData(:,eyeTrack.PUPIL,eyeTrack.LEFTEYE)=...
            rawData(:,rawData_BeGazeEyeTracker.DATA_LEFTEYE_PUPIL_DIAMETER_MM);
        tmpData(:,eyeTrack.PUPIL,eyeTrack.RIGHTEYE)=...
            rawData(:,rawData_BeGazeEyeTracker.DATA_RIGHTEYE_PUPIL_DIAMETER_MM);
    else        
        tmpData(:,eyeTrack.PUPIL,eyeTrack.LEFTEYE)=...
            rawData(:,rawData_BeGazeEyeTracker.DATA_LEFTEYE_MAPPED_DIAMETER);
        tmpData(:,eyeTrack.PUPIL,eyeTrack.RIGHTEYE)=...
            rawData(:,rawData_BeGazeEyeTracker.DATA_RIGHTEYE_MAPPED_DIAMETER);
    end
    
    %   .VALIDITY - Channel Validity
    % Validity codes of the eyeTrack class are inherited from the
    %Tobii eyeTracker. Any other eye tracker has to map the
    %validity/quality codes to these codes.    
    %
    %Note that validity codes are used to calculate blinks
    %
    %In the case of the BeGaze eyeTracker the user can estimate the
    %validity codes based on timing and latency. But the user may decide
    %not to export these values. In those cases, I need to estimate
    %the quality from the value of the gaze.
    
    %Derived from timing and latency
    %I'm not currently sure of how these two; timing and latency are expressed,
    %and the BeGaze User manual doesn't give much information neither.
    %So take it easy here...
    if all(isnan(rawData(:,rawData_BeGazeEyeTracker.DATA_TIMING))) ...
            && all(isnan(rawData(:,rawData_BeGazeEyeTracker.DATA_LATENCY)))
        tmpData(:,eyeTrack.VALIDITY,eyeTrack.LEFTEYE)=0;
    elseif all(isnan(rawData(:,rawData_BeGazeEyeTracker.DATA_TIMING)))
        tmpData(:,eyeTrack.VALIDITY,eyeTrack.LEFTEYE)= ...
            and(rawData(:,rawData_BeGazeEyeTracker.DATA_TIMING),...
            rawData(:,rawData_BeGazeEyeTracker.DATA_LATENCY));
        idx=isnan(tmpData(:,eyeTrack.VALIDITY,eyeTrack.LEFTEYE));
        tmpData(idx,eyeTrack.VALIDITY,eyeTrack.LEFTEYE)=4;
    else %Derived from recorded data
        lx_nan  = isnan(rawData(:,rawData_BeGazeEyeTracker.DATA_LEFTEYE_GAZE_X));
        ly_nan  = isnan(rawData(:,rawData_BeGazeEyeTracker.DATA_LEFTEYE_GAZE_Y));
        rx_nan  = isnan(rawData(:,rawData_BeGazeEyeTracker.DATA_RIGHTEYE_GAZE_X));
        ry_nan  = isnan(rawData(:,rawData_BeGazeEyeTracker.DATA_RIGHTEYE_GAZE_Y));
        
        l_nan = any([lx_nan ly_nan],2);
        r_nan = any([rx_nan ry_nan],2);
           
        
        %Operations NOR and NAND are no longer available, and they should
        %be done by applying NOT to OR and AND respectively.
        % https://la.mathworks.com/help/matlab/matlab_prog/truth-table-for-logical-operations.html
        nonEyeIdx = not(or(l_nan,r_nan)); 
        oneEyeIdx = xor(l_nan,r_nan);
        twoEyeIdx = not(and(l_nan,r_nan));
        tmpData(nonEyeIdx,eyeTrack.VALIDITY,eyeTrack.LEFTEYE)=4;
        tmpData(oneEyeIdx,eyeTrack.VALIDITY,eyeTrack.LEFTEYE)=1;
        tmpData(twoEyeIdx,eyeTrack.VALIDITY,eyeTrack.LEFTEYE)=0;
    end    
        
        %Also check periods of 0.00s
        tmp =  [rawData(:,rawData_BeGazeEyeTracker.DATA_LEFTEYE_GAZE_X) ...
                rawData(:,rawData_BeGazeEyeTracker.DATA_LEFTEYE_GAZE_Y) ...
                rawData(:,rawData_BeGazeEyeTracker.DATA_RIGHTEYE_GAZE_X) ...
                rawData(:,rawData_BeGazeEyeTracker.DATA_RIGHTEYE_GAZE_Y)];
        zerosIdx = all(tmp==0,2);
        tmpData(zerosIdx,eyeTrack.VALIDITY,eyeTrack.LEFTEYE)=4;
        
        %Finally get rid of any remining NaN
        restIdx =isnan(tmpData(:,eyeTrack.VALIDITY,eyeTrack.LEFTEYE));
        tmpData(restIdx,eyeTrack.VALIDITY,eyeTrack.LEFTEYE)=4;
        
       %and simply replicate for the right eye
        tmpData(:,eyeTrack.VALIDITY,eyeTrack.RIGHTEYE)=...
             tmpData(:,eyeTrack.VALIDITY,eyeTrack.LEFTEYE);
    
end

structData.data = tmpData;


%% Set signal Tags
structData=setSignalTag(structData,1,'Left eye');
structData=setSignalTag(structData,2,'Right eye');

%% Set Timescale
%structData.qbsoluteStartTime = obj.recordingTime;
structData.timestampts = round(timestamps);

%% Assign rest of data
events = obj.events;
structData.events = events;
structData.fixationMethod = 'dwelltime';
structData.fixationEye = obj.fixationEye;
structData.fixationRadius = obj.fixationRadius;
structData.fixationDuration = obj.fixationDuration;
structData.screenResolution = obj.screenResolution;
structData.coordinateUnits = obj.coordinateUnits;

%% Extract the timeline
theTimeline=timeline(nSamples); %No conditions.
theTimeline.timestamps = structData.timestamps;

theTimeline=addCondition(theTimeline,'Fixations',[]);
theTimeline=addCondition(theTimeline,'Saccades',[]);
theTimeline=addCondition(theTimeline,'Blinks',[]);
%Set blinks condition to be non-exclusory with Fixations and Saccades
theTimeline=setExclusory(theTimeline,'Blinks','Fixations',0);
theTimeline=setExclusory(theTimeline,'Blinks','Saccades',0);


%Identify fixations, saccades and blinks
% The information about fixation, saccades and blinks may be already
%in the data in the columns:
%
% DATA_MOVEMENTTYPE
% DATA_MOVEMENTTYPE_LEFT
% DATA_MOVEMENTTYPE_RIGHT
%
%which in turn come from the raw data;
%
% B_EVENTINFO (Column marked as 'b event info' in the raw imported file)
% L_EVENTINFO (Column marked as 'l event info' in the raw imported file)
% R_EVENTINFO (Column marked as 'r event info' in the raw imported file)
%
%However, thes columns may have not been exported by the user, and hence
%would be filled with NaNs by the time they get here. Note that there may
%still be a few NaNs even of the columns were exported, for unknown values.
%
% So in order to get the fixations, saccades and blinks:
%   1) if the information is present, then I need to conciliate the
%   information from both eyes.
%   2) if the information is NOT present (all values to NaN), then I need
%   to calculate then by my own algorithms.
%

if nSamples>0
    %Eye movements
    bMovement = rawData(:,rawData_BeGazeEyeTracker.DATA_MOVEMENTTYPE);
    lMovement = rawData(:,rawData_BeGazeEyeTracker.DATA_MOVEMENTTYPE_LEFT);
    rMovement = rawData(:,rawData_BeGazeEyeTracker.DATA_MOVEMENTTYPE_RIGHT);
    %           + NaN - If unused or not known
    %           + 1 - For fixation movements
    %           + 2 - For saccades
    %           + 3 - For blinks
    
    
    if all(isnan(bMovement)) && all(isnan(lMovement)) && all(isnan(rMovement))
        %Calculate fixations, saccades and blinks on my own
        
        structData=identifyFixations(structData); %Method dwelltime is the one used by ClearView
        %This also sets the saccades episodes.
        %0.3% disparity may appear with respect to original Clear View
        %detection (see my notebook 7-Nov-2008)
        theTimeline=setConditionEvents(theTimeline,'Fixations',...
            getFixations(structData));
        theTimeline=setConditionEvents(theTimeline,'Saccades',...
            getSaccades(structData));
        
        %Set blinks condition to be non-exclusory with Fixations and Saccades
        tmpT= structData.timeline;
        tmpT=setExclusory(tmpT,'Blinks','Fixations',0);
        tmpT=setExclusory(tmpT,'Blinks','Saccades',0);
        structData=set(structData,'Timeline',tmpT);
        
        structData=identifyBlinks(structData);
        theTimeline=setConditionEvents(theTimeline,'Blinks',...
            getBlinks(structData));
        
    else %Conciliate the available information from both eyes.
        
        if version_IsHigherOrEqual(theFileVersion,'3.5')
            %Merge the movement info
            %Ideally something like:
            %
            %   bMovement || (lMovement && rMovement)
            %
            %but neither NaNs can be converted to logical, nor the logical
            %functions will keep the movement value. Ergo, I need something
            %more sophisticated.
            bMovement(isnan(bMovement))=0;
            lMovement(isnan(lMovement))=0;
            rMovement(isnan(rMovement))=0;
            tmpRLmatch = (lMovement == rMovement);
            lMovement(~tmpRLmatch)=0;
            rMovement(~tmpRLmatch)=0;
            %Now both rMovement and lMovement have the same info
            
            eMovements=max(bMovement,lMovement);
        else
            eMovements=bMovement;
        end
        
        %           + NaN - If unused or not known
        %           + 1 - For fixation movements
        %           + 2 - For saccades
        %           + 3 - For blinks
        train = eMovements==1;
        [onsets,durations]=extractEvents(train);
        theTimeline=setConditionEvents(theTimeline,'Fixations',[onsets durations]);
        
        train = eMovements==2;
        [onsets,durations]=extractEvents(train);
        theTimeline=setConditionEvents(theTimeline,'Saccades',[onsets durations]);
        
        train = eMovements==3;
        [onsets,durations]=extractEvents(train);
        theTimeline=setConditionEvents(theTimeline,'Blinks',[onsets durations]);
    end
end


nEvents= obj.nEvents;
events = obj.events;
%In two steps; 1) first collect all the different events and add the
%corresponding conditions, ensuring that they are non exclusory
for ee=1:nEvents
    tmpEvent=events(ee);
    try
        theTimeline=addCondition(theTimeline,tmpEvent.name,[],0);
        %Note that this will only add a new condition if the
        %condition has not already been added
    catch ME
        if strcmp(ME.identifier,'ICNNA:timeline:addCondition:RepeatedTag')
            %Simply ignore
        else
            rethrow(ME);
        end
    end
end
%2) Revisit the conditions to get the tags, and 
%revisit the events picking up the relevant for each
%condition
nConds = theTimeline.nConditions;
frames = 1:length(timestamps); %%FOE Debug: 3-May-2010
                               %%I no longer use the frames in rd to
                               %%extract the onset/duration of events
for ii=1:nConds
    tmpTag=getConditionTag(theTimeline,ii);
    if (~strcmp(tmpTag,'Fixations')) && (~strcmp(tmpTag,'Saccades')) ...
            && (~strcmp(tmpTag,'Blinks'))
        tmpEvents=zeros(0,2);
        for jj=1:nEvents
            tmpEvent=events(jj);
            if strcmp(tmpEvent.name,tmpTag)
                %Each type of event must be converted differently
                switch (tmpTag)
                    case 'Keyboard'
                        %Events are instantaneous
                        %Field .key is always 3 and field .data1 is 32
                        %I need to convert the timestamp into the
                        %closest.
                        idx=find(timestamps>tmpEvent.info(obj.EVENTINFO_TIMESTAMP));
                        onset=frames(min(idx));
                        if isempty(onset)
                            onset=frames(end);
                        end
                        duration=0;
                    case 'TCPData'
                        %Events are instantaneous
                        %Field .key is always 6 and fields
                        %.data1 and .data2 are 0
                        %I need to convert the timestamp into the
                        %closest.
                        idx=find(timestamps>tmpEvent.info(obj.EVENTINFO_TIMESTAMP));
                        onset=frames(min(idx));
                        if isempty(onset)
                            onset=frames(end);
                        end
                        duration=0;
%                     case 'LMouseButton'
%                         %Events are instantaneous
%                         %Field .key is 1 and fields
%                         %.data1 and .data2 I'm not sure of what they
%                         %represent
%                         %I need to convert the timestamp into the
%                         %closest.
%                         idx=find(timestamps>tmpEvent.info(obj.EVENTINFO_TIMESTAMP));
%                         onset=frames(min(idx));
%                         if isempty(onset)
%                             onset=frames(end);
%                         end
%                         duration=0;
                    otherwise
                        eventNumber=tmpEvent.info(obj.EVENTINFO_DATA1);
                        idxFixationLast=find(fixationData(:,4)==eventNumber);
                        if ~isempty(idxFixationLast)
                            onset=min(idxFixationLast);
                            duration=length(idxFixationLast);
                        else
                            %Consider the event instantaneous
                            idx=find(timestamps>tmpEvent.info(obj.EVENTINFO_TIMESTAMP));
                            onset=frames(min(idx));
                            if isempty(onset)
                                onset=frames(end);
                            end
                            duration=0;
                        end
                end
                tmpEvents(end+1,:)=[onset duration];
            end
        end
        theTimeline=setConditionEvents(theTimeline,tmpTag,tmpEvents);
        clear tmpEvents
    end
end

structData.timeline = theTimeline;



end


%% AUXILIAR FUNCTIONS
function [onsets,durations]=extractEvents(train)
%Extract onsets and durations from a binary train of stimulus
train =[0; train]; %temporarily add a fictitious initial sample
onsets = find((train(2:end)-train(1:end-1))==1);
endings = find((train(2:end)-train(1:end-1))==-1);
if length(endings)<length(onsets)
    %it has finished on an event
    endings = [endings; length(train)];
        %Note that endings will be pointing to the "next" sample
end
durations = endings-onsets;
end
