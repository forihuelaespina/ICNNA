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
% Copyright 2013-23
% @author: Felipe Orihuela-Espina
%
% See also getPairings, setPairings, setOptodeTypes
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


types=obj.optodesTypes;
if exist('idx','var')
    idx(idx<1)=[];
    idx(idx>obj.nOptodes)=[];
    types=types(idx,:);
end


end