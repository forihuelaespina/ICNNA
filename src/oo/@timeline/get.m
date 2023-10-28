function val = get(obj, propName)
% TIMELINE/GET DEPRECATED (v1.2). Get properties from the specified object
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
% 'NConditions' - The number of conditions declared in the timeline.
%
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also timeline, getCondition, getConditionTag,
%   getConditionEvents
%



%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): 29-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED (v1.2).
%   Bug fixed:
%   + Comment for property nConditions was inaccurate.
%   + 1 error was still not using error code.
%

warning('ICNNA:timeline:get:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for accessing the attribute ' ...
         'e.g. timeline.' lower(propName) '.']); 
    %Maintain method by now to accept different capitalization though.

switch lower(propName)
    case 'length'
       val = obj.length;
    case 'samplingrate'
       val = obj.samplingRate;
    case 'nominalsamplingrate'
       val = obj.nominalSamplingRate;
    case 'starttime'
       val = obj.startTime;
    case 'timestamps'
       val = obj.timestamps;
    case 'nconditions'
       val = obj.nConditions;
    otherwise
       error('ICNNA:timeline:get:InvalidProperty',...
                [propName,' is not a valid property'])
end