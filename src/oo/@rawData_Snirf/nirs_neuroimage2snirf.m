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
% ICNNA stores wavelength information in the @rawData objects different
% from the nirs_neuroimage (the rawData is accesible via the dataSource
% object containing the nirs_neuroimage when the dataSource is locked).
% Therefore, the snirf data related to this
% cannot be extracted from the nirs_neuroimage. You can of course later
% change this by manipulating this object's attribute snirfImg before
% saving to a file using export.
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
% Copyright 2023
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
for iML = 1:nMeasurements
    tmpML = icnna.data.snirf.measurement();

    chIdx = ceil(iML/nSignals);
    src = clm.pairings(chIdx,1);
    src = clm.pairings(chIdx,1);

    signalID = mod(chIdx,nSignals);
    if signalID == 0
        signalID = nSignals; %Not strictly needed, I could have
                             %go ahead with the 0, but just for the sake of
                             %my sanity (I can use ICNNA's constants!)
    end

    tmpML.sourceIndex = clm.pairings(chIdx,1);
    tmpML.detectorIndex = clm.pairings(chIdx,2)-nSources;
    tmpML.wavelengthIndex = 0; %The wavelength index makes no sense
                                %for MBLL reconstructed Hb data as this uses
                                %BOTH wavelengths; yet, the field itself is
                                %compulsory in snirf.
    % tmpML.wavelengthActual: 0
    % tmpML.wavelengthEmissionActual: 0
    tmpML.dataType = 99999; %Processed
    % tmpML.dataTypeLabel: [1×0 char]
    switch(signalID)
        case nirs_neuroimage.OXY
            tmpML.dataTypeLabel = 'HbO';
        case nirs_neuroimage.DEOXY
            tmpML.dataTypeLabel = 'HbR';
        % case nirs_neuroimage.CYTOCHROME
        %     tmpML.dataTypeLabel = 'CCO'; %NOTE: This is not a .snirf standard supported dataTypeLabel
        case nirs_neuroimage.TOTALHB
            tmpML.dataTypeLabel = 'HbT';
        % case nirs_neuroimage.HBDIFF
        %     tmpML.dataTypeLabel = 'HbDiff'; %NOTE: This is not a .snirf standard supported dataTypeLabel
        otherwise
            error('ICNNA:rawData_Snirf:nirs_neuroimage2snirf:InvalidSignalIdentifier', ...
                  ['Unexpected signal identifier ' num2str(signalID) ...
                   'in channel ' num2str(chIdx) ...
                   ' (measurement ' num2str(iML) ').']);

    end

    tmpML.dataUnit = 'microMole';
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
for iCond = 1:t.nConditions
    tmpStim = icnna.data.snirf.stim();

    tmpStim.name = t.getConditionTag(iCond);

    %snirf works in timestamps whereas ICNNA works in samples.
    %I need to translate the onsets and durations
    cEvents   = t.getConditionEvents(tmpStim.name);
    onsets    = t.timestamps(cEvents(:,1));
    durations = cEvents(:,1)/t.nominalSamplingRate;
    if size(cEvents,2)==3
        amplitudes = cEvents(:,3);
    else
        amplitudes = ones(size(cEvents,1),1);
    end
    tmpStim.data = [onsets durations amplitudes];

    %By now do NOT export the eventsInfo. See remark above on this regard.
    % dataLabels: {0×1 cell}

    nDS.stim(iCond) = tmpStim;
end




%% Probe
tmpProbe = icnna.data.snirf.probe();

tmpProbe.wavelengths   = [0 0]; %This is only stored in the raw data, not in the nirs_neuroimage so I have no way to know this directly.
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