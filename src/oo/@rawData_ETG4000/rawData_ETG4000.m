%Class rawData_ETG4000
%
%A rawData_ETG4000 represents the experimentally recorded data
%with a HITACHI ETG 4000 NIRS device during a fNIRS session.
%This data is not yet converted to a proper neuroimage.
%
%This class also contains some experimental parameters such as
%the sampling rate etc...
%
% The interoptode distance is fixed at 3cm.
% The Hitachi ETG-4000 OTS operates at two wavelengths:
%   695 +/- 20nm
%   830 +/- 20nm
%with and optical intensity of 2.0mW per wavelength (see ETG-4000
%Instruction manual, Section 12 pg. 12-1) and has 24 channels or
%picture elements by default. The deviation from the
%nominal wavelength is recorded in the raw light intensity files.
%
%The main attribute is lightRawData holding the raw light intensity
%data. It is a matrix sized
% (nWLengths*nChannels+1) x nSamples.
%   Note that each channel has nWLengths measurements at the different
%   wavelengths.
%
%               Sample_1  Sample_2 ... Sample_n
%   Ch1^l1
%   ...
%   Ch1^lm
%   Ch2^l1
%   ...
%   ChC^lm
%
%
%
%% Probes, optode arrays and conversion to nirs_neuroimage
%
%	The ETG-4000 has 1 probe for each set of 24 channels.
%Each probe may be configured using one optode array holding
%24 channels (e.g. 4x4), one optode array holding 22 channels
%(e.g. 5x3) or two optode arrays holding 12 channels each 
%for a total of 24 channels (e.g. 3x3).
%
%   +=================================================+
%   | NOTE: Only those probes marked as read/imported |
%   | will be used during the conversion.             |
%   +=================================================+
%
% One property (.probesInfo) controls how the probes are
%read/imported, and how the optode arrays are configured.
%
%
%
%% Remarks
%
% Private function
%
%       coe=table_abscoeff;
%
% is actually copyrighted by fOSA and licenced under the GNU end user
% licence agreement.
%
%
%% Superclass
%
% rawData - An abstract class for holding raw data.
%
%
%% Properties
%
%   ICNA started when the HITACHI data file version was 1.06. As such
% 1.06 is the default version. A few attributes became available only
% at later versions. For these, it has been annotated when ICNA became
% aware of this attribute.
%
%   .fileVersion - The HITACHI data file version. By default is set to 1.06.
%  == Patient information
%   .userName - The user name
%   .userAge - The user age
%   .userSex - The user sex
%   .userBirthDate - The user birth date. A date in MATLAB's datenum
%               format.
%           Available as from HITACHI file version 1.21
%  == Analysis information (for presentation only)
%	.analyzeMode='continuous'; %Not sure of what is this used for.
%   .preTime=1; %in [s]
%   .postTime=1; %in [s]
%   .recoveryTime=1; %in [s]
%   .baseTime=1; %in [s]
%   .fittingDegree=1;
%   .hpf ='No Filter'; %High pass cutoff frequency in [Hz] or 'No Filter'
%   .lpf ='No Filter'; %Low pass cutoff frequency in [Hz] or 'No Filter'
%   .movingAvg=1; %Moving average smoothing for presentation only
%  == Measurement information
%   .measurementDate - See inherited property .date. Timestamps are
%       expressed with respect to this date.
%   .probesetInfo - An array of struct holding information about the probe
%       sets and their configuration. There is one position for each
%       probe. This property has the length of the highest probe read
%       so far. Each probe record (struct) contains the following fields:
%           .read - A binary record (0 -not read (default); 1 -read)
%               of the probes imported so far.  For instance, when reading
%               48 channels from 2 probe sets, one can read the second
%               probe set first; in that case,
%                   .probesInfo(1).read=0;
%                   .probesInfo(2).read=1;
%                 and the length of probesInfo will be 2, indicating
%               that the second probe has been imported but not the first.
%                   It follows that the total number of probes imported
%               is the sum of this field across the .probesInfo array.
%                 This is not an attribute read from the data file itself,
%               but allows ICNA to track more than one probe.
%           .type - A cell array of string indicating whether the probe
%               is for adults or neonates. It might be expected that the 
%               type is shared across all probes, but no effort
%               is made to check this.
%               Available as from HITACHI file version 1.21
%           .mode - A string containing the mode for the
%               probe which determines the number and type of the
%               optode arrays used. Currently accepted modes are:
%                   + '3x3' (2 optode arrays; 2x12=24 channels) - Default
%                   + '3x5' (1 optode arrays; 22 channels)
%                   + '4x4' (1 optode arrays; 24 channels)
%               Note that the number of optode
%               arrays may be larger than the number of probes
%               (e.g. 1 probe set to mode 3x3 actually has 2 optode
%               arrays). Note that the number of channels can actually
%               be calculated from the mode.
%   .wLengths=[695 830] - The nominal wavelengths at which the light
%             intensities were acquired in [nm].
%   .samplingPeriod - Sampling period i.e. time between two
%             measurements in [s]. Note that the sampling rate
%             is calculated on the fly as 1/samplingPeriod
%   .nBlocks - DEPRECATED. See Repeat Count
%   .repeatCount - Number of times the sequence of stimulus is repeated.
%       For very simple experiments with a single stimulus (say A),
%       you can indicate only 1 stimulus in the train in the HITACHI
%       software and repeat the train of stimulus 5 times
%       (Repeat Count == nBlocks ==5). However, for more complicated
%       train of stimulus (e.g. ABAB), the number of blocks or trials
%       no longer coincides with the number of blocks per stimulus.
%
%  == The data
%   .lightRawData - The raw light intensity data. The third dimension
%       of the matrix holds the information for the different probe set.
%       The size of the matrix along the 3rd dimension matches the length
%       of the property .probesInfo
%   .marks - Stimulus marks. One column per probe set. The n-th column
%       corresponds to the marks for the n-th probe set
%       The number of columns matches the length of the property
%       .probesetInfo
%   .timestamps - Timestamps relative to the object 'Date' (inherited)
%       in [s]. Absolute timestamps are obtained from the
%       Time column in the data section.
%       	+ Note that the first time stamp does NOT have to be 0!.
%           + Milliseconds are expressed as a fraction of seconds.
%       One column per probe set. The n-th column
%       corresponds to the marks for the n-th probe set
%       The number of columns matches the length of the property
%       .probesetInfo
%       It might be expected that the timestamps are shared across
%       all probes, but no effort is made to check this.
%   .bodyMovement - Track of body movement artifacts by the ETG-4000.
%       One column per probe set. The n-th column
%       corresponds to the marks for the n-th probe set
%       The number of columns matches the length of the property
%       .probesetInfo
%   .removalMarks - Track of removal marks by the ETG-4000. Not sure of
%       what is this used for.
%       One column per probe set. The n-th column
%       corresponds to the marks for the n-th probe set
%       The number of columns matches the length of the property
%       .probesetInfo
%   .preScan - Track of preScan stamps by the ETG-4000. Not sure of
%       what is this used for.
%       One column per probe set. The n-th column
%       corresponds to the marks for the n-th probe set
%       The number of columns matches the length of the property
%       .probesetInfo
%  
%% Methods
%
% Type methods('rawData_ETG4000') for a list of methods
%
%
% Copyright 2008-16
% @date: 12-May-2008
% @author: Felipe Orihuela-Espina
% @modified: 14-Jan-2016
%
% See also rawData, rawData_ETG4000
%

