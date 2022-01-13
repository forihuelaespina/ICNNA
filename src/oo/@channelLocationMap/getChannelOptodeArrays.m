function [optArrays,oaInfo]=getChannelOptodeArrays(obj,idx)
%CHANNELLOCATIONMAP/GETCHANNELOPTODEARRAYS Gets the optode arrays for channels
%
% optArrays=getChannelOptodeArrays(obj) Gets the optode arrays for all
%   channels as an nx1 vector. The vector may be empty if the
%   number of channels is 0.
%
% optArrays=getChannelOptodeArrays(obj,idx) Gets the optode arrays for the
%   selected channels as an nx1 vector. If any of the indexes to channels
%   is beyond the number of channels, it will be ignored. The vector
%   may be empty if the number of channels is 0, or none of the
%   indexes is valid.
%
% [optArrays,optArraysInfo]=getChannelOptodeArrays(obj,...) Gets the optode
%   arrays for the selected channels as an nx1 vector and retrieves
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
% @date: 26-Nov-2012
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also setChannelOptodeArrays, getOptodeArraysInfo, 
%   getChannel3DLocations, getChannelSurfacePositions,
%   getChannelStereotacticPositions, getChannelProbeSets
%

%% Log
%
% 8-Sep-2013: Method name changed from getOptodeArrays to
%       getChannelOptodeArrays.
%



optArrays=obj.chOptodeArrays;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>get(obj,'nChannels'))=[];
    optArrays=optArrays(idx,:);
end
oaInfo=obj.optodeArrays; %Retrieve information for all arrays