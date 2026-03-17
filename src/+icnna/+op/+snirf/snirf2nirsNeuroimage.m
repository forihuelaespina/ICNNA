function nimg = snirf2nirsNeuroimage(snirfObj,options)
%SNIRF2nirs_neuroimage Convert SNIRF object to ICNNA nirs_neuroimage
%
% sdata = icnna.op.snirf.snirf2nirsNeuroimage(snirfObj,options)
%
% Converts a SNIRF object into an ICNNA @nirs_neuroimage object,
% without applying any reconstruction attempt, e.g. the MBLL, and hence
% preserving the recorded light intensities (or the OD depending on
% the content of the .snirf file).
%
% This function extracts:
%   + Channel definitions (source–detector pairings)
%   + Probe geometry
%   + Timeline and experimental conditions
%   + Raw intensity time series
%
% The resulting object can be used for further preprocessing steps 
% prior to optical density conversion or concentration reconstruction.
%
%% Remarks
%
% Unlike rawData_Snirf.convert, this function does NOT perform
% modified Beer-Lambert law (MBLL) reconstruction. Instead,
% the signals remain as recorded intensities or optical densities.
%
% SNIRF files may contain several independent datasets (i.e.
% multiple entries in snirfObj.nirs). This function converts
% one dataset at a time. See option 'nirsDatasetIndex'.
%
% The signal dimension in the resulting @nirs_neuroimage object
% corresponds to the number of wavelengths recorded.
%
%
%% Known limitations
%
% + Only continuous-wave intensity signals are currently supported.
%
% + SNIRF datasets using frequency-domain or time-domain measurement
%   types will trigger an error.
%
% + Optical intensities are stored directly; no attempt is made
%   to convert them into optical density or haemoglobin concentrations.
%
%
%% Error handling
%
% The function will trigger an error or warning in the following cases:
%
% 1. Invalid options
%       - .allowOverlappingConditions not boolean
%       - .nirsDatasetIndex not positive integer
%
% 2. Invalid input type
%       - snirfObj is not @icnna.data.snirf.snirf or @icnna.data.snirf.nirs
%
% 3. Dataset index out of bounds
%       - Returns an empty nirs_neuroimage object with a warning
%
% 4. Unsupported data type
%       - Only CW amplitude (dataType == 1) is supported
%
% 5. Empty dataset
%       - If dataTimeSeries is empty, sdata.data will be empty; timeline
%   and probe information are still recovered.
%
% In addition a warning is yielded if data time series are empty.
%
%% Input Parameters
%
% snirfObj - icnna.data.snirf.snirf
%   The object containing the SNIRF data to convert.
%
% options - Optional. struct with fields:
%   .allowOverlappingConditions - bool. Default is true
%       Behaviour when stimulus events overlap.
%
%       +=====================================================+
%       | WATCH OUT!! This flag is "inverted" with regards to |
%       | timeline's exclusory property. Allowing overlapping |
%       | conditions i.e. this property being 'true', means   |
%       | that timeline exclusory will be set to false, and   |
%       | viceversa.                                          |
%       +=====================================================+
%
%   .nirsDatasetIndex - int. Default is 1
%       Index of the dataset to convert.
%
%
%
%% Output
%
% nimg - @nirs_neuroimage
%   nirs_neuroimage object containing the intensity signals
%   organised as <samples × channels × wavelengths>.
%
%
%
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also nirs_neuroimage, snirfProbe2channelLocationMap, snirfNirs2timeline
%



%% Log
%
% -- ICNNA v1.4.1
%
% 5-Mar-2026: FOE
%   + File created.
%



%% Deal with options
opt = struct();
opt.nirsDatasetIndex = 1;
opt.allowOverlappingConditions = 1;
if exist('options','var') && isstruct(options)
    if isfield(options,'allowOverlappingConditions')
        opt.allowOverlappingConditions = options.allowOverlappingConditions;
    end
    if isfield(options,'nirsDatasetIndex')
        opt.nirsDatasetIndex = options.nirsDatasetIndex;
    end
end

