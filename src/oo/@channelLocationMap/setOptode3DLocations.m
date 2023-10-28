function obj=setOptode3DLocations(obj,idx,locations)
%CHANNELLOCATIONMAP/SETOPTODE3DLOCATIONS Set 3D locations for optodes
%
% obj=setOptode3DLocations(obj,idx,locations) Updates the 3D locations
%   for a optode or a set of optodes.
%   Indexes lower than 0 or beyond the number of optodes will be
%   ignored.
%
%
%% Parameters
%
% idx - A vector of optode indexes.
%
% positions - A nx3 matrix of 3D locations where n is the length
%       of idx.
%
%
%
%
% Copyright 2013
% @author: Felipe Orihuela-Espina
%
% See also getOptode3DLocations, setOptodeSurfacePositions,
%   setOptodeStereotacticPositions,
%   setOptodeOptodeArrays, setOptodeProbeSets
%


%% Log
%
%
% File created: 8-Sep-2013
% File last modified (before creation of this log): N/A. This method had
%   not been modified since creation.
%
% 8-Sep-2013: Method created
%
%
% 21-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%


assert(numel(idx)==size(locations,1),...
        ['ICNNA:optodeLocationMap:setOptode3DLocations:InvalidParameterValue',...
         'Number of optode indexes mismatches number of locations.']);
assert(size(locations,2)==3,...
        ['ICNNA:optodeLocationMap:setOptode3DLocations:InvalidParameterValue',...
         'Unexpected dimensionality for locations.']);
idx=reshape(idx,numel(idx),1); %Ensure it is a vector

tempIdx=find(idx<1 | idx> obj.nOptodes);
idx(tempIdx)=[];
locations(tempIdx,:)=[];

obj.optodesLocations(idx,:)=locations;

assertInvariants(obj);

end
