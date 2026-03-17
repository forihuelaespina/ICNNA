function ml = unfoldMeasurementList(data)
%Unfold the measurement list of the snirf data into a table.
%
% ml = icnna.op.snirf.unfoldMeasurementList(data)
% ml = icnna.op.snirf.unfoldMeasurementList(measurementList)
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
% Copyright 2023-26
% @author: Felipe Orihuela-Espina
%
% See also 
%

%% Log
%
% 20-Apr-2023: FOE
%   + File adapted from script myHomer3_unfoldMeasurementList
%
%
% -- v1.4.1
%
% 3-Mar-2026: FOE
%   + Isolated to its own methods (from auxiliary method for
%   rawData_Snirf.convert)
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

