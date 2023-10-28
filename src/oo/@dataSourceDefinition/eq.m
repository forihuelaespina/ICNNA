function res=eq(obj,obj2)
%DATASOURCEDEFINITION/EQ Compares two dataSourceDefinition objects.
%
% obj1==obj2 Compares two dataSourceDefinition objects.
%
% res=eq(obj1,obj2) Compares two dataSourceDefinition objects.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also dataSourceDefinition
%


%% Log
%
% File created: 21-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%   + Removed some old commented code no longer in use.
%   + Added support for new property classVersion
%


res=true;
if ~isa(obj2,'dataSourceDefinition')
    res=false;
    return
end

res = res && (obj.id==obj2.id);
res = res && (strcmp(obj.type,obj2.type));
res = res && (obj.deviceNumber==obj2.deviceNumber);



end