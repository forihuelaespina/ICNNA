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

%% Log
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 13-February-2022 (ESR): We simplify the code
%   + All cases are in the rawData_UCLWireless class.
%   + We create a dependent property inside the rawData_UCLWireless class.
%   + The nSamples, nChannels and nEvents properties are in the
%   rawData_UCLWireless class.

propertyArgIn = varargin;
    while (length(propertyArgIn) >= 2)
       prop = propertyArgIn{1};
       val = propertyArgIn{2};
       propertyArgIn = propertyArgIn(3:end);
       
       %obj.(lower(prop)) = val; %Ignore case
       
       
   tmp = lower(prop);
    
    switch (tmp)

            case {'wlengths','nominalwavelengthset'}
                obj.wLengths = val; 
            case 'pretimeline'
                obj.preTimeline = val;
            case 'rawdata'
                obj.rawData = val;
            case 'samplingrate'
                obj.samplingRate = val;
            case 'timestamps'
                obj.timestamps = val;
            
        otherwise 
            obj=set@rawData(obj, prop, val);
    end
       
    end
   
end
