function obj=setChannelOptodeArrays(obj,idx,optArrays)
%CHANNELLOCATIONMAP/SETCHANNELOPTODEARRAYS Set the associated optode arrays for channels
%
% obj=setChannelOptodeArrays(obj,idx,optArrays) Updates the associated optode
%   arrays for a channel or a set of channels.
%   Indexes lower than 0 or beyond the number of channels will be
%   ignored.
%
% Please refer to method setOptodeArraysInfo for updating the information
%associated with an optode array
%
%% Parameters
%
% idx - A vector of channel indexes.
%
% optArrays - A nx1 vector of associated optode arrays where n is the
%       length of idx.
%
%
%
%
% Copyright 2012-13
% @author: Felipe Orihuela-Espina
%
% See also getChannelOptodeArrays, setChannel3DLocations,
%   setChannelSurfacePositions, setChannelStereotacticPositions,
%   setChannelProbeSets, setOptodeArraysInfo
%


%% Log
%
%
% File created: 22-Dec-2012
% File last modified (before creation of this log): 12-Oct-2013
%
% 12-Oct-2013: Bugs fixed. Mislabelled property obj.optodesOptodeArrays.
%       When enlarging the length of the optode arrays info, the 
%       assigment of the topographical arrangement when the associated
%       channels or optodes were zero, was incorrect.
%
% 10-Sep-2013: Bug fixed. Initialization of
%       obj.optodeArrays(oa).chTopoArrangement was made with 3 columns
%       instead of 2.
%
% 8-Sep-2013: Method name changed from getOptodeArrays to
%       getChannelOptodeArrays. Also updated the properties accessed
%       e.g. from .topoArrangement to .chTopoArrangement. Updated
%       "links" of the See also
%
%
% 21-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%
%



assert(numel(idx)==numel(optArrays),...
        ['ICNNA:channelLocationMap:setChannelOptodeArrays:InvalidParameterValue',...
         'Number of channel indexes mismatches number of associated ' ...
         'optode arrays.']);
idx=reshape(idx,numel(idx),1); %Ensure both are vectors
optArrays=reshape(optArrays,numel(optArrays),1);

tempIdx=find(idx<1 | idx>obj.nChannels);
idx(tempIdx)=[];
optArrays(tempIdx)=[];

obj.chOptodeArrays(idx)=optArrays;

%It may be necessary to increase the length of the optode arrays info
nOAs = max(obj.chOptodeArrays);
if nOAs > length(obj.optodeArrays)
    for oa=length(obj.optodeArrays)+1:nOAs
        %Set defaults
        obj.optodeArrays(oa).mode='';
        obj.optodeArrays(oa).type='';
        
        %get the number of associated channels
        nAssocChannels = length(find(obj.chOptodeArrays==oa));
        obj.optodeArrays(oa).chTopoArrangement=zeros(nAssocChannels,2);
        %...and arrange them in line
        if nAssocChannels~=0
            obj.optodeArrays(oa).chTopoArrangement(:,1)=1:nAssocChannels;
        end

        %get the number of associated optodes
        nAssocOptodes = length(find(obj.optodesOptodeArrays==oa));
        obj.optodeArrays(oa).optodesTopoArrangement=zeros(nAssocOptodes,2);
        %...and arrange them in line (interspersed with the optodes)
        if nAssocOptodes~=0
            obj.optodeArrays(oa).optodesTopoArrangement(:,1)=(1:nAssocOptodes)-0.5;
        end
        
    end
end

%It may be necessary to increase the topographic locations slots
nOAs = length(obj.optodeArrays);
for oa=1:nOAs
   %find out the number of associated channels
   nAssocChannels = length(find(obj.chOptodeArrays==oa));
   %find out the number of topographic locations slots
   nTopoLocations = size(obj.optodeArrays(oa).chTopoArrangement,1);
   if nAssocChannels > nTopoLocations
        obj.optodeArrays(oa).chTopoArrangement(end+1:nAssocChannels,:)=...
                        zeros(nAssocChannels-nTopoLocations,2);
        %...and arrange them in line
        obj.optodeArrays(oa).chTopoArrangement(nTopoLocations+1:nAssocChannels,1)= ...
                        nTopoLocations+1:nAssocChannels;
   end
end


assertInvariants(obj);

end
