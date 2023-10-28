function res=eq(obj,obj2)
%NIRS_NEUROIMAGE/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also nirs_neuroimage
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


if ~isa(obj2,'nirs_neuroimage')
    res=false;
    return
end

res = res && (strcmp(obj.probeMode,obj2.probeMode));
if ~res
    return
end


res=eq@neuroimage(obj,obj2);
if ~res
    return
end


end