%% Log
%
% 14-Jan-2016 (FOE): Comments improved.
%
% 13-February-2022 (ESR): Get/Set Methods created in rawData_ETG4000.
%   + The methods are added with the new structure. All the properties have 
%   the new structure.
%   + The new structure enables new MATLAB functions
%   + We create a dependent property inside the rawData_ETG4000 class.
%   + The samplingRate, version, nBlocks, nProbes, nProbeSets and nChannels properties dependents are in the
%   rawData_ETG4000 class.
%
% 02-May-2022 (ESR): rawData_ETG4000 class SetAccess=private, GetAccess=private) removed
%   + The access from private to public was commented because before the data 
%   did not request to enter the set method and now they are forced to be executed, 
%   therefore the private accesses were modified to public.
%

classdef rawData_ETG4000 < rawData
    properties %(SetAccess=private, GetAccess=private)
        fileVersion='1.06';
        %Patient information
        userName='';
        userSex='';
        userAge=[];
        userBirthDate=[]; % A date vector
        %Analysis information (for presentation only)
        analyzeMode='continuous';
        preTime=1; %in [s]
        postTime=1; %in [s]
        recoveryTime=1; %in [s]
        baseTime=1; %in [s]
        fittingDegree=1;
        hpf ='No Filter'; %High pass cutoff frequency in [Hz] or 'No Filter'
        lpf ='No Filter'; %Low pass cutoff frequency in [Hz] or 'No Filter'
        movingAvg=1; %Moving average smoothing for presentation only
        %Measure information
        %nProbes=0;%DEPRECATED. Total number of probes imported.
        %probeMode='3x3';%DEPRECATED. A strings containing the probe mode.
        %nChannels=0;%DEPRECATED. The number of Channels derived
                    %from the probeMode.
        probesetInfo = struct('read',{},'type',{},'mode',{});
        wLengths=[695 830];%The nominal wavelengths at which the light
            %intensities were acquired in [nm].
        samplingPeriod=0.1%Sampling rate i.e. time between two
                        %measurements in [s]
        %nBlocks=0; %DEPRECATED
        repeatCount=0; %Repeat Count
        %The data itself!!
        %NOTE: In MATLAB, an assignment:
        %   + a=nan(0,0,0) leads to an empty array 0-by-0-by-0 with ndims 3
        %   + a=nan(0,n) leads to an empty array 0-by-n with ndims 2
        %   + a=nan(0,0,n) leads to an empty array 0-by-0-by-n with
        %           ndims 3, iff n~=1!!
        %but unfortunately
        %   + a=nan(0,0) leads to an empty array [] with ndims 2
        %   + a=nan(0,0,1) leads to an empty array [] with ndims 2
        
        lightRawData=nan(0,0,0);%The raw light intensity data.
            %note that intializing to nan(0,0) is equal to
            %initializing to []. See above
        marks=nan(0,0);%The stimulus marks.
        timestamps=nan(0,0);%Timestamps.
        bodyMovement=nan(0,0);%Body movement artifacts as determined by the ETG-4000
        removalMarks=nan(0,0);%Removal marks
        preScan=nan(0,0);%preScan stamps
    end
    
    properties (Dependent)
        samplingRate
        version
        nBlocks
        nProbes
        nProbeSets
        nChannels
    end
 
    methods    
        function obj=rawData_ETG4000(varargin)
            %RAWDATA_ETG4000 RawData_ETG4000 class constructor
            %
            % obj=rawData_ETG4000() creates a default rawData_ETG4000
            %   with ID equals 1.
            %
            % obj=rawData_ETG4000(obj2) acts as a copy constructor of
            %   rawData_ETG4000
            %
            % obj=rawData_ETG4000(id) creates a new rawData_ETG4000
            %   with the given identifier (id). The name of the
            %   rawData_ETG4000 is initialised
            %   to 'RawDataXXXX' where is the id preceded with 0.
            %

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'rawData_ETG4000')
                obj=varargin{1};
                return;
            else
                obj.id=varargin{1};
                obj.description=['RawData' num2str(obj.id,'%04i')];
            end
            assertInvariants(obj);

        end
        
        %% Get/Set methods    
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.
        
        %Analysis information (for presentation only)
        %analyzeMode
        function val = get.analyzeMode(obj)
           % The method is converted and encapsulated. 
            % obj is the rawData_ETG4000 class
            % val is the value added in the object
            % get.analyzeMode(obj) = Get the data from the rawData_ETG4000 class
            % and look for the analyzeMode object.
           val = obj.analyzeMode; 
        end
        function obj = set.analyzeMode(obj,val)
            % The method is converted and encapsulated and can be used 
            % as the example in the constructor method.
            % This method allows the change of data values.
            %   obj is the rawData_ETG4000 class
            %   val = is the provided value, later it is conditioned 
            %   according to the data type.
            if (ischar(val))
                obj.analyzeMode = val;
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a string');
            end
        end
        
        %Analysis information (for presentation only)
        %baseTime
        function val = get.baseTime(obj)
           val = obj.baseTime; 
        end
        function obj = set.baseTime(obj,val)
            if (isscalar(val) && (floor(val)==val) && val>0)
                obj.baseTime = val;
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a positive integer');
            end
        end
        
        %bodyMovement
        function val = get.bodyMovement(obj)
           val = obj.bodyMovement; 
        end
        function obj=set.bodyMovement(obj,val)
            if (all(floor(val)==val) && all(val>=0))
                obj.bodyMovement = val;
                %Note that the number of columns is expected to
                %match the number of probes sets declared.
                %See assertInvariants
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a matrix positive integer.');
            end 
        end
        
        % fileVersion
        function val = get.fileVersion(obj)
           val = obj.fileVersion; 
        end
        function obj = set.fileVersion(obj,val)
            if (ischar(val))
                obj.fileVersion = val;
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a string');
            end
        end
        
        %Analysis information (for presentation only)
        %fittingDegree
        function val = get.fittingDegree(obj)
            val = obj.fittingDegree;
        end
        function obj = set.fittingDegree(obj,val)
           if (isscalar(val) && (floor(val)==val) && val>0)
                obj.fittingDegree = val;
           else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a positive integer');
           end
        end
        
        %Analysis information (for presentation only)
        %hpf
        function val = get.hpf(obj)
           val = obj.hpf; 
        end
        function obj = set.hpf(obj,val)
            obj.hpf = val;
        end
        
        %Measure information
        %wLengths
        function val = get.wLengths(obj)
            val = obj.wLengths;
        end
        function obj = set.wLengths(obj,val)
           if (isvector(val) && isreal(val))
                obj.wLengths = val;
           else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a vector of wavelengths in nm.');
           end 
        end
        
        %Analysis information (for presentation only)
        %lpf
        function val = get.lpf(obj)
            val = obj.lpf;
        end
        function obj = set.lpf(obj,val)
            obj.lpf = val;
        end
        
        %lightRawData
        function val = get.lightRawData(obj)
            val = obj.lightRawData;%The raw light intensity data. 
        end
        function obj = set.lightRawData(obj,val)
            if (isreal(val) && size(val,3)==length(obj.probesetInfo))
                obj.lightRawData = val;
                    %Note that the size along the 3rd dimension is expected to
                    %match the number of probes sets declared.
                    %See assertInvariants
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                      'Size of data is expected to match the number of probes sets declared.');
            end 
        end
        
        %Analysis information (for presentation only)
        %movingAvg
        function val = get.movingAvg(obj)
            val = obj.movingAvg;
        end
        function obj = set.movingAvg(obj,val)
            if (isscalar(val) && val>0)
                obj.movingAvg = val;
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a positive real number in [s].');
            end
        end
        
        %The data itself!!
        %marks
        function val = get.marks(obj)
           val = obj.marks;%The stimulus marks. 
        end
        function obj = set.marks(obj,val)
            if (all(floor(val)==val) && all(val>=0))
                obj.marks = val;
                    %Note that the number of columns is expected to
                    %match the number of probes sets declared.
                    %See assertInvariants
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                      'Value must be a matrix positive integer.');
            end
        end
        
        %nBlocks
        function val = get.nBlocks(obj) %DEPRECATED
            val = obj.repeatCount;
                warning('ICNA:rawData_ETG4000:get:Deprecated',...
                ['The use of ''nBlocks'' has been deprecated. ' ...
                'Please use ''repeatCount'' instead.']); 
        end
        function obj = set.nBlocks(obj,val)
            if (isscalar(val) && (floor(val)==val) && val>0)
                obj.repeatCount = val;
                warning('ICNA:rawData_ETG4000:set:Deprecated',...
                    ['The use of ''nBlocks'' has been deprecated. ' ...
                    'Please use ''repeatCount'' instead.']);
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a positive integer.');
            end
        end
        
        %nProbes
        function val = get.nProbes(obj)
           val = length(obj.probesetInfo);
                warning('ICNA:rawData_ETG4000:get:Deprecated',...
                ['The use of ''nProbes'' has been deprecated. ' ...
                'Please use ''nProbeSets'' instead.']); 
        end
        
        %nProbeSets
        function val = get.nProbeSets(obj)
           val = length(obj.probesetInfo); 
        end
        
        %nChannels
        function val = get.nChannels(obj)
           %Total number of channels across all probes.
           %val = sum(obj.nChannels); %DEPRECATED
            nProbeSets=length(obj.probesetInfo);
            nCh=0; 
            for ps=1:nProbeSets
                if obj.probesetInfo(ps).read %Count only those which have been imported
                    pMode=obj.probesetInfo(ps).mode;
                    switch (pMode)
                        case '3x3'
                            nCh =nCh+24;
                        case '4x4'
                            nCh =nCh+24;
                        case '3x5'
                            nCh =nCh+22;
                        otherwise
                            error('ICNA:rawData_ETG4000:get:UnexpectedProbeSetMode',...
                                'Unexpected probe set mode.');
                    end
                end
            end
               val=nCh;
        end
        
        %preScan
        function val = get.preScan(obj)
           val = obj.preScan; 
        end
        function obj = set.preScan(obj,val)
            if (all(floor(val)==val) && all(val>=0))
                obj.preScan = val;
                %Note that the number of columns is expected to
                %match the number of probes sets declared.
                %See assertInvariants
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a matrix positive integer.');
            end
        end
        
        %Analysis information (for presentation only):------------------>
        %preTime
        function val = get.preTime(obj)
           val = obj.preTime; 
        end
        function obj = set.preTime(obj,val)
           if (isscalar(val) && (floor(val)==val) && val>0)
                obj.preTime = val;
           else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a positive integer');
           end 
        end
        
        %postTime
        function val = get.postTime(obj)
            val = obj.postTime;
        end
        function obj = set.postTime(obj,val)
            if (isscalar(val) && (floor(val)==val) && val>0)
                obj.postTime = val;
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a positive integer');
            end
        end
        
        %recoveryTime
        function val = get.recoveryTime(obj)
           val = obj.recoveryTime; 
        end
        function obj = set.recoveryTime(obj,val)
           if (isscalar(val) && (floor(val)==val) && val>0)
                obj.recoveryTime = val;
           else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a positive integer');
           end
        end
        
        %----------------------------------------------------------------->
        
        %Measure information
        %repeatCount
        function val = get.repeatCount(obj)
            val = obj.repeatCount;
        end
        function obj = set.repeatCount(obj,val)
            if (isscalar(val) && (floor(val)==val))
                obj.repeatCount = val;
            else
               error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a positive integer or 0.');
            end
        end
        
        %removalMarks
        function val = get.removalMarks(obj)
            val = obj.removalMarks;
        end
        function obj = set.removalMarks(obj,val)
            if (all(floor(val)==val) && all(val>=0))
                obj.removalMarks = val;
                %Note that the number of columns is expected to
                %match the number of probes sets declared.
                %See assertInvariants
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a matrix positive integer.');
            end
        end
        
        %Measure information
        %samplingPeriod
        function val = get.samplingPeriod(obj)
            val = obj.samplingPeriod;
        end
        function obj = set.samplingPeriod(obj,val)
            if (isscalar(val) && isreal(val) && val>0)
                obj.samplingPeriod = val;
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a positive real');
            end
        end
        
        %samplingRate Dependent samplingPeriod
        function val = get.samplingRate(obj)
            val = 1/obj.samplingPeriod;
        end
        function obj = set.samplingRate(obj,val)
            if (isscalar(val) && isreal(val) && val>0)
                obj.samplingPeriod = 1/val; %como agregar?
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a positive real');
            end
        end
        
        %timesStamps
        function val = get.timestamps(obj)
            val = obj.timestamps;
        end
        function obj = set.timestamps(obj,val)
            if (all(val>=0))
                obj.timestamps = val;
                %Note that the number of columns is expected to
                %match the number of probes sets declared.
                %See assertInvariants
           else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a matrix positive integer.');
           end 
        end
        
        %Patient information: ------------------------------------------->
        %userName
        function val = get.userName(obj)
           val = obj.userName; 
        end
        function obj = set.userName(obj,val)
            if (ischar(val))
                obj.userName = val;
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a string');
            end
        end
        
        %userSex
        function val = get.userSex(obj)
           val = obj.userSex; 
        end
        function obj = set.userSex(obj,val)
            if (ischar(val))
                obj.userSex = val;
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a string');
            end
        end
        
        %userBirthDate
        function val = get.userBirthDate(obj)
           val = obj.userBirthDate; 
        end
        function obj = set.userBirthDate(obj,val)
           if (ischar(val) || isvector(val) || isscalar(val))
                obj.userBirthDate = datenum(val);
           else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a date (whether a string, datevec or datenum).');
           end 
        end
        
        %userAge
        function val = get.userAge(obj)
           val = obj.userAge; 
        end
        function obj = set.userAge(obj,val)
           if (isscalar(val) && isreal(val))
                obj.userAge = val;
           else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be numeric');
           end 
        end
        %---------------------------------------------------------------->
        
        %version
        function val = get.version(obj)
           val = obj.fileVersion; %DEPRECATED
                warning('ICNA:rawData_ETG4000:get:Deprecated',...
                ['The use of ''version'' has been deprecated. ' ...
                'Please use ''fileVersion'' instead.']); 
        end
        function obj = set.version(obj,val)%DEPRECATED
            if (ischar(val))
                obj.fileVersion = val;
                warning('ICNA:rawData_ETG4000:set:Deprecated',...
                    ['The use of ''version'' has been deprecated. ' ...
                    'Please use ''fileVersion'' instead.']);
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a string');
            end
        end
        
    end

    methods (Access=protected)
        assertInvariants(obj);
    end
    
    methods (Static)
        coe=table_abscoeff;
    end

end
