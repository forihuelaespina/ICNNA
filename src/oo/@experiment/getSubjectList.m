function idList=getSubjectList(obj)
%EXPERIMENT/GETSUBJECTLIST Get a list of IDs of defined subjects
%
% idList=getSubjectList(obj) Get a list of IDs of defined subjects or an
%     empty list if no subjects have been defined.
%
% It is possible to navigate through the subjects using the idList
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getNSubjects, getSubject
%


%% Log
%
% File created: 23-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 23-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to update get/set methods for struct like access
%



nElements=obj.nSubjects;
idList=zeros(1,nElements);
for ii=1:nElements
    tmpSubject = obj.subjects{ii};
    idList(ii)=tmpSubject.id;
end
idList=sort(idList);


end