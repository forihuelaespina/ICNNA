function types=getOptodeTypes(obj,idx)
%CHANNELLOCATIONMAP/GETOPTODETYPES Gets the types for optodes
%
% types=getOptodeTypes(obj) Gets the types for all
%   optodes as an nx1 column vector. The vector may be empty if the
%   number of optodes is 0.
%
% types=getOptode3DLocations(obj,idx) Gets the types for the
%   selected optodes as an nx1 column vector. If any of the indexes to 
%   optodes is beyond the number of optodes, it will be ignored. The 
%   matrix may be empty if the number of optodes is 0, or none of the
%   indexes is valid.
%
%
%
% Optode types can be one of the following:
%
%   * Unknown; identified by constant OPTODE_TYPE_UNKNOWN
%   * Emisor or light source; identified by constant OPTODE_TYPE_EMISOR
%   * Detector; identified by constant OPTODE_TYPE_DETECTOR
%
%
%
% Copyright 2013
% @date: 8-Sep-2013
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also getPairings, setPairings, setOptodeTypes
%


%% Log
%
% 8-Sep-2013: Method created
%


types=obj.optodesTypes;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>get(obj,'nOptodes'))=[];
    types=types(idx,:);
end