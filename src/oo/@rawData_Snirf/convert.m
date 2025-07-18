function nimg=convert(obj,varargin)
%RAWDATA_SNIRF/CONVERT Convert snirf data to an nirs_neuroimage
%
% nimg=convert(obj) Convert snirf data to an nirs_neuroimage
%
% nimg=convert(obj,optionName,optionValue) Convert snirf data to an
%   nirs_neuroimage, using the modified
%   Beer-Lambert law (MBLL) with additional options specified
%   by one or more optionName, optionValue pair arguments.
%
%
% If snirf data is raw, it also reconstructs the light intensities to a
% fNIRS neuroimage, using the modified Beer-Lambert law (MBLL)
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
% snirf files can hold several neuroimages at once i.e. different
% .nirs datasets. This function only converts one at a time. You need
% to loop over this function to convert the different datasets. See
% option 'nirsDatasetIndex'.
%
%
% Since snirf files can support both raw and/or reconstructed
% data, it may be the case that the data has already been reconstructed.
% Notwithstanding, this function still does reformat the data into
% ICNNA's classical structuredData format.
%
% Currently only Raw Continuous Wave or reconstructed HbO/HbR is supported.
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
%   'nirsDatasetIndex' - Index of the nirs dataset to be converted. By
%       default is set to 1.
%       snirf files can hold several neuroimages at once i.e. different
%       .nirs datasets. This function only converts one at a time. You need
%       to loop over this function chagning the value of this options to
%       convert the different datasets. If the index does not have a
%       corresponding dataset, an error is issued.
%
%   'AllowOverlappingConditions' - Permit adding conditions to the
%       timeline with an events overlapping behaviour.
%           0 - Overlapping conditions
%           1 - (Default) Non-overlapping conditions
%
%   'DefaultDPF' - A default DPF value. By default is set to 6.26.
%   'I0ref' - char array.
%       Determines how to establish the reference intensity I0.
%       Options are;
%       'first' - Use only the first sample. Used by classical fOSA
%       'first50' - Default. Use the first 50 samples (or all if the
%           timeseries is less than 50). Used by fOSA v2.2 and onwards
%           and the ICNNA option.
%       'mean' - Use the mean of the timeseries. Used by Homer.
%
%
% 
% Copyright 2023-25
% @author: Felipe Orihuela-Espina
% 
%
% See also rawData_NIRScout, import, neuroimage, NIRS_neuroimage, mbll
%



