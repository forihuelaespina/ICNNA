function obj=removeSource(obj,id)
% SESSIONDEFINITION/REMOVESOURCE Removes a source of data from the session
%definition
%
% obj=removeSource(obj,id) Removes the source of data whose ID==id from
%   the session definition. If the source has not been defined,
%   nothing is done.
%
% Copyright 2008
% @date: 10-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also addSource, clearSources, removeSource, getNSources
%

idx=findSource(obj,id);
if (~isempty(idx))
    obj.sources(idx)=[];
end
assertInvariants(obj);