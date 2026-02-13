function obj = addDetectors(obj,dets)
%Add @icnna.data.core.lightDetector(s) to the @icnna.data.core.nirsMontage
%
% obj = addDetectors(obj,srcs) 
%
% Add light detectors to a nirs montage. 
%
% This method is an ALL or NONE; either all new light detectors must
%be added or none will be added.
% 
%
%% Parameters
%
% srcs - icnna.data.core.lightDetector[]
%   Array of light detectors to be added. If empty, nothing is added.
%  
%% Output
%
% obj - @icnna.data.core.nirsMontage
%   The nirs montage with the light detectors updated.
%
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
%
% See also icnna.data.core.lightDetector
%


%% Log
%
%
% -- ICNNA v1.4.0
%
% 25-Dec-2025: FOE 
%   + File created.
%


if isempty(dets)
    %Do nothing
    return
end

tmpIDs = [[obj.detectors.id]'; [dets.id]'];
assert(numel(tmpIDs) == numel(unique(tmpIDs)),...
        ['icnna:data:core:nirsMontage:addDetectors:InvalidEvent ', ...
        'Repeated light detectors |id|.']);

tmpNames = [{obj.detectors.name}'; {dets.name}'];
assert(numel(tmpNames) == numel(unique(tmpNames)),...
        ['icnna:data:core:nirsMontage:addDetectors:InvalidEvent ', ...
        'Repeated light detectors |name|.']);


nDets    = obj.nDetectors;
nNewDets = numel(dets);

%Add the detectors
[~,idx] = sort(tmpIDs);

obj.detectors = [obj.detectors; dets];
obj.detectors = obj.detectors(idx); %Sort by detector ID


end