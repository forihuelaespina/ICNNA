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


classdef rawData_ETG4000 < rawData
    properties (SetAccess=private, GetAccess=private)
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

end
