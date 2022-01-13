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
% Copyright 2012-13
% @date: 26-Nov-2012
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also setChannelStereotacticPositions, getChannel3DLocations,
%   getChannelSurfacePositions, getChannelOptodeArrays, getChannelProbeSets
%


%% Log
%
% 8-Sep-2013: Method name changed from getStereotacticPositions to
%       getChannelStereotacticPositions. Also updated the property
%       accessed from .stereotacticPositions to .chStereotacticPositions
%


sp=obj.chStereotacticPositions;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>get(obj,'nChannels'))=[];
    sp=sp(idx,:);
end