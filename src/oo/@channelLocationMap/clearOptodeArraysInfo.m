function obj=clearOptodeArraysInfo(obj)
%CHANNELLOCATIONMAP/CLEAROPTODEARRAYSINFO Reset optode arrays information records.
%
% obj=clearOptodeArraysInfo(obj) Reset optode arrays
%   information records. For unused optode arrays above the currently
%   used optode array i.e. max(getOptodeArrays(obj)), information record
%   will be fully removed. For used optode arrays and unused optode
%   arrays below the currently used optode array
%   i.e. max(getOptodeArrays(obj)), the information record will remain
%   but the information itself will be reset to default values.
%
%
%% Remarks
%
% This method does NOT deassociate channels from the optode arrays! Use
%setOptodeArrays method for that.
%
%
%
%
% Copyright 2012-13
% @date: 22-Dec-2012
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also getOptodeArraysInfo, setOptodeArraysInfo,
%

%% Log
%
% 8-Sep-2013: Support for topological arrangement of optodes. Updated
%       "links" of the See also section
%



obj.optodeArrays = struct('mode',{},'type',{},...
                                'chTopoArrangement',{},...
                                'optodesTopoArrangement',{});
nOAs = max(getOptodeArrays(obj));
for oa=1:nOAs
    obj.optodeArrays(oa).mode='';
    obj.optodeArrays(oa).type='';
    %get the number of associated channels
    nAssocChannels = length(find(obj.chOptodeArrays==oa));
    obj.optodeArrays(oa).chTopoArrangement=zeros(nAssocChannels,3);
    %...and arrange them in line
    obj.optodeArrays(oa).chTopoArrangement(:,1)=1:nAssocChannels;
    obj.optodeArrays(oa).optodesTopoArrangement=zeros(nAssocChannels,2);
    %...and arrange them in line (interspersed with the channels)
    obj.optodeArrays(oa).optodesTopoArrangement(:,1)=(1:nAssocChannels)-0.5;
end
assertInvariants(obj);
