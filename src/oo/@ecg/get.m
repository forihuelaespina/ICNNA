function val = get(obj, propName)
% ECG/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
%
% == Inherited
% 'ID' - The neuroimage ID.
% 'Description' - A short description of the image
% 'NSamples' - Number of samples 
% 'NChannels' - Number of picture elements (e.g. channels)
% 'NSignals' - Number of signals
% 'Timeline' - The image timeline
% 'Integrity' - The image integrity status per picture element
% 'Data' - The image data itself
%
% == Others
% 'StartTime' - Absolute start time as a date vector:
%       [YY, MM, DD, HH, MN, SS]
% 'SamplingRate' - Sampling Rate in [Hz]
% 'Timestamps' - Timestamps in milliseconds relative to the absolute start
%   time
% 'Data' - The ECG data
% 'NN' - The NN intervals as represented by the RR intervals (without
%       recalculating them). Refer to private method getRR for
%       calculating RR intervals. This form is disencouraged; please
%       use get(obj,'RR') instead.
% 'RPeaksMode' - Gets the R peaks maintenance mode.
% 'Threhsold' - The threshold (either manual or automatic)
% 'RPeaks' - Gets the R peaks (without recalculating them). Refer to
%       private method getRPeaks for calculating R peaks
% 'RR' - Gets the RR intervals (recalculating them). Refer to
%       private method getRR for calculating RR intervals
%
%
%
% Copyright 2009-2024
% @author Felipe Orihuela-Espina
%
% See also ecg
%


%% Log:
%
% File created: 19-Jan-2009
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 29-May-2019: FOE:
%   + Log started
%   + Added support for property rPeaksAlgo
%
% 12-Apr-2024: FOE:
%   + Got rid of old label @date
%   + property name is now case insensitive.
%


switch lower(propName)
case 'starttime'
   val = obj.startTime;
case 'samplingrate'
   val = obj.samplingRate;
case 'timestamps'
   val = obj.timestamps;
case 'nn'
   val = obj.rr;
case 'rpeaksmode'
   val = obj.rPeaksMode;
case 'rpeaksalgo'
   val = obj.rPeaksAlgo;
case 'threshold'
   val = obj.threshold;
case 'rpeaks'
   val = obj.rPeaks;
case 'rr'
   val = obj.rr;

otherwise
   val = get@structuredData(obj, propName);
end


end