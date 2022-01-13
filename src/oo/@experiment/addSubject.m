function obj=addSubject(obj,newSubjects)
% EXPERIMENT/ADDSUBJECT Add new subjects to the dataset
%
% obj=addSubject(obj,s) Add a new subject to the experiment dataset.
%   If a subject with the same ID has already been defined within
%   the dataset, then a warning is issued
%   and nothing is done.
%
% This function can insert multiple subjects at a time, by
%using a cell array of subjects in s.
%
%----------------------------
%Remarks
%----------------------------
%
%In adding a new subject, the session definitions of the experiment
%may be updated.
%
% a) If the subject contains one or more new session definitions
%   which are not yet defined in the experiment, and that do not
%   conflict the experiment current record of session definitions,
%   the subject is added and the new definitions are collected
%   and added to the experiment repository.
%
% b) If the subject contains one or more session whose definitions
%   may conflict with the existing session definitions a warning
%   is issued. The subject is not added to the experiment.
%
% A conflicting definition is a sessionDefinition which has the
%same ID of an existing one, but is not equal to it.
%
%
% Copyright 2008
% @date: 16-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also removeSubject, setSubject
%

if (length(newSubjects)==1 && isa(newSubjects,'subject'))
    %Insert single subject
    s=subject(newSubjects);
    
    idx=findSubject(obj,get(s,'ID'));
    if isempty(idx)
        if existSessionDefinitionConflicts(obj,s)
        warning('ICNA:experiment:addSubject:SessionDefinitionConflict',...
            'Session definition conflict found. Subject not added.');
        else
            %Collect the new session definitions
            defs=collectSessionDefinitionsFromSubject(obj,s,1);
            obj=addSessionDefinition(obj,defs);
            obj.subjects(end+1)={s};
        end
    else
        warning('ICNA:experiment:addSubject:RepeatedID',...
            'A subject with the same ID has already been defined.');
    end
    
 
elseif iscell(newSubjects) %Insert multiple subjects
    barProgress=0;
    h = waitbar(barProgress,'Adding multiple subjects - 0%');
    step=1/(length(newSubjects)*2);

idxs=zeros(1,0);
for ii=1:numel(newSubjects)
    waitbar(barProgress,h,['Adding multiple subjects - Check Stage - ' ...
                    num2str(round(barProgress*100)) '%']);
    barProgress=barProgress+step;
    if isa(newSubjects{ii},'subject')
        if isempty(findSubject(obj,get(newSubjects{ii},'ID')))
            %Check possible sessionDefinitions coflicts
            if existSessionDefinitionConflicts(obj,newSubjects{ii})
                warning(['ICNA:experiment:addSubject:'...
                    'SessionDefintionConflict'],...
                    ['Session definition conflict found. ' ...
                    'Subject in position ' num2str(ii) ...
                    ' will not be added.']);
            else
                %Collect the new session definitions
                defs=collectSessionDefinitionsFromSubject(obj,...
                            newSubjects{ii},1);
                obj=addSessionDefinition(obj,defs);
                idxs=[idxs ii];
            end
            
        else
             warning('ICNA:experiment:addSubject:RepeatedID',...
                ['A subject with ID=' ...
                     num2str(get(newSubjects{ii},'ID')) ...
                     ' has already been defined.']);
        end
    else
        warning('ICNA:experiment:addSubject:InvalidParameter',...
                ['Element in position ' num2str(ii) ' is not a subject.']);
    end
end


waitbar(barProgress,h,['Adding multiple subjects - Saving stage - ' ...
                num2str(round(barProgress*100)) '%']);
barProgress=barProgress+step;
obj.subjects(end+1:end+length(idxs))=newSubjects(idxs);
clear newSubjects

waitbar(1,h);
close(h);

else
    error('Invalid input subject/s. For multiple subjects use a cell array');
end
assertInvariants(obj);
