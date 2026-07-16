function res=eq(obj,obj2)
%SESSIONDEFINITION/EQ Compares two sessionDefinition objects.
%
% obj1==obj2 Compares two sessionDefinition objects.
%
% res=eq(obj1,obj2) Compares two sessionDefinition objects.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also sessionDefinition
%


%% Log
%
% File created: 11-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%   + Removed some old commented code no longer in use.
%   + Added support for new property classVersion
%
%
% -- ICNNA v1.4.2.1
%
% 9-Jul-2026: FOE
%   + classVersion comparison now reads through the classVersion() accessor
%   (was direct property access), for consistency with the other eq methods
%   and the version guards after the classVersion Constant->immutable change.
%   Behaviour unchanged.
%


res=true;
if ~isa(obj2,'sessionDefinition')
    res=false;
    return
end

res = res && (strcmp(classVersion(obj),classVersion(obj2)));
res = res && (obj.id==obj2.id);
res = res && (strcmp(obj.name,obj2.name));
res = res && (strcmp(obj.description,obj2.description));

res = res && (obj.nDataSources==obj2.nDataSources);

if ~res
    return
end

ids1=getSourceList(obj);
ids2=getSourceList(obj2);
res = res && (all(ids1==ids2));
if ~res
    return
end

for ss=ids1
    res = res && (getSource(obj,ss)==getSource(obj2,ss));
    if ~res
        return
    end
end



end
