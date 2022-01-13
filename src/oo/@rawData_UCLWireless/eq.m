function res=eq(obj,obj2)
%RAWDATA_UCLWIRELESS/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2016
% @date: 1-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 1-Sep-2016
%
% See also rawData_UCLWireless
%

res=true;
if ~isa(obj2,'rawData_UCLWireless')
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
res = res && (all(all(get(obj,'OxyRawData')==get(obj2,'OxyRawData'))));
res = res && (all(all(get(obj,'DeoxyRawData')==get(obj2,'DeoxyRawData'))));
res = res && (all(all(get(obj,'Timestamps')==get(obj2,'Timestamps'))));
preTimeline1=get(obj,'PreTimeline');
preTimeline2=get(obj,'PreTimeline');
res = res && (isequal(preTimeline1,preTimeline2));

