function obj = set(obj,varargin)
% ECG/SET Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%Modifying the ECG data also adjusts the timeline and the
%integrity status as appropriate.
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
% 'Data' - The image data itself. Also updates the RR intervals
%	as follows; if RRMode is set to 'auto' then automatically
%	recomputes the new RR intevrals. If RRMode is set to 'manual'
%	then clear any existing RR intervals.
%
% == Others
% 'StartTime' - Absolute start time as a date vector:
%       [YY, MM, DD, HH, MN, SS]
% 'SamplingRate' - Sampling Rate in [Hz].
%       It automatically updates the timestamps
% 'RPeaksMode' - Sets the R peaks maintenance mode to either 
%   'manual' or 'auto'. In changing to 'auto' R peaks intervals
%   are refreshed.
% 'RPeaksAlgo' - Sets the R peaks detection algorithm to either 
%   'LoG' or 'Chen2017'. If 'RPeaksMode' is set to 'auto' R peaks
%   are refreshed.
% 'Threshold' - The threshold (either manual or automatic). Changing
%    this property is only possible when in manual mode. Setting
%    a new threshold automatically recalculates the rPeaks.
% 'RPeaks' - Manually sets the R peaks. See also 'RPeaksMode' and
%	'Threshold'. Refer to private method getRR for calculating
%	 RR intervals
%
%
% Copyright 2009
% @date: 19-Jan-2009
% @author Felipe Orihuela-Espina
%
% See also structuredData, get
%

%% Log:
%
% 29-May-2019: FOE:
%   + Log started
%   + Added support for property rPeaksAlgo
%

%% Log
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 20-February-2022 (ESR): We simplify the code
%   + All cases are in the ecg class.
%   + We create a dependent property inside the ecg class.
%   + The data, NN and RR properties are in the
%   ecg class.

propertyArgIn = varargin;
   while (length(propertyArgIn) >= 2)
       prop = propertyArgIn{1};
       val = propertyArgIn{2};
       propertyArgIn = propertyArgIn(3:end);
       
       obj.(lower(prop)) = val; %Ignore case
   end
end
%assertInvariants(obj);