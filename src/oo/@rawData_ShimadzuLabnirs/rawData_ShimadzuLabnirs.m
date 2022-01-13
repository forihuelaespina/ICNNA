%Class rawData_ShimadzuLabnirs
%
%A rawData_ShimadzuLabnirs represents the experimentally recorded data
%with a Shimadzu Labnirs device during a fNIRS session. Although, the
%Shimadzu device can provide the raw data into a .OMM file, this file is
%not stored on plain text and currently we have no access to the file
%format. Currently we only have access to the already converted data that
%comes in a .csv file.
%
% The original file also contains some experimental parameters such as
%the sampling rate, channel distribution,a dn variable interoptode
%distance, wavelengths, etc... but again, we currently do not have
%access to it.
%
% While departing from the converted hemodynamic data we have no
%information about the interoptode distance or channel location.
% The Shimadzu Labnirs operates at 4 wavelengths:
%   {Dark, 780, 805, 830}
%
%... from which 3 haemoglobin species are reconstructed (oxy-, deoxy-, and
%total). Note that the total hemoglobin is not calculated as the sum of oxy
%and deocy but actually reconstructed as another physiological paranmeter.
%
%The data which has been provided to us, has 84 channels but the system can
%hold more than that.
%
% Data is the reconstructed haemoglobin concentrations file comes as
%follows:
%
% + Line 1: Channel headers (3 columns per channel)
% + Line 2: Signal headers (timestamps, timeline flags, mark, and data)
% + Lines 3-end: Hb data
%
%
%
%
%% Probes, optode arrays and conversion to nirs_neuroimage
%
% The original data file .OMM contain information about the channel
%locations and probes, but this information is not available in the
%hemodynamic data file.
%
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
%   .wLengths=[780 805 830] - The nominal wavelengths at which the light
%             intensities were acquired in [nm].
%   .samplingRate - Sampling rate in [Hz].
%  == The data
%   .rawData - The raw hemodynamic data. A matrix of nsamples x
%       (3 x nchannels). Hemoglobin species are always in
%       oxy/deoxy/total sequence; e.g.
%           Ch1/HbO, Ch1/HbR, Ch1/HbT, Ch2/HbO, Ch2/HbR, Ch2/HbT, ...
%   .timestamps - Timestamps relative to experiment start
%       in [s]. 
%       	+ Note that the first time stamp does NOT have to be 0!.
%           + Milliseconds are expressed as a fraction of seconds.
%       It is assumed that the timestamps are shared across
%       all probes, but no effort is made to check this.
%   .preTimeline - What seems to be timeline of the experiment. Just a
%       sequence of integers with 1 flag per sample.
%   .marks - Apparently unused. No idea what this is for. Just a
%       sequence of integers with 1 flag per sample.
%  
%% Methods
%
% Type methods('rawData_ShimadzuLabnirs') for a list of methods
%
%
% Copyright 2016
% @date: 20-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 20-Sep-2016
%
% See also rawData, rawData_ShimadzuLabnirs
%

%% Log
%
% 20-Sep-2016 (FOE): Class created.
%


classdef rawData_ShimadzuLabnirs < rawData
    properties (SetAccess=private, GetAccess=private)
        %Measure information
        wLengths=[780 805 830];%The nominal wavelengths at which the light
            %intensities were acquired in [nm].
        samplingRate=27;%Sampling rate in [Hz]
        %The data itself!!
        %NOTE: In MATLAB, an assignment:
        %   + a=nan(0,0,0) leads to an empty array 0-by-0-by-0 with ndims 3
        %   + a=nan(0,n) leads to an empty array 0-by-n with ndims 2
        %   + a=nan(0,0,n) leads to an empty array 0-by-0-by-n with
        %           ndims 3, iff n~=1!!
        %but unfortunately
        %   + a=nan(0,0) leads to an empty array [] with ndims 2
        %   + a=nan(0,0,1) leads to an empty array [] with ndims 2
        
        rawData=nan(0,0);%The raw light intensity data.
            %note that intializing to nan(0,0) is equal to
            %initializing to []. See above
        timestamps=nan(0,0);%Timestamps.
        preTimeline=[];%preTimeline
        marks=[];%Marks
    end
 
    methods    
        function obj=rawData_ShimadzuLabnirs(varargin)
            %RAWDATA_SHIMADZULABNIRS RawData_ShimadzuLabnirs class constructor
            %
            % obj=rawData_ShimadzuLabnirs() creates a default rawData_ShimadzuLabnirs
            %   with ID equals 1.
            %
            % obj=rawData_ShimadzuLabnirs(obj2) acts as a copy constructor of
            %   rawData_ShimadzuLabnirs
            %
            % obj=rawData_ShimadzuLabnirs(id) creates a new rawData_ShimadzuLabnirs
            %   with the given identifier (id). The name of the
            %   rawData_ShimadzuLabnirs is initialised
            %   to 'RawDataXXXX' where is the id preceded with 0.
            %

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'rawData_ShimadzuLabnirs')
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
