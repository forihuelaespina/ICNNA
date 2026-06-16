function obj=nirs_neuroimage2snirf(obj,nimg)
%RAWDATA_SNIRF/NIRS_NEUROIMAGE2SNIRF Convert an nirs_neuroimage to snirf data
%
% obj=nirs_neuroimage2snirf(obj,nimg) Convert an nirs_neuroimage to snirf data
%
%
% In a sense, this function is the opposite to convert. In the convert
% function we take the attribute .snirfImg of class icnna.data.snirf.snirf
% and generate an object of class nirs_neuroimage. Here, we take the an
% object of class nirs_neuroimage and reformat it back to an object of
% class icnna.data.snirf.snirf stored in the attribute .snirfImg
%
%
%% Remarks
%
% 1) Meta-data
% ICNNA stores subject and session information in objects different
% from the nirs_neuroimage. Therefore, the snirf meta-data related to this
% cannot be extracted from the nirs_neuroimage. In here, only "generic"
% default meta-data is created. You can of course later change this by
% manipulating this object's attribute snirfImg before saving to a file
% using export.
%
% 2) Wavelengths in the snirf probe
% For processed (post-MBLL) data, ICNNA stores wavelength information
% in the @rawData objects rather than the nirs_neuroimage, so it cannot
% be recovered here and probe.wavelengths is set to zeros as a placeholder.
% For raw intensity data, wavelengths are recovered from nimg.signalTags
% when tags follow the 'I(lambda=<wl>nm)' convention; entries remain 0
% for any signal whose wavelength tag could not be parsed.
% In either case you can override probe.wavelengths by manipulating
% this object's attribute snirfImg before saving to a file using export.
%
% 3) Stims additional data and dataLabels
% Both snirf and ICNNA can store additional information for each event
% in the timeline. However, in snirf, this additional information are
% simply additional columns in the stim(i).data matrix, whereas ICNNA
% associates a cell array to the condition and hence can store more rich
% data than just scalar values associated to the events. In this sense,
% not all data in ICNNA can be exported to snirf. To avoid potential
% conflicts, by the time being, ICNNA's eventsInfo will not be exported
% to the snirf object (not even the scalar information if any). If you
% want to preserve this, you'll need to do it manually afterwards.
%
% 4) Aux data
% ICNNA stores auxiliary information collected during the sessions
% in different dataSource objects. Therefore, the snirf data related to
% these cannot be extracted from the nirs_neuroimage.
% You can of course later change this by manipulating this object's
% attribute snirfImg before saving to a file using export.
%
% 
%
%
%
%% Input parameters
%
% nimg - A nirs neuroimage object.
%
%% Output parameters
%
% This object
%
%
%
%
%
%
% 
% Copyright 2023-26
% @author: Felipe Orihuela-Espina
% 
%
% See also rawData_NIRScout, import, neuroimage, NIRS_neuroimage, mbll
%

