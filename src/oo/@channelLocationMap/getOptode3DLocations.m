function locations=getOptode3DLocations(obj,idx)
%CHANNELLOCATIONMAP/GETOPTODE3DLOCATIONS Gets the 3D locations for optodes
%
% locations=getOptode3DLocations(obj) Gets the 3D locations for all
%   optodes as an nx3 matrix. The matrix may be empty if the
%   number of optodes is 0.
%
% locations=getOptode3DLocations(obj,idx) Gets the 3D locations for the
%   selected optodes as an nx3 matrix. If any of the indexes to optodes
%   is beyond the number of optodes, it will be ignored. The matrix
%   may be empty if the number of optodes is 0, or none of the
%   indexes is valid.
%
%
%
% Copyright 2013
% @date: 8-Sep-2013
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also setOptode3DLocations, getOptodeSurfacePositions,
%   getOptodeStereotacticPositions,
%   getOptodeOptodeArrays, getOptodeProbeSets, getReferencePoints
%


%% Log
%
% 8-Sep-2013: Method created
%


locations=obj.optodesLocations;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>get(obj,'nOptodes'))=[];
    locations=locations(idx,:);
end