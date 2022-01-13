function ps=getOptodeProbeSets(obj,idx)
%CHANNELLOCATIONMAP/GETOPTODEPROBESETS Gets the probe sets for optodes
%
% probeSets=getOptodeProbeSets(obj) Gets the probe sets for all
%   optodes as an nx1 vector. The vector may be empty if the
%   number of optodes is 0.
%
% probeSets=getOptodeProbeSets(obj,idx) Gets the probe sets for the
%   selected optodes as an nx1 vector. If any of the indexes to optodes
%   is beyond the number of optodes, it will be ignored. The vector
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
% See also setOptodeProbeSets, getOptode3DLocations,
%   getOptodeSurfacePositions, getOptodeOptodeArrays,
%   getOptodeStereotacticPositions
%

%% Log
%
% 8-Sep-2013: Method created.
%



ps=obj.optodesProbeSets;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>get(obj,'nOptodes'))=[];
    ps=ps(idx,:);
end