function idList=getSourceList(obj)
%SESSIONDEFINITION/GETSOURCELIST Get a list of IDs of defined sources
%
% idList=getSourceList(obj) Get a list of IDs of defined sources of
%     data or an empty list if no sources have been defined.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getNSources, addSource
%



%% Log
%
% File created: 21-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 23-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to use get/set methods for struct like access.
%


nElements=obj.nDataSources;
idList=zeros(1,nElements);
for ii=1:nElements
    tmp = obj.sources{ii};
    idList(ii)=tmp.id;
end
idList=sort(idList);

end