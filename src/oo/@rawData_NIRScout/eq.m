function res=eq(obj,obj2)
%RAWDATA_NIRScout/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2018
% @date: 4-Abr-2018
% @author Felipe Orihuela-Espina
% @modified: 25-Abr-2018
%
% See also rawData_NIRScout
%




%% Log
%
% 4/25-Apr-2018: FOE. Method created
%
%



res=true;
if ~isa(obj2,'rawData_NIRScout')
    res=false;
    return
end

res=eq@rawData(obj,obj2);

%General information
res = res && (strcmp(get(obj,'FileName'),get(obj2,'FileName')));
res = res && (strcmp(get(obj,'Device'),get(obj2,'Device')));
res = res && (strcmp(get(obj,'Source'),get(obj2,'Source')));
res = res && (strcmp(get(obj,'StudyTypeModulation'),get(obj2,'StudyTypeModulation')));
res = res && (strcmp(get(obj,'FileVersion'),get(obj2,'FileVersion')));
res = res && (get(obj,'SubjectIndex')==get(obj2,'SubjectIndex')));
if ~res
    return
end


%Measure information
res = res && (all(get(obj,'NominalWavelengthSet')...
                  ==get(obj2,'NominalWavelengthSet')));
res = res && (get(obj,'nSources')==get(obj2,'nSources'));
res = res && (get(obj,'nDetectors')==get(obj2,'nDetectors'));
res = res && (get(obj,'nChannels')==get(obj2,'nChannels'));
res = res && (get(obj,'nSteps')==get(obj2,'nSteps'));
res = res && (get(obj,'nTriggerInputs')==get(obj2,'nTriggerInputs'));
res = res && (get(obj,'nTriggerOutputs')==get(obj2,'nTriggerOutputs'));
res = res && (get(obj,'nAnalogInputs')==get(obj2,'nAnalogInputs'));
res = res && (get(obj,'samplingRate')==get(obj2,'samplingRate'));
res = res && (all(get(obj,'modulationAmplitudes')...
                  ==get(obj2,'modulationAmplitudes')));
res = res && (all(get(obj,'modulationThresholds')...
                  ==get(obj2,'modulationThresholds')));
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
res = res && (strcmp(get(obj,'paradigmStimulusType'),get(obj2,'paradigmStimulusType')));

% Experimental Notes
res = res && (strcmp(get(obj,'Notes'),get(obj2,'Notes')));
if ~res
    return
end

% Gain settings
res = res && (all(all(get(obj,'Gains')==get(obj2,'Gains'))));


% Markers Information
res = res && (all(all(get(obj,'eventTriggerMarkers')==get(obj2,'eventTriggerMarkers'))));
if ~res
    return
end

% Data Structure
res = res && (all(all(get(obj,'SDKey')==get(obj2,'SDKey'))));
res = res && (all(all(get(obj,'SDMask')==get(obj2,'SDMask'))));
res = res && (get(obj,'nChannels')==get(obj2,'nChannels'));
if ~res
    return
end

%Channel Distances
res = res && (all(get(obj,'ChannelDistances')==get(obj2,'ChannelDistances')));
if ~res
    return
end





%Patient information
res = res && (strcmp(get(obj,'SubjectName'),get(obj2,'SubjectName')));
res = res && (strcmp(get(obj,'SubjectGender'),get(obj2,'SubjectGender')));
%res = res && (get(obj,'SubjectBirthDate')==get(obj2,'SubjectBirthDate'));
res = res && all(get(obj,'SubjectAge')==get(obj2,'SubjectAge'));
if ~res
    return
end




%The data itself!!
res = res && (all(all(get(obj,'LightRawData')==get(obj2,'LightRawData'))));
% res = res && (all(all(get(obj,'Marks')==get(obj2,'Marks'))));
% res = res && (all(all(get(obj,'Timestamps')==get(obj2,'Timestamps'))));
% res = res && (all(all(get(obj,'BodyMovement')==get(obj2,'BodyMovement'))));
% res = res && (all(all(get(obj,'RemovalMarks')==get(obj2,'RemovalMarks'))));
% res = res && (all(all(get(obj,'preScan')==get(obj2,'preScan'))));

