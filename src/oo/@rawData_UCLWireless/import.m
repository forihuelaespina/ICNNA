function obj=import(obj,filename)
%RAWDATA_UCLWIRELESS/IMPORT Reads the raw light intensities 
%
% obj=import(obj,filename) Reads the light intensities recorded in
%   a .csv file produced by the Hitachi ETG-4000 NIRS system.
%   Note that HITACHI uses one file per probes set. Thus, if you are
%   using more than one probes set (e.g. 48 channels), you will have to
%   call this method for each probes set.
%   This will overwrite any previous data in the corresponding probe set. 
%
%
%   +=================================================+
%   | NOTE: Header data will be overwritten everytime |
%   |you call this method. Although it should be      |
%   |expected that the header across different probes |
%   |sets ought to be the same. This is not currently |
%   |check.                                           |
%   +=================================================+
%
%
%
%
%% The UCL wireless device data
%
% The file is a matlab file that contains a lot of variables (most of
%them are criptic to me). The following
%are the ones which seem to have interest for us (please note that the
%following are only educated guesses; as I have truly no clue about
%what's in the variables):
%
% n_channels - Number of channels. Nevertheless this number can also be
%   retrieved from the data variables.
% nirs_data - A struct with 5 fields (likely AFTER downsampling)
%       .oxyData - HbO2 data, but I do not know in which processing "state"
%           it is.
%       .dxyData - HbR data, but I do not know in which processing "state"
%           it is.
%       .fs - Sampling frequency (Likely 5Hz)
%       .nch - Yep! Number of channels again.
%       wavelength - A vector with the nominal acquisition wavelengths.
% HBO_raw - The raw HbO2 data. A matrix of <nsamples,nchannels>
% HBR_raw - The raw HbR data. A matrix of <nsamples,nchannels>
% onsets - A vector of stimulus onsets?
% fs - Sampling frequency in Hz (original)
% fs_new - Sampling frequency in Hz (after downsampling)
% t - timestamps in seconds (original).
% t_new - timestamps in seconds (after downsampling).
% e - What seems to be timeline of the experiment. It is a struct with the
%   following fields:
%       .label - Experimental condition name
%       .code - Experimental condition code
%       .remainder - No idea
%       .starttime - Event onset in hh:mm:ss.ms
%       .endtime - Event offset in hh:mm:ss.ms
%
%
% Note that data is already reconstructed.%
%
%
%
% The original data was accompanied by an additional folder labelled
%"Digitizer" which appears to contain information which is relevant
%for the channelLocationMap class. In particular, a file called
%Opt_Ch.csv appears to contain 3D locations
%of optodes, both emisor and detectors and channels. This file is however
%ignored at this time.
%
%
%
%% Remarks
%
% Please note that the optode "effective" wavelengths at the different
% channels at which the optode is working might slightly differ from
% the "nominal" wavelengths. These effective wavelengths are also
% available at the Hitachi file, for each of the channels.
% However ICNA is not taking that into account at the moment, and I
% consider the nominal waveleghts to be the effective wavelengths.
%
% Since this is a matlab file, data is already in variables. Easy peasy!
%
% No effort is currently made in checking whether the file is
% an original UCL Wireless Optical Topography data file. This is simply
% assumed to be true.
%
%% Parameters
%
% filename - The ETG-4000 data file to import
%
%
% 
% Copyright 2016
% @date: 1-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 1-Sep-2016
%
% See also rawData_UCLWireless, convert
%



%% Log
%
% 12-Oct-2013: A step back. The new code "forgot" how to read previous
%   versions of the HITACHI file. This has now been fixed, and different
%   file versions can be read.
%


% Open the data file for conversion
tmpData = load(filename);


% h = waitbar(0,'Reading header...',...
%     'Name','Importing raw data (UCL Wireless)');
%fprintf('Importing raw data (UCL Wireless) -> 0%%');

% Read Measurement information

%Get the wavelengths [nm] at which light is measured
obj=set(obj,'NominalWavelenghtSet',sort(tmpData.nirs_data.wavelength));

%waitbar(0.12,h);
%fprintf('\b\b\b12%%');



% Get the sampling rate in [Hz]
obj=set(obj,'SamplingRate',tmpData.fs);

%x=0.15;
%waitbar(x,h,'Reading Data - 15%');
%fprintf('\b\b\b15%%');

%% Reading the Data ================================

%Get the raw data
theRawData(:,:,1) = tmpData.HBO_raw;
theRawData(:,:,2) = tmpData.HBR_raw;
obj=set(obj,'rawData',theRawData);


%Get the timestamps
obj=set(obj,'timestamps',tmpData.t);


%Get the timeline events
obj=set(obj,'preTimeline',tmpData.e);



clear tmpData

%waitbar(1,h);
%close(h);
%fprintf('\b\b\b100%%\n');

assertInvariants(obj);


end