function idx=findSubject(obj,id)
%EXPERIMENT/FINDSUBJECT Finds a subject within the experiment
%
% idx=findSubject(obj,id) returns the index of the subject.
%   If the subject has not been defined it returns an empty
%   matrix [].
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also experiment, subject, assertInvariants



%% Log
%
% File created: 20-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 23-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to use get/set methods for struct like access.
%



nElements=length(obj.subjects);
idx=[];
for ii=1:nElements
    tmpSubj = obj.subjects{ii};
    subjID=tmpSubj.id;
    if (id==subjID)
        idx=ii;
        % Since the subject id cannot be repeated we can stop as
        %soon as it is found.
        break
    end
end

end