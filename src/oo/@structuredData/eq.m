function res=eq(obj,obj2)
%STRUCTUREDDATA/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008-12
% @date: 11-Jul-2008
% @author Felipe Orihuela-Espina
% @modified: 8-Mar-2012
%
% See also structuredData
%

res=true;
if ~isa(obj2,'structuredData')
    res=false;
    return
end

res = res && (get(obj,'ID')==get(obj2,'ID'));
res = res && (strcmp(get(obj,'Description'),get(obj2,'Description')));

tags1=get(obj,'SignalTags');
tags2=get(obj2,'SignalTags');
if (length(tags1)==length(tags2))
    for tt=1:length(tags1)
        res = res && (strcmp(tags1{tt},tags2{tt}));
        if ~res
            break
        end
    end
else
    res=false;
    return
end


t1=get(obj,'Timeline');
t2=get(obj2,'Timeline');
res = res && (t1==t2);

%res = res && (all(all(all(get(obj,'Data')==get(obj2,'Data')))));
res = res && isequalwithequalnans(get(obj,'Data'),get(obj2,'Data'));
res = res && (all(all(double(get(obj,'Integrity'))...
                            ==double(get(obj2,'Integrity')))));
