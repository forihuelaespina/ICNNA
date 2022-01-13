function res=eq(obj,obj2)
%RAWDATA_BIOHARNESSECG/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2009
% @date: 19-Jan-2009
% @author Felipe Orihuela-Espina
%
% See also rawData_BioHarnessECG
%

res=true;
if ~isa(obj2,'rawData_BioHarnessECG')
    res=false;
    return
end

res=eq@rawData(obj,obj2);

%Measure information
res = res && all(get(obj,'StartTime')==get(obj2,'StartTime'));
res = res && (get(obj,'SamplingRate')==get(obj2,'SamplingRate'));
if ~res
    return
end

%The data itself!!
res = res && (all(get(obj,'Timestamps')==get(obj2,'Timestamps')));
res = res && (all(get(obj,'RawData')==get(obj2,'RawData')));

