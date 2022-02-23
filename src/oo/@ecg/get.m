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
% Copyright 2009
% @date: 19-Jan-2009
% @author Felipe Orihuela-Espina
%
% See also ecg
%


%% Log:
%
% 29-May-2019: FOE:
%   + Log started
%   + Added support for property rPeaksAlgo
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 20-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the ecg class.
%   + We create a dependent property inside the ecg class 
%
%
     val = obj.(lower(propName)); %Ignore case
end