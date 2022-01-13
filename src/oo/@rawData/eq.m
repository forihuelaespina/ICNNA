function res=eq(obj,obj2)
%RAWDATA/EQ Compares two objects.
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
% See also rawData
%

res=true;
if ~isa(obj2,'rawData')
    res=false;
    return
end

res = res && (get(obj,'ID')==get(obj2,'ID'));
res = res && (strcmp(get(obj,'Description'),get(obj2,'Description')));
res = res && (strcmp(get(obj,'Date'),get(obj2,'Date')));
