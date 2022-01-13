function s=getSubject(obj,id)
%EXPERIMENT/GETSUBJECT Get the subject identified by id
%
% s=getSubject(obj,id) gets the subject identified by id or an empty
%   matrix if the subject has not been defined.
%
% Copyright 2008
% @date: 16-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also getNSubjects, getSubjectList
%

i=findSubject(obj,id);
if (~isempty(i))
    s=obj.subjects{i};
else
    s=[];
end
