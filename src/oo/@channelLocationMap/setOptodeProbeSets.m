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
% Copyright 2013
% @date: 8-Sep-2013
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also getOptodeProbeSets, setOptode3DLocations,
%   setOptodeSurfacePositions,
%   setOptodeStereotacticPositions, setOptodeOptodeArrays,
%


%% Log
%
% 8-Sep-2013: Method created
%



assert(numel(idx)==numel(ps),...
        ['ICNA:channelLocationMap:setOptodeProbeSets:InvalidParameterValue',...
         'Number of optode indexes mismatches number of associated ' ...
         'probe sets.']);
idx=reshape(idx,numel(idx),1); %Ensure both are vectors
ps=reshape(ps,numel(ps),1);

tempIdx=find(idx<1 | idx>get(obj,'nOptodes'));
idx(tempIdx)=[];
ps(tempIdx)=[];

obj.optodesProbeSets(idx)=ps;

assertInvariants(obj);

end
