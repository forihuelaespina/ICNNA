function display(obj)
%RAWDATA_NIRScout/DISPLAY Command window display of a rawData_NIRScout
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2018-23
% @author Felipe Orihuela-Espina
%
% See also rawData_NIRScout, get, set
%






%% Log
%
% File created: 4-Apr-2008
% File last modified (before creation of this log): 17-Apr-2012
%
% 17-May-2018: FOE. Trigger markers are now displayed with num2str for
%   improving legilibility.
%
% 4/25-Apr-2018: FOE. Method created
%
% 13-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%



disp(' ');
disp([inputname(1),'= ']);
disp(' ');
try
    disp(['   Class version: ' num2str(obj.classVersion)]);
catch
    disp('   Class version: N/A');
end
%Inherited
disp(['   ID: ' num2str(obj.id)]);
disp(['   Description: ' obj.description]);
disp(['   Date (Reference for timestamps): ' datestr(obj.date,0)]);

%Patient Information
disp(['   User Name: ' obj.subjectName]);
% tmpBirthDate=datestr(get(obj,'SubjectBirthDate'),24);
% if isempty(tmpBirthDate)
%     disp('   User Birth Date: ');
% else
%     disp(['   User Birth Date: ' tmpBirthDate]);
% end
disp(['   User Age: ' num2str(obj.subjectAge)]);
disp(['   User Gender: ' obj.subjectGender]);


%General Information
disp(['   Filename: ' obj.filename]);
disp(['   Device: ' obj.device]);
disp(['   Source: ' obj.source]);
disp(['   Study Type Modulation Amplitude (Mod): ' obj.studyTypeModulation]);
disp(['   File Version (NIRStar software version): ' obj.fileVersion]);
disp(['   Subject Index: ' num2str(obj.subjectIndex)]);



% Measurement information
disp(['   Number of source steps in measurements: ' num2str(obj.nSources)]);
disp(['   Number of detectors: ' num2str(obj.nDetectors)]);
disp(['   Number of steps (illumination pattern): ' num2str(obj.nSteps)]);

disp(['   Total Number of Channels: ' num2str(obj.nChannels)]);
disp(['   Wavelengths [nm]: ' num2str(obj.wLengths)]);
disp(['   Sampling Rate [Hz]: ' num2str(obj.samplingRate)]);

disp(['   Number of trigger inputs: ' num2str(obj.nTriggerInputs)]);
%Pending: I need to check for the device to be NIRScoutX
%disp(['   Number of trigger outputs: ' num2str(obj.nTriggerOutputs)]);

%This is only for fututre versions; so not active right now.
%disp(['   Number of analog inputs: ' num2str(obj.nAnalogInputs)]);

disp(['   Modulation Amplitudes: ' num2str(obj.modulationAmplitudes)]);
disp(['   Modulation Thresholds: ' num2str(obj.modulationThresholds)]);
                                    %for Laser).
disp('   Probeset: ');
disp(obj.probesetInfo);



% Paradigm Information
disp(['   Paradigm Stimulus Type: ' obj.paradigmStimulusType]);

% Experimental Notes
disp(['   Notes: ' obj.notes]);

% Gain Settings
G=obj.gains;
if ~isempty(G)
    disp(['   Gains (Rows - Sources; Cols - Detectors): ']);
    disp(G);
end

% Markers Information
disp(['   Event Trigger Markers (#1 - Time (in seconds); #2 - Condition marker; #3 - Scan frame): ']);
disp(num2str(obj.eventTriggerMarkers));

% Data Structure
G=obj.sdKey;
if ~isempty(G)
    disp(['   S-D key (Rows - Sources; Cols - Detectors): ']);
    disp(G)
end
G=obj.sdMask;
if ~isempty(G)
    disp(['   S-D Mask (Rows - Sources; Cols - Detectors): ']);
    disp(G)
end

% Channel Distances
G=obj.channelDistances;
if ~isempty(G)
    disp(['   Channel Distances [mm]: ']);
    disp(G)
end





%Data
disp(['   Data Size: ' num2str(size(obj.lightRawData))]);

% %Unreported properties:
% % + marks
% % + timestamps
% % + bodyMovement
% % + removalMarks
% % + preScan


disp(' ');
