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
% Copyright 2012-23
% @author: Felipe Orihuela-Espina
%
% See also getChannelProbeSets, setChannel3DLocations,
%   setChannelSurfacePositions,
%   setChannelStereotacticPositions, setChannelOptodeArrays,
%


%% Log
%
%
% File created: 22-Dec-2012
% File last modified (before creation of this log): 8-Sep-2013
%
% 8-Sep-2013: Method name changed from getProbeSets to
%       getChannelProbeSets. Updated "links" of the
%       See also section
%
%
% 21-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%



assert(numel(idx)==numel(ps),...
        ['ICNNA:channelLocationMap:setChannelProbeSets:InvalidParameterValue',...
         'Number of channel indexes mismatches number of associated ' ...
         'probe sets.']);
idx=reshape(idx,numel(idx),1); %Ensure both are vectors
ps=reshape(ps,numel(ps),1);

tempIdx=find(idx<1 | idx>obj.nChannels);
idx(tempIdx)=[];
ps(tempIdx)=[];

obj.chProbeSets(idx)=ps;

assertInvariants(obj);

end
