function obj=removeStructuredData(obj,id)
% DATASOURCE/REMOVESTRUCTUREDDATA Removes a structured data element
%
% obj=removeStructuredData(obj,id) Removes the structured data whose ID==id
%   from the dataSource. If the structured data element does not exist,
%   nothing is done.
%
% Copyright 2008
% @date: 13-Jun-2008
% @author Felipe Orihuela-Espina
%
% See also addStructuredData, setStructuredData, clearStructuredData
%

idx=findStructuredData(obj,id);
if (~isempty(idx))
    obj.structured(idx)=[];
end
assertInvariants(obj);