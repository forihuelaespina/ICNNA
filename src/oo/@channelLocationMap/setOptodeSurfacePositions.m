function obj=setOptodeSurfacePositions(obj,idx,positions)
%CHANNELLOCATIONMAP/SETOPTODESURFACEPOSITIONS Set surface positions for optodes
%
% obj=setOptodeSurfacePositions(obj,idx,positions) Updates the surface
%   position for a optode or a set of optodes.
%   Indexes lower than 0 or beyond the number of optodes will be
%   ignored.
%
%
%% Parameters
%
% idx - A vector of optode indexes.
%
% positions - A cell array of strings containing surface positions.
%       You may indicate an empty string '' to clear/unset a position.
%       Currently, only the 10/20 and UI 10/10 systems
%       [JurcakV2007] are supported.
%
%
%% References
%
%   [JurcakV2007] Jurcak, V.; Tsuzuki, D.; Dan, I. "10/20, 10/10,
%   and 10/5 systems revisited: Their validity as relative
%   head-surface-based positioning systems" NeuroImage 34 (2007) 1600–1611
%  
%
%
% Copyright 2023
% @author: Felipe Orihuela-Espina
%
% See also getOptodeSurfacePositions, setOptode3DLocations,
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




if ~iscell(positions)
    error('ICNNA:channelLocationMap:setOptodeSurfacePositions:InvalidParameterValue',...
          'Positions must be a cell array.');
end
    
assert(numel(idx)==numel(positions),...
        ['ICNNA:channelLocationMap:setSurfacePositions:InvalidParameterValue',...
         'Number of optode indexes mismatches number of positions.']);
idx=reshape(idx,numel(idx),1); %Ensure both are vectors
positions=reshape(positions,numel(positions),1);

%Check whether the indicated positions correspond to defined positions
[valid]=channelLocationMap.isValidSurfacePosition(positions,...
                                get(obj,'SurfacePositioningSystem'));
if ~all(valid)
    warning('ICNNA:optodeLocationMap:setSurfacePositions:InvalidPosition',...
        'Invalid positions found. Only valid positions will be updated.');
    tempIdx=find(~valid);
    idx(tempIdx)=[];
    positions(tempIdx)=[];
end


tempIdx=find(idx<1 | idx> obj.nOptodes);
idx(tempIdx)=[];
positions(tempIdx)=[];

obj.optodesSurfacePositions(idx)=positions;
    
assertInvariants(obj);

end
