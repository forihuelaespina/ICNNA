function obj=setOptodeProbeSets(obj,idx,ps)
%CHANNELLOCATIONMAP/SETOPTODEPROBESETS Set the associated probe sets for optodes
%
% obj=setOptodeProbeSets(obj,idx,ps) Updates the associated probe
%   sets for a optode or a set of optodes.
%   Indexes lower than 0 or beyond the number of optodes will be
%   ignored.
%
%
%% Parameters
%
% idx - A vector of optode indexes.
%
% ps - A nx1 vector of associated probe sets where n is the
%       length of idx.
%
%
%
%
% Copyright 2013-23
% @author: Felipe Orihuela-Espina
%
% See also getOptodeProbeSets, setOptode3DLocations,
%   setOptodeSurfacePositions,
%   setOptodeStereotacticPositions, setOptodeOptodeArrays,
%


%% Log
%
% File created: 8-Sep-2013
% File last modified (before creation of this log): N/A. This method
%   was never updated after creation.
%
% 8-Sep-2013: Method created
%   + Added this log.
%
% 20-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%



assert(numel(idx)==numel(ps),...
        ['ICNNA:channelLocationMap:setOptodeProbeSets:InvalidParameterValue',...
         'Number of optode indexes mismatches number of associated ' ...
         'probe sets.']);
idx=reshape(idx,numel(idx),1); %Ensure both are vectors
ps=reshape(ps,numel(ps),1);

tempIdx=find(idx<1 | idx>obj.nOptodes);
idx(tempIdx)=[];
ps(tempIdx)=[];

obj.optodesProbeSets(idx)=ps;

assertInvariants(obj);

end
