function val = get(obj, propName)
% RAWDATA_ETG4000/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%This method extends the superclass get method
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
% See also rawData.get, set
%

switch propName
case 'StartTime'
   val = obj.startTime;
case 'SamplingRate'
   val = obj.samplingRate;
%The data itself!!
case 'Timestamps'
   val = obj.timestamps;
case 'RawData'
   val = obj.data;%The raw ECG data.
   
otherwise
   val = get@rawData(obj, propName);
end