function obj=clearSources(obj)
% SESSIONDEFINITION/CLEARSOURCES Removes all existing sources of data
%
% obj=clearSources(obj) Removes all existing sources of data from
%   the session definition.
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also addSource, removeSource
%

obj.sources=cell(1,0);
assertInvariants(obj);