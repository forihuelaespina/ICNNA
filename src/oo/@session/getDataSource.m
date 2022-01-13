function s=getDataSource(obj,id)
%SESSION/GETDATASOURCE Get the dataSource identified by id
%
% s=getDataSource(obj,id) gets the dataSource identified by id or an empty
%   matrix if the dataSource has not been defined.
%
% Copyright 2008
% @date: 25-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also getNDataSources, getDataSourceList
%

i=findDataSource(obj,id);
if (~isempty(i))
    s=obj.sources{i};
else
    s=[];
end
