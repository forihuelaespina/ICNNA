function obj = set(obj,varargin)
% RAWDATA_UCLWIRELESS/SET Set object properties and return the updated object
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
% 'rawData' - A raw data matrix with both Oxy and deoxy data. Matrix is
%       sized <nSamples,nChannels,2> and along the third dimension are the
%       oxy (first plane) and deoxy (second plane)
% 'Timestamps' - Vector of sample acquisition timestamps in [s]
%       Relative to the object's Date. Note that no check
%       is done regarding the validity of the timestamps.
%       One column per probe set.
% 'preTimeline' - PreTimeline-like events. A struct with the following fields:
%       .label - Experimental condition name
%       .code - Experimental condition code
%       .remainder - No idea
%       .starttime - Event onset in hh:mm:ss.ms
%       .endtime - Event offset in hh:mm:ss.ms
%
%
%
% Copyright 2016
% @date: 1-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 1-Sep-2016
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
            error('ICNA:rawData_UCLWireless:set:InvalidParameterValue',...
                  'Value must be a vector of wavelengths in nm.');
        end

    case 'samplingrate'
        if (isscalar(val) && isreal(val) && val>0)
            obj.samplingRate = val;
        else
            error('ICNA:rawData_UCLWireless:set:InvalidParameterValue',...
                  'Value must be a positive real');
        end
        
%The data itself!!
    case 'rawdata'
        if (isreal(val) && size(val,3)==2)
            obj.oxyRawData = val(:,:,1);
            obj.deoxyRawData = val(:,:,2);
        else
            error('ICNA:rawData_UCLWireless:set:InvalidParameterValue',...
                  'Data is expected to contain both Oxy and Deoxy data.');
        end
        
    case 'timestamps'
        if (all(val>=0))
            obj.timestamps = val;
                %Note that the length of timestamps is expected to match
                %that of the rawData
                %See assertInvariants
        else
            error('ICNA:rawData_UCLWireless:set:InvalidParameterValue',...
                  'Value must be a vector positive integer.');
        end


    case 'pretimeline'
        if (isstruct(val) && ...
                isfield(val,'label') && ...
                isfield(val,'code') && ...
                isfield(val,'remainder') && ...
                isfield(val,'starttime') && ...
                isfield(val,'endtime'))
                
            obj.preTimeline = val;
        else
            error('ICNA:rawData_UCLWireless:set:InvalidParameterValue',...
                  ['Value must be a struct with the following fields: ' ...
                  'label, code, remainder, starttime, endtime.']);
        end



   otherwise
        obj=set@rawData(obj, prop, val);
   end
end
