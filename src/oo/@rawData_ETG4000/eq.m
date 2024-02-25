function res=eq(obj,obj2)
%RAWDATA_ETG4000/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also rawData_ETG4000
%




%% Log
%
% File created: 11-Jul-2008
% File last modified (before creation of this log): 30-Dec-2012
%
% 3-Dec-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%   + Added support for new property classVersion
%


res=true;
if ~isa(obj2,'rawData_ETG4000')
    res=false;
    return
end

res=eq@rawData(obj,obj2);

res = res && (obj.classVersion==obj2.classVersion);


res = res && (strcmp(obj.fileVersion,obj2.fileVersion));
%Patient information
res = res && (strcmp(obj.subjectName,obj2.subjectName));
res = res && (strcmp(obj.subjectSex,obj2.subjectSex));
res = res && (obj.subjectAge==obj2.subjectAge);
res = res && all(obj.subjectBirthDate==obj2.subjectBirthDate);
if ~res
    return
end

%Analysis information (for presentation only)
res = res && (strcmp(obj.analyzeMode,obj2.analyzeMode));
res = res && (obj.preTime == obj2.preTime);
res = res && (obj.postTime == obj2.postTime);
res = res && (obj.recoveryTime == obj2.recoveryTime);
res = res && (obj.baseTime == obj2.baseTime);
res = res && (obj.fittingDegree == obj2.fittingDegree);
if (ischar(obj.hpf))
    res = res && (strcmp(obj.hpf,obj2.hpf));
else
    res = res && (obj.hpf==obj2.hpf);
end
if (ischar(obj.lpf))
    res = res && (strcmp(obj.lpf,obj2.lpf));
else
    res = res && (obj.lpf==obj2.lpf);
end
res = res && (obj.movingAverage == obj2.movingAverage);
if ~res
    return
end


%Measure information
res = res && (all(obj.nominalWavelengthSet == obj2.nominalWavelengthSet));
res = res && (obj.nProbeSets == obj2.nProbeSets);
if ~res
    return
end
pm1=getProbeSetInfo(obj);
pm2=getProbeSetInfo(obj2);
res = res && (isequal(pm1,pm2));
if ~res
    return
end

res = res && (obj.samplingPeriod == obj2.samplingPeriod);
res = res && (obj.repeatCount == obj2.repeatCount);
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

end