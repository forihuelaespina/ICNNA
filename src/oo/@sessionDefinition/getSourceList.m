function idList=getSourceList(obj)
%SESSIONDEFINITION/GETSOURCELIST Get a list of IDs of defined sources
%
% idList=getSourceList(obj) Get a list of IDs of defined sources of
%     data or an empty list if no sources have been defined.
%
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also getNSources, addSource
%

nElements=getNSources(obj);
idList=zeros(1,nElements);
for ii=1:nElements
    idList(ii)=get(obj.sources{ii},'ID');
end
idList=sort(idList);