function idList=getSubjectList(obj)
%EXPERIMENT/GETSUBJECTLIST Get a list of IDs of defined subjects
%
% idList=getSubjectList(obj) Get a list of IDs of defined subjects or an
%     empty list if no subjects have been defined.
%
% It is possible to navigate through the subjects using the idList
%
% Copyright 2008
% @date: 23-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also getNSubjects, getSubject
%

nElements=getNSubjects(obj);
idList=zeros(1,nElements);
for ii=1:nElements
    idList(ii)=get(obj.subjects{ii},'ID');
end
idList=sort(idList);