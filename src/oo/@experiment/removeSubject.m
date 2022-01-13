function obj=removeSubject(obj,id)
% EXPERIMENT/REMOVESUBJECT Removes a subject
%
% obj=addSubject(obj,id) Removes subject whose ID==id from the
%   experiment. If the subject does not exist, nothing is done.
%
% Copyright 2008
% @date: 20-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also addSubject, setSubject, clearSubjects
%

idx=findSubject(obj,id);
if (~isempty(idx))
    obj.subjects(idx)=[];
end
assertInvariants(obj);