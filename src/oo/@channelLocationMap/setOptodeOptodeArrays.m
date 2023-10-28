function obj=setOptodeOptodeArrays(obj,idx,optArrays)
%CHANNELLOCATIONMAP/SETOPTODEOPTODEARRAYS Set the associated optode arrays for optodes
%
% obj=setOptodeOptodeArrays(obj,idx,optArrays) Updates the associated optode
%   arrays for a optode or a set of optodes.
%   Indexes lower than 0 or beyond the number of optodes will be
%   ignored.
%
% Please refer to method setOptodeArraysInfo for updating the information
%associated with an optode array
%
%% Parameters
%
% idx - A vector of optode indexes.
%
% optArrays - A nx1 vector of associated optode arrays where n is the
%       length of idx.
%
%
%
%
% Copyright 2013-23
% @author: Felipe Orihuela-Espina
%
% See also getOptodeOptodeArrays, setOptode3DLocations,
%   setOptodeSurfacePositions, setOptodeStereotacticPositions,
%   setOptodeProbeSets, setOptodeArraysInfo
%


%% Log
%
%
% File created: 8-Sep-2013
% File last modified (before creation of this log): 12-Oct-2013
%
% 12-Oct-2013: Bug fixed.
%       When enlarging the length of the optode arrays info, the 
%       assigment of the topographical arrangement when the associated
%       channels or optodes were zero, was incorrect.
%
% 10-Sep-2013: Bug fixed. Initialization of
%       obj.optodeArrays(oa).optodesTopoArrangement was made with 3 columns
%       instead of 2.
%
%
% 8-Sep-2013: Method created
%
%
% 21-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%



assert(numel(idx)==numel(optArrays),...
        ['ICNNA:channelLocationMap:setOptodeOptodeArrays:InvalidParameterValue',...
         'Number of optode indexes mismatches number of associated ' ...
         'optode arrays.']);
idx=reshape(idx,numel(idx),1); %Ensure both are vectors
optArrays=reshape(optArrays,numel(optArrays),1);

tempIdx=find(idx<1 | idx> obj.nOptodes);
idx(tempIdx)=[];
optArrays(tempIdx)=[];

obj.optodesOptodeArrays(idx)=optArrays;

%It may be necessary to increase the length of the optode arrays info
nOAs = max(obj.optodesOptodeArrays);
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
            obj.optodeArrays(oa).chTopoArrangement(:,1)=[1:nAssocChannels]';
        end
        
        %get the number of associated optodes
        nAssocOptodes = length(find(obj.optodesOptodeArrays==oa));
        obj.optodeArrays(oa).optodesTopoArrangement=zeros(nAssocOptodes,2);
        %...and arrange them in line (interspersed with the optodes)
        if nAssocOptodes~=0
            obj.optodeArrays(oa).optodesTopoArrangement(:,1)=([1:nAssocOptodes]')-0.5;
        end
    end
end

%It may be necessary to increase the topographic locations slots
nOAs = length(obj.optodeArrays);
for oa=1:nOAs
   %find out the number of associated optodes
   nAssocOptodes = length(find(obj.optodesOptodeArrays==oa));
   %find out the number of topographic locations slots
   nTopoLocations = size(obj.optodeArrays(oa).optodesTopoArrangement,1);
   if nAssocOptodes > nTopoLocations
        obj.optodeArrays(oa).optodesTopoArrangement(end+1:nAssocOptodes,:)=...
                        zeros(nAssocOptodes-nTopoLocations,2);
        %...and arrange them in line (interspersed with channels)
        obj.optodeArrays(oa).optodesTopoArrangement(nTopoLocations+1:nAssocOptodes,1)= ...
                        nTopoLocations+(1:nAssocOptodes)-0.5;
   end
end


assertInvariants(obj);

end
