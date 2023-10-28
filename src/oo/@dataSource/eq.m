function res=eq(obj,obj2)
%DATASOURCE/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also dataSource
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



res=true;
if ~isa(obj2,'dataSource')
    res=false;
    return
end

res = res && (obj.id==obj2.id);
res = res && (strcmp(obj.name,obj2.name));
res = res && (obj.deviceNumber==obj2.deviceNumber);
res = res && (obj.lock==obj2.lock);
res = res && (obj.activeStructured==obj2.activeStructured);
if ~res
    return
end

r1=getRawData(obj);
r2=getRawData(obj2);
if (isempty(r1) && isempty(r2))
    %Do nothing
elseif (isempty(r1) && ~isempty(r2))
    res=false;
    return;
elseif (~isempty(r1) && isempty(r2))
    res=false;
    return;
elseif (~isempty(r1) && ~isempty(r2))
    res = res && (r1==r2);
end

res = res && (obj.nStructuredData==obj2.nStructuredData);
if ~res
    return
end

nElements=obj.nStructuredData;
for cc=1:nElements
    c1=getStructuredData(obj,cc);
    c2=getStructuredData(obj2,cc);
    
    if (isempty(c1) && isempty(c2))
        %Do nothing
    elseif (isempty(c1) && ~isempty(c2))
        res=false;
        return;
    elseif (~isempty(c1) && isempty(c2))
        res=false;
        return;
    elseif (~isempty(c1) && ~isempty(c2))
        res = res && (c1==c2);
    end
    
    if ~res
        return
    end
end




end
