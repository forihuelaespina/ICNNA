function val = get(obj, propName)
% TIMELINE/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
%
% 'Length' - The length of the timeline in samples.
% 'SamplingRate' - Average sampling rate. This is calculated on the
%       fly from the timestamps and use in many operations
%       e.g. getAvgTaskTime. This is different from the nominal
%       sampling rate.
% 'NominalSamplingRate' - Declared sampling rate. It may differ from the
%       real sampling rate (see 'SamplingRate'). This is used for
%       automatically generating timesamples when these latter are
%       unknown.
% 'StartTime' - An absolute start date (as a datenum)
% 'Timestamps' - A vector (of 'Length'x1) of timestamps in seconds
%       expressed relative to the startTime.
% 'NConditions' - The length of the timeline in samples.
%
%
%
% Copyright 2008-12
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 29-Dec-2012
%
% See also timeline, set, getCondition, getConditionTag,
%   getConditionEvents
%

%% Log
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 31-January-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the timeline class.
%

    val = obj.(lower(propName)); %Ignore case

end