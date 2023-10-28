function sp=getOptodeSurfacePositions(obj,idx)
%CHANNELLOCATIONMAP/GETCHANNELSURFACEPOSITIONS Gets the surface positions for optodes
%
% sp=getOptodeSurfacePositions(obj) Gets the surface positions for all
%   optodes as a cell array. The cell array may be empty if the
%   number of optodes is 0.
%
% sp=getOptodeSurfacePositions(obj,idx) Gets the surface positions for the
%   selected optodes as a cell array. If any of the indexes to optodes
%   is beyond the number of optodes, it will be ignored. The cell
%   array may be empty if the number of optodes is 0, or none of the
%   indexes is valid.
%
%% Parameters
%
% idx - (Optional) A vector of optode indexes.
%
%
%% References
%
%   [JurcakV2007] Jurcak, V.; Tsuzuki, D.; Dan, I. "10/20, 10/10,
%   and 10/5 systems revisited: Their validity as relative
%   head-surface-based positioning systems" NeuroImage 34 (2007) 1600–1611
%
%
% Copyright 2013-23
% @author: Felipe Orihuela-Espina
%
% See also setOptodeSurfacePositions, getOptode3DLocations,
%   getOptodeStereotacticPositions,
%   getOptodeOptodeArrays, getOptodeProbeSets
%


%% Log
%
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
%



sp=obj.optodesSurfacePositions;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>obj.nOptodes)=[];
    sp=sp(idx);
end


end