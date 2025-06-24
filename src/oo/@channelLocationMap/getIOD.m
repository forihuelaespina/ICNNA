function [iod] = getIOD(obj)
%CHANNELLOCATIONMAP/GETIOD Gets the interoptode distances for all channels
%
%   [[iod] = getIOD(obj) - Gets the interoptode distances for all channels.
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
%   +==========================================+
%   | The units of the distances correspond to |
%   | whatever units the optode locations are  |
%   | expressed.                               |
%   +==========================================+
%
%
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also channelLocationMap
%



%% Log
%
% 14-Apr-2025: FOE
%   + File created.
%


iod = nan(obj.nChannels,1);
pairings = obj.getPairings();
for iCh = 1:obj.nChannels
    srcIdx = pairings(iCh,1);
    detIdx = pairings(iCh,2);
    tmpIOD = obj.optodesLocations(srcIdx,:) ...
           - obj.optodesLocations(detIdx,:);
    iod(iCh) = sqrt(sum(tmpIOD.^2));
    %Simplified to Euclidean (rather than geodesic)
end


end