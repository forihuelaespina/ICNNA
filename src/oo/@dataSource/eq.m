function res=eq(obj,obj2)
%DATASOURCE/EQ Compares two objects.
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
% See also dataSource
%

res=true;
if ~isa(obj2,'dataSource')
    res=false;
    return
end

res = res && (get(obj,'ID')==get(obj2,'ID'));
res = res && (strcmp(get(obj,'Name'),get(obj2,'Name')));
res = res && (get(obj,'DeviceNumber')==get(obj2,'DeviceNumber'));
res = res && (get(obj,'Lock')==get(obj2,'Lock'));
res = res && (get(obj,'ActiveStructured')==get(obj2,'ActiveStructured'));
if ~res
    return
end

r1=getRawData(obj);
r2=getRawData(obj2);
if (isempty(r1) && isempty(r2))
    %Do nothing
elseif (isempty(r1) && ~isempty(r2))
    res=false;
    return;
elseif (~isempty(r1) && isempty(r2))
    res=false;
    return;
elseif (~isempty(r1) && ~isempty(r2))
    res = res && (r1==r2);
end

res = res && (getNStructuredData(obj)==getNStructuredData(obj2));
if ~res
    return
end

nElements=getNStructuredData(obj);
for cc=1:nElements
    c1=getStructuredData(obj,cc);
    c2=getStructuredData(obj2,cc);
    
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
