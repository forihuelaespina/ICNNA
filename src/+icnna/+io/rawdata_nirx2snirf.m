function [res] = rawdata_nirx2snirf(theRawData)
% Convert a icnna.data.misc.rawData_NIRx object to a icnna.data.snirf.snirf object.
%
% [res] = rawdata_nirx2snirf(theRawData)
%
%
%
%% Remarks
%
% In older versions of the NIRx files, the nominal measurement wavelengths
%were stored in:
%
%   hdr->[ImagingParameters]->Wavelengths
%
% This field, and indeed the whole [ImagingParameters] section of the
%header parameter does not seem to be avaiable from version:
%
% Version=2021.9.0-6-g14ef4a71
%
% In previous versions (NIRStar v14.1), the NIRScout was operating at:
%
% [760 850] nm
%
% Moreover, from some .snirf files saved together with NIRx data, I can
%see that these wavelengths remain. So for the time being, if I can't
%find the wavelengths, these wavelengths will be assumed.
%
%% Parameters
%
% theRawData - icnna.data.misc.rawData_NIRx
%
%
%% Output
%
% res - icnna.data.snirf.snirf
%
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.misc.rawData_NIRx, icnna.data.snirf.snirf
%


%% Log
%
%   + Function available since ICNNA v1.2.3
%
% 2-Feb-2025: FOE
%   + File and class created.
%   + Currently not yet importing aux.
%   + Backward compatibility is limited at this point.
%
% 11-Feb-2025: FOE
%   + Bug fixed. Added property snirf.fileVersion that I had forgotten.
%
% 17-May-2025: FOE
%   + Motivated for the issue with ARSLA experiment file
%   '.\002 MG\NIRX\2024-01-03_0012024-01-03_001_lsl.tri' I have now
%   added a stage to correct for possible errors in the data acquisition
%   affecting the alteration of the clock. Note that this is not a bug
%   fixing i.e. an error of the code, but an error in the data file.
%   So although in principle it may be cleaner to provide a solution
%   for this issue "outside" this function, but I decided to attend it
%   in here as it may be present in other files. The function now
%   raise a warning and makes an attempt to fix the error in the data
%   (it DOES NOT change the data file, but the output snirf would be
%   amended for this issue).
%

%% Preliminaries

tmpData = theRawData.dataFiles;
%Note that the keys of the theRawData.dataFiles contains not only the
%extension but also the rest of the filename. This first part is not
%known but can be easily recovered by simply requesting the list of the
%keys, and looking for one of the wavelengths .wl* files.
tmpKeys = keys(tmpData);
matches = strfind(tmpKeys,'.wl');
idx=[];
for ii = 1:length(matches)
    if ~isempty(matches{ii})
        idx = [idx ii];
    end
end
tmpKey = tmpKeys(idx(1));
[~,filename,~] = fileparts(tmpKey);
filename = char(filename);
%disp(['Base Filename: ' filename]);
nWavelengths = length(idx); %I will need this below
clear idx matches ii

%Retrieve the most relevant files for easy access.
try
    %Note that the header file may be called;
    %    [filename '.hdr']
    % or [filename '_config.hdr']
    matches = strfind(tmpKeys,'.hdr');
    idx=[];
    for ii = 1:length(matches)
        if ~isempty(matches{ii})
            idx = ii;
            break
        end
    end
    header = tmpData(tmpKeys(idx));
    if iscell(header)
        header = header{1};
    end
    clear idx matches ii
catch ME
    error("ICNNA:op:io:rawdata_nirx2snirf:FileNotFound",...
          ['Unable to find ' filename '.hdr']);
end

try
    for iWl = 1:nWavelengths
        tmpWl = tmpData([filename '.wl' num2str(iWl)]);
        wl(:,:,iWl) = tmpWl{1};
        clear tmpWl
    end
    clear iWl
catch ME
    error("ICNNA:op:io:rawdata_nirx2snirf:FileNotFound",...
          ['Unable to find ' filename '.wl?' ]);
end



%Initialize the result
res = icnna.data.snirf.snirf();
res.formatVersion = '1.0';
tmpNirs = icnna.data.snirf.nirsDataset();

nirxFileVersion = 'Unknown';



%% Gather the meta data
tmpMetaData = icnna.data.snirf.metaDataTags();
%The subjectID can be found either in .hdr->[ExperimentNotes]->experiment_subject
%or in _description.json->subject
tmpExperimentNotes = header('ExperimentNotes');
tmpMetaData.subjectID = char(tmpExperimentNotes('experiment_subject'));
if isempty(tmpMetaData.subjectID)
    try
        tmpDescription = tmpData([filename '_description.json']);
        tmpDescription = tmpDescription{1};
        tmpMetaData.subjectID  = tmpDescription.subject;
    catch ME
        %No need to do anything. Simply skip the subjectID
    end
