function idx=findSubject(obj,id)
%EXPERIMENT/FINDSUBJECT Finds a subject within the experiment
%
% idx=findSubject(obj,id) returns the index of the subject.
%   If the subject has not been defined it returns an empty
%   matrix [].
%
% Copyright 2008
% @date: 20-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also experiment, subject, assertInvariants

nElements=length(obj.subjects);
idx=[];
for ii=1:nElements
    subjID=get(obj.subjects{ii},'ID');
    if (id==subjID)
        idx=ii;
        % Since the subject id cannot be repeated we can stop as
        %soon as it is found.
        break
    end
end