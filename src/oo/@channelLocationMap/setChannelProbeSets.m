function obj=setChannelProbeSets(obj,idx,ps)
%CHANNELLOCATIONMAP/SETCHANNELPROBESETS Set the associated probe sets for channels
%
% obj=setChannelProbeSets(obj,idx,ps) Updates the associated probe
%   sets for a channel or a set of channels.
%   Indexes lower than 0 or beyond the number of channels will be
%   ignored.
%
%
%% Parameters
%
% idx - A vector of channel indexes.
%
% ps - A nx1 vector of associated probe sets where n is the
%       length of idx.
%
%
%
%
% Copyright 2012-13
% @date: 22-Dec-2012
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also getChannelProbeSets, setChannel3DLocations,
%   setChannelSurfacePositions,
%   setChannelStereotacticPositions, setChannelOptodeArrays,
%


%% Log
%
% 8-Sep-2013: Method name changed from getProbeSets to
%       getChannelProbeSets. Updated "links" of the
%       See also section
%



assert(numel(idx)==numel(ps),...
        ['ICNA:channelLocationMap:setChannelProbeSets:InvalidParameterValue',...
         'Number of channel indexes mismatches number of associated ' ...
         'probe sets.']);
idx=reshape(idx,numel(idx),1); %Ensure both are vectors
ps=reshape(ps,numel(ps),1);

tempIdx=find(idx<1 | idx>get(obj,'nChannels'));
idx(tempIdx)=[];
ps(tempIdx)=[];

obj.chProbeSets(idx)=ps;

assertInvariants(obj);

end