end
%The measurement date and time can be found in .hdr->[GeneralInfo]->Date
tmpGeneralInfo = header('GeneralInfo');
tmpMeasurementDate = datetime(tmpGeneralInfo('Date'));
tmpMetaData.measurementDate = tmpMeasurementDate;
tmpMetaData.measurementTime = tmpMeasurementDate;
tmpMetaData.lengthUnit      = 'mm';
tmpMetaData.timeUnit        = 's';
tmpMetaData.frequencyUnit   = 'Hz';
tmpMetaData.frequencyUnit   = 'Hz';
tmpMetaData.additional      = configureDictionary("string","string");
if exist('tmpDescription','var')
    fields = fieldnames(tmpDescription);
    for iField = 1:length(fields)
        tmpField = fields{iField};
        tmpMetaData.additional(tmpField) = tmpDescription.(tmpField);
    end
end
fields = keys(tmpExperimentNotes);
for iField = 1:length(fields)
    tmpField = char(fields(iField));
    tmpMetaData.additional(tmpField) = tmpExperimentNotes(tmpField);
end
clear fields tmpField
if tmpGeneralInfo.isKey('Version')
    tmpMetaData.additional('Version') = tmpGeneralInfo('Version');
    nirxFileVersion = tmpGeneralInfo('Version');
end
if tmpGeneralInfo.isKey('Device ID')
    tmpMetaData.additional('DeviceID')  = tmpGeneralInfo('Device ID');
        %Note that I'm intentionally removing the space in the key
end
tmpNirs.metaDataTags = tmpMetaData;
clear tmpMetaData tmpNotes



%% Read data block
tmpDataBlock = icnna.data.snirf.dataBlock();
[nSamples,nChannels,nWavelengths] = size(wl);
nMeasurements = nChannels*nWavelengths;
tmpDataBlock.dataTimeSeries = reshape(permute(wl,[1 3 2]),[nSamples nMeasurements]);
%NIRx is not storing the timestamps. So I need to generate these from the
%samplingRate
samplingRate = str2num(tmpGeneralInfo('Sampling rate')); %Uses Hz
tmpDataBlock.time = [0:nSamples-1]*(1/samplingRate);
%Add the measurements information
tmpDataStructure = header('DataStructure');
channelIndices = char(tmpDataStructure('Channel indices'));
if channelIndices(1) == '\' %Found \n
    channelIndices = channelIndices(3:end);
end
channelIndices = sscanf(channelIndices,'%d-%d,',[2 nMeasurements])';
chIdx = ceil((1:nMeasurements)/2);
wlIdx = nWavelengths-mod(1:nMeasurements,nWavelengths);
for iMeas = 1:nMeasurements
    tmpMeasurement = icnna.data.snirf.measurement();
    tmpMeasurement.sourceIndex     = channelIndices(chIdx(iMeas),1);
    tmpMeasurement.detectorIndex   = channelIndices(chIdx(iMeas),2);
    tmpMeasurement.wavelengthIndex = wlIdx(iMeas);
    tmpMeasurement.dataType        = 1; %CW, Amplitude
    tmpMeasurement.dataTypeLabel   = 'raw-DC'; %CW, Amplitude
    
    tmpDataBlock.measurementList(iMeas) = tmpMeasurement;
    clear tmpMeasurement
end

tmpNirs.data(1) = tmpDataBlock;



%% Read timeline
%
% Up to NIRStar v14.2 
%
%   .hdr->[Markers]
%
% Event Trigger Markers: Records the event markers received by the
%   digital trigger inputs, with time stamp and frame number. Each event
%   contains 3 numbers;
%       Column 1: Time (in seconds) of trigger event after the scan
%           started.
%       Column 2: Trigger channel identifier, or condition marker.
%           Triggers received on each digital input DIx (where x denotes
%           the trigger channel) on the front panel are encoded as numbers
%           2DI(x-1), e.g. DI1, DI2, and DI3 are encoded as 1, 2, and 8,
%           respectively. The file stores the sum of simultaneously
%           triggered inputs in decimal representation. By using
%           combinations of trigger inputs, as many as 15 conditions
%           can be encoded by NIRScout and NIRSport systems, while
%           NIRScoutX receives up to 255 conditions (8 inputs).
%       Column 3: The number of the scan frame during which the
%           trigger event was received.
%   The hash symbols '#' are used to identify the beginning and end
%   of the table. The section looks like this:
%   
%   [Markers]
%   Events=#
%   86.40 1 300 e.g. Trigger of input 1 recorded after 86.40s, during frame no. 12
%   116.40 2 404
%   146.40 1 508
%   ... ... ...
%   476.39 2 1654
%   #
%
% From v2021.9.0-6-g14ef4a71
%
%   Timeline data is found in the new .tri file
%
%   2024-01-02T14:13:13.762634;38;1
%   2024-01-02T14:13:43.758906;191;2
%
% where:
%   Column 1: Time (in date and time)
%   Column 2: Scan frame 
%   Column 2: Marker
%

