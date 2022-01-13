function res=eq(obj,obj2)
%SESSIONDEFINITION/EQ Compares two sessionDefinition objects.
%
% obj1==obj2 Compares two sessionDefinition objects.
%
% res=eq(obj1,obj2) Compares two sessionDefinition objects.
%
%
% Copyright 2008
% @date: 11-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also sessionDefinition
%

res=true;
if ~isa(obj2,'sessionDefinition')
    res=false;
    return
end

res = res && (get(obj,'ID')==get(obj2,'ID'));
res = res && (strcmp(get(obj,'Name'),get(obj2,'Name')));
res = res && (strcmp(get(obj,'Description'),get(obj2,'Description')));

res = res && (getNSources(obj)==getNSources(obj2));

if ~res
    return
end

ids1=getSourceList(obj);
ids2=getSourceList(obj2);
res = res && (all(ids1==ids2));
if ~res
    return
end

for ss=ids1
    res = res && (getSource(obj,ss)==getSource(obj2,ss));
    if ~res
        return
    end
end
