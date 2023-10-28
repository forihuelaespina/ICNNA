function obj = set(obj,varargin)
% RAWDATA_NIRScout/SET DEPRECATED. Set object properties and return the updated object
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
% Copyright 2018-23
% @author Felipe Orihuela-Espina
%
% See also rawData.set, get
%



%% Log
%
% File created: 4-Apr-2008
% File last modified (before creation of this log): 7-Nov-2020
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
%
% 13-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%   + Nested method cropOrRemoveEvents has now been separated
%   to a private method.
%
%





warning('ICNNA:rawData_NIRScout:set:Deprecated',...
        ['DEPRECATED. Use struct like syntax for setting the attribute ' ...
         'e.g. rawData_NIRScout.' lower(varargin{1}) ' = ... ']); 






propertyArgIn = varargin;
while (length(propertyArgIn) >= 2)
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch lower(prop)
%General information
    case 'filename'
        obj.filename = val;
        % if (ischar(val))
        %     obj.filename = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a string');
        % end

    case 'device'
        obj.device = val;
        % if (ischar(val))
        %     obj.device = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a string');
        % end

    case 'source'
        obj.source = val;
        % if (ischar(val) && ismember(upper(val),{'LED','LASER'}))
        %     obj.source = upper(val);
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be either "LED" or "LASER".');
        % end

    case 'studytypemodulation'
        obj.studyTypeModulation = val;
        % if (ischar(val))
        %     obj.studyTypeModulation = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a string');
        % end

        
    case 'fileversion'
        obj.fileVersion = val;
        % if (ischar(val))
        %     obj.fileVersion = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a string');
        % end
        
    case 'subjectindex'
        obj.subjectIndex = val;
        % if (isscalar(val) && isnumeric(val) && mod(val,val)==0)
        %     obj.subjectIndex = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be an integer number.');
        % end
        
