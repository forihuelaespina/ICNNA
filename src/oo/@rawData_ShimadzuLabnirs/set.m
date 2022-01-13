function obj = set(obj,varargin)
% RAWDATA_SHIMADZULABNIRS/SET Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%
%This method extends the superclass set method
%
%% Properties
%
%== Inherited
% 'Description' - Changes the description of the object
% 'Date' - Changes the date associated with the object.
%
% == Others
% 'NominalWavelengthSet' - Set of wavelength at which the device operates
%       assuming no error
% 'SamplingRate' - Sampling Rate in [Hz]
% 'rawData' - A raw data matrix with oxy, deoxy and total data. Matrix is
%       sized <nSamples,3xnChannels> and hemoglobin species are always in
%       oxy/deoxy/total sequence; e.g.
%           Ch1/HbO, Ch1/HbR, Ch1/HbT, Ch2/HbO, Ch2/HbR, Ch2/HbT, ...
% 'Timestamps' - Vector of sample acquisition timestamps in [s]
%       Relative to the object's Date. Note that no check
%       is done regarding the validity of the timestamps.
%       One column per probe set.
% 'preTimeline' - Vector of PreTimeline-like events. Just a
%       sequence of integers with 1 flag per sample.
% 'marks' - Vector of marks. Just a
%       sequence of integers with 1 flag per sample.
%  
%
%
%
% Copyright 2016
% @date: 20-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 20-Sep-2016
%
% See also rawData.set, get
%


propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch lower(prop)
%Measure information
    case 'nominalwavelenghtset'
        if (isvector(val) && isreal(val))
            obj.wLengths = val;
        else
            error('ICNA:rawData_ShimadzuLabnirs:set:InvalidParameterValue',...
                  'Value must be a vector of wavelengths in nm.');
        end

    case 'samplingrate'
        if (isscalar(val) && isreal(val) && val>0)
            obj.samplingRate = val;
        else
            error('ICNA:rawData_ShimadzuLabnirs:set:InvalidParameterValue',...
                  'Value must be a positive real');
        end
        
%The data itself!!
    case 'rawdata'
        if (isreal(val) && (mod(size(val,2),3)==0))
            obj.rawData = val(:,:);
        else
            error('ICNA:rawData_ShimadzuLabnirs:set:InvalidParameterValue',...
                  'Data is expected to contain all Oxy, Deoxy and Total Hb data.');
        end
        
    case 'timestamps'
        if (isvector(val) && all(val>=0))
            obj.timestamps = val;
                %Note that the length of timestamps is expected to match
                %that of the rawData
                %See assertInvariants
        else
            error('ICNA:rawData_ShimadzuLabnirs:set:InvalidParameterValue',...
                  'Value must be a vector positive integer.');
        end


    case 'pretimeline'
        if (isvector(val) && isreal(val))
            obj.preTimeline = val;
                %Note that the length of pretimeline vector is expected to match
                %that of the rawData
                %See assertInvariants
        else
            error('ICNA:rawData_ShimadzuLabnirs:set:InvalidParameterValue',...
                  ['Value must be a vector positive integer.']);
        end


    case 'marks'
        if (isvector(val) && isreal(val))
            obj.marks = val;
                %Note that the length of marks vector is expected to match
                %that of the rawData
                %See assertInvariants
        else
            error('ICNA:rawData_ShimadzuLabnirs:set:InvalidParameterValue',...
                  ['Value must be a vector positive integer.']);
        end



   otherwise
        obj=set@rawData(obj, prop, val);
   end
end
