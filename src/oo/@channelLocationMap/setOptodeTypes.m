function obj=setOptodeTypes(obj,idx,types)
%CHANNELLOCATIONMAP/SETOPTODETYPES Set types for optodes
%
% obj=setOptodeTypes(obj,idx,types) Updates the types
%   for a optode or a set of optodes.
%   Indexes lower than 0 or beyond the number of optodes will be
%   ignored.
%
% Optode types can be one of the following:
%
%   * Unknown; identified by constant OPTODE_TYPE_UNKNOWN
%   * Emisor or light source; identified by constant OPTODE_TYPE_EMISOR
%   * Detector; identified by constant OPTODE_TYPE_DETECTOR
%
%
%% Parameters
%
% idx - A vector of optode indexes.
%
% types - A nx1 vector of types where n is the length of idx.
%
%
%
%
% Copyright 2013-23
% @author: Felipe Orihuela-Espina
%
% See also getOptodeTypes, getPairings, setPairings
%


%% Log
%
% File created: 8-Sep-2013
% File last modified (before creation of this log): N/A. This method was
%   never updated since creation.
%
% 8-Sep-2013: Method created
%   + Added this log.
%
% 20-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%


assert(numel(idx)==size(types,1),...
        ['ICNA:optodeLocationMap:setOptodeTypes:InvalidParameterValue',...
         'Number of optode indexes mismatches number of types.']);
idx=reshape(idx,numel(idx),1); %Ensure it is a vector
types=reshape(types,numel(types),1); %Ensure it is a vector

tempIdx=find(idx<1 | idx> obj.nOptodes);
idx(tempIdx)=[];
types(tempIdx)=[];

obj.optodesTypes(idx)=types;

assertInvariants(obj); %This will check that the types are one of the accepted kind

end
