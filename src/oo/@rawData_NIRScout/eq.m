function res=eq(obj,obj2)
%RAWDATA_NIRScout/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2018-23
% @author Felipe Orihuela-Espina
%
% See also rawData_NIRScout
%




%% Log
%
% File created: 4-Apr-2008
% File last modified (before creation of this log): 25-Apr-2012
%
% 4/25-Apr-2018: FOE. Method created
%
% 13-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%



res=true;
if ~isa(obj2,'rawData_NIRScout')
    res=false;
    return
end

res=eq@rawData(obj,obj2);

%General information
res = res && (strcmp(obj.fileName,obj2.fileName));
res = res && (strcmp(obj.device,obj2.device));
res = res && (strcmp(obj.source,obj2.source));
res = res && (strcmp(obj.studyTypeModulation,obj2.studyTypeModulation));
res = res && (strcmp(obj.fileVersion,obj2.fileVersion));
res = res && (obj.subjectIndex==obj2.subjectIndex);
if ~res
    return
end


%Measure information
res = res && (all(obj.nominalWavelengthSet==obj2.nominalWavelengthSet));
res = res && (obj.nSources==obj2.nSources);
res = res && (obj.nDetectors==obj2.nDetectors);
res = res && (obj.nChannels==obj2.nChannels);
res = res && (obj.nSteps==obj2.nSteps);
res = res && (obj.nTriggerInputs==obj2.nTriggerInputs);
res = res && (obj.nTriggerOutputs==obj2.nTriggerOutputs);
res = res && (obj.nAnalogInputs==obj2.nAnalogInputs);
res = res && (obj.samplingRate==obj2.samplingRate);
res = res && (all(obj.modulationAmplitudes==obj2.modulationAmplitudes));
res = res && (all(obj.modulationThresholds==obj2.modulationThresholds));
if ~res
    return
end
pm1=getProbeSetInfo(obj);
pm2=getProbeSetInfo(obj2);
res = res && (isequal(pm1,pm2));
if ~res
    return
end


% Paradigm Information
res = res && (strcmp(obj.paradigmStimulusType,obj2.paradigmStimulusType));

% Experimental Notes
res = res && (strcmp(obj.notes,obj2.notes));
if ~res
    return
end

% Gain settings
res = res && (all(all(obj.gains==obj2.gains)));


% Markers Information
res = res && (all(all(obj.eventTriggerMarkers==obj2.eventTriggerMarkers)));
if ~res
    return
end

% Data Structure
res = res && (all(all(obj.sdKey==obj.sdKey)));
res = res && (all(all(obj.sdMask==obj.sdMask)));
res = res && (obj.nChannels==obj2.nChannels);
if ~res
    return
end

%Channel Distances
res = res && (all(obj.channelDistances==obj2.channelDistances));
if ~res
    return
end





%Patient information
res = res && (strcmp(obj.userName,obj2.userName));
res = res && (strcmp(obj.userGender,obj2.userGender));
%res = res && (get(obj,'SubjectBirthDate')==get(obj2,'SubjectBirthDate'));
res = res && all(obj.userAge==obj2.userAge);
if ~res
    return
end




%The data itself!!
res = res && (all(all(obj.lightRawData==obj2.lightRawData)));
% res = res && (all(all(get(obj,'Marks')==get(obj2,'Marks'))));
% res = res && (all(all(get(obj,'Timestamps')==get(obj2,'Timestamps'))));
% res = res && (all(all(get(obj,'BodyMovement')==get(obj2,'BodyMovement'))));
% res = res && (all(all(get(obj,'RemovalMarks')==get(obj2,'RemovalMarks'))));
% res = res && (all(all(get(obj,'preScan')==get(obj2,'preScan'))));

end