%Measure information
    case 'nsources'
        obj.nSources = val;
        % if (isscalar(val) && isnumeric(val) && mod(val,val)==0 && val>=0)
        %     obj.nSources = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be an integer number.');
        % end

    case 'ndetectors'
        obj.nDetectors = val;
        % if (isscalar(val) && isnumeric(val) && mod(val,val)==0 && val>=0)
        %     obj.nDetectors = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be an integer number.');
        % end

    case 'nchannels'
        obj.nChannels = val;
        % if (isscalar(val) && isnumeric(val) && mod(val,val)==0 && val>=0)
        %     obj.nChannels = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be an integer number.');
        % end

    case 'nsteps'
        obj.nSteps = val;
        % if (isscalar(val) && isnumeric(val) && mod(val,val)==0)
        %     obj.nSteps = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be an integer number.');
        % end


    case 'nominalwavelenghtset'
        obj.wLengths = val;
        % if (isvector(val) && isreal(val))
        %     obj.wLengths = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a vector of wavelengths in nm.');
        % end

    case 'ntriggerinputs'
        obj.nTriggerInputs = val;
        % if (isscalar(val) && isnumeric(val) && mod(val,val)==0)
        %     obj.nTriggerInputs = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be an integer number.');
        % end

    case 'ntriggeroutputs'
        obj.nTriggerOutputs = val;
        % if (isscalar(val) && isnumeric(val) && mod(val,val)==0)
        %     obj.nTriggerOutputs = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be an integer number.');
        % end

    case 'nanaloginputs'
        obj.nAnalogInputs = val;
        % if (isscalar(val) && isnumeric(val) && mod(val,val)==0)
        %     obj.nAnalogInputs = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be an integer number.');
        % end

    case 'modulationamplitudes'
        obj.modulationAmplitudes = val;
        % if (isvector(val) && isreal(val))
        %     obj.modulationAmplitudes = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a vector of amplitudes.');
        % end

    case 'modulationthresholds'
        obj.modulationThresholds = val;
        % if (isvector(val) && isreal(val))
        %     obj.modulationThresholds = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a vector of thresholds.');
        % end

    case 'samplingperiod'
        obj.samplingRate = val;
        % if (isscalar(val) && isreal(val) && val>0)
        %     obj.samplingRate = 1/val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a positive real');
        % end

    case 'samplingrate'
        obj.samplingRate = val;
        % if (isscalar(val) && isreal(val) && val>0)
        %     obj.samplingRate = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a positive real');
        % end
        
        
        
    case 'probeset'
        obj.probesetInfo = val;
        % if (isstruct(val))
        %     %The fields in this probeset struct are NOT always the
        %     %same. So these have to be check everytime.
        %     obj.probesetInfo = struct('probes',[],'geom',[],...
        %                 'temphandles',[],'headmodel','',...
        %                 'probeInforFileName','','probeInforFilePath','');
        %     fields = fieldnames(val);
        %     nFields = length(fields);
        %     for ff=1:nFields
        %         fieldname = fields{ff};
        %         if isfield(obj.probesetInfo,fieldname)
        %             obj.probesetInfo.(fieldname) = val.(fieldname);
        %         else
        %             warning('ICNNA:rawData_NIRScout:set:UnexpectedParameterValue',...
        %                     ['Unexpected field name ''' fieldname '''in probe set descriptor. Ignoring field.'])
        %         end
        %     end
        % 
        % 
        %    %Field setupType is not present in all file versions.
        %    % I have found it in version 14.2 but not in 15.2
        %    %but it was used for several things during conversion
        %    %to structuredData.
        %    if ~isfield(obj.probesetInfo.probes,'setupType')
        %        obj.probesetInfo.probes.setupType = 1;
        %    end
        % 
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a struct.');
        % end
        
% %     case 'probemode'
% %         if (ischar(val))
% %             obj.probeMode = val;
% %         else
% %             error('Value must be a string');
% %         end
% % 
% %     case 'nchannels'
% %         if (isscalar(val) && (floor(val)==val) ...
% %                 && val>0)
% %             obj.nChannels = val;
% %         else
% %             error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
% %                  'Value must be a positive integer');
% %         end
% 



% Paradigm Information
    case 'paradigmstimulustype'
        obj.paradigmStimulusType = val;
        % if (ischar(val))
        %     obj.paradigmStimulusType = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a string');
        % end

% Experimental Notes
    case 'notes'
        obj.notes = val;
        % if (ischar(val))
        %     obj.notes = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a string');
        % end




% Gain settings
    case 'gains'
        obj.gains = val;
        % if any(any(val<0))
        %     warning('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Nagative gain found.');
        % end
        % obj.gains = val;
            
% Markers Information
    case 'eventtriggermarkers'
        obj.eventTriggerMarkers = val;
        % if (size(val,2)==3 && all(all(floor(val(:,2:3))==val(:,2:3))) && all(all(val>=0)))
        %     obj.eventTriggerMarkers = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a 3 columns matrix with the second and third columns being integer numbers.');
        % end


% Data Structure
    case 'sdkey'
        obj.sdKey = val;
        % if (all(all(floor(val)==val)) && all(all(val>=0)))
        %     obj.sdKey = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a matrix positive integers.');
        % end
        
    case 'sdmask'
        obj.sdMask = val;
        % if (all(all(ismember(val,[0,1]))))
        %     obj.sdMask = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a binary matrix (of 0s and 1s).');
        % end
        
        
% Channel Distances
    case 'channeldistances'
        obj.channelDistances = val;
        % if (all(all(val>=0)) && length(val)==obj.nChannels)
        %     obj.channelDistances = val;
        % else
        %     if (length(val)==obj.nChannels)
        %         error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a vector positive numbers.');
        %     else
        %         error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Number of channel distances is different from the number of channels.');
        %     end
        % end

       
        

%Patient information
    case 'subjectname'
        obj.userName = val;
        % if ischar(val)
        %     obj.userName = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a string');
        % end

    case 'subjectgender'
        obj.userGender = val;
        % if isempty(val)
        %     obj.userGender = 'U';
        % elseif ischar(val)
        %     %Try to decode the gender; if not possible, set to 'U'
        %     %and issue a warning.
        %     if ismember(upper(val),{'F','FEMALE','WOMAN'})
        %         obj.userGender = 'F';
        %     elseif ismember(upper(val),{'M','MALE','MAN'})
        %         obj.userGender = 'M';
        %     elseif ismember(upper(val),{'U'})
        %         obj.userGender = 'U';
        %     else
        %         obj.userGender = 'U';
        %         warning('ICNNA:rawData_NIRScout:set:UnexpectedParameterValue',...
        %                 ['Value for subject gender is not recognised. ' ...
        %                 'It will be set to (U)nset. ' ...
        %                 'Try common gender identifiers e.g. (M)ale or (F)emale.']);
        %     end
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be a string.');
        % end

%     case 'subjectbirthdate'
%         if (ischar(val) || isvector(val) || isscalar(val))
%             obj.userBirthDate = datenum(val);
%         else
%             error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
%                   'Value must be a date (whether a string, datevec or datenum).');
%         end

    case 'subjectage'
        obj.userAge = val;
        % if (isscalar(val) && isreal(val))
        %     obj.userAge = val;
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Value must be numeric');
        % end
        % 

    
%The data itself!!
    case 'lightrawdata'
        obj.lightRawData = val;
        % if (isreal(val) && size(val,3)==length(obj.probesetInfo))
        %     obj.lightRawData = val;
        %         %Note that the size along the 3rd dimension is expected to
        %         %match the number of probes sets declared.
        %         %See assertInvariants
        % else
        %     error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
        %           'Size of data is expected to match the number of probes sets declared.');
        % end
        
%     case 'marks'
%         if (all(floor(val)==val) && all(val>=0))
%             obj.marks = val;
%                 %Note that the number of columns is expected to
%                 %match the number of probes sets declared.
%                 %See assertInvariants
%         else
%             error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
%                   'Value must be a matrix positive integer.');
%         end
% 
%     case 'timestamps'
%         if (all(val>=0))
%             obj.timestamps = val;
%                 %Note that the number of columns is expected to
%                 %match the number of probes sets declared.
%                 %See assertInvariants
%         else
%             error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
%                   'Value must be a matrix positive integer.');
%         end
% 
%     case 'bodymovement'
%         if (all(floor(val)==val) && all(val>=0))
%             obj.bodyMovement = val;
%                 %Note that the number of columns is expected to
%                 %match the number of probes sets declared.
%                 %See assertInvariants
%         else
%             error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
%                   'Value must be a matrix positive integer.');
%         end
% 
%     case 'removalmarks'
%         if (all(floor(val)==val) && all(val>=0))
%             obj.removalMarks = val;
%                 %Note that the number of columns is expected to
%                 %match the number of probes sets declared.
%                 %See assertInvariants
%         else
%             error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
%                   'Value must be a matrix positive integer.');
%         end
% 
%     case 'prescan'
%         if (all(floor(val)==val) && all(val>=0))
%             obj.preScan = val;
%                 %Note that the number of columns is expected to
%                 %match the number of probes sets declared.
%                 %See assertInvariants
%         else
%             error('ICNNA:rawData_NIRScout:set:InvalidParameterValue',...
%                   'Value must be a matrix positive integer.');
%         end



   otherwise
        obj=set@rawData(obj, prop, val);
   end
end


% %Ensure number of channelDistances matches the number of channels (visible
% %in the mask)
% sillyNChannels = get(obj,'nChannels');
% if (numel(obj.channelDistances) < sillyNChannels)
%     %Add new distances and send warning
%     obj.channelDistances(end+1:end+sillyNChannels)=nan;
%     warning('Adding default channel distances to new channels.')
% elseif (numel(obj.channelDistances) > sillyNChannels)
%     %Discard latter distances and send warning
%     obj.channelDistances(sillyNChannels+1:end)=[];
%     warning('Removing extra channel distances.')
% %else %(obj.channelsDistances == sum(sum(obj.sdMask)))
%     %Do nothing
% end
 
end


