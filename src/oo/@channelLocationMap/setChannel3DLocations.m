function obj=setChannel3DLocations(obj,idx,locations)
%CHANNELLOCATIONMAP/SETCHANNEL3DLOCATIONS Set 3D locations for channels
%
% obj=setChannel3DLocations(obj,idx,locations) Updates the 3D locations
%   for a channel or a set of channels.
%   Indexes lower than 0 or beyond the number of channels will be
%   ignored.
%
%
%% Parameters
%
% idx - A vector of channel indexes.
%
% positions - A nx3 matrix of 3D locations where n is the length
%       of idx.
%
%
%
%
% Copyright 2012-13
% @author: Felipe Orihuela-Espina
%
% See also getChannel3DLocations, setChannelSurfacePositions,
%   setChannelStereotacticPositions,
%   setChannelOptodeArrays, setChannelProbeSets
%


%% Log
%
%
% File created: 22-Dec-2012
% File last modified (before creation of this log): 8-Sep-2013
%
% 8-Sep-2013: Method name changed from get3DLocations to
%       getChannel3DLocations. Also updated the property accessed
%       from .locations to .chLocations. Updated "links" of the
%       See also section
%
% 21-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%


assert(numel(idx)==size(locations,1),...
        ['ICNA:channelLocationMap:setChannel3DLocations:InvalidParameterValue',...
         'Number of channel indexes mismatches number of locations.']);
assert(size(locations,2)==3,...
        ['ICNA:channelLocationMap:setChannel3DLocations:InvalidParameterValue',...
         'Unexpected dimensionality for locations.']);
idx=reshape(idx,numel(idx),1); %Ensure it is a vector

tempIdx=find(idx<1 | idx> obj.nChannels);
idx(tempIdx)=[];
locations(tempIdx,:)=[];

obj.chLocations(idx,:)=locations;

assertInvariants(obj);

end