colNames = {'time','frame','marker'};
markers = array2table(zeros(0, length(colNames)), ...
                    'VariableNames', colNames);



%Read markers
if version_IsHigherOrEqual('2021.9.0',nirxFileVersion)
    markers = tmpData([filename '_lsl.tri']);
    markers = markers{1};
    markers.Properties.VariableNames = colNames;

    %Replace absolute times with relative times; but note that
    %not every sample has an entry, e.g. the first line is NOT
    %the reference time 0 as this may correspond already to sample
    %frame k.
    %Hence, from the "lowest" row I need to figure out the reference
    %time (using the sampling rate above)
    
    tmpTime = markers{:,'time'};
    %timeOffset   = 0;
    if ~isempty(tmpTime)
            %Note 1: Remember! Because of errors in data collection, the
            %lowest may not be the first (so transiently until correction
            %below, some relative times may be negative wrt sample 1).
            %Note 2: The correction of the timeOffset of the first mark
            %is is ONLY needed if there is no corrections of the
            %timestamps, as otherwise the original raw timestamps will be
            %ignored anyway.
        timeOffset   = markers{1,'frame'}*(1/samplingRate);
        %markers.time = seconds(tmpTime - min(tmpTime)) + timeOffset; 
        %markers.time = seconds(tmpTime - min(tmpTime)); 
        markers.time = seconds(tmpTime - tmpTime(1)); 
    end

elseif version_IsHigherOrEqual('14.1',nirxFileVersion)
    tmpMarkers = header('Markers');
    markers    = tmpMarkers('Events');
    markers    = table(markers(:,1),markers(:,3),markers(:,2),...
                        'VariableNames',colNames);
        %These already are relative times, so no need to convert to
        %relative.
    timeOffset   = 0;

else
    warning('ICNNA:op:io:rawData_nirx2snirf:StimNotFound',...
            'Stim not found');
end





%17-May-2025: Repair times if needed
%In principle, if data of a session is correctly acquired, its
%events file *.tri will contained a list of events and markers
%ordered by timestamps. HOWEVER, we have discover a specific
%error (for file '002 MG/NIRX/2024-01-03_001' but may be present
%in others) whereby the clock at some apparently random sample
%it goes back by a random amount of time. This is very difficult
%to catch because the file format remains correct, and it the
%change in the clock time is insufficient to change the order
%of the marker, everything looks normal except for some apparently
%long or short episode of the timeline. But in cases like file
% '002 MG/NIRX/2024-01-03_001', this alteration of the time,
%was worth 1 minute and 15 seconds (at sample 124150) and completely
%changed the order of the markers.
tmpTime    = markers{:,'time'};
tmpSamples = markers{:,'frame'};
% Check if the vector of timestamps and samples is sorted in ascending order
isTimestampsSorted = isequal(tmpTime,    sort(tmpTime, 'ascend'));
isSamplesSorted    = isequal(tmpSamples, sort(tmpSamples, 'ascend'));
% And repair as needed
if ~isSamplesSorted & ~isTimestampsSorted
    error('icnna.op.io.rawdata_nirx2snirf::UnableToRecoverTimeline', ...
          ['Timestamps and frames ' ...
             'in *_lsl.tri are not sorted. Unable to recover the' ...
             'timeline.']);
elseif isSamplesSorted & ~isTimestampsSorted
    warning(['icnna.op.io.rawdata_nirx2snirf:: Timestamps in *_lsl.tri ' ...
             'are not sorted. Attempting to fix the timestampts using ' ...
             'the frame.']);
    markers.time = tmpSamples * (1/samplingRate);

elseif isTimestampsSorted & ~isSamplesSorted
    warning(['icnna.op.io.rawdata_nirx2snirf:: Frames in *_lsl.tri ' ...
             'are not sorted. Attempting to fix the frame numbers ' ...
             'using the timestamps.']);
    %With (relative) times correct, I just need to "shift"
    %the relative times by the offset of the first mark.
    markers.time = markers.time + timeOffset; 
    markers.frame = round(tmpTime * samplingRate);

else %no need to correct, just shift by the offset
        %IMPORTANT: Note that the correction of the offset is not needed
        %if the times have been recalculated.
    %With (relative) times and samples correct, I just need to "shift"
    %the relative times by the offset of the first mark.
    markers.time = markers.time + timeOffset; 
end




