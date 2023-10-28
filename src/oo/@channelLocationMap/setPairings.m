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
% Copyright 2013-23
% @author: Felipe Orihuela-Espina
%
% See also getPairings, getOptodeTypes, setOptodeTypes
%


%% Log
%
%
% File created: 8-Sep-2013
% File last modified (before creation of this log): N/A. This method was
%   never update since creation.
%
% 8-Sep-2013: Method created
%   + Added this log.
%
% 20-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%


assert(numel(idx)==size(pairings,1),...
        ['ICNNA:channelLocationMap:setPairings:InvalidParameterValue',...
         'Number of channel indexes mismatches number of pairings.']);
assert(size(pairings,2)==2,...
        ['ICNNA:channelLocationMap:setPairings:InvalidParameterValue',...
         'Unexpected dimensionality for pairings.']);
idx=reshape(idx,numel(idx),1); %Ensure it is a vector

tempIdx=find(idx<1 | idx>obj.nChannels);
idx(tempIdx)=[];
pairings(tempIdx,:)=[];

obj.pairings(idx,:)=pairings;

assertInvariants(obj); %This will check that the <emisor,detector> invariant is met

end
