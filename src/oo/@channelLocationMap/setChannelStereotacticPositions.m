function obj=setChannelStereotacticPositions(obj,idx,positions)
%CHANNELLOCATIONMAP/SETCHANNELSTEREOTACTICPOSITIONS Set stereotactic positions for channels
%
% obj=setChannelStereotacticPositions(obj,idx,positions) Updates the
%   stereotactic positions for a channel or a set of channels.
%   Indexes lower than 0 or beyond the number of channels will be
%   ignored.
%
%
%% Parameters
%
% idx - A vector of channel indexes.
%
% positions - A nx3 matrix of stereotactic positions where n is the length
%       of idx.
%
%
%
%
% Copyright 2012-13
% @date: 22-Dec-2012
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also getChannelStereotacticPositions, setChannel3DLocations,
%   setChannelSurfacePositions,
%   setChannelOptodeArrays, setChannelProbeSets
%


%% Log
%
% 8-Sep-2013: Method name changed from getStereotacticPositions to
%       getChannelStereotacticPositions. Also updated the property accessed
%       from .stereotacticPositions to .chStereotacticPositions.
%       Updated "links" of the See also section
%


assert(numel(idx)==size(positions,1),...
        ['ICNA:channelLocationMap:setChannelStereotacticPositions:InvalidParameterValue',...
         'Number of channel indexes mismatches number of positions.']);
assert(size(positions,2)==3,...
        ['ICNA:channelLocationMap:setChannelStereotacticPositions:InvalidParameterValue',...
         'Unexpected dimensionality for stereotactic positions.']);
idx=reshape(idx,numel(idx),1); %Ensure it is a vector

tempIdx=find(idx<1 | idx>get(obj,'nChannels'));
idx(tempIdx)=[];
positions(tempIdx,:)=[];

obj.chStereotacticPositions(idx,:)=positions;

assertInvariants(obj);

end
