function obj=setPairings(obj,idx,pairings)
%CHANNELLOCATIONMAP/SETPAIRINGS Sets the pairings of optodes conforming the channels
%
% obj=setChannel3DLocations(obj,idx,pairings) Sets the pairings of
%   optodes conforming the channels.
%   Indexes lower than 0 or beyond the number of channels will be
%   ignored.
%   Pairings should be made from emisors (or unknown) to detectors (or
%   unknown) optodes types. Please check getOptodeTypes for further
%   information
%
%
%% Parameters
%
% idx - A vector of channel indexes.
%
% positions - A nx2 matrix of <emisor, detector> pairs for the channels
%   
%
%
%
% Copyright 2013
% @date: 8-Sep-2013
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also getPairings, getOptodeTypes, setOptodeTypes
%


%% Log
%
% 8-Sep-2013: Method created
%


assert(numel(idx)==size(pairings,1),...
        ['ICNA:channelLocationMap:setPairings:InvalidParameterValue',...
         'Number of channel indexes mismatches number of pairings.']);
assert(size(pairings,2)==2,...
        ['ICNA:channelLocationMap:setPairings:InvalidParameterValue',...
         'Unexpected dimensionality for pairings.']);
idx=reshape(idx,numel(idx),1); %Ensure it is a vector

tempIdx=find(idx<1 | idx>get(obj,'nChannels'));
idx(tempIdx)=[];
pairings(tempIdx,:)=[];

obj.pairings(idx,:)=pairings;

assertInvariants(obj); %This will check that the <emisor,detector> invariant is met

end
