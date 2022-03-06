function obj = set(obj,varargin)
% RAWDATA_NIRScout/SET Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%
%This method extends the superclass set method
%
%% Properties
%
%== Inherited
% 'Description' - Changes the description of the object
% 'Date' - Changes the date associated with the object.
%
% == Others
%   'filename' - The filename (without extension). The NIRStar 
%       software organizes and names files automatically. A number of
%       files are generated in each measurement bu they are all stored
%       in the same directory and shared a common filename (with different
%       extensions). 
%   'device' - The NIRS system type. 
%   'source' - Type of source used (LED or Laser). By default is set to 'LED'.
%   'studyTypeModulation' - Study type to set modulation amplitude. This
%       corresponds to field "Mod" in the .hdr input file (but note
%       that the real modulation amplitudes are set later in the Imaging
%       Parameters section. 
%   'fileVersion' - The NIRStar software version. 
%   'subjectIndex' - Subject index. 
%
%   .probesetInfo' - An struct holding information about the probe
%       sets and their configuration. 
%
%   'nSources' - Number of source steps in measurement.
%   'nDetectors' - Number of detectors. 
%   'nChannels' - Number of channels. 
%   'nSteps' - Number of steps (illumination pattern). 
%   'wLengths' - The nominal wavelengths at which the light
%       intensities were acquired in [nm]. 
%   'nTriggerInputs' - Number of trigger inputs. 
%   'nTriggerOutputs' - Number of trigger outputs (only available for
%       NIRScoutX). 
%   'nAnalogInputs' - Number of auxiliary analog inputs. Reserve for future
%       usage. 
%   'samplingRate' - Sampling rate in Hz. 
%   'modulationAmplitudes' - An array with the modulation amplitudes used
%       for illumination. 
%   'modalutionThresholds' - An array with the modulation threshold used (?0 only
%       for Laser). 
%
%   'paradigmStimulusType' - Specifies paradigm (future option)
%
%   'notes' - A string of experimental notes. 
%
%   'gains' - The gain settings used in the measurement are
%       recorded in a matrix. The gain for channel Si-Dj is found in the
%       ith row and jth column (counting from the upper left). Valid gains
%       for neighboring source-detector-pairs usually are in the range
%       of 4...7 for adults, depending on head size, hair density/color,
%       and measurement site. A gain value of ‘8’ indicates that too
%       little or no light was received for this particular pairing.
%       The gain values range from 0 (gain factor 100 = 1) through 8
%       (gain factor 108). 
%
%   'eventTriggerMarkers' - A matrix for recording the event markers
%       received by the digital trigger inputs, with time stamp and
%       frame numbers. Each event is a row that
%       contains 3 numbers;
%         Column 1: Time (in seconds) of trigger event after the scan
%           started.
%         Column 2: Trigger channel identifier, or condition marker.
%           Triggers received on each digital input DIx (where x denotes
%           the trigger channel) on the front panel are encoded as numbers
%           2DI(x-1), e.g. DI1, DI2, and DI3 are encoded as 1, 2, and 8,
%           respectively. The file stores the sum of simultaneously
%           triggered inputs in decimal representation. By using
%           combinations of trigger inputs, as many as 15 conditions
%           can be encoded by NIRScout and NIRSport systems, while
%           NIRScoutX receives up to 255 conditions (8 inputs).
%         Column 3: The number of the scan frame during which the
%           trigger event was received.
%       By default is empty, set to nan(0,3).
%
%   'sdKey' (source-detector key) - A matrix mapping
%       a column in the data files (*.wl1, *.wl2) to a source-detector
%       pair. The column in the data files for potential pair Si-Dj is
%       found in the ith row and jth column (counting from the upper
%       left). This attribute makes a header for the data files. For
%       source detector pairs without an associated column in the data
%       files (*.wl1, *.wl2), a nan value is stored. 
%
%   'sdMask' (source-detector mask) stores the masking pattern in a matrix
%       Channels that are set not to be
%       displayed are identified by '0's, while channels set to be
%       displayed are labeled with '1's. Counting from the upper left,
%       the column number corresponds to the detector channel, and
%       the row number corresponds to the source position. 
%
%   'channelsDistances' - The channel distance in [mm] declared in the
%       hardware configuration and used for the Beer-Lambert Law calculations
%       during a scan are recorded here. The order corresponds to the order
%       of the channel list in one of the software dialogs. 
%
%   'userName' - The user name. 
%   'userAge' - The user age in years.
%   'userGender' - The user gender. (U)nset -default, (M)ale or (F)emale. 
%
%   'lightRawData' - The raw light intensity data. The third dimension
%       of the matrix holds the information for the different wavelengths
%       across all source detector pairs (whether visible or note- see
%       SDKey and SDMask).
%
%
%
%
%
% Copyright 2018
% @author Felipe Orihuela-Espina
%
% See also rawData.set, get
%



%% Log
%
% 4/25-Apr-2018: FOE. Method created
%
% 26-Apr-2019: FOE
%   Bug fixing. Detected by Samuel Montero. Error reading field
%   .subjectgender from the .inf file. It was assumed that the
%   allowed values could be U, M or F but actually in the NIRx
%   software, this is an open string field, and thus can contain
%   other values; e.g. Man, male, etc. The request for strict values
%   have been relaxed, and only a warning is yield if unrecognized.
%
% 30-Oct-2019: FOE
%   - Bug fixing. Detected by Michele Rojas. Error reading probeset
%   Field ''headmodel'' not recorgnised. Also, unrecognised fields
%   are now ignored, rather than forcing an error.
%   - Added capacity to handle missing field probes.setupType to
%   support file version 15.2
%   - Bug fixing. SubjectGender field now records (U)ndefined for
%   empty strings.
%
% 7-Nov-2020: FOE
%   - Bug fixing. Gains can be negative (-1). I have substituted the
%   error message for a warning.
%   - Bug fixing. While setting the channel distances and ensuring
%   that the number of channelDistances matches the number of channels
%   I was directly comparing the (content of the) channelDistances to
%   the number of channels, instead of the numel.
%
% 13-February-2022 (ESR): We simplify the code
%   + All cases are in the rawData_NIRScout class.
%   + We create a dependent property inside the rawData_NIRScout
%   class.
%   + All properties are in the rawData_NIRScout class.
%
%

propertyArgIn = varargin;
while (length(propertyArgIn) >= 2)
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   
%General information

    tmp = lower(prop);
    
    switch (tmp)
        
            case 'channeldistances'
                obj.channelDistances = val;
            case 'device'
                obj.device = val;
            case 'eventtriggermarkers'
                obj.eventTriggerMarkers = val;
            case 'filename'
                obj.filename = val;
            case 'fileversion'
                obj.fileVersion = val;
            case 'gains'
                obj.gains = val;
            case {'wlengths','nominalwavelengthset'}
                obj.wLengths = val;
            case 'lightrawdata'
                obj.lightRawData = val;
            case 'modulationamplitudes'
                obj.modulationAmplitudes = val;
            case 'modulationthresholds'
                obj.modulationThresholds = val;
            case 'notes'
                obj.notes = val;
            case 'nanaloginputs'
                obj.nAnalogInputs = val;
            case 'nchannels'
                obj.nChannels = val;
            case 'ndetectors'
                obj.nDetectors = val;
            case 'nsources'
                obj.nSources = val;
            case 'nsteps'
                obj.nSteps = val;
            case 'ntriggerinputs'
                obj.nTriggerInputs = val;
            case 'ntriggeroutputs'
                obj.nTriggerOutputs = val;
            case 'probeset'
                obj.probesetInfo = val;
            case 'paradigmstimulustype'
                obj.paradigmStimulusType = val;
            case 'source'
                obj.source = val;
            case 'studytypemodulation'
                obj.studyTypeModulation = val;
            case 'subjectindex'
                obj.subjectIndex = val;
            case 'samplingrate'
                obj.samplingRate = val;
            case 'samplingperiod'
                obj.samplingPeriod = val;
            case 'sdkey'
                obj.sdKey = val;
            case 'sdmask'
                obj.sdMask = val;
            case 'subjectage'
                obj.userAge = val;
            case 'subjectgender'
                obj.userGender = val;
            case 'subjectname'
                obj.userName = val;

        otherwise
            obj=set@rawData(obj, prop, val);
    end


   
end


%Ensure number of channelDistances matches the number of channels (visible
%in the mask)
sillyNChannels = get(obj,'nChannels');
if (numel(obj.channelDistances) < sillyNChannels)
    %Add new distances and send warning
    obj.channelDistances(end+1:end+sillyNChannels)=nan;
    warning('Adding default channel distances to new channels.')
elseif (numel(obj.channelDistances) > sillyNChannels)
    %Discard latter distances and send warning
    obj.channelDistances(sillyNChannels+1:end)=[];
    warning('Removing extra channel distances.')
%else %(obj.channelsDistances == sum(sum(obj.sdMask)))
    %Do nothing
end
 
end


