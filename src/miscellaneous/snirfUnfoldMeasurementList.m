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
% 6-Apr-2024: FOE
%   + Adapted to handle optional fields.
%   + Refined DataTypeLabel from cell array to array of objects (char)
%

function ml = snirfUnfoldMeasurementList(data)

tmpList = data; %Default; the measurement list has been passed directly.
if isa(data,'icnna.data.snirf.dataBlock')
    tmpList = data.measurementList;
end


%Unfold measurement list for quicker access of some operations below.
nMeasurements          = length(tmpList);

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
