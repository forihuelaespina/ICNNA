function res=eq(obj,obj2)
%RAWDATA/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also rawData
%


%% Log
%
% File created: 11-Jul-2008
% File last modified (before creation of this log): N/A This method had
%   not been updated since creation.
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%   + Removed some old commented code no longer in use.
%   + Added support for new property classVersion
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
if ~isa(obj2,'rawData')
    res=false;
    return
end

res = res && strcmp(classVersion(obj),classVersion(obj2));
res = res && (obj.id==obj2.id);
res = res && (strcmp(obj.description,obj2.description));
res = res && (strcmp(obj.date,obj2.date));

end