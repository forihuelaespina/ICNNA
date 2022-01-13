function s=getStructuredData(obj,id)
%DATASOURCE/GETSTRUCTUREDDATA Get the structured data identified by id
%
% s=getStructuredData(obj,id) gets the structured data identified
%   by id or an empty matrix if the structured data has not been defined.
%
% Copyright 2008
% @date: 25-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also findStructuredData, getStructuredDataList
%

i=findStructuredData(obj,id);
if (~isempty(i))
    s=obj.structured{i};
else
    s=[];
end
