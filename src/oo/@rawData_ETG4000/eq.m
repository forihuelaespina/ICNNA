function res=eq(obj,obj2)
%RAWDATA_ETG4000/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008-12
% @date: 11-Jul-2008
% @author Felipe Orihuela-Espina
% @modified: 30-Dec-2012
%
% See also rawData_ETG4000
%

res=true;
if ~isa(obj2,'rawData_ETG4000')
    res=false;
    return
end

res=eq@rawData(obj,obj2);

res = res && (strcmp(get(obj,'FileVersion'),get(obj2,'FileVersion')));
%Patient information
res = res && (strcmp(get(obj,'SubjectName'),get(obj2,'SubjectName')));
res = res && (strcmp(get(obj,'SubjectSex'),get(obj2,'SubjectSex')));
res = res && (get(obj,'SubjectBirthDate')==get(obj2,'SubjectBirthDate'));
res = res && all(get(obj,'SubjectAge')==get(obj2,'SubjectAge'));
if ~res
    return
end

%Analysis information (for presentation only)
res = res && (strcmp(get(obj,'AnalyzeMode'),get(obj2,'AnalyzeMode')));
res = res && (get(obj,'PreTime')==get(obj2,'PreTime'));
res = res && (get(obj,'PostTime')==get(obj2,'PostTime'));
res = res && (get(obj,'RecoveryTime')==get(obj2,'RecoveryTime'));
res = res && (get(obj,'BaseTime')==get(obj2,'BaseTime'));
res = res && (get(obj,'FittingDegree')==get(obj2,'FittingDegree'));
if (ischar(get(obj,'HPF')))
    res = res && (strcmp(get(obj,'HPF'),get(obj2,'HPF')));
else
    res = res && (get(obj,'HPF')==get(obj2,'HPF'));
end
if (ischar(get(obj,'LPF')))
    res = res && (strcmp(get(obj,'LPF'),get(obj2,'LPF')));
else
    res = res && (get(obj,'LPF')==get(obj2,'LPF'));
end
res = res && (get(obj,'MovingAverage')==get(obj2,'MovingAverage'));
if ~res
    return
end


%Measure information
res = res && (all(get(obj,'NominalWavelengthSet')...
                  ==get(obj2,'NominalWavelengthSet')));
res = res && (get(obj,'nProbeSets')==get(obj2,'nProbeSets'));
if ~res
    return
end
pm1=getProbeSetInfo(obj);
pm2=getProbeSetInfo(obj2);
res = res && (isequal(pm1,pm2));
if ~res
    return
end

res = res && (get(obj,'SamplingPeriod')==get(obj2,'SamplingPeriod'));
res = res && (get(obj,'repeatCount')==get(obj2,'repeatCount'));
if ~res
    return
end

%The data itself!!
res = res && (all(all(get(obj,'LightRawData')==get(obj2,'LightRawData'))));
res = res && (all(all(get(obj,'Marks')==get(obj2,'Marks'))));
res = res && (all(all(get(obj,'Timestamps')==get(obj2,'Timestamps'))));
res = res && (all(all(get(obj,'BodyMovement')==get(obj2,'BodyMovement'))));
res = res && (all(all(get(obj,'RemovalMarks')==get(obj2,'RemovalMarks'))));
res = res && (all(all(get(obj,'preScan')==get(obj2,'preScan'))));

