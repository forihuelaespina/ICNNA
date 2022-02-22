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
% 'Description' - Changes the description of the object
% 'Date' - Changes the date associated with the object.
%
% == Others
% 'Version' - DEPRECATED. Version of data structure of the ETG-4000 file
%       Use 'FileVersion' instead.
% 'FileVersion' - Version of data structure of the ETG-4000 file
% 'SubjectName' - The subject's name
% 'SubjectSex' - The subject's sex
% 'SubjectBirthDate' - The subject's birth date
% 'SubjectAge' - The subject's age in years
% 'AnalyzeMode' - Analyze mode
% 'PreTime' - Pre time
% 'PostTime' - Post time
% 'RecoveryTime' - Recovery time
% 'BaseTime' - Baseline time
% 'FittingDegree' - Degree of the polynolmial function for detrending
% 'HPF' - High Pass Filter
% 'LPF' - Low Pass Filter
% 'MovingAverage' - Number of seconds of a moving average filter
% 'NominalWavelengthSet' - Set of wavelength at which the device operates
%       assuming no error
% 'SamplingPeriod' - Sampling Period in [s]
% 'SamplingRate' - Sampling Rate in [Hz]
% 'nBlocks' - DEPRECATED. Number of times the stimulus train sequence is repeated
%       Use 'RepeatCount' instead.
% 'RepeatCount' - Number of times the stimulus train sequence is repeated
% 'LightRawData' - The light intensitites recorded
% 'Marks' - Stimulus marks representing the timeline
%       One column per probe set.
% 'Timestamps' - Vector of sample acquisition timestamps in [s]
%       Relative to the object's Date. Note that no check
%       is done regarding the validity of the timestamps.
%       One column per probe set.
% 'BodyMovement' - Body movement artifacts as determined by the ETG-4000
%       One column per probe set.
% 'RemovalMarks' - Removal marks
%       One column per probe set.
% 'preScan' - preScan stamps
%       One column per probe set.
%
%
%
% Copyright 2008-17
% @date: 13-Jun-2008
% @author Felipe Orihuela-Espina
% @modified: 28-Jul-2017
%
% See also rawData.set, get
%



%% Log
%
% 28-Jul-2017 (FOE): Bug fixed.
%   When setting the value of the moving average it was expecting
%   an integer, but this value is expressed in seconds and thus
%   it may actually be a real number.
%
% 14-Jan-2016 (FOE): Bug fixed.
%   When setting the lightRawData check for input size now properly
%   checks the match in size with the number of probe sets declared
%   instead of expecting a 3D matrix.
%
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 17-February-2022 (ESR): We simplify the code
%   + All cases are in the rawData_UCLWireless class.
%   + We create a dependent property inside the rawData_ETG4000 class.
%   
%

propertyArgIn = varargin;
while (length(propertyArgIn) >= 2)
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);

   obj.(lower(prop)) = val; %Ignore case
end
    assertInvariants(obj);
end
