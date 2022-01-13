function obj2=merge(obj,e)
% EXPERIMENT/MERGE Merges two experiments into one
%
% obj=merge(obj,e) Merge two experiments (obj and e) together.
%
%Bring the data from two experiment into a single one.
%
%
%  #==============================================#
%  | The subjects IDs from experiment e will be   |
%  | updated if necessary.                        |
%  #==============================================#
%
% Copyright 2008
% @date: 17-Jun-2008
% @author Felipe Orihuela-Espina
%
% See also experiment
%

list1=getSubjectList(obj);
list2=getSubjectList(e);

barProgress=0;
h = waitbar(barProgress,'Merging experiments - 0%');
step=1/(length(list2)*2);

brandNewSubjectsIds=setdiff(list2,list1);
repeatedSubjectsIds=intersect(list2,list1);

%Brand new subjects
tmpNewSubjects=cell(1,length(brandNewSubjectsIds));
for i=brandNewSubjectsIds
    waitbar(barProgress,h,['Merging experiments - ' ...
        num2str(round(barProgress*100)) '%']);
    barProgress=barProgress+step;

    tmpNewSubjects(i)={getSubject(e,i)};
end
obj=addSubject(obj,tmpNewSubjects);
clear tmpNewSubjects
    
%Those with repeated ID
tmpNewSubjects=cell(1,length(repeatedSubjectsIds));
maxId=max(list1);
if (isempty(maxId)), maxId=0; end;
pos=1;
for i=repeatedSubjectsIds
    waitbar(barProgress,h,['Merging experiments - ' ...
        num2str(round(barProgress*100)) '%']);
    barProgress=barProgress+step;

    tmpSubj=getSubject(e,i);
    tmpSubj=set(tmpSubj,'ID',maxId+pos);
    tmpNewSubjects(i)={tmpSubj};
    pos=pos+1;
end
obj=addSubject(obj,tmpNewSubjects);
clear tmpNewSubjects

%Now finishing...
waitbar(barProgress,h,['Merging experiments - Saving stage - ' ...
                num2str(round(barProgress*100)) '%']);

assertInvariants(obj);
waitbar(1,h);
close(h);

