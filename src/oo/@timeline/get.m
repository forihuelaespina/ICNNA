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

switch lower(propName)
case 'length'
   val = obj.length;
case 'samplingrate'
   val = 0;
   if obj.length == 0
        val = 0;
   elseif obj.length == 1
        val = 1/timestamps(1);
   else
        val = 1/nanmean(obj.timestamps(2:end)-obj.timestamps(1:end-1));
   end
case 'nominalsamplingrate'
   val = obj.nominalSamplingRate;
case 'starttime'
   val = obj.startTime;
case 'timestamps'
   val = obj.timestamps;
case 'nconditions'
   val = length(obj.conditions);
otherwise
   error([propName,' is not a valid property'])
end