function obj=clearStructuredData(obj)
% DATASOURCE/CLEARSTRUCTUREDDATA Removes all existing structured data
%
% obj=clearStructuredData(obj) Removes all existing structured data from
%   the dataSource.
%
% Copyright 2008
% @date: 13-Jun-2008
% @author Felipe Orihuela-Espina
%
% See also structuredData, addStructuredData, setStructuredData,
%removeStructuredData
%

obj.structured=cell(1,0);
obj.activeStructured=0;
assertInvariants(obj);