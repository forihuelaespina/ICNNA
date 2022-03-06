function val = get(obj, propName)
% RAWDATA_NIRScout/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%This method extends the superclass get method
%
%% Properties
%
%== Inherited
% 'Description' - Gets the object's description
% 'Date' - Gets the date associated with the object.
%       See also timestamps
%
% == Others
%
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
%   'nDetectors' - Number of detector. 
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
% Copyright 2018
% @date: 4-Apr-2018
% @author Felipe Orihuela-Espina
% @modified: 25-Apr-2018
%
% See also rawData.get, set
%




%% Log
%
% 4/25-Apr-2018: FOE. Method created
%
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 13-February-2022 (ESR): We simplify the code
%   + All cases are in the rawData_NIRScout class.
%   + We create a dependent property inside the rawData_NIRScout.
%
     %val = obj.(lower(propName)); %Ignore case
      tmp = lower(propName);
    
    switch (tmp)
        
            case 'channeldistances'
                val = obj.channelDistances;
            case 'device'
                val = obj.device;
            case 'eventtriggermarkers'
                val = obj.eventTriggerMarkers;
            case 'filename'
                val = obj.filename;
            case 'fileversion'
                val = obj.fileVersion;
            case 'gains'
                val = obj.gains;
            case {'wlengths','nominalwavelengthset'}
                val=obj.wLengths;
            case 'lightrawdata'
                val = obj.lightRawData;
            case 'modulationamplitudes'
                val = obj.modulationAmplitudes;
            case 'modulationthresholds'
                val = obj.modulationThresholds;
            case 'notes'
                val = obj.notes;
            case 'nanaloginputs'
                val = obj.nAnalogInputs;
            case 'nchannels'
                val = obj.nChannels;
            case 'ndetectors'
                val = obj.nDetectors;
            case 'nsources'
                val = obj.nSources;
            case 'nsteps'
                val = obj.nSteps;
            case 'ntriggerinputs'
                val = obj.nTriggerInputs;
            case 'ntriggeroutputs'
                val = obj.nTriggerOutputs;
            case 'probeset'
                val = obj.probesetInfo;
            case 'paradigmstimulustype'
                val = obj.paradigmStimulusType;
            case 'source'
                val = obj.source;
            case 'studytypemodulation'
                val = obj.studyTypeModulation;
            case 'subjectindex'
                val = obj.subjectIndex;
            case 'samplingrate'
                val = obj.samplingRate;
            case 'samplingperiod'
                val = obj.samplingPeriod;
            case 'sdkey'
                val = obj.sdKey;
            case 'sdmask'
                val = obj.sdMask;
            case 'subjectage'
                val = obj.userAge;
            case 'subjectgender'
                val = obj.userGender;
            case 'subjectname'
                val = obj.userName;
           

        otherwise 
            val = get@rawData(obj, propName);
    end
     
end