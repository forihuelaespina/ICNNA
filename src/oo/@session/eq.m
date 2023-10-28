function res=eq(obj,obj2)
%SESSION/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also session
%


%% Log
%
% File created: 11-Jul-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 24-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%   + Added support for new property classVersion
%


res=true;
if ~isa(obj2,'session')
    res=false;
    return
end

res = res && (strcmp(obj.classVersion,obj2.classVersion));
res = res && (obj.definition==obj2.definition);
res = res && (strcmp(obj.date,obj2.date));
if ~res
    return
end

res = res && (obj.nDataSources==obj2.nDataSources);
if ~res
    return
end

srcIDs=getDataSourceList(obj);
for cc=srcIDs
    c1=getDataSource(obj,cc);
    c2=getDataSource(obj2,cc);
    
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