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

%% Log
%
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 13-February-2022 (ESR): We simplify the code
%   + All cases are in the rawData_ShimadzuLabnirs class.
%   + We create a dependent property inside the rawData_ShimadzuLabnirs
%   class.
%   + The nSamples, nChannels and nEvents properties are in the
%   rawData_ShimadzuLabnirs class.

propertyArgIn = varargin;
while (length(propertyArgIn) >= 2)
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   
   obj.(lower(prop)) = val; %Ignore case
  
end
    assertInvariants(obj);
end
