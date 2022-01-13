function ps=getChannelProbeSets(obj,idx)
%CHANNELLOCATIONMAP/GETCHANNELPROBESETS Gets the probe sets for channels
%
% probeSets=getChannelProbeSets(obj) Gets the probe sets for all
%   channels as an nx1 vector. The vector may be empty if the
%   number of channels is 0.
%
% probeSets=getChannelProbeSets(obj,idx) Gets the probe sets for the
%   selected channels as an nx1 vector. If any of the indexes to channels
%   is beyond the number of channels, it will be ignored. The vector
%   may be empty if the number of channels is 0, or none of the
%   indexes is valid.
%
%
%
% Copyright 2012-13
% @date: 26-Nov-2012
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also setChannelProbeSets, getChannel3DLocations,
%   getChannelSurfacePositions, getChannelOptodeArrays,
%   getChannelStereotacticPositions
%

%% Log
%
% 8-Sep-2013: Method name changed from getProbeSets to
%       getChannelProbeSets.
%



ps=obj.chProbeSets;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>get(obj,'nChannels'))=[];
    ps=ps(idx,:);
end