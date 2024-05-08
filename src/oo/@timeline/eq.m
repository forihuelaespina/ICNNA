function res=eq(obj,obj2)
%TIMELINE/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also timeline
%


%% Log
%
% File created: 11-Jul-2008
% File last modified (before creation of this log): 29-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%   + Removed some old commented code no longer in use.
%   + Added support for new property classVersion
%

res=true;
if ~isa(obj2,'timeline')
    res=false;
    return
end

res = res && (strcmp(obj.classVersion,obj2.classVersion));
res = res && (obj.length==obj2.length);
res = res && (obj.startTime==obj2.startTime);
res = res && all(obj.timestamps==obj2.timestamps);
res = res && (obj.nominalSamplingRate ==obj2.nominalSamplingRate);
if ~res
    return
end

e1=getExclusory(obj);
e2=getExclusory(obj2);
res = res && all(all(e1==e2));
if ~res
    return
end

res = res && (obj.nConditions==obj2.nConditions);
if ~res
    return
end

nCond=obj.nConditions;
for cc=1:nCond
    c1 = getCondition(obj,cc);
    c2 = getCondition(obj,cc);
    res = res && isequal(c1,c2);
    if ~res
        return
    end
end


end