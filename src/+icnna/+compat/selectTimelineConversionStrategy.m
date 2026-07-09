function [convertFcn] = selectTimelineConversionStrategy(aTimeline)
% Selects the (source -> icnna.data.core.timeline) converter
%
%   [convertFcn] = icnna.compat.selectTimelineConversionStrategy(aTimeline)
%
%
%% Exemplary use
%
%   convertFcn = icnna.compat.selectTimelineConversionStrategy(aTimeline);
%   t = convertFcn(aTimeline);
%
%
%% Behaviour
%
% Extension point: Register a further converter here as new legacy
% representations appear. Keep each converter as a new converter
% function in +icnna/+compat.
% It eliminates the otherwise need for an inline ladder of conversion bodies.
%
% The dispatched function is the one specific to the source class
% only. Class version dispatches are layered as divergence appear.
%
%
%
%% Error handling
%
%   @li icnna:compat:selectTimelineConversionStrategy:InvalidInputType - Raised
%       if the input type is not compatible with an @icnna.data.core.timeline.
%
%
%% Input parameters
%
% aTimeline - {icnna.data.core.timeline | timeline (oo/)}
%   A timeline to migrate.
%
%% Output
%
% convertFcn - handle to function
%   A handle to the converter function.
%
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.timeline
%
%



%% Log
%
% -- ICNNA v1.4.2
%
% 8-Jul-2026: FOE
%   + File created.
%  

tmpClassStr = class(aTimeline);

switch (tmpClassStr)
    case 'icnna.data.core.timeline'
        convertFcn = @icnna.data.core.timeline; %call the copy constructor

    case 'timeline'
        convertFcn = @icnna.compat.ooTimeline2CoreTimeline; 

    otherwise
        error('icnna:compat:selectTimelineConversionStrategy:InvalidInputType',...
            ['Class ' tmpClassStr ...
            ' is not compatible with @icnna.data.core.timeline.']);
end

end