if ~isempty(markers{:,'time'})    
    uniqueMarkers = unique(markers.marker);
    uniqueMarkers(uniqueMarkers == 0) = [];%Ignore marker 0 if present
    nStim = length(uniqueMarkers);
    for iStim = 1:nStim
        tmpStim = icnna.data.snirf.stim();
        tmpStim.name = uniqueMarkers(iStim);
        if isnumeric(uniqueMarkers(iStim))
            tmpStim.name = num2str(uniqueMarkers(iStim));
        end
        tmpStim.dataLabels = {'starttime','duration','value'};
    
        cEvents = markers(markers.marker == uniqueMarkers(iStim),:);
        tmpStim.data = [cEvents.time zeros(size(cEvents,1),1) ones(size(cEvents,1),1)];
        
        tmpNirs.stim(iStim) = tmpStim;
    end
end
clear markers cEvents iStim tmpStim timeOffset tmpTime



%% Read probe
%
% Up to NIRStar v14.2 
%
%   .hdr->[DataStructure]
%
% Data Structure: This section records the arrangement of detector
%   channels in the .wl1 and .wl2 files, and the channel masking pattern.
%       + 'S-D-Key' (source-detector key) denotes the order in which
%           the columns of the data files (*.wl1, *.wl2) are assigned
%           to source-detector combinations. Each channel is denoted by
%           the source number, a minus sign ('-') and the detector number.
%           The channel pair is followed by a colon (:) and the
%           corresponding column index in the optical data files. The
%           column index is followed by a comma (',') and the next
%           channel. This variable may be read to generate a table
%           header for the data files.
%       + 'S-D-Mask' stores the masking pattern in a table (for channel
%           masking, see Section 5.5). Channels that are set not to be
%           displayed are identified by '0's, while channels set to be
%           displayed are labeled with '1's. Counting from the upper left,
%           the column number corresponds to the detector channel, and
%           the row number corresponds to the source position. The example
%           below shows a 4-source/4-detector measurement, in which all
%           channels are displayed except for source 2 / detector 3.
%   The hash symbols '#' are used to identify the beginning and end
%   of the table. The section looks like this:
%
%   [DataStructure]
%   S-D-Key="1-1:1,1-2:2,1-3:3,1-4:4,1-5:5,1-6:6,1-7:7,1-8:8,1-9:9,1-10:10,
%   ...
%   S-D-Mask=#
%   1 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0
%   1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0
%   0 0 1 1 1 1 0 0 0 0 0 0 0 0 0 0
%   0 0 0 1 0 1 1 0 0 0 0 0 0 0 0 0
%   ...
%   0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
%   #"
%
% From v2021.9.0-6-g14ef4a71
%
%   Probe data is found in the new '*_probeInfo.mat' file
%
%   It is a struct with two fields
%   .headmodel - Char array. e.g. 'ICBM152'
%   .probes - Struct. Include the following fields;
%       .nSource0: 16
%       .nDetector0: 30
%       .nChannel0: nChannels
%       .index_c: [nChannels×2 double]
%       .coords_s2: [nSources×2 double]
%       .coords_s3: [nSources×3 double]
%       .normals_s: [nSources×3 double]
%       .labels_s: {1×nSources cell}
%       .coords_d3: [nDetectors×3 double]
%       .coords_d2: [nDetectors×2 double]
%       .normals_d: [nDetectors×3 double]
%       .labels_d: {1×nDetectors cell}
%       .coords_o3: []
%       .coords_o2: []
%       .normals_o: []
%       .labels_o: {}
%       .coords_c3: [nChannels×3 double]
%       .coords_c2: [nChannels×2 double]
%       .normals_c: [nChannels×3 double]
%
%

tmpProbe = icnna.data.snirf.probe();

if version_IsHigherOrEqual('2021.9.0',nirxFileVersion)

    tmpProbe.wavelengths = [760 850];
        %See Remarks above

    pInfo = tmpData([filename '_probeInfo.mat']);
    pInfo = pInfo{1}.probeInfo;

    tmpProbe.sourceLabels    = pInfo.probes.labels_s;
    tmpProbe.sourcePos2D     = pInfo.probes.coords_s2;
    tmpProbe.sourcePos3D     = pInfo.probes.coords_s3;

    tmpProbe.detectorLabels  = pInfo.probes.labels_d;
    tmpProbe.detectorPos2D   = pInfo.probes.coords_d2;
    tmpProbe.detectorPos3D   = pInfo.probes.coords_d3;


    tmpNirs.metaDataTags.additional('headmodel') = pInfo.headmodel;


elseif version_IsHigherOrEqual('14.1',nirxFileVersion)

    tmpImagingParameters = header('ImagingParameters');
    tmpProbe.wavelengths = ImagingParameters('Wavelengths');

else
    warning('ICNNA:op:io:rawData_nirx2snirf:StimNotFound',...
            'Stim not found');
end

tmpNirs.probe = tmpProbe;



%% Read aux (if available)
%

%By now, do nothing



res.nirs(1) = tmpNirs;


end