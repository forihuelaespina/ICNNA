function obj=clearDataSources(obj)
% SESSION/CLEARDATASOURCES Removes all existing data sources
%
% obj=clearDataSources(obj) Removes all existing data source from
%   the session.
%
% Copyright 2008
% @date: 13-Jun-2008
% @author Felipe Orihuela-Espina
%
% See also addDataSource, setDataSource, removeDataSource
%

obj.sources=cell(1,0);
assertInvariants(obj);