function nimg=convert(obj,varargin)
%RAWDATA_NIRScout/CONVERT Convert raw light intensities to a neuroimage
%
% nimg=convert(obj) Convert raw light intensities to a fNIRS
%   neuroimage, using the modified Beer-Lambert law (MBLL).
%
% nimg=convert(obj,optionName,optionValue) Convert raw light
%   intensities to a fNIRS neuroimage, using the modified
%   Beer-Lambert law (MBLL) with additional options specified
%   by one or more optionName, optionValue pair arguments.
%
%
%
%% The modified Beer-Lambert law:
%
% This function performs the modified Beer-Lambert law (MBLL)
%conversion using ICNNA/miscellaneous/mbll.m function. Please
%refer to that function for further details.
% 
%
%
%% Remarks
%
% Currently the separation distance between the optodes
%is fixed to 30 mm.
%
%% Known bugs
%
% At the moment the code is assuming that light intensities
%are recorded at two wavelengths. However, there may be
%other devices which record more than 2 wavelengths. In
%that case, this code will not work properly.
%
% Please note that the optode "effective" wavelengths at
% the different channels at which the optode is working might
% slightly differ from the "nominal" wavelengths.
% ICNNA does not takes this into account at the moment,
% and considers the nominal waveleghts to be the effective
% wavelengths.
%
%% Parameters
%
% obj - The rawData_NIRScout object to be converted to a nirs_neuroimage
%
% Options - optionName, optionValue pair arguments
%   'AllowOverlappingConditions' - Permit adding conditions to the
%       timeline with an events overlapping behaviour.
%           0 - Overlapping conditions
%           1 - (Default) Non-overlapping conditions
%
%   'DefaultDPF' - A default DPF value. By default is set to 6.26.
%
%
% 
% Copyright 2018
% Copyright over some comments belong to their authors.
% @author: Felipe Orihuela-Espina
% 
%
% See also rawData_NIRScout, import, neuroimage, NIRS_neuroimage, mbll
%



%% Log
%
% File created: 25-Apr-2008
% File last modified (before creation of this log): 25-Apr-2012
%
% 17-May-2018: FOE. IMPORTANT NOTE: The code in ICNNA version 1.1.3
%   assumed that marks were coupled. Apparently, this
%   is not the case, and we have been unable to trace where does
%   NIRStar saves the information of the duration. In the meantime
%   this has been desactivated and instead marks are considered as
%   single instantaneous marks. Also, reduced some redundant comments
%   now that reconstruction is made in an external function (mbll).
%
% 25-Apr-2018: FOE. Method created
%
%
% 13-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%


