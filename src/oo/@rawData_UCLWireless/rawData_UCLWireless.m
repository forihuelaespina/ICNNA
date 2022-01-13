%Class rawData_UCLWireless
%
%A rawData_UCLWireless represents the experimentally recorded data
%with UCL Wireless device during a fNIRS session. This corresponds to
%experimental data acquired by UCL and that they share with us when
%Samuel A. Montero Hernández made a research secondement with them.
%We have no information about the device (but I have reasons to believe
%it is a HITACHI ETG-100 Wireless. Data was provided already in a matlab
%file and was provided as is, and was
%already reconstructed i.e. HbO and HbR already available. We do not
%have access to the raw light intensities data.
%
%This class also contains some experimental parameters such as
%the sampling rate etc...
%
%
%
%
%
%
%
%% Probes, optode arrays and conversion to nirs_neuroimage
%
% The original data was accompanied by an additional folder labelled
%"Digitizer" which appears to contain information which is relevant
%for the channelLocationMap class.
%
% In particular, a file called Opt_Ch.csv appears to contain 3D locations
%of optodes, both emisor and detectors and channels.
%
%
%% Superclass
%
% rawData - An abstract class for holding raw data.
%
%
%% Properties
%
%  == Measurement information
%   .wLengths=[705 830] - The nominal wavelengths at which the light
%             intensities were acquired in [nm]. Retrieved from
%             nirs_data.wavelength
%   .samplingRate - Sampling rate in [Hz]. Retrieved from fs.
%  == The data
%   .oxyRawData - The raw hemodynamic data. A matrix of nsamples x
%       nchannels. Retrieved from HBO_raw.
%   .deoxyRawData - The raw hemodynamic data. A matrix of nsamples x
%       nchannels. Retrieved from HBR_raw.
%   .timestamps - Timestamps relative to experiment start
%       in [s]. Retrieved from t.
%       	+ Note that the first time stamp does NOT have to be 0!.
%           + Milliseconds are expressed as a fraction of seconds.
%       It is assumed that the timestamps are shared across
%       all probes, but no effort is made to check this.
%   .preTimeline - What seems to be timeline of the experiment. Retrieved
%       from e. It is a struct with the following fields:
%       .label - Experimental condition name
%       .code - Experimental condition code
%       .remainder - No idea
%       .starttime - Event onset in hh:mm:ss.ms
%       .endtime - Event offset in hh:mm:ss.ms
%  
%% Methods
%
% Type methods('rawData_UCLWireless') for a list of methods
%
%
% Copyright 2016
% @date: 1-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 1-Sep-2016
%
% See also rawData, rawData_UCLWireless
%

%% Log
%
% 1-Sep-2016 (FOE): Class created.
%


classdef rawData_UCLWireless < rawData
    properties (SetAccess=private, GetAccess=private)
        %Measure information
        wLengths=[705 830];%The nominal wavelengths at which the light
            %intensities were acquired in [nm].
        samplingRate=5%Sampling rate in [Hz]
        %The data itself!!
        %NOTE: In MATLAB, an assignment:
        %   + a=nan(0,0,0) leads to an empty array 0-by-0-by-0 with ndims 3
        %   + a=nan(0,n) leads to an empty array 0-by-n with ndims 2
        %   + a=nan(0,0,n) leads to an empty array 0-by-0-by-n with
        %           ndims 3, iff n~=1!!
        %but unfortunately
        %   + a=nan(0,0) leads to an empty array [] with ndims 2
        %   + a=nan(0,0,1) leads to an empty array [] with ndims 2
        
        oxyRawData=nan(0,0);%The raw light intensity data.
            %note that intializing to nan(0,0) is equal to
            %initializing to []. See above
        deoxyRawData=nan(0,0);%The raw light intensity data.
            %note that intializing to nan(0,0) is equal to
            %initializing to []. See above
        timestamps=nan(0,0);%Timestamps.
        preTimeline=struct('label',{},'code',{},...
                           'remainder',{}, ...
                           'starttime',{}, ...
                           'entime',{});%preTimeline
    end
 
    methods    
        function obj=rawData_UCLWireless(varargin)
            %RAWDATA_UCLWireless RawData_UCLWireless class constructor
            %
            % obj=rawData_UCLWireless() creates a default rawData_UCLWireless
            %   with ID equals 1.
            %
            % obj=rawData_UCLWireless(obj2) acts as a copy constructor of
            %   rawData_UCLWireless
            %
            % obj=rawData_UCLWireless(id) creates a new rawData_UCLWireless
            %   with the given identifier (id). The name of the
            %   rawData_UCLWireless is initialised
            %   to 'RawDataXXXX' where is the id preceded with 0.
            %

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'rawData_UCLWireless')
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
    

end
