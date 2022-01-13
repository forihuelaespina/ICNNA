function pairings=getPairings(obj,idx)
%CHANNELLOCATIONMAP/GETPAIRINGS Gets the pairings of optodes conforming the channels
%
% pairings=getPairings(obj) Gets the pairings of optodes conforming 
%   the channels as an nx2 matrix of <emisor, detector> pairs.
%   The matrix may be empty if the number of channels is 0.
%
% pairings=getPairings(obj,idx) Gets the pairings of optodes conforming 
%   the channels as an nx2 matrix of <emisor, detector> pairs.
%   If any of the indexes to channels is beyond the number of channels,
%   it will be ignored. The matrix may be empty if the number of channels 
%   is 0, or none of the indexes is valid.
%
%
%
%% Output
%
% pairings - An nx2 matrix of <emisor, detector> pairs for the channels
%
%
% Copyright 2013
% @date: 8-Sep-2013
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also setPairings, getOptodeTypes, setOptodeTypes
%


%% Log
%
% 8-Sep-2013: Method created
%


pairings=obj.pairings;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>get(obj,'nChannels'))=[];
    pairings=pairings(idx,:);
end