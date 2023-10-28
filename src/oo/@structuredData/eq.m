function res=eq(obj,obj2)
%STRUCTUREDDATA/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also structuredData
%




%% Log
%
% File created: 11-Jul-2008
% File last modified (before creation of this log): 8-Mar-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%




res=true;
if ~isa(obj2,'structuredData')
    res=false;
    return
end

res = res && (obj.id==obj2.id);
res = res && (strcmp(obj.description,obj2.description));

tags1= obj.signalTags;
tags2= obj2.signalTags;
if (length(tags1)==length(tags2))
    for tt=1:length(tags1)
        res = res && (strcmp(tags1{tt},tags2{tt}));
        if ~res
            break
        end
    end
else
    res=false;
    return
end


t1=obj.timeline;
t2=obj2.timeline;
res = res && (t1==t2);

%res = res && (all(all(all(obj.data==obj2.data))));
res = res && isequalwithequalnans(obj.data,obj2.data);
res = res && (all(all(double(obj.integrity)==double(obj2.integrity))));


end
