function res=eq(obj,obj2)
%LOGARITHMICRADIALGRID/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008
% @date: 15-Aug-2008
% @author Felipe Orihuela-Espina
%
% See also logarithmicRadialGrid
%

if ~isa(obj2,'logarithmicRadialGrid')
    res=false;
    return
end


res=eq@menaGrid(obj,obj2);
if ~res
    return
end

res = res && get(obj,'MinimumRadius')==get(obj2,'MinimumRadius');
res = res && get(obj,'MaximumRadius')==get(obj2,'MaximumRadius');
res = res && get(obj,'NRings')==get(obj2,'NRings');
res = res && get(obj,'NAngles')==get(obj2,'NAngles');

