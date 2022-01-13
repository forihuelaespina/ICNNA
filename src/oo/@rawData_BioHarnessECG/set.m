function obj = set(obj,varargin)
% RAWDATA_ETG4000/SET Set object properties and return the updated object
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
% 'ID' - A numerical identifier
% 'Description' - Changes the description of the object
% 'Date' - Changes the date associated with the object.
%
% == Others
% 'StartTime' - Absolute start time as a date vector:
%       [YY, MM, DD, HH, MN, SS]
% 'SamplingRate' - Sampling Rate in [Hz]
% 'Timestamps' - Timestamps in milliseconds relative to the absolute start
%   time
% 'RawData' - The ECG recorded
%
%
%
% Copyright 2009
% @date: 19-Jan-2009
% @author Felipe Orihuela-Espina
%
% See also rawData.set, get
%

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
    case 'StartTime'
        tmpVal=datenum(val);
        if all(tmpVal==val)
            error('Value must be a date vector; [YY, MM, DD, HH, MN, SS]');
        else
            obj.startTime = datevec(tmpVal);
        end

    case 'SamplingRate'
        if (isscalar(val) && isreal(val) && val>0)
            obj.samplingRate = val;
        else
            error('Value must be a positive real');
        end
        
    case 'Timestamps'
        if (isvector(val) && all(floor(val)==val) && all(val>=0))
            obj.timestamps = val;
        else
            error('Value must be a vector positive integers.');
        end

%The data itself!!
    case 'RawData'
        if (isreal(val))
            obj.data = val;
        else
            error('A matrix of real numbers expected.');
        end


   otherwise
        obj=set@rawData(obj, prop, val);
   end
end
