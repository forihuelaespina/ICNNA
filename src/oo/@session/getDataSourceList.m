function idList=getDataSourceList(obj)
%SESSION/GETDATASOURCELIST Get a list of IDs of defined dataSources
%
% idList=getDataSourceList(obj) Get a list of IDs of defined 
%     dataSources or an empty list if no dataSources have been defined.
%
% It is possible to navigate through the dataSources using the idList
%
% Copyright 2008
% @author Felipe Orihuela-Espina
%
% See also getNDataSources, getDataSource
%




%% Log
%
% File created: 25-Apr-2008
% File last modified (before creation of this log): N/A. This method had
%   never been updated since creation.
%
% 24-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%



nElements=obj.nDataSources;
idList=zeros(1,nElements);
for ii=1:nElements
    tmp = obj.sources{ii};
    idList(ii)=tmp.id;
end
idList=sort(idList);


end