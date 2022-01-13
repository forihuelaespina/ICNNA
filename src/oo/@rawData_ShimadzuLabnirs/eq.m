function res=eq(obj,obj2)
%RAWDATA_SHIMADZULABNIRS/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2016
% @date: 20-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 20-Sep-2016
%
% See also rawData_ShimadzuLabnirs
%

res=true;
if ~isa(obj2,'rawData_ShimadzuLabnirs')
    res=false;
    return
end

res=eq@rawData(obj,obj2);


%Measure information
res = res && (all(get(obj,'NominalWavelengthSet')...
                  ==get(obj2,'NominalWavelengthSet')));
res = res && (get(obj,'SamplingRate')==get(obj2,'SamplingRate'));
if ~res
    return
end

%The data itself!!
res = res && (all(all(get(obj,'rawData')==get(obj2,'OxyRawData'))));
res = res && (all(all(get(obj,'Timestamps')==get(obj2,'Timestamps'))));
res = res && (all(all(get(obj,'PreTimeline')==get(obj2,'PreTimeline'))));
res = res && (all(all(get(obj,'Marks')==get(obj2,'Marks'))));
