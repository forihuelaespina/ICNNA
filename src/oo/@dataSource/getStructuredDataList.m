function idList=getStructuredDataList(obj)
%DATASOURCE/GETSTRUCTUREDDATALIST Get a list of IDs of defined structured data
%
% idList=getStructuredDataList(obj) Get a list of IDs of defined
%   structured dataor an empty list if no structured data have been defined.
%
% It is possible to navigate through the structured data using the idList
%
% Copyright 2008
% @date: 25-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also findStructuredData, getStructuredData, getNStructuredData
%

nElements=getNStructuredData(obj);
idList=zeros(1,nElements);
for ii=1:nElements
    idList(ii)=get(obj.structured{ii},'ID');
end
idList=sort(idList);