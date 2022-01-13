function res=eq(obj,obj2)
%NEUROIMAGE/EQ Compares two objects.
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
% See also neuroimage
%

if ~isa(obj2,'neuroimage')
    res=false;
    return
end

res=eq@structuredData(obj,obj2);
if ~res
    return
end

clm1=get(obj,'ChannelLocationMap');
clm2=get(obj2,'ChannelLocationMap');
res = res && (clm1==clm2);
if ~res
    return
end

