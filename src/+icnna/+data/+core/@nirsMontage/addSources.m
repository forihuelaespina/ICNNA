function obj = addSources(obj,srcs)
%Add @icnna.data.core.lightSource(s) to the @icnna.data.core.nirsMontage
%
% obj = addSources(obj,srcs) 
%
% Add light sources to a nirs montage. 
%
% This method is an ALL or NONE; either all new light sources must
%be added or none will be added.
% 
%
%% Parameters
%
% srcs - icnna.data.core.lightSource[]
%   Array of light sources to be added. If empty, nothing is added.
%  
%% Output
%
% obj - @icnna.data.core.nirsMontage
%   The nirs montage with the light sources updated.
%
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
%
% See also icnna.data.core.lightSource
%


%% Log
%
%
% -- ICNNA v1.4.0
%
% 25-Dec-2025: FOE 
%   + File created.
%


if isempty(srcs)
    %Do nothing
    return
end

tmpIDs = [[obj.sources.id]'; [srcs.id]'];
assert(numel(tmpIDs) == numel(unique(tmpIDs)),...
        ['icnna:data:core:nirsMontage:addSources:InvalidEvent ', ...
        'Repeated light sources |id|.']);

tmpNames = [{obj.sources.name}'; {srcs.name}'];
assert(numel(tmpNames) == numel(unique(tmpNames)),...
        ['icnna:data:core:nirsMontage:addSources:InvalidEvent ', ...
        'Repeated light sources |name|.']);


nSrcs    = obj.nSources;
nNewSrcs = numel(srcs);

%Add the light sources
[~,idx] = sort(tmpIDs);

obj.sources = [obj.sources; srcs];
obj.sources = obj.sources(idx); %Sort by source ID


end