function obj=removeDataSource(obj,id)
% SESSION/REMOVEDATASOURCE Removes a dataSource from the session
%
% obj=removeDataSource(obj,id) Removes the dataSource whose ID==id from the
%   session. If the dataSource does not exist, nothing is done.
%
% Copyright 2008
% @date: 13-Jun-2008
% @author Felipe Orihuela-Espina
%
% See also addDataSource, setDataSource, clearDataSources
%

idx=findDataSource(obj,id);
if (~isempty(idx))
    obj.sources(idx)=[];
end
assertInvariants(obj);