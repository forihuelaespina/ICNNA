function obj = set(obj,varargin)
% TIMELINE/SET Set object properties and return the updated object
%
% obj = set(obj,'PropertyName',propertyValue) Set object properties and
%   return the updated object
%
%% Properties
%
% 'Length' - Length of the timeline in number of samples
%When updating the 'Length', if the current timeline has
%events defined that last beyond the new size, this operation
%will issue a warning before cropping or removing those events.
% 'NominalSamplingRate' - Declared sampling rate in Hz. It may
%       differ from the real sampling rate (see get(obj,'SamplingRate')).
%       This is used for automatically generating timesamples
%       when these latter are unknown. Note however that setting the
%       nominalSamplingRate does not recompute (existing) timestamps.
% 'StartTime' - An absolute start date
% 'Timestamps' - A vector (of 'Length'x1) of timestamps in seconds
%       expressed relative to the startTime. From these, the real
%       average sampling rate (different from the nominal sampling
%       rate) is calculated.
%
%
%
%
% Copyright 2008-12
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 29-Dec-2012
%
%See also get, addCondition, addConditionEvents, setConditionEvents
%

%% Log
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 31-January-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the timeline class.
%   + Creation of the .cropOrRemoveEvents object:
%   the Auxiliar Nested functions are inside.

propertyArgIn = varargin;
while (length(propertyArgIn) >= 2)
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);

   obj.(lower(prop)) = val; %Ignore case
end
    assertInvariants(obj);

end