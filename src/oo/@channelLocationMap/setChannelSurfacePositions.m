function obj=setChannelSurfacePositions(obj,idx,positions)
%CHANNELLOCATIONMAP/SETCHANNELSURFACEPOSITIONS Set surface positions for channels
%
% obj=setChannelSurfacePositions(obj,idx,positions) Updates the surface
%   position for a channel or a set of channels.
%   Indexes lower than 0 or beyond the number of channels will be
%   ignored.
%
%
%% Parameters
%
% idx - A vector of channel indexes.
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
% Copyright 2012-13
% @date: 26-Nov-2012
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also getChannelSurfacePositions, setChannel3DLocations,
%   setChannelStereotacticPositions,
%   setChannelOptodeArrays, setChannelProbeSets
%


%% Log
%
% 8-Sep-2013: Method name changed from getSurfacePositions to
%       getChannelSurfacePositions. Also updated the property accessed
%       from .surfacePositions to .chSurfacePositions. Updated "links"
%       of the See also section
%




if ~iscell(positions)
    error('ICNA:channelLocationMap:setChannelSurfacePositions:InvalidParameterValue',...
          'Positions must be a cell array.');
end
    
assert(numel(idx)==numel(positions),...
        ['ICNA:channelLocationMap:setSurfacePositions:InvalidParameterValue',...
         'Number of channel indexes mismatches number of positions.']);
idx=reshape(idx,numel(idx),1); %Ensure both are vectors
positions=reshape(positions,numel(positions),1);

%Check whether the indicated positions correspond to defined positions
[valid]=channelLocationMap.isValidSurfacePosition(positions,...
                                get(obj,'SurfacePositioningSystem'));
if ~all(valid)
    warning('ICNA:channelLocationMap:setSurfacePositions:InvalidPosition',...
        'Invalid positions found. Only valid positions will be updated.');
    tempIdx=find(~valid);
    idx(tempIdx)=[];
    positions(tempIdx)=[];
end


tempIdx=find(idx<1 | idx>get(obj,'nChannels'));
idx(tempIdx)=[];
positions(tempIdx)=[];

obj.chSurfacePositions(idx)=positions;
    
assertInvariants(obj);

end
