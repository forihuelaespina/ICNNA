function sp=getChannelSurfacePositions(obj,idx)
%CHANNELLOCATIONMAP/GETCHANNELSURFACEPOSITIONS Gets the surface positions for channels
%
% sp=getChannelSurfacePositions(obj) Gets the surface positions for all
%   channels as a cell array. The cell array may be empty if the
%   number of channels is 0.
%
% sp=getChannelSurfacePositions(obj,idx) Gets the surface positions for the
%   selected channels as a cell array. If any of the indexes to channels
%   is beyond the number of channels, it will be ignored. The cell
%   array may be empty if the number of channels is 0, or none of the
%   indexes is valid.
%
%% Parameters
%
% idx - (Optional) A vector of channel indexes.
%
%
%% References
%
%   [JurcakV2007] Jurcak, V.; Tsuzuki, D.; Dan, I. "10/20, 10/10,
%   and 10/5 systems revisited: Their validity as relative
%   head-surface-based positioning systems" NeuroImage 34 (2007) 1600–1611
%
%
% Copyright 2012-23
% @author: Felipe Orihuela-Espina
%
% See also setChannelSurfacePositions, getChannel3DLocations,
%   getChannelStereotacticPositions,
%   getChannelOptodeArrays, getChannelProbeSets
%


%% Log
%
%
% File created: 26-Nov-2012
% File last modified (before creation of this log): 8-Sep-2013
%
% 8-Sep-2013: Method name changed from getSurfacePositions to
%       getChannelSurfacePositions. Also updated the property accessed
%       from .surfacePositions to .chSurfacePositions
%   + Added this log.
%
% 20-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%


sp=obj.chSurfacePositions;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>obj.nChannels)=[];
    sp=sp(idx);
end


end