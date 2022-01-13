function s=getSource(obj,id)
%SESSIONDEFINITION/GETSOURCE Gets the data source definiton identified by id
%
% s=getSource(obj,id) Gets the data source definiton identified by id
%   or an empty string if the data source has not been defined.
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also getNSources, getSourceList, setSource, addSource
%

s='';
i=findSource(obj,id);
if (~isempty(i))
    s=obj.sources{i};
end
