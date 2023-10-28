function res=eq(obj,obj2)
%NEUROIMAGE/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also neuroimage
%


%% Log
%
%
% File created: 11-Jul-2008
% File last modified (before creation of this log): 22-Dec-2012
%
% 20-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%

if ~isa(obj2,'neuroimage')
    res=false;
    return
end

res=eq@structuredData(obj,obj2);
if ~res
    return
end

clm1=obj.chLocationMap;
clm2=obj2.chLocationMap;
res = res && (clm1==clm2);
if ~res
    return
end


end
