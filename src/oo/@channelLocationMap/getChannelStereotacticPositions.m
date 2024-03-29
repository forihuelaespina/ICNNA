function sp=getChannelStereotacticPositions(obj,idx)
%CHANNELLOCATIONMAP/GETCHANNELSTEREOTACTICPOSITIONS Gets the stereotactic positions for channels
%
% positions=getChannelStereotacticPositions(obj) Gets the stereotactic positions
%   for all channels as an nx3 matrix. The matrix may be empty if the
%   number of channels is 0.
%
% positions=getChannelStereotacticPositions(obj,idx) Gets the stereotactic
%   positions for the selected channels as an nx3 matrix. If any of
%   the indexes to channels is beyond the number of channels, it will
%   be ignored. The matrix may be empty if the number of channels is 0,
%   or none of the indexes is valid.
%
%
%
% Copyright 2012-23
% @author: Felipe Orihuela-Espina
%
% See also setChannelStereotacticPositions, getChannel3DLocations,
%   getChannelSurfacePositions, getChannelOptodeArrays, getChannelProbeSets
%


%% Log
%
%
% File created: 26-Nov-2012
% File last modified (before creation of this log): 8-Sep-2013
%
% 8-Sep-2013: Method name changed from getStereotacticPositions to
%       getChannelStereotacticPositions. Also updated the property
%       accessed from .stereotacticPositions to .chStereotacticPositions
%   + Added this log.
%
% 20-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%


sp=obj.chStereotacticPositions;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>obj.nChannels)=[];
    sp=sp(idx,:);
end


end