%% Log
%
% 29-Aug-2023: FOE
%   File created.
%
% 19-April-2024: FOE
%   + Bug fixed. Events durations were wrongly being read from the onsets
%       column
%
% 8-May-2024: FOE
%   Added support for stim dataLabels
%
% -- ICNNA v1.4.1
%
% 22-May-2026: FOE
%   + Updated to work with icnna.data.core.timeline
%       e.g. Replaced:
%           tmpStim.name = t.getConditionTag(iCond)
%           tmpCond      = t.getCondition(tmpStim.name);
%           cEvents   = tmpCond.events;
%       With
%           allConds  = t.getConditions(); %Retrieve all conditions
%           tmpCond   = allConds(iCond);
%           cEvents   = tmpCond.cevents;
%           cEvents   = [[cevents.onsets]' [cevents.durations]' [cevents.amplitudes]'];
%
%   Watch out! No backwards compatibility is provided. Now, this is
%   not as terrible as it may seems as in principle, the nirs_neuroimage
%   class will already type cast old timelines to modern
%   icnna.data.core.timeline.
%
% 23-May-2026: FOE
%   + Bug fixed. Raw intensity nirs_neuroimages (e.g. from rawData_NIRx/import
%       via .wl1/.wl2 files) were incorrectly encoded as processed data
%       (dataType=99999 with HbO/HbR labels). Fixed by detecting signal type
%       via nimg.signalTags (convention: raw tags start with 'I(') and
%       branching:
%         Raw intensity -> dataType=1 (CW amplitude), wavelengthIndex=signalID
%         Processed Hb  -> dataType=99999 (existing logic, unchanged)
%   + Bug fixed. signalID was computed as mod(chIdx,nSignals) where
%       chIdx=ceil(iML/nSignals). Because two consecutive measurements
%       share the same chIdx, both received the same signalID, causing
%       signals to be swapped for even-numbered channels. Fixed to
%       signalID = mod(iML-1, nSignals) + 1.
%       Affects both raw intensity and processed Hb export paths.
%   + Bug fixed. probe.wavelengths was assigned [0 0] (1x2 row vector),
%       violating the (:,1) column-vector constraint of probe.wavelengths.
%       For raw intensity, wavelengths are now populated from
%       wavelengthsFromTags (extracted from nimg.signalTags in the
%       detection block). For processed Hb, replaced with zeros(nSignals,1).
%       Remark 2 in the function header updated accordingly.
%   + Bug fixed. dataTypeLabel was left empty for raw intensity measurements.
%       Set to 'raw-DC' to match the expected CW amplitude label.
%



%% Preliminaries

clm = nimg.chLocationMap;
t   = nimg.timeline;
srcIdx = find(clm.optodesTypes == clm.OPTODE_TYPE_EMISOR);
detIdx = find(clm.optodesTypes == clm.OPTODE_TYPE_DETECTOR);
nSources = length(srcIdx);
nDetectors = length(detIdx);

%Let's start by creating the new snirf object, and the companion
%nirsDataset object
obj.snirfImg = icnna.data.snirf.snirf();

nDS = icnna.data.snirf.nirsDataset();


%Create the children objects

%% Meta-data
tmpMetaData = icnna.data.snirf.metaDataTags();

tmpMetaData.subjectID = 'Subj000X';
tmpMetaData.measurementDate = datestr(nimg.timeline.startTime,1);
tmpMetaData.measurementTime = datestr(nimg.timeline.startTime,13);
tmpMetaData.lengthUnit = 'mm';
tmpMetaData.timeUnit = 's';
tmpMetaData.frequencyUnit = 'Hz';
%tmpMetaData.additional = [];

nDS.metaDataTags = tmpMetaData;

%% Data block
tmpDataBlock = icnna.data.snirf.dataBlock();


%Data needs to be flattened from 3D to 2D array
nSignals = size(nimg.data,3);
tmpData = permute(nimg.data,[1 3 2]); %This will intercalate Hb species
        %so that instead of having:
        %
        % ch1_Oxy, ch2_Oxy, ..., ch1_Deoxy, ch2_Deoxy, ...
        %
        % we get
        %
        % ch1_Oxy, ch1_Deoxy, ch2_Oxy, ch2_Deoxy, ...
tmpDataBlock.dataTimeSeries = reshape(tmpData,[size(tmpData,1) size(tmpData,2)*size(tmpData,3)]);
nMeasurements = size(tmpDataBlock.dataTimeSeries,2);



%Detect signal type from signal tags.
% Convention:
% * raw intensity tags start with 'I(' per
%   rawData_NIRx/buildSignalLabel;
% * processed Hb tags do not — e.g. 'HbO', 'HbR', 'HbT'.
%
%Default to processed (Hb) when tags are absent or unrecognised.
%
isRawIntensity = false;
wavelengthsFromTags = zeros(nSignals, 1); %Pre-allocate; 0 = unknown wavelength
if ~isempty(nimg.signalTags) && iscell(nimg.signalTags) && ...
        ~isempty(nimg.signalTags{1})
    firstTag = strtrim(char(nimg.signalTags{1}));
    if length(firstTag) >= 2 && strncmp(firstTag, 'I(', 2)
        isRawIntensity = true;
        for iTag = 1:min(nSignals, length(nimg.signalTags))
            tag = strtrim(char(nimg.signalTags{iTag}));
            tok = regexp(tag, 'I\(lambda=(\d+(?:\.\d+)?)nm\)', ...
                        'tokens', 'once');
            if ~isempty(tok)
                wavelengthsFromTags(iTag) = str2double(tok{1});
            end
        end
    end
end




for iML = 1:nMeasurements
    tmpML = icnna.data.snirf.measurement();

    chIdx = ceil(iML/nSignals);

    signalID = mod(iML-1, nSignals) + 1;

    tmpML.sourceIndex   = clm.pairings(chIdx,1);
    tmpML.detectorIndex = clm.pairings(chIdx,2)-nSources;

    if isRawIntensity
        %Raw CW intensity: each signal slice corresponds to one wavelength.
        tmpML.wavelengthIndex = signalID; %signal 1 -> wl1, signal 2 -> wl2
        tmpML.dataType        = 1;        %CW amplitude (SNIRF spec v1.1 §11)
        tmpML.dataTypeLabel   = 'raw-DC'; %Optional for CW; not required
        tmpML.dataUnit        = '';       %Unit not standardised for raw NIRx data
    else
        %Processed (post-MBLL Hb concentrations)
        tmpML.wavelengthIndex = 0; %The wavelength index makes no sense
                                    %for MBLL reconstructed Hb data as this uses
                                    %BOTH wavelengths; yet, the field itself is
                                    %compulsory in snirf.
        % tmpML.wavelengthActual: 0
        % tmpML.wavelengthEmissionActual: 0
        tmpML.dataType = 99999; %Processed
        switch(signalID)
            case nirs_neuroimage.OXY
                tmpML.dataTypeLabel = 'HbO';
            case nirs_neuroimage.DEOXY
                tmpML.dataTypeLabel = 'HbR';
            % case nirs_neuroimage.CYTOCHROME
            %     tmpML.dataTypeLabel = 'CCO';
            case nirs_neuroimage.TOTALHB
                tmpML.dataTypeLabel = 'HbT';
            otherwise
                error('icnna:rawData_Snirf:nirs_neuroimage2snirf:InvalidSignalIdentifier', ...
                      ['Unexpected signal identifier ' num2str(signalID) ...
                       ' in channel ' num2str(chIdx) ...
                       ' (measurement ' num2str(iML) ').']);
        end
        tmpML.dataUnit = 'microMole';
    end

    tmpML.dataTypeIndex = 0;
    % tmpML.sourcePower: 0
    % tmpML.detectorGain: 0
    % tmpML.moduleIndex: 0
    % tmpML.sourceModuleIndex: 0
    % tmpML.detectorModuleIndex: 0

    tmpDataBlock.measurementList(iML) = tmpML;
end

tmpDataBlock.time = reshape(t.timestamps,numel(t.timestamps),1);



nDS.data = tmpDataBlock;


%% Timeline
allConds = t.getConditions(); %Retrieve all conditions
for iCond = 1:t.nConditions
    tmpStim = icnna.data.snirf.stim();

    %snirf works in timestamps whereas ICNNA works in samples.
    %I need to translate the onsets and durations


    %22-May-2026: FOE
    %   Update to work with icnna.data.core.timeline
    %tmpStim.name = t.getConditionTag(iCond); 
    %tmpCond   = t.getCondition(tmpStim.name);
    %cEvents   = tmpCond.events;
        %Above lines is no longer needed as I can now directly
        %retrieve the condition using the id.
    tmpCond   = allConds(iCond);
    tmpStim.name = tmpCond.name;
    cEvents   = tmpCond.cevents;
    cEvents   = [[cEvents.onsets]' [cEvents.durations]' [cEvents.amplitudes]'];

    if strcmp(tmpCond.unit,'samples')
        %Convert samples to seconds
        onsets    = t.timestamps(cEvents(:,1));
        durations = cEvents(:,2)/t.nominalSamplingRate;
    else %Unit is already seconds
        onsets    = cEvents(:,1);
        durations = cEvents(:,2);
    end
    if size(cEvents,2)==3
        amplitudes = cEvents(:,3);
    else
        amplitudes = ones(size(cEvents,1),1);
    end
    tmpStim.data = [onsets durations amplitudes];

    if isfield(tmpCond,'dataLabels')
        tmpStim.dataLabels = tmpCond.dataLabels;
    end

    %By now do NOT export the eventsInfo. See remark above on this regard.
    % dataLabels: {0×1 cell}

    nDS.stim(iCond) = tmpStim;
end




%% Probe
tmpProbe = icnna.data.snirf.probe();

if isRawIntensity
    %Wavelengths recovered from nimg.signalTags (see detection block above).
    %Entries remain 0 for any signal whose wavelength could not be parsed.
    tmpProbe.wavelengths = wavelengthsFromTags; %(:,1) double, column vector
else
    %Wavelength info is not stored in the nirs_neuroimage for processed data.
    %Set to zeros as a placeholder; amend via snirfImg before saving if needed.
    tmpProbe.wavelengths = zeros(nSignals, 1);
end
tmpProbe.sourcePos2D   = clm.optodesLocations(srcIdx,1:2);
tmpProbe.sourcePos3D   = clm.optodesLocations(srcIdx,:);
tmpProbe.detectorPos2D = clm.optodesLocations(detIdx,1:2);
tmpProbe.detectorPos3D = clm.optodesLocations(detIdx,:);

nDS.probe = tmpProbe;

 
%% Aux info
%Aux info is stored in different dataSources so it is not possible to
%recover it here.

%for iAux = 1:t.nAux
%   tmpAux = icnna.data.snirf.auxBlock();
%   nDS.aux(iAux) = tmpAux;
%end

%Finally, add the nirsDataset to the snirf object
obj.snirfImg.nirs(end+1) = nDS;


end