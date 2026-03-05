function [iod] = getIOD(obj)
%CHANNELLOCATIONMAP/GETIOD Gets the interoptode distances for all channels
%
%   [[iod] = getIOD(obj) - Gets the interoptode distances for all channels.
%
%% Known limitation
%
% @channelLocationMap class does NOT store the spatial units, e.g.
% [cm] or [mm]. This can make deciding whether a channel is a short
% channel or a long channel ambiguous.
%
%% Remarks
%
%   By default, interoptode distances are calculated over the 3D locations
% of the sources and detectors. Only if 3D locations are not available, 
% the 2D locations will be used.
%
%   Interoptode distances are approximated using Euclidean distances.
%
%
%% Parameters
%
% obj - An @channelLocationMap.
%
%% Output
% iod - double[]. Channel interoptode distances.
%
%   +==========================================+
%   | The units of the distances correspond to |
%   | whatever units the optode locations are  |
%   | expressed.                               |
%   +==========================================+
%
%
%
% Copyright 2025-26
% @author: Felipe Orihuela-Espina
%
% See also channelLocationMap
%



%% Log
%
% 14-Apr-2025: FOE
%   + File created.
%
% 18-Feb-2026: FOE
%   + Bug fixed. Retrieval of locations for sources and detectors
%   was only using 1D coordinate rather than all 3D; first for
%   sources and second for detectors.
%   + Improved efficiency. Got rid of a per-channel loop.
%

pairings = obj.getPairings();
%Watch out! Pairings indexes src and detectors together
% as optodes. The next two lines are therefore the indexes
% over the complete optode list, rather than as separate
% counting for sources and detectors. In extracting the
% locations from property optodesLocations there is no need
% to additionally check for the optode type.
srcIdx = pairings(:,1);
detIdx = pairings(:,2);
srcLocations = obj.optodesLocations(srcIdx,:);
detLocations = obj.optodesLocations(detIdx,:);

tmpIOD = srcLocations - detLocations;
iod = sqrt(sum(tmpIOD.^2,2));
    %Simplified to Euclidean (rather than geodesic)


end