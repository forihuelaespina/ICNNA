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
% Copyright 2013
% @date: 8-Sep-2013
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also getOptodeSurfacePositions, setOptode3DLocations,
%   setOptodeStereotacticPositions,
%   setOptodeOptodeArrays, setOptodeProbeSets
%


%% Log
%
% 8-Sep-2013: Method created
%




if ~iscell(positions)
    error('ICNA:channelLocationMap:setOptodeSurfacePositions:InvalidParameterValue',...
          'Positions must be a cell array.');
end
    
assert(numel(idx)==numel(positions),...
        ['ICNA:channelLocationMap:setSurfacePositions:InvalidParameterValue',...
         'Number of optode indexes mismatches number of positions.']);
idx=reshape(idx,numel(idx),1); %Ensure both are vectors
positions=reshape(positions,numel(positions),1);

%Check whether the indicated positions correspond to defined positions
[valid]=channelLocationMap.isValidSurfacePosition(positions,...
                                get(obj,'SurfacePositioningSystem'));
if ~all(valid)
    warning('ICNA:optodeLocationMap:setSurfacePositions:InvalidPosition',...
        'Invalid positions found. Only valid positions will be updated.');
    tempIdx=find(~valid);
    idx(tempIdx)=[];
    positions(tempIdx)=[];
end


tempIdx=find(idx<1 | idx>get(obj,'nOptodes'));
idx(tempIdx)=[];
positions(tempIdx)=[];

obj.optodesSurfacePositions(idx)=positions;
    
assertInvariants(obj);

end
