function n=getNSubjects(obj)
%EXPERIMENT/GETNSUBJECTS Gets the number of subjects
%
% n=getNSubjects(obj) Gets the number of subjects defined in the
%       experiment dataset
%
%
% Copyright 2008
% @date: 16-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also getSubjectList
%

n=length(obj.subjects);
