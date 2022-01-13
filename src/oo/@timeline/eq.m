function res=eq(obj,obj2)
%TIMELINE/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008-12
% @date: 11-Jul-2008
% @author Felipe Orihuela-Espina
% @modified: 29-Dec-2012
%
% See also timeline
%

res=true;
if ~isa(obj2,'timeline')
    res=false;
    return
end

res = res && (get(obj,'Length')==get(obj2,'Length'));
res = res && (get(obj,'StartTime')==get(obj2,'StartTime'));
res = res && all(get(obj,'Timestamps')==get(obj2,'Timestamps'));
res = res && (get(obj,'NominalSamplingRate')==get(obj2,'NominalSamplingRate'));
if ~res
    return
end

e1=getExclusory(obj);
e2=getExclusory(obj2);
res = res && all(all(e1==e2));
if ~res
    return
end

res = res && (get(obj,'NConditions')==get(obj2,'NConditions'));
if ~res
    return
end

nCond=get(obj,'NConditions');
for cc=1:nCond
    c1 = getCondition(obj,cc);
    c2 = getCondition(obj,cc);
    res = res && isequal(c1,c2);
%     c1Tag=getConditionTag(obj,cc);
%     c2Tag=getConditionTag(obj2,cc);
%     
%     res = res && strcmp(c1Tag,c2Tag);
%     res = res && all(all(getConditionEvents(obj,c1Tag)==...
%         getConditionEvents(obj2,c2Tag)));
    if ~res
        return
    end
end
