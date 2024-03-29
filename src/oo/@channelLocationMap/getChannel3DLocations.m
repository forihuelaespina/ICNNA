function locations=getChannel3DLocations(obj,idx)
%CHANNELLOCATIONMAP/GETCHANNEL3DLOCATIONS Gets the 3D locations for channels
%
% locations=getChannel3DLocations(obj) Gets the 3D locations for all
%   channels as an nx3 matrix. The matrix may be empty if the
%   number of channels is 0.
%
% locations=getChannel3DLocations(obj,idx) Gets the 3D locations for the
%   selected channels as an nx3 matrix. If any of the indexes to channels
%   is beyond the number of channels, it will be ignored. The matrix
%   may be empty if the number of channels is 0, or none of the
%   indexes is valid.
%
%
%
% Copyright 2012-23
% @author: Felipe Orihuela-Espina
%
% See also setChannel3DLocations, getChannelSurfacePositions,
%   getChannelStereotacticPositions,
%   getChannelOptodeArrays, getChannelProbeSets, getReferencePoints
%


%% Log
%
%
% File created: 26-Nov-2012
% File last modified (before creation of this log): 8-Sep-2013
%
% 8-Sep-2013: Method name changed from get3DLocations to
%       getChannel3DLocations. Also updated the property accessed
%       from .locations to .chLocations
%   + Added this log.
%
% 20-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%


locations=obj.chLocations;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>obj.nChannels)=[];
    locations=locations(idx,:);
end


end