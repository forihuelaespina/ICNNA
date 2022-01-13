function [optArrays,oaInfo]=getOptodeOptodeArrays(obj,idx)
%CHANNELLOCATIONMAP/GETOPTODEOPTODEARRAYS Gets the optode arrays for optodes
%
% optArrays=getOptodeArrays(obj) Gets the optode arrays for all
%   optodes as an nx1 vector. The vector may be empty if the
%   number of optodes is 0.
%
% optArrays=getOptodeArrays(obj,idx) Gets the optode arrays for the
%   selected optodes as an nx1 vector. If any of the indexes to optodes
%   is beyond the number of optodes, it will be ignored. The vector
%   may be empty if the number of optodes is 0, or none of the
%   indexes is valid.
%
% [optArrays,optArraysInfo]=getOptodeOptodeArrays(obj,...) Gets the optode
%   arrays for the selected optodes as an nx1 vector and retrieves
%   the information for all the optode arrays i.e. mode, etc. The
%   information is retrieved for all arrays regardless of whether
%   they are present in the list of optode arrays optArrays. For any
%   channel ch, the channel is associated to the optode array
%   optArrays(ch) which has the associated information
%   optArraysInfo(optArrays(ch)).
%
%
%
% Copyright 2012-13
% @date: 8-Sep-2013
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also setOptodeOptodeArrays, getOptodeArraysInfo, 
%   getOptode3DLocations, getOptodeSurfacePositions,
%   getOptodeStereotacticPositions, getOptodeProbeSets
%

%% Log
%
% 8-Sep-2013: Method created
%



optArrays=obj.optodesOptodeArrays;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>get(obj,'nOptodes'))=[];
    optArrays=optArrays(idx,:);
end
oaInfo=obj.optodeArrays; %Retrieve information for all arrays