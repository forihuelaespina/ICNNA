function [oaInfo]=getOptodeArraysInfo(obj,idx)
%CHANNELLOCATIONMAP/GETOPTODEARRAYSINFO Get the information associated to the optode arrays
%
% oaInfo=getOptodeArraysInfo(obj) Gets the information associated
%   for all optode arrays. The struct may be empty if the
%   number of optode arrays is 0.
%
% oaInfo=getOptodeArraysInfo(obj,idx) Gets the information associated
%   for the selected optode arrays. If any of the indexes to optode arrays
%   is beyond the number of optode arrays, it will be ignored. The struct
%   may be empty if the number of optode arrays is 0, or none of the
%   indexes are valid.
%
% Please refer to channelLocationMap class documentation for the
%information fields.
%
%
% Copyright 2012-13
% @date: 22-Dec-2012
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also setOptodeArraysInfo, setChannelOptodeArrays, 
%   getChannel3DLocations, getChannelSurfacePositions,
%   getChannelStereotacticPositions, getChannelProbeSets
%   setOptodeOptodeArrays, 
%   getOptode3DLocations, getOptodeSurfacePositions,
%   getOptodeStereotacticPositions, getOptodeProbeSets
%

%% Log
%
% 8-Sep-2013: Updated "links" of the See also call to other methods
%


oaInfo=obj.optodeArrays;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>length(obj.optodeArrays))=[];
    oaInfo=oaInfo(idx);
end
