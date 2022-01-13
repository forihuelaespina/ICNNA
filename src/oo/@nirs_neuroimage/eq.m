function res=eq(obj,obj2)
%NIRS_NEUROIMAGE/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008-12
% @date: 11-Jul-2008
% @author Felipe Orihuela-Espina
% @modified: 22-Dec-2012
%
% See also nirs_neuroimage
%

if ~isa(obj2,'nirs_neuroimage')
    res=false;
    return
end

res = res && (strcmp(get(obj,'ProbeMode'),get(obj2,'ProbeMode')));
if ~res
    return
end


res=eq@neuroimage(obj,obj2);
if ~res
    return
end

%Nothing else to do 