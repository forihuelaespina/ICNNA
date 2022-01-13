function res=eq(obj,obj2)
%DATASOURCEDEFINITION/EQ Compares two dataSourceDefinition objects.
%
% obj1==obj2 Compares two dataSourceDefinition objects.
%
% res=eq(obj1,obj2) Compares two dataSourceDefinition objects.
%
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also dataSourceDefinition
%

res=true;
if ~isa(obj2,'dataSourceDefinition')
    res=false;
    return
end

res = res && (get(obj,'ID')==get(obj2,'ID'));
res = res && (strcmp(get(obj,'Type'),get(obj2,'Type')));
res = res && (get(obj,'DeviceNumber')==get(obj2,'DeviceNumber'));
