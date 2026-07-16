function res=eq(obj,obj2)
%SUBJECT/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2023
% @author Felipe Orihuela-Espina
%
% See also subject
%


%% Log
%
% 21-May-2023: FOE
%
%   Just realised that the class subject lack the eq method!!!!
%
%   + Method created.
%
%
% -- ICNNA v1.4.2.1
%
% 9-Jul-2026: FOE
%   + classVersion comparison changed from '==' on the property to strcmp on
%   the classVersion() accessor. classVersion is now an immutable per-object
%   property, so '==' on version strings can error on unequal lengths and
%   yields a non-scalar operand for && ; strcmp gives scalar, length-tolerant
%   string equality, and the accessor is the sanctioned (polymorphic) read.
%

res=true;
if ~isa(obj2,'subject')
    res=false;
    return
end

res = res && strcmp(classVersion(obj),classVersion(obj2));
res = res && (strcmp(obj.name,obj2.name));
res = res && (obj.age==obj2.age);
res = res && (obj.sex==obj2.sex);
res = res && (obj.hand==obj2.hand);
if ~res
    return
end





res = res && (obj.nSessions==obj2.nSessions);
if ~res
    return
end

nElem=obj.nSessions;
for iElem=1:nElem
    obj1 = getSession(obj,iElem);
    obj2 = getSession(obj,iElem);
    res = res && isequal(obj1,obj2);
    if ~res
        return
    end
end



end