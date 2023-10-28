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
% Copyright 2012-23
% @author: Felipe Orihuela-Espina
%
% See also setChannelProbeSets, getChannel3DLocations,
%   getChannelSurfacePositions, getChannelOptodeArrays,
%   getChannelStereotacticPositions
%

%% Log
%
%
% File created: 26-Nov-2012
% File last modified (before creation of this log): 8-Sep-2013
%
% 8-Sep-2013: Method name changed from getProbeSets to
%       getChannelProbeSets.
%   + Added this log.
%
% 20-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%



ps=obj.chProbeSets;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>obj.nChannels)=[];
    ps=ps(idx,:);
end


end