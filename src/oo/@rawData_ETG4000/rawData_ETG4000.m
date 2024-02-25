classdef rawData_ETG4000 < rawData
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
%   .userAge - The user age. Since ICNNA v1.2,1, default to undefined 0.
%   .userSex - The user sex. Since ICNNA v1.2,1, default to undefined 'U'.
%   .userBirthDate - The user birth date. A date in MATLAB's datenum
%               format. Since v1.2,1, default to today.
%           Available as from HITACHI file version 1.21
%           NOTE: In ICNNA v1.2,1 type of this attribute was change from
%               datenum to datetime which may not be fully backward
%               compatible.
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
% Copyright 2008-23
% @author: Felipe Orihuela-Espina
%
% See also rawData, rawData_ETG4000
%

%% Log
%
%
% File created: 12-May-2008
% File last modified (before creation of this log): 14-Jan-2016
%
% 14-Jan-2016 (FOE): Comments improved.
%   + Added this log.
%
% 3-Dec-2023 (FOE): Comments improved.
%   + Got rid of old labels @date and @modified.
%   + Added property classVersion. Set to '1.0' by default.
%   + Added get/set methods support for struct like access to attributes.
%   + For those attributes above also started to simplify the set
%   code replacing it with validation rules on the declaration.
%




    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end


    properties (SetAccess=private, GetAccess=private)
        fileVersion(1,:) char ='1.06';
        %Patient information
        userName(1,:) char ='';
        userSex(1,1) char {mustBeMember(userSex,{'M','F','U'})}='U';
        userAge(1,1) double {mustBeInteger, mustBeNonnegative}=0;
        userBirthDate(1,1) datetime = datetime('now'); % A datenum
        %Analysis information (for presentation only)
        analyzeMode(1,:) char ='continuous';
        preTime(1,1) double {mustBeNonnegative}=1; %in [s]
        postTime(1,1) double {mustBeNonnegative}=1; %in [s]
        recoveryTime(1,1) double {mustBeNonnegative}=1; %in [s]
        baseTime(1,1) double {mustBeNonnegative}=1; %in [s]
        fittingDegree(1,1) double {mustBeInteger, mustBeNonnegative}=1;
        hpf(1,:) char ='No Filter'; %High pass cutoff frequency in [Hz] or 'No Filter'
        lpf(1,:) char ='No Filter'; %Low pass cutoff frequency in [Hz] or 'No Filter'
        movingAvg=1; %Moving average smoothing for presentation only
        %Measure information
        %nProbes=0;%DEPRECATED. Total number of probes imported.
        %probeMode='3x3';%DEPRECATED. A strings containing the probe mode.
        %nChannels=0;%DEPRECATED. The number of Channels derived
                    %from the probeMode.
        probesetInfo = struct('read',{},'type',{},'mode',{});
        wLengths(1,:) double {mustBeNonnegative}=[695 830];%The nominal wavelengths at which the light
            %intensities were acquired in [nm].
        samplingPeriod(1,1) double {mustBeNonnegative}=0.1%Sampling rate i.e. time between two
                        %measurements in [s]
        %nBlocks=0; %DEPRECATED
        repeatCount(1,1) double {mustBeInteger, mustBeNonnegative}=0; %Repeat Count
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
        nChannels
        nominalWavelengthSet
        samplingRate
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
  
    end

    methods (Access=protected)
        assertInvariants(obj);
    end
    
    methods (Static)
        coe=table_abscoeff;
    end




    methods

      %Getters/Setters

      function res = get.fileVersion(obj)
         %Gets the object |fileVersion|
         res = obj.fileVersion;
      end
      function obj = set.fileVersion(obj,val)
         %Sets the object |fileVersion|
         obj.fileVersion = val;
      end

    function res = get.userName(obj)
         %Gets the object |userName|
         res = obj.userName;
      end
      function obj = set.userName(obj,val)
         %Sets the object |userName|
         obj.userName = val;
      end

    function res = get.userAge(obj)
         %Gets the object |userAge|
         res = obj.userAge;
      end
      function obj = set.userAge(obj,val)
         %Sets the object |userAge|
         obj.userAge = val;
      end


    function res = get.userSex(obj)
         %Gets the object |userSex|
         res = obj.userSex;
      end
      function obj = set.userSex(obj,val)
         %Sets the object |userSex|
         obj.userSex = val;
      end

      function res = get.userBirthDate(obj)
         %Gets the object |userBirthDate|
         res = obj.userBirthDate;
      end
      function obj = set.userBirthDate(obj,val)
         %Sets the object |userBirthDate|
         obj.userBirthDate = val;
      end

      function res = get.analyzeMode(obj)
         %Gets the object |analyzeMode|
         res = obj.analyzeMode;
      end
      function obj = set.analyzeMode(obj,val)
         %Sets the object |analyzeMode|
         obj.analyzeMode = val;
      end

      function res = get.preTime(obj)
         %Gets the object |preTime|
         res = obj.preTime;
      end
      function obj = set.preTime(obj,val)
         %Sets the object |preTime|
         obj.preTime = val;
      end

      function res = get.postTime(obj)
         %Gets the object |postTime|
         res = obj.postTime;
      end
      function obj = set.postTime(obj,val)
         %Sets the object |postTime|
         obj.postTime = val;
      end

      function res = get.recoveryTime(obj)
         %Gets the object |recoveryTime|
         res = obj.recoveryTime;
      end
      function obj = set.recoveryTime(obj,val)
         %Sets the object |recoveryTime|
         obj.recoveryTime = val;
      end

      function res = get.baseTime(obj)
         %Gets the object |baseTime|
         res = obj.baseTime;
      end
      function obj = set.baseTime(obj,val)
         %Sets the object |baseTime|
         obj.baseTime = val;
      end

      function res = get.fittingDegree(obj)
         %Gets the object |fittingDegree|
         res = obj.fittingDegree;
      end
      function obj = set.fittingDegree(obj,val)
         %Sets the object |fittingDegree|
         obj.fittingDegree = val;
      end

      function res = get.lpf(obj)
         %Gets the object |lpf|
         res = obj.lpf;
      end
      function obj = set.lpf(obj,val)
         %Sets the object |lpf|
         obj.lpf = val;
      end

      function res = get.hpf(obj)
         %Gets the object |hpf|
         res = obj.hpf;
      end
      function obj = set.hpf(obj,val)
         %Sets the object |hpf|
         obj.hpf = val;
      end

      function res = get.movingAvg(obj)
         %Gets the object |movingAvg|
         res = obj.movingAvg;
      end
      function obj = set.movingAvg(obj,val)
         %Sets the object |movingAvg|
         obj.movingAvg = val;
      end

      function res = get.wLengths(obj)
         %Gets the object |wLengths|
         res = obj.wLengths;
      end
      function obj = set.wLengths(obj,val)
         %Sets the object |wLengths|
         obj.wLengths = val;
      end

      function res = get.samplingPeriod(obj)
         %Gets the object |samplingPeriod|
         res = obj.samplingPeriod;
      end
      function obj = set.samplingPeriod(obj,val)
         %Sets the object |samplingPeriod|
         obj.samplingPeriod = val;
      end

      function res = get.repeatCount(obj)
         %Gets the object |repeatCount|
         res = obj.repeatCount;
      end
      function obj = set.repeatCount(obj,val)
         %Sets the object |repeatCount|
         obj.repeatCount = val;
      end








      function res = get.nChannels(obj)
         %(DEPENDENT) Gets the object |nChannels|
         %
         % The number of channels in the data.
         % This is equivalent to size(obj.data,2)
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
                         error('ICNNA:rawData_ETG4000:get:UnexpectedProbeSetMode',...
                             'Unexpected probe set mode.');
                 end
             end
         end
         res=nCh;
      end


      function res = get.samplingRate(obj)
         %(DEPENDENT) Gets the object |samplingRate|
         %
         % The sampling rate.
         % This is equivalent to 1/samplingPeriod
         res = 1/obj.samplingPeriod;
      end
      function obj = set.samplingRate(obj,val)
         %(DEPENDENT) sets the object |samplingRate|
         obj.samplingPeriod = 1/val;
      end


      function res = get.nominalWavelengthSet(obj)
         %(DEPENDENT) Gets the object |wLengths|
         res = obj.wLengths;
      end
      function obj = set.nominalWavelengthSet(obj,val)
         %(DEPENDENT) Sets the object |wLengths|
         warning('ICNNA:rawData_ETG4000:set.nominalWavelengthSet:Deprecated', ...
                 'Property date has been deprecated. Use property wLengths instead.');
         obj.wLengths = val;
      end




    end
end
