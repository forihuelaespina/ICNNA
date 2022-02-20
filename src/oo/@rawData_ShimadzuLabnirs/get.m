function val = get(obj, propName)
% RAWDATA_SHIMADZULABNIRS/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%This method extends the superclass get method
%
%% Properties
%
%== Inherited
% 'Description' - Gets the object's description
% 'Date' - Gets the date associated with the object.
%       See also timestamps
%
% == Others
% 'NominalWavelengthSet' - Set of wavelength at which the device operates
%       assuming no error
% 'SamplingRate' - Sampling Rate in [Hz]
% 'rawData' - The oxyhaemoglobin raw concentrations recorded
% 'Timestamps' - Sample acquisition timestamps relative
%       to experiment onset (inherited). 
% 'nSamples' - Number of temporal samples
% 'nChannels' - Number of channels
% 'preTimeline' - A vector with preTimeline experimntal condition flags
% 'nEvents' - Number of pretimeline-like events
% 'marks' - A vector of marks.
%
%
%
%
%
% Copyright 2016
% @date: 20-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 20-Sep-2016
%
% See also rawData.get, set
%

%% Log
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 13-February-2022 (ESR): We simplify the code
%   + All cases are in the rawData_ShamdzuLabnirs class.
%   + We create a dependent property inside the rawData_ShamdzuLabnirs.
%

     val = obj.(lower(propName)); %Ignore case
end