function [t] = ooTimeline2CoreTimeline(aTimeline)
% A converter. Converts a legacy oo/@timeline into an @icnna.data.core.timeline
%
%   [t] = icnna.compat.ooTimeline2CoreTimeline(aTimeline)
%
%
%% Remarks
%
% This function is used by icnna.compat.toCoreTimeline via
% icnna.compat.selectTimelineConversionStrategy.
%
% v1.4.2: Delegates to the icnna.data.core.timeline typecasting
%   constructor, which currently owns the property mapping. Ideally,
%   this should be the only place that depends on that typecasting
%   constructor branch ahead of freezing oo/@timeline facilitating
%   the eventual deprecation and disappearance of that legacy class.
%   In other words, right now just a wrapper of the typecasting
%   constructor in icnna.data.core.timeline.
%
%% Input parameters
%
% aTimeline - @timeline (oo/)
%   A legacy oo/@timeline to migrate to @icnna.data.core.timeline.
%
%% Output
%
% t - icnna.data.core.timeline
%   The timeline migrated to @icnna.data.core.timeline
%
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also oo/@timeline, icnna.data.core.timeline
%
%



%% Log
%
% -- ICNNA v1.4.2
%
% 8-Jul-2026: FOE
%   + File created.
%  


prevState = warning('off','icnna:data:core:timeline:timeline:Deprecated');
    %Silence the deprecated warning when accessed this way.
restore   = onCleanup(@() warning(prevState)); %#ok<NASGU>
t = icnna.data.core.timeline(aTimeline);

end