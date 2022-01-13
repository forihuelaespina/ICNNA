function res=eq(obj,obj2)
%ECG/EQ Compares two objects.
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
% See also ecg
%

%% Log:
%
% 29-May-2019: FOE:
%   + Log started
%   + Added support for property rPeaksAlgo
%


if ~isa(obj2,'ecg')
    res=false;
    return
end

res=eq@structuredData(obj,obj2);
if ~res
    return
end

%Measure information
res = res && all(get(obj,'StartTime')==get(obj2,'StartTime'));
res = res && (get(obj,'SamplingRate')==get(obj2,'SamplingRate'));
res = res && (get(obj,'RPeaksMode')==get(obj2,'RPeaksMode'));
res = res && (get(obj,'RPeaksAlgo')==get(obj2,'RPeaksAlgo'));
res = res && (get(obj,'Threshold')==get(obj2,'Threshold'));
res = res && all(get(obj,'RPeaks')==get(obj2,'RPeaks'));
res = res && all(get(obj,'RR')==get(obj2,'RR'));
if ~res
    return
end

%%Derived properties (timestamps) are not necessaryly compared...

%The data itself!!
res = res && (all(get(obj,'Data')==get(obj2,'Data')));