%Validate options
if ~ismember(opt.allowOverlappingConditions,[false,true])
    error('icnna:op:snirf2nirsNeuroimage:InvalidOption',...
        'Option .allowOverlappingConditions must be false or true.');
end

if ~(isnumeric(opt.nirsDatasetIndex) && opt.nirsDatasetIndex>=1)
    error('icnna:op:snirf2nirsNeuroimage:InvalidOption',...
        'Option .nirsDatasetIndex must be a positive integer.');
end


%% Dataset validation
if (opt.nirsDatasetIndex > length(snirfObj.nirs) || opt.nirsDatasetIndex <=0)
    warning('icnna:op:snirf2nirsNeuroimage:InvalidDataset', ...
        ['Dataset ' num2str(opt.nirsDatasetIndex) ...
         ' not found. Returning empty nirs_neuroimage.']);
    nimg = nirs_neuroimage();
    return
end


%% Resolve the dataset
if isa(snirfObj,'icnna.data.snirf.snirf')
    if opt.nirsDatasetIndex > length(snirfObj.nirs)
        error('icnna:op:snirf2nirsNeuroimage:InvalidOption',...
            ['Dataset ' num2str(opt.nirsDatasetIndex) ' not found in SNIRF container.']);
    end
    tmpNirs = snirfObj.nirs(opt.nirsDatasetIndex);

elseif isa(snirfObj,'icnna.data.snirf.nirs')
    tmpNirs = snirfObj;

else
    error('icnna:op:snirf2nirsNeuroimage:InvalidInput',...
        ['Unsupported input type: ' class(snirfObj)]);
end




%% Determine number of samples, channels, wavelengths
if isempty(tmpNirs.data.dataTimeSeries)
    % Empty dataset safeguard (soft)
    warning('icnna:op:snirf2nirsNeuroimage:EmptyDataset', ...
        'Selected dataset contains no samples. Timeline and channel mapping will still be returned, data will be empty.');
    nSamples = 0;  % Will create zero-sample nirs_neuroimage
else
    nSamples = size(tmpNirs.data.dataTimeSeries,1);
end
nWavelengths = length(tmpNirs.probe.wavelengths);



%% Measurement list unfolding
tmpMeasurementList = icnna.op.snirf.unfoldMeasurementList(tmpNirs.data);
nMeasurements      = length(tmpNirs.data.measurementList);


%% Determine channels
channelList  = table2array(unique(tmpMeasurementList(:,{'sourceIndex','detectorIndex'})));
nChannels    = size(channelList,1);

%% Create nirs_neuroimage object
nimg = nirs_neuroimage(1,[nSamples,nChannels,nWavelengths]);


%% Channel locations / probe mapping
nimg.chLocationMap = icnna.op.snirf.snirfProbe2channelLocationMap(tmpNirs);


%% Timeline and stimulus conversion
opt2 = struct();
opt2.allowOverlappingConditions = opt.allowOverlappingConditions;
    %Watch out! this is the "invert" of the exclusory behaviour.
nimg.timeline = icnna.op.snirf.snirfNirs2timeline(tmpNirs,opt2);



%% Data extraction
allTypes = [tmpNirs.data.measurementList(:).dataType];
if ~all(allTypes == 1)
    error('icnna:snirf2nirsNeuroimage:UnsupportedDataType',...
        'Only CW amplitude data is supported.');
end

% Allocate data array
tmpData = nan(nSamples,nChannels,nWavelengths);

for iMeas = 1:nMeasurements
    tmpMeasurement = tmpNirs.data.measurementList(iMeas);

    iSrc = tmpMeasurement.sourceIndex;
    iDet = tmpMeasurement.detectorIndex;
    iCh  = find(channelList(:,1)==iSrc & channelList(:,2)==iDet);
    iWl  = tmpMeasurement.wavelengthIndex;

    tmpData(:,iCh,iWl) = tmpNirs.data.dataTimeSeries(:,iMeas);

end

for iWl = 1:nWavelengths
    signalTags(iWl) = {['\lambda = ' ...
                        num2str(tmpNirs.probe.wavelengths(iWl)) ' [nm]']}; 
end


nimg.data = tmpData;
nimg.signalTags = signalTags;

end