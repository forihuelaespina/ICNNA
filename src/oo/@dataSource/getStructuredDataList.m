function idList=getStructuredDataList(obj)
%DATASOURCE/GETSTRUCTUREDDATALIST Get a list of IDs of defined structured data
%
% idList=getStructuredDataList(obj) Get a list of IDs of defined
%   structured dataor an empty list if no structured data have been defined.
%
% It is possible to navigate through the structured data using the idList
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also findStructuredData, getStructuredData, getNStructuredData
%


%% Log
%
% File created: 25-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 24-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to use get/set methods for struct like access.
%

nElements=obj.nStructuredData;
idList=zeros(1,nElements);
for ii=1:nElements
    tmpElement = obj.structured{ii};
    idList(ii)=tmpElement.id;
end
idList=sort(idList);

end