% ml = snirfUnfoldMeasurementList(data)
% ml = snirfUnfoldMeasurementList(measurementList)
%
%Unfold the measurement list of a snirf nirs/data into a MATLAB table
% object for quicker access of certain operations.
%
%
%% Remark
%
% In the snirf format, and in particular in icnna.data.snirf.dataBlock
%object the measurement list is a list of icnna.data.snirf.measurement
%objects.
%
% Everytime one needs to access the information about the source and
%detectors involved in a channel, this list has to be navigated, which
%is tedious and costly.
%
% This functions, unfolds the list into a compact MATLAB table for
%quicker access.
%
%
%% Input Parameters
%
% data - A Homer3 icnna.data.snirf.dataBlock object. This class is expected
%   to have at least the following 3 attributes;
%   .dataTimeSeries - A matrix of double sized <nSamples,2/3>
%       This is a 2D or 3D array.
%       If it's 3D then: <DATA TIME POINTS> x <DATA TYPES x CHANNELS> 
%           where data types can be wavelengths or chromophores.
%       If it's 2D then: <DATA TIME POINTS> x <Num OF MEASUREMENTS>
%   .time - A matrix of double sized <nSamples,1>
%       This is the vector of timestamps
%   .measurementList - A list of icnna.data.snirf.measurement objects
%       Each object contains information about the corresponding 
%       source, detector, wavelength or chromophore, etc
%
% OR
%
% measurementList - A list of icnna.data.snirf.measurement objects
%       Each object contains information about the corresponding 
%       source, detector, wavelength or chromophore, etc
%       e.g. data.measurementList
% 
%
%% Output Parameters
%
% ml - A table of measurements in data.
%   Each row represents one icnna.data.snirf.measurement object unfolded.
%   Each column represents an original attribute of the
%   icnna.data.snirf.measurement objects composing the data.measurementList.
%
%
%
%
%
%
% Copyright 2024
% @author: Felipe Orihuela-Espina
%
% See also plotSnirfDataOnProbe
%

%% Log
%
% 21-Feb-2024: FOE
%   + File created from previous code myHomer3_unfoldMeasurementList.m
%

function ml = snirfUnfoldMeasurementList(data)

tmpList = data; %Default; the measurement list has been passed directly.
if isa(data,'icnna.data.snirf.dataBlock')
    tmpList = data.measurementList;
end


%Unfold measurement list for quicker access of some operations below.
nMeasurements      = length(tmpList);
tmpSourceIndex     = nan(nMeasurements,1);
tmpDetectorIndex   = nan(nMeasurements,1);
tmpWavelengthIndex = nan(nMeasurements,1);
tmpDataType        = nan(nMeasurements,1);
tmpDataTypeLabel   = cell(nMeasurements,1);
tmpDataTypeIndex   = nan(nMeasurements,1);
tmpSourcePower     = nan(nMeasurements,1);
tmpDetectorGain    = nan(nMeasurements,1);
tmpModuleIndex     = nan(nMeasurements,1);
for iMeas = 1:nMeasurements
    tmpSourceIndex(iMeas)     = tmpList(iMeas).sourceIndex;
    tmpDetectorIndex(iMeas)   = tmpList(iMeas).detectorIndex;
    tmpWavelengthIndex(iMeas) = tmpList(iMeas).wavelengthIndex;
    tmpDataType(iMeas)        = tmpList(iMeas).dataType;
    tmpDataTypeLabel(iMeas)   = {tmpList(iMeas).dataTypeLabel};
    tmpDataTypeIndex(iMeas)   = tmpList(iMeas).dataTypeIndex;
    tmpSourcePower(iMeas)     = tmpList(iMeas).sourcePower;
    tmpDetectorGain(iMeas)    = tmpList(iMeas).detectorGain;
    tmpModuleIndex(iMeas)     = tmpList(iMeas).moduleIndex;
end
ml = table(tmpSourceIndex,tmpDetectorIndex,...
           tmpWavelengthIndex,tmpDataType,tmpDataTypeLabel,...
           tmpDataTypeIndex,tmpSourcePower,tmpDetectorGain,...
           tmpModuleIndex, ...
           'VariableNames',{'sourceIndex', 'detectorIndex',...
           'wavelengthIndex','dataType','dataTypeLabel',...
           'dataTypeIndex','sourcePower','detectorGain',...
           'moduleIndex'});


end