opt.allowOverlappingConditions = 1; %Default. Non-overlapping conditions
opt.defaultDPF = 6.26; %Average DPF accepted value for normal adult head
while ~isempty(varargin) %Note that the object itself is not counted.
    optName = varargin{1};
    if length(varargin)<2
        error('ICNA:rawData_NIRScout:convert:InvalidOption', ...
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
                error('ICNA:rawData_NIRScout:convert:InvalidOption', ...
                     ['Option ' optName ': Unexpected value ' num2str(optValue) '.']);
            end
            
        case 'defaultdpf'
            opt.defaultDPF = optValue;
        otherwise
            error('ICNA:rawData_NIRScout:convert:InvalidOption', ...
                  ['Invalid option ' optName '.']);
    end
end


%fprintf('Converting intensities to Hb data ->  0%%');





%   .probesetInfo - An struct holding information about the probe
%       sets and their configuration. The struct has the following fields;
%       .geom - Some standard information about the head and the
%           international 10-20 system
%           |
%           |- NIRxHead - 
%           .   |
%           .   |- ext1020sys 
%           .   .   |
%           .   .   |- coords3d (nPoints x 3)
%           .   .   |
%           .   .   |- labels (1 x 137) with 1|37 being the number of
%           .   .   |       labels of the 10/20 system
%           .   .   |
%           .   .   |- normals (137 x 3)
%           .   .   |
%           .   .   |- center (1 x 3)
%           .   .   |
%           .   .   |- sphere (137 x 3)
%           .   .   |
%           .   .   |- coords2d (137 x 2) - Note that these are NOT a
%           .   .           reduction of the 3D coordinates above. These
%           .   .           seem to be normalized.
%           .   |
%           .   |- mesh - Not all of the following may be defined;
%           .   .   |
%           .   .   |- nodes (nPoints x 4) - Point ID and 3D coordinates
%           .   .   |
%           .   .   |- elems (???? x 5)
%           .   .   |
%           .   .   |- belems (???? x 4)
%           .   .   |
%           .   .   |- fiducials (13 x 4) - Used to generate the affine
%           .   .           transformation matrix for source/detector
%           .   .           registrationsSee NIRSLab User's Manual
%           .   .           v2016.01 (pg.183)
%           .   |
%           .   |- mesh1 - See fields for mesh.
%           .   |
%           .   |- mesh2 - See fields for mesh.
%           .   |
%           .   |- mesh3 - See fields for mesh.
%           |
%           |- xy2dcircle - 
%           .   |
%           .   |- xycircles (??? x 2) -  
%           .   |
%           .   |- xynose (3 x 2) -  
%           .   |
%           .   |- xycross1 (2 x 2) -  
%           .   |
%           .   |- xycross2 (2 x 2) -  
%           .   |
%           .   |- xysquare (5 x 2) -  
%           .   |
%           .   |- xyearL (9 x 2) - Left ear <X,Y> 
%           .   |
%           .   |- xyearR (9 x 2) - Right ear <X,Y> 
%           .
%       .probes - A struct containing channel coordinate values for
%           sources and detectors, both in 2D and 3D spaces.
%           |
%           |- setupType - Scalar
%           |
%           |- nSource0 - Number of sources
%           |
%           |- nDetector0 - Number of detectors
%           |
%           |- nspecify_s - Scalar.
%           |
%           |- normals_s (nSource0 x 3) - Normals of the sources ???
%           |
%           |- coords_s2 (nSource0 x 2) - 2D coordinates of the sources?
%           |
%           |- coords_s3 (nSource0 x 3) - 3D coordinates of the sources?
%           |
%           |- index_s  (nSource0 x 2) - Link to .geom.NIRxHead.nodes? For
%           .               sources
%           |
%           |- nspecify_d - Scalar.
%           |
%           |- normals_d (nSource0 x 3) - Normals of the detectors ???
%           |
%           |- coords_d2 (nSource0 x 2) - 2D coordinates of the detectors?
%           |
%           |- coords_d3 (nSource0 x 3) - 3D coordinates of the detectors?
%           |
%           |- index_d  (nSource0 x 2) - Link to .geom.NIRxHead.nodes? For
%           .               detectors
%           |
%           |- nearDetectors -
%           |
%           |- nearDetectors0 -
%           |
%           |- nChannel0 - Number of configured channels?
%           |
%           |- coords_s2 (nChannel0 x 2) - 2D coordinates of the channels
%           |
%           |- coords_s3 (nChannel0 x 3) - 3D coordinates of the channels
%           |
%           |- index_c  (nChannel0 x 2) - Link to .geom.NIRxHead.nodes? For
%           .               channels
%           |
%           |- normals_c (nChannel0 x 3) - Normals of the channels
%           |
%           |- sourcei0 - Scalar
%           |
%           |- viewType - Scalar. 2 for 2D top? view, or 3 for 3D view.
%           |
%           |- viewangle3 - Azimuth and elevation for the 3D view?
%           .
%       .temphandles - A struct. Not understood.
%       .probeInforFileName - A string with the montage filename
%       .probeInforFilePath - A string with the path to the montage file
%






% %Start by catching the list of imported probe sets. This will
% %be useful at several points during the conversion.
% importedPSidx = [];
% for pp=1:get(obj,'nProbeSets')
%     if obj.probesetInfo(pp).read
%         importedPSidx = [importedPSidx pp];
%     end
% end

%Check if probe information has been defined
if isempty(obj.probesetInfo.probes)
    %Can't do much more, can I? So just return the default neuroimage
    nimg=nirs_neuroimage(1);
    return
end


%assert(length(obj.channelDistances) == obj.probesetInfo.probes.nChannel0, ...
%        'Unexpected number of channel distances');
        


%Some basic initialization
nSamples=size(obj.lightRawData,1);
nSignals=length(obj.wLengths);
nChannels = obj.nChannels;
nWlengths=length(obj.nominalWavelengthSet);
nimg=nirs_neuroimage(1,[nSamples,nChannels,nSignals]);


dpf=lower('ok');
%dpf=lower('no');
%coefficients=table_abscoeff;
%optodeSeparation = 3; %Separation distance between the optodes in [cm]
optodeSeparation = obj.channelDistances; %Per channel separation distance
                        %between the optodes in [cm]

%Check the optode types
%Assume they are all equal and simply get it from the first imported
%probes set
options.dpf = opt.defaultDPF; 
switch (obj.probesetInfo.probes.setupType)
    case 1
        %Do nothing. Use the default above.
    otherwise
        if strcmp(dpf,'ok')
            warning('ICNA:rawData_NIRScout:convert:InexactDPF',...
                ['The DPF for probe type ''' ...
                obj.probesetInfo(pp).type ''' is not currently ' ...
                'available. A DPF=' num2str(opt.defaultDPF) ' will be used.']);
        end
end

%Note that the channels may be spread across different probes sets,
%Thus, temporarily bring them all together in a single matrix.
%Also, take advantage of the loop for collecting the information
%for the channelLocationMap.
tmpLRD = []; %Light raw data
chProbeSets = [];
chOptodeArrays = [];
oaInfo = struct('mode',{},'type',{},...
                'chTopoArrangement',{},...
                'optodesTopoArrangement',{});
pp=1; %P-th probe set. Just 1 in the NIRScout
oa=1; %N-th optode array. Just 1 in the NIRScout
oaInfo(oa).mode = ['NIRScout_' num2str(obj.probesetInfo.probes.setupType)];
oaInfo(oa).type = num2str(obj.probesetInfo.probes.setupType);
tmpChCoords = obj.probesetInfo.probes.coords_c3;
[nRows,nCols]=size(tmpChCoords);
nRows = min(nRows,obj.nChannels);
oaInfo.chTopoArrangement = nan(obj.nChannels,nCols);
oaInfo.chTopoArrangement(1:nRows,:) = tmpChCoords(1:nRows,:);

oa_nCh=obj.nChannels; %size(oaInfo(oa).chTopoArrangement,1);
probeSet_nCh=obj.nChannels;
oaInfo.optodesTopoArrangement = obj.probesetInfo.probes.coords_c2;

chOptodeArrays = [chOptodeArrays; oa*ones(oa_nCh,1)];
chProbeSets = [chProbeSets; pp*ones(probeSet_nCh,1)];
%tmpLRD = [tmpLRD obj.lightRawData(:,1:nWlengths*probeSet_nCh,pp)];
            


%% Convert intensities
%wwait=waitbar(0,'Converting intensities->Hb data... 0%');

%Filter only the acquired channels
tmpLRD = obj.lightRawData;
tmpSDKey = obj.sdKey;
tmpSDMask = obj.sdMask;
chIdx = sort(tmpSDKey(find(tmpSDMask)));

%Apply MBLL
M=mbll(tmpLRD(:,chIdx,:),options);

c_hb=zeros(nSamples,nChannels,2);
c_hb(:,:,nirs_neuroimage.OXY)=M(:,:,1);
c_hb(:,:,nirs_neuroimage.DEOXY)=M(:,:,2);
nimg=set(nimg,'Data',c_hb);

%fprintf('\n');

%Now update the channel location map information
%nimg=set(nimg,'ProbeMode',obj.probeMode); %DEPRECATED CODE
%waitbar(1,wwait,'Updating channel location map...');
%fprintf('Updating channel location map...\n');
clm = get(nimg,'ChannelLocationMap');
clm = setChannelProbeSets(clm,1:nChannels,chProbeSets);
clm = setChannelOptodeArrays(clm,1:nChannels,chOptodeArrays);
clm = setOptodeArraysInfo(clm,1:length(oaInfo),oaInfo);
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



%  == Markers Information
%   .eventTriggerMarkers: A matrix for recording the event markers
%       received by the digital trigger inputs, with time stamp and
%       frame numbers. Each event is a row that
%       contains 3 numbers;
%         Column 1: Time (in seconds) of trigger event after the scan
%           started.
%         Column 2: Trigger channel identifier, or condition marker.
%           Triggers received on each digital input DIx (where x denotes
%           the trigger channel) on the front panel are encoded as numbers
%           2DI(x-1), e.g. DI1, DI2, and DI3 are encoded as 1, 2, and 8,
%           respectively. The file stores the sum of simultaneously
%           triggered inputs in decimal representation. By using
%           combinations of trigger inputs, as many as 15 conditions
%           can be encoded by NIRScout and NIRSport systems, while
%           NIRScoutX receives up to 255 conditions (8 inputs).
%         Column 3: The number of the scan frame during which the
%           trigger event was received.
%       By default is empty, set to nan(0,3).


tmpMarks=obj.eventTriggerMarkers(:,2);
tmpSamples=obj.eventTriggerMarkers(:,3);

conds=sort(unique(tmpMarks))';
for cc=conds
    tag=num2str(cc);
    idx=find(tmpMarks==cc);
    onsets=tmpSamples(idx);
    endings=tmpSamples(idx);
    %%%IMPORTANT NOTE: The code below correspond to ICNNA version 1.1.3
    %%%The code below assumed that marks were coupled. Apparently, this
    %%%is not the case, and we have been unable to trace where does
    %%%NIRStar saves the information of the duration. In the meantime
    %%%this has been desactivated and instead marks are considered as
    %%%single instantaneous marks.    
%    onsets=tmpSamples(idx(1:2:end));
%    endings=tmpSamples(idx(2:2:end));
%     if (length(onsets)==length(endings))
%         %Do nothing
%         %Each onset has its ending defined
%     elseif (length(onsets)-1==length(endings))
%         %the last onset is unmatched, i.e. the trial should
%         %finish by the end of the recording
%         warning('ICNA:rawData_NIRScout:convert:MissedTrialEnding',...
%                 ['Missed end of trial for condition ' tag '. ' ...
%                 'Setting end of trial to the end of the recording.']);
%         endings=[endings; nSamples];
%     else
%         warning('ICNA:rawData_NIRScout:convert:CorruptCondition',...
%                 ['Corrupt block/trial definitions for condition ' ...
%                 tag '. Ignoring block/trial definitions.']);
%         onsets=zeros(0,1);
%         endings=zeros(0,1);
%     end
    durations=endings-onsets;
    stim=[onsets durations];
    tag=num2str(cc);
    try
        theTimeline=addCondition(theTimeline,tag,stim,...
                                opt.allowOverlappingConditions);
    catch
        warning('ICNA:rawData_NIRScout:convert:CorruptCondition',...
                ['Events overlap in exclusory conditions. ' ...
                'Attempting setting non-exclusory conditions.']);
        opt.allowOverlappingConditions=0;
        theTimeline=addCondition(theTimeline,tag,stim,...
                                opt.allowOverlappingConditions);
        
    end
end


%... and now the same with the timestamps
tmpTimestamps=(1:nSamples)*obj.samplingPeriod;
theTimeline.timestamps = tmpTimestamps';
theTimeline.startTime  = obj.date;
theTimeline.nominalSamplingRate  = obj.samplingRate;

nimg=set(nimg,'Timeline',theTimeline);




%close (wwait);
