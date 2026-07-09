function [t] = toCoreTimeline(aTimeline)
%Converts any accepted timeline representation to @icnna.data.core.timeline
%
% [t] = icnna.compat.toCoreTimeline(aTimeline)
%
% Migration adapter. It guarantees an @icnna.data.core.timeline regardless
% of which timeline representation the caller holds. It provides a single
% named seam through which ICNNA code accepts different representations of
% the same concept while the underlying codebase is being migrated. This
% permits safe insertion at call sites without worrying about the
% representation upon which the data arrives.
%
% Note the subtle difference with a more rigid typecasting.
%
%% Behaviour
%
% Single migration seam for calling sites. Packaged based +icnna/ code
% still accepts the legacy oo/@timeline. This compatibility function
% decouples the calling site from the specific representation so that
% new code can evolve without having to worry about compatibility issues.
%
%   @li If the input object |aTimeline| is already an @icnna.data.core.timeline,
%       it is returned unchanged. 
% 
%   @li If the input object |aTimeline| is a legacy oo/@timeline, then this
%       is typecasted to @icnna.data.core.timeline by means of the
%       registered conversion strategy (see
%       icnna.compat.selectTimelineConversionStrategy)
%
%   @li Any other input type raises an error (see Sect Error Handling).
% 
% The adapter is idempotent. Applying it n times equals applying it once.
%
%% Remarks
%
% Conversion is dispatched by source representation, one isolated strategy
% per source, rather than by an inline type ladder. New legacy
% representations (or later, distinct source class versions) are added by
% registering a new strategy in
% icnna.compat.selectTimelineConversionStrategy, and having a converter as
% a new package function. The public signature and the calling site do not
% change.
%
%% Assumptions
%
% In some cases, the migrations is a simple typecasting e.g. when the source
% is a oo/@timeline, but this may not always be the case.
%
%% Input parameters
%
% aTimeline - {icnna.data.core.timeline | timeline (oo/)}
%   A timeline to migrate.
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

convertFcn = icnna.compat.selectTimelineConversionStrategy(aTimeline);
t = convertFcn(aTimeline);

end