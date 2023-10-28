function res=eq(obj,obj2)
%EXPERIMENT/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2023
% @author Felipe Orihuela-Espina
%
% See also experiment
%


%% Log
%
% 21-May-2023: FOE
%
%   Just realised that the class experiment lack the eq method!!!!
%
%   + Method created.
%

res=true;
if ~isa(obj2,'experiment')
    res=false;
    return
end

res = res && (obj.classVersion==obj2.classVersion);
res = res && (strcmp(obj.name,obj2.name));
res = res && (strcmp(obj.description,obj2.description));
res = res && (strcmp(obj.version,obj2.version));
res = res && (strcmp(obj.date,obj2.date));
res = res && (obj.studyDate == obj2.studyDate);
if ~res
    return
end





res = res && (obj.nDataSourceDefinitions==obj2.nDataSourceDefinitions);
if ~res
    return
end

nElem=obj.nDataSourceDefinitions;
for iElem=1:nElem
    obj1 = getDataSourceDefinition(obj,iElem);
    obj2 = getDataSourceDefinition(obj,iElem);
    res = res && isequal(obj1,obj2);
    if ~res
        return
    end
end



res = res && (obj.nSessionDefinitions==obj2.nSessionDefinitions);
if ~res
    return
end

nElem=obj.nSessionDefinitions;
for iElem=1:nElem
    obj1 = getSessionDefinition(obj,iElem);
    obj2 = getSessionDefinition(obj,iElem);
    res = res && isequal(obj1,obj2);
    if ~res
        return
    end
end



res = res && (obj.nSubjects==obj2.nSubjects);
if ~res
    return
end

nSubj=obj.nSubjects;
for iSubj=1:nSubj
    obj1 = getSubject(obj,iSubj);
    obj2 = getSubject(obj,iSubj);
    res = res && isequal(obj1,obj2);
    if ~res
        return
    end
end



end