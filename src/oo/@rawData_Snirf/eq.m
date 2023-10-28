function res=eq(obj,obj2)
%RAWDATA_SNIRF/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2023
% @author Felipe Orihuela-Espina
%
% See also rawData_NIRScout
%




%% Log
%
% 20-May-2023: FOE
%   + File created
%



res=true;
if ~isa(obj2,'rawData_Snirf')
    res=false;
    return
end

res=eq@rawData(obj,obj2);

%General information
res = res && (eq(obj.snirfImg,obj2.snirfImg));
if ~res
    return
end



end