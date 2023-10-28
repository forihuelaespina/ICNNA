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
% Copyright 2023
% @author: Felipe Orihuela-Espina
%
% See also setOptodeProbeSets, getOptode3DLocations,
%   getOptodeSurfacePositions, getOptodeOptodeArrays,
%   getOptodeStereotacticPositions
%

%% Log
%
% File created: 8-Sep-2013
% File last modified (before creation of this log): N/A. This method was
%   never update since creation.
%
% 8-Sep-2013: Method created
%   + Added this log.
%
% 20-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%



ps=obj.optodesProbeSets;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>obj.nOptodes)=[];
    ps=ps(idx,:);
end


end