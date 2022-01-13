function obj=clearSubjects(obj)
% EXPERIMENT/CLEARSUBJECTS Removes all existing subjects
%
% obj=clearSubjects(obj) Removes all existing subjects from the
%   dataset.
%
% Copyright 2008
% @date: 13-Jun-2008
% @author Felipe Orihuela-Espina
%
% See also addSubject, setSubject, removeSubject
%

obj.subjects=cell(1,0);
assertInvariants(obj);