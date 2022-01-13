function obj=removeReferencePoints(obj,idx)
%CHANNELLOCATIONMAP/REMOVEREFERENCEPOINTS Eliminates reference points
%
% obj=removeReferencePoints(obj) Eliminates ALL reference points.
%
% obj=removeReferencePoints(obj,idx) Eliminates reference points.
%   Indexes lower than 0 will be ignored. Indexes above the current
%   number of reference points will be ignored.
%
%
%
%% Parameters
%
% idx - A vector of indexes to reference points.
%
%
%
%
%
% Copyright 2013
% @date: 28-Aug-2013
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also getReferencePoints, addReferencePoints, setReferencePoints,
%   getChannel3DLocations, setChannel3DLocations
%   getOptode3DLocations, setOptode3DLocations
%


%% Log
%
% 8-Sep-2013: Updated "links" of the See also call to other methods
%


if nargin==1
    obj.referencePoints = struct('name',{},'location',{});
else
    
    
    %Ignore idx below 1 and above existing number of reference points
    tempIdx=find(idx<1 || idx>length(obj.referencePoints));
    idx(tempIdx)=[];
    
    obj.referencePoints(idx)=[];

end
assertInvariants(obj);

