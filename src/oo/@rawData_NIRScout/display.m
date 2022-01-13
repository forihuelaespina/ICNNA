function display(obj)
%RAWDATA_NIRScout/DISPLAY Command window display of a rawData_NIRScout
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2018
% @date: 4-Abr-2018
% @author Felipe Orihuela-Espina
% @modified: 17-May-2018
%
% See also rawData_NIRScout, get, set
%






%% Log
%
% 17-May-2018: FOE. Trigger markers are now displayed with num2str for
%   improving legilibility.
%
% 4/25-Apr-2018: FOE. Method created
%
%



disp(' ');
disp([inputname(1),'= ']);
disp(' ');
%Inherited
disp(['   ID: ' num2str(get(obj,'ID'))]);
disp(['   Description: ' get(obj,'Description')]);
disp(['   Date (Reference for timestamps): ' datestr(get(obj,'Date'),0)]);

%Patient Information
disp(['   User Name: ' get(obj,'SubjectName')]);
% tmpBirthDate=datestr(get(obj,'SubjectBirthDate'),24);
% if isempty(tmpBirthDate)
%     disp('   User Birth Date: ');
% else
%     disp(['   User Birth Date: ' tmpBirthDate]);
% end
disp(['   User Age: ' num2str(get(obj,'SubjectAge'))]);
disp(['   User Gender: ' get(obj,'SubjectGender')]);


%General Information
disp(['   Filename: ' get(obj,'Filename')]);
disp(['   Device: ' get(obj,'Device')]);
disp(['   Source: ' get(obj,'Source')]);
disp(['   Study Type Modulation Amplitude (Mod): ' get(obj,'StudyTypeModulation')]);
disp(['   File Version (NIRStar software version): ' get(obj,'FileVersion')]);
disp(['   Subject Index: ' num2str(get(obj,'SubjectIndex'))]);



% Measurement information
disp(['   Number of source steps in measurements: ' num2str(get(obj,'nSources'))]);
disp(['   Number of detectors: ' num2str(get(obj,'nDetectors'))]);
disp(['   Number of steps (illumination pattern): ' num2str(get(obj,'nSteps'))]);

disp(['   Total Number of Channels: ' num2str(get(obj,'nChannels'))]);
disp(['   Wavelengths [nm]: ' num2str(obj.wLengths)]);
disp(['   Sampling Rate [Hz]: ' num2str(get(obj,'SamplingRate'))]);

disp(['   Number of trigger inputs: ' num2str(get(obj,'nTriggerInputs'))]);
%Pending: I need to check for the device to be NIRScoutX
%disp(['   Number of trigger outputs: ' num2str(get(obj,'nTriggerOutputs'))]);

%This is only for fututre versions; so not active right now.
%disp(['   Number of analog inputs: ' num2str(get(obj,'nAnalogInputs'))]);

disp(['   Modulation Amplitudes: ' num2str(obj.modulationAmplitudes)]);
disp(['   Modulation Thresholds: ' num2str(obj.modulationThresholds)]);
                                    %for Laser).
disp('   Probeset: ');
disp(get(obj,'Probeset'));



% Paradigm Information
disp(['   Paradigm Stimulus Type: ' get(obj,'paradigmStimulusType')]);

% Experimental Notes
disp(['   Notes: ' get(obj,'Notes')]);

% Gain Settings
G=get(obj,'Gains');
if ~isempty(G)
    disp(['   Gains (Rows - Sources; Cols - Detectors): ']);
    disp(G);
end

% Markers Information
disp(['   Event Trigger Markers (#1 - Time (in seconds); #2 - Condition marker; #3 - Scan frame): ']);
disp(num2str(get(obj,'EventTriggerMarkers')));

% Data Structure
G=get(obj,'SDKey');
if ~isempty(G)
    disp(['   S-D key (Rows - Sources; Cols - Detectors): ']);
    disp(G)
end
G=get(obj,'SDMask');
if ~isempty(G)
    disp(['   S-D Mask (Rows - Sources; Cols - Detectors): ']);
    disp(G)
end

% Channel Distances
G=get(obj,'ChannelDistances');
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
