function n=getNDataSources(obj)
%SESSION/GETNDATASOURCES Gets the number of dataSources defined
%
% n=getNDataSources(obj) Gets the number of dataSources defined
%
%
% Copyright 2008
% @date: 25-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also getDataSource, getDataSourceList, clearDataSources,
% addDataSource
%

n=length(obj.sources);