%% Log
%
% 20-May-2023: FOE
%   + File created
%
% 14-Feb-2024: FOE
%   + Bug fixed. The .snirf file format does NOT check whether stimulus
%       event last beyond the last sample e.g. starttime+duration may be
%       bigger than the timestamp of the last sample. However, ICNNA
%       asserts that no conditon event lasts beyond the last sample.
%       In this bug fixing, event that last beyond the last sample are
%       truncated.
%
% 20-Feb-2024: FOE
%   + Bug fixed. If the stimulus timeline have events of the same stimulus
%   that overlap, when setting up the timeline this was causing an error.
%   Now, the events are merged into a single event whereby I take the
%   earliest onset and the latest offset of the "group" (if there are more
%   than two; for instance:
%       [30 15;
%       [35 15;   ==> max offset 40+15=65 ==> [30 35]
%       [40 15]
%   + Bug fixed. When setting up the timeline, it was not checking for
%   onsets at 0. Onsets at 0 are now "shifted" to sample 1.
%
% 6-Apr-2024: FOE
%   + Adapted to handle optional fields.
%   + Auxiliar function unfoldMeasurementList refined DataTypeLabel from
%       cell array to array of objects (char)
%
% 8-May-2024: FOE
%   + Bug fixed. Now also saves amplitudes
%   + Bug fixed. Up to timeline class version '1.0', ICNNA does NOT have
%   anything equivalent to snirf dataLabels, so the information on the
%   dataLabels was getting lost. I have now added some rudimentary
%   support in the timeline class but this is not likely a good solution...
%
% 14-May-2024: FOE
%   + Bug fixed. Only attempt conversion to samples if condition events
%   is not empty.
%
% 12-Apr-2025: FOE (v1.3.0)
%   Change in behaviour;
%   + Allow IOD to be different for each channel for a better support
%   of the short channels and HD models. Correct reconstructions was
%   possible before but required to call this function several times
%   separetely for each different IOD. Now this is done in 1 shot and
%   by default.
%   + Allow the reference I0 to calculate the OD to be different from the
%   first samples. This is a trick use by other software tools e.g. Homer
%   uses the mean of the whole signal (rather than only the first 50
%   samples as fOSA -and ICNNA by inheritance- did), that can enhance
%   stability of the signal. For this a new option I0ref is provided.
%



opt.nirsDatasetIndex = 1; %Index of the nirs dataset to be converted.
opt.allowOverlappingConditions = 1; %Default. Non-overlapping conditions
opt.defaultDPF = 6.26; %Average DPF accepted value for normal adult head
opt.I0ref = 'first50'; %From v1.3.0. Method to calculate I0.
while ~isempty(varargin) %Note that the object itself is not counted.
    optName = varargin{1};
    if length(varargin)<2
        error('ICNA:rawData_NIRScout:convert:InvalidOption', ...
            ['Option ' optName ': Missing option value.']);
    end
    optValue = varargin{2};
    varargin(1:2)=[];
    
    switch lower(optName)
        case 'nirsdatasetindex'
            opt.nirsDatasetIndex = optValue;
        case 'allowoverlappingconditions'
            %Check that the value is acceptable
            %   0 - Overlapping conditions
            %   1 - Non-overlapping conditions
            if (optValue==0 || optValue==1)
                opt.allowOverlappingConditions = optValue;
            else
                error('ICNNA:rawData_Snirf:convert:InvalidOption', ...
                     ['Option ' optName ': Unexpected value ' num2str(optValue) '.']);
            end
            
        case 'defaultdpf'
            opt.defaultDPF = optValue;
        case 'i0ref'
            opt.I0ref = optValue;
        otherwise
            error('ICNNA:rawData_Snirf:convert:InvalidOption', ...
                  ['Invalid option ' optName '.']);
    end
end




if (opt.nirsDatasetIndex>length(obj.snirfImg.nirs)    ...
    || opt.nirsDatasetIndex<=0)
    warning('ICNNA:rawData_Snirf:convert:InvalidOption', ...
                  ['Dataset ' num2str(opt.nirsDatasetIndex) ' not found. Returning empty image.']);
    nimg=nirs_neuroimage(1);
    return
end    




%% Some basic initialization

tmpNirs = obj.snirfImg.nirs(opt.nirsDatasetIndex);



tmpMeasurementList = unfoldMeasurementList(tmpNirs.data);

%Figure out number of data types, e.g. number of wavelengths or
%chromophores, as well as the number of channels
nMeasurements = length(tmpNirs.data.measurementList);
% nDataTypes = max(tmpMeasurementList.dataType)
    %This above does not work. The field dataType exists but may be not used.
    %Instead, "pick" a channel and check how many measurements there are
    %for this channel.
iSrc = tmpMeasurementList.sourceIndex(1);
iDet = tmpMeasurementList.detectorIndex(1);
tmpMeasurementsPerChannel = find((tmpMeasurementList.sourceIndex == iSrc)  &  ...
                                 (tmpMeasurementList.detectorIndex == iDet));
nDataTypes = length(tmpMeasurementsPerChannel);

%Figure out the channels from the measurements
channelList = table2array(unique(tmpMeasurementList(:,{'sourceIndex','detectorIndex'})));
%nChannels = nMeasurements/nDataTypes;
nChannels = size(channelList,1);


nSamples=size(tmpNirs.data.dataTimeSeries,1);
nSignals=nMeasurements/nChannels;
nWlengths=length(tmpNirs.probe.wavelengths);
nimg=nirs_neuroimage(1,[nSamples,nChannels,nSignals]);



channelLocations3D = (tmpNirs.probe.sourcePos3D(channelList(:,1),:)+tmpNirs.probe.detectorPos3D(channelList(:,2),:))/2;



%% Deal with the probe.
%Snirf probe ought the be converted to a channelLocationMap
clm = channelLocationMap;
clm.nChannels = nChannels;

%Bring together sources and detectors under optodes
nSources   = size(tmpNirs.probe.sourcePos2D,1);
nDetectors = size(tmpNirs.probe.detectorPos2D,1);
clm.nOptodes = nSources + nDetectors;
clm.optodesLocations = [tmpNirs.probe.sourcePos3D; ...
                        tmpNirs.probe.detectorPos3D];
clm = clm.setOptodeTypes(1:nSources,    clm.OPTODE_TYPE_EMISOR*ones(nSources,1));
clm = clm.setOptodeTypes(nSources+(1:+nDetectors),clm.OPTODE_TYPE_DETECTOR*ones(nDetectors,1));
clm = clm.setOptodeProbeSets(1:nChannels,ones(nChannels,1));
oaInfo.mode = 'unknown';
oaInfo.type = 'unknown'; %snirf does not store this information
oaInfo.chTopoArrangement = channelLocations3D;
oaInfo.optodesTopoArrangement = clm.optodesLocations;
clm = clm.setOptodeArraysInfo(1,oaInfo);
clm = clm.setOptodeOptodeArrays(1:clm.nOptodes,ones(clm.nOptodes,1));
clm = clm.setOptodeProbeSets(1:clm.nOptodes,ones(clm.nOptodes,1));

%channelList = table2array(unique(tmpMeasurementList(:,{'sourceIndex','detectorIndex'})));
%"translate" snirf detector index to ICNNA optode index (i.e. shift
% indices by number of sources)
clm = clm.setPairings(1:nChannels,[channelList(:,1) nSources+channelList(:,2)]);


%Establish nominal channel locations at the mid point between
%the source and the detector
% channelLocations2D = (tmpNirs.probe.sourcePos2D(channelList(:,1),:)+tmpNirs.probe.detectorPos2D(channelList(:,2),:))/2;
%     %2D channel locations is not used by ICNNA, but calculated here anyway
clm = clm.setChannel3DLocations(1:nChannels,channelLocations3D);
clm = clm.setChannelOptodeArrays(1:nChannels,ones(nChannels,1));
clm = clm.setChannelProbeSets(1:nChannels,ones(nChannels,1));

nimg.chLocationMap = clm;




%% Deal with the timeline
%One condition per stimulus

t = timeline(nSamples);
t.timestamps = tmpNirs.data.time;
t.nominalSamplingRate = t.samplingRate;
                        %snirf does not stored a nominal sampling rate.
                        %Assume the nominal sampling rate to be equal to
                        %the average sampling rate.
nStims = length(tmpNirs.stim);
for iStim = 1:nStims
    tmpStim = tmpNirs.stim(iStim);
    cTag = tmpStim.name;
    %Convert from time to samples
    % 14-May-2025: FOE
    %   + Bug fixed. Only attempt conversion to samples if
    %not empty
    if ~isempty(tmpStim.data)
        onsets   = round(tmpStim.data(:,1)*t.nominalSamplingRate);
        durations= round(tmpStim.data(:,2)*t.nominalSamplingRate);
    else
        onsets   = [];
        durations= [];
    end
    % 8-May-2024: FOE
    %   + Bug fixed. Now also saves amplitudes
    amplitudes = ones(numel(onsets),1);
    if size(tmpStim.data,2)>2
        amplitudes = tmpStim.data(:,3);
    end

    % 14-Feb-2024: FOE
    %   + Bug fixed. In this bug fixing, events that start beyond the last 
    %       sample are truncated.
    onsets = max(0,min(onsets, nSamples));
    

    % 20-Feb-2024: FOE
    %   + Bug fixed. When setting up the timeline, it was not checking for
    %   onsets at 0. Onsets at 0 are now "shifted" to sample 1.
    tmpIdx = find(onsets == 0);
    onsets(tmpIdx) = 1; %Shift to 1st sample.
    % 20-Feb-2024: FOE
    %   + Bug fixed. If the stimulus timeline have events of the same stimulus
    %   that overlap, when setting up the timeline this was causing an error.
    %   Now, the events are merged into a single event whereby I take the
    %   earliest onset and the latest offset of the "group" (if there are more
    %   than two; for instance:
    %       [30 15;
    %       [35 15;   ==> max offset 40+15=65 ==> [30 35]
    %       [40 15]
    tmpcevents = unique([onsets durations amplitudes],'rows'); %merge events if required    
    if isempty(tmpcevents)
        tmpcevents = zeros(0,3);
    end
    jj=1;
    while (jj < length(tmpcevents(:,1)))
        currentOnset  = tmpcevents(jj,1);
        currentOffset = tmpcevents(jj,1)+tmpcevents(jj,2);
        nextOnset     = tmpcevents(jj+1,1);
        nextOffset    = tmpcevents(jj+1,1)+tmpcevents(jj+1,2);
        if  (currentOffset >= nextOnset)
            latestOffset = max(currentOffset,nextOffset);
            tmpcevents(jj,2)   = latestOffset - currentOnset; %New duration
            tmpcevents(jj+1,:) = [];
        else
            jj = jj+1;
        end
    end

    % 14-Feb-2024: FOE
    %   + Bug fixed. The .snirf file format does NOT check whether stimulus
    %       event last beyond the last sample e.g. starttime+duration may be
    %       bigger than the timestamp of the last sample. However, ICNNA
    %       asserts that no conditon event lasts beyond the last sample.
    %       In this bug fixing, events that last beyond the last 
    %       sample are truncated.
    tmpcevents(:,2) = max(0,min(tmpcevents(:,2), nSamples-tmpcevents(:,1)));

    if isempty(t.getCondition(cTag))
        % 8-May-2024: FOE
        %   + Bug fixed. Up to timeline class version '1.0', ICNNA does NOT have
        %   anything equivalent to snirf dataLabels, so the information on the
        %   dataLabels was getting lost. I have now added some rudimentary 
        %   support in the timeline class but this is likely not a good solution...
        if isproperty(tmpStim,'dataLabels')
            t = t.addCondition(cTag,tmpcevents,tmpStim.dataLabels,0);
        else
            t = t.addCondition(cTag,tmpcevents,0);
        end
    else
        t = t.addConditionEvents(cTag,tmpcevents);
    end
end



nimg.timeline = t;




%% Deal with the data

%snirf files can support both raw and/or reconstructed data.
%The way to convert the data obviously depends on the state
%state in which it is received.

%It is expected that within a single nirs dataset all measurements
%are of the same "type". Snirf supports the following dataTypes
% Supported measurementList(k).dataType values in dataTimeSeries
% 001-100: Raw - Continuous Wave (CW)
% 
% 001 - Amplitude
% 051 - Fluorescence Amplitude
% 101-200: Raw - Frequency Domain (FD)
% 
% 101 - AC Amplitude
% 102 - Phase
% 151 - Fluorescence Amplitude
% 152 - Fluorescence Phase
% 201-300: Raw - Time Domain - Gated (TD Gated)
% 
% 201 - Amplitude
% 251 - Fluorescence Amplitude
% 301-400: Raw - Time domain – Moments (TD Moments)
% 
% 301 - Amplitude
% 351 - Fluorescence Amplitude
% 401-500: Raw - Diffuse Correlation Spectroscopy (DCS):
% 
% 401 - g2
% 410 - BFi
% 99999: Processed
tmpDataType = tmpNirs.data.measurementList(1).dataType;
    %All others measurements will have to have this same code

switch (tmpDataType)
    case 1 %CW-Amplitude
        %Requires reconstruction
        tmpLightRawData = nan(nSamples, nChannels, nWlengths);
        for iMeas = 1:nMeasurements
            tmpMeasurement = tmpNirs.data.measurementList(iMeas);
            iSrc = tmpMeasurement.sourceIndex;
            iDet = tmpMeasurement.detectorIndex;
            iCh  = find(channelList(:,1) == iSrc & channelList(:,2) == iDet);
            iWl  = tmpMeasurement.wavelengthIndex;
            tmpLightRawData(:,iCh,iWl) = tmpNirs.data.dataTimeSeries(:,iMeas);
        end

        %Apply MBLL
        options.dpf = opt.defaultDPF; %Snirf format does NOT stores the DPF!
                                      %Thus use some default one.
        options.I0ref = opt.I0ref;
        options.iod = nimg.chLocationMap.getIOD();
                         %12-Apr-2025: FOE (v1.3.0) Change in behaviour.
                         % Before v1.3.0 this was set to a default fixed
                         % iod equal to 3cm.
                         % Now direct support for short channel and HD
                         % can be done directly
        M = mbll(tmpLightRawData,options);
        tmpData = zeros(nSamples,nChannels,2);
        tmpData(:,:,nirs_neuroimage.OXY)   = M(:,:,1);
        tmpData(:,:,nirs_neuroimage.DEOXY) = M(:,:,2);
        %nimg=set(nimg,'Data',tmpData);        
        nimg.data = tmpData;        

    case 99999 %Processed
        %If processed, no need to reconstruct. Data is already HbO2/HbR/HbT
        tmpData = nan(nSamples, nChannels, nSignals);
        for iMeas = 1:nMeasurements
            tmpMeasurement = tmpNirs.data.measurementList(iMeas);
            iSrc = tmpMeasurement.sourceIndex;
            iDet = tmpMeasurement.detectorIndex;
            iCh  = find(channelList(:,1) == iSrc & channelList(:,2) == iDet);
            iSignal = 0;
            switch (tmpMeasurement.dataTypeLabel)
                case 'HbO'
                    iSignal = nirs_neuroimage.OXY;
                case 'HbR'
                    iSignal = nirs_neuroimage.DEOXY;
                case 'HbT'
                    iSignal = nirs_neuroimage.TOTALHB;
                otherwise
                    error('ICNNA:rawData_Snirf:convert:UnexpectedDataLabel', ...
                          ['Unexpected data label ' tmpMeasurement.dataTypeLabel '. ' ...
                           'Either not a valid .snirf data label or not supported yet by ICNNA.']);
            end
            tmpData(:,iCh,iSignal) = tmpNirs.data.dataTimeSeries(:,iMeas);
        end
        %nimg=set(nimg,'Data',tmpData);
        nimg.data = tmpData;


    otherwise
        error('ICNNA:rawData_Snirf:convert:UnexpectedDataType', ...
              ['Unexpected data type ' tmpDataType '. ' ...
               'Either not a valid .snirf data type or not supported yet by ICNNA.']);

end











end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% AUXILIARY FUNCTION


function ml = unfoldMeasurementList(data)
% ml = unfoldMeasurementList(data)
% ml = unfoldMeasurementList(measurementList)
%
%Unfold the measurement list of the snirf data into a table for quicker
% access of certain operations.
%
%
%% Remark
%
% Everytime one needs to access the information about the source and
%detectors involved in a channel. this list has to be navigated, which
%is tedious and costly.
%
% This functions, unfolds the list for quicker access.
%
%
%% Input Parameters
%
% data - A icnna.data.snirf.dataBlock dataClass object. This class is expected
%   to have at least the following 3 attributes;
%   .dataTimeSeries - A matrix of double sized <nSamples,2/3>
%       This is a 2D or 3D array.
%       If it's 3D then: <DATA TIME POINTS> x <DATA TYPES x CHANNELS> 
%           where data types can be wavelengths or chromophores.
%       If it's 2D then: <DATA TIME POINTS> x <Num OF MEASUREMENTS>
%   .time - A matrix of double sized <nSamples,1>
%       This is the vector of timestamps
%   .measurementList - A list of Homer3 Snirf MeasListClass objects
%       Each MeasListClass object contains information about the
%       corresponding source, detector, wavelength or chromophore, etc
%
% OR
%
% measurementList - A list of icnna.data.snirf.measurement objects
%       Each measurement object contains information about the
%       corresponding source, detector, wavelength or chromophore, etc
%       e.g. data.measurementList
% 
%
%% Output Parameters
%
% ml - A table of measurements in data.
%   Each column represents an original property of the
%   icnna.data.snirf.measurement objects composing the data.measurementList.
%   Each row represents one icnna.data.snirf.measurement object unfolded.
%
%
%
%
%
%
% Copyright 2023
% @author: Felipe Orihuela-Espina
%
% See also 
%

%% Log
%
% 20-Apr-2023: FOE
%   + File adapted from script myHomer3_unfoldMeasurementList
%

tmpList = data; %Default; the measurement list has been passed directly.
if isa(data,'icnna.data.snirf.dataBlock')
    tmpList = data.measurementList;
end


%Unfold measurement list for quicker access of some operations below.
nMeasurements = length(tmpList);
tmpSourceIndex         = nan(nMeasurements,1);
tmpDetectorIndex       = nan(nMeasurements,1);
tmpWavelengthIndex     = nan(nMeasurements,1);
tmpWavelengthActual    = nan(nMeasurements,1);
tmpWavelengthEmissionActual = nan(nMeasurements,1);
tmpDataType            = nan(nMeasurements,1);
tmpDataUnit            = strings(nMeasurements,1);
tmpDataTypeLabel       = strings(nMeasurements,1);
tmpDataTypeIndex       = nan(nMeasurements,1);
tmpSourcePower         = nan(nMeasurements,1);
tmpDetectorGain        = nan(nMeasurements,1);
tmpModuleIndex         = nan(nMeasurements,1);
tmpSourceModuleIndex   = nan(nMeasurements,1);
tmpDetectorModuleIndex = nan(nMeasurements,1);

for iMeas = 1:nMeasurements
    tmpSourceIndex(iMeas)         = tmpList(iMeas).sourceIndex;
    tmpDetectorIndex(iMeas)       = tmpList(iMeas).detectorIndex;
    tmpWavelengthIndex(iMeas)     = tmpList(iMeas).wavelengthIndex;
    if tmpList(iMeas).isproperty('wavelengthActual')
        tmpWavelengthActual(iMeas)    = tmpList(iMeas).wavelengthActual;
    end
    if tmpList(iMeas).isproperty('wavelengthEmissionActual')
        tmpWavelengthEmissionActual(iMeas) = tmpList(iMeas).wavelengthEmissionActual;
    end
    tmpDataType(iMeas)            = tmpList(iMeas).dataType;
    if tmpList(iMeas).isproperty('dataUnit')
        tmpDataUnit(iMeas)            = tmpList(iMeas).dataUnit;
    end
    if tmpList(iMeas).isproperty('dataTypeLabel')
        tmpDataTypeLabel(iMeas)       = tmpList(iMeas).dataTypeLabel;
    end
    tmpDataTypeIndex(iMeas)       = tmpList(iMeas).dataTypeIndex;
    if tmpList(iMeas).isproperty('sourcePower')
        tmpSourcePower(iMeas)         = tmpList(iMeas).sourcePower;
    end
    if tmpList(iMeas).isproperty('detectorGain')
        tmpDetectorGain(iMeas)        = tmpList(iMeas).detectorGain;
    end
    if tmpList(iMeas).isproperty('moduleIndex')
        tmpModuleIndex(iMeas)         = tmpList(iMeas).moduleIndex;
    end
    if tmpList(iMeas).isproperty('sourceModuleIndex')
        tmpSourceModuleIndex(iMeas)   = tmpList(iMeas).sourceModuleIndex;
    end
    if tmpList(iMeas).isproperty('detectorModuleIndex')
        tmpDetectorModuleIndex(iMeas) = tmpList(iMeas).detectorModuleIndex;
    end
end

ml = table(tmpSourceIndex,tmpDetectorIndex,...
           tmpWavelengthIndex,tmpWavelengthActual,tmpWavelengthEmissionActual,...
           tmpDataType,tmpDataUnit,char(tmpDataTypeLabel),...
           tmpDataTypeIndex,tmpSourcePower,tmpDetectorGain,...
           tmpModuleIndex,tmpSourceModuleIndex,tmpDetectorModuleIndex, ...
           'VariableNames',{'sourceIndex', 'detectorIndex',...
           'wavelengthIndex','wavelengthActual','wavelengthEmissionActual',...
           'dataType','dataUnit','dataTypeLabel',...
           'dataTypeIndex','sourcePower','detectorGain',...
           'moduleIndex','sourceModuleIndex','detectorModuleIndex',});


end

