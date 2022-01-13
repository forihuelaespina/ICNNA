function res=eq(obj,obj2)
%SESSION/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008
% @date: 11-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also session
%

res=true;
if ~isa(obj2,'session')
    res=false;
    return
end

res = res && (get(obj,'Definition')==get(obj2,'Definition'));
res = res && (strcmp(get(obj,'Date'),get(obj2,'Date')));
if ~res
    return
end

res = res && (getNDataSources(obj)==getNDataSources(obj2));
if ~res
    return
end

srcIDs=getDataSourceList(obj);
for cc=srcIDs
    c1=getDataSource(obj,cc);
    c2=getDataSource(obj2,cc);
    
    if (isempty(c1) && isempty(c2))
        %Do nothing
    elseif (isempty(c1) && ~isempty(c2))
        res=false;
        return;
    elseif (~isempty(c1) && isempty(c2))
        res=false;
        return;
    elseif (~isempty(c1) && ~isempty(c2))
        res = res && (c1==c2);
    end
    
    if ~res
        return
    end
end
