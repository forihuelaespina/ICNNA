function obj=import(obj,filename)
%RAWDATA_LSL/IMPORT Reads the Lab Streaming Layer (LSL) data
%
% obj=import(obj,filename) Reads the LSL data recorded in
%   a .xdf file generated using the LSL protocol.
%
% The LSL data file is a .xdf plain text file. The specification
%for the XDF files can be found here:
%
% https://github.com/sccn/xdf/wiki/Specifications
%
% and a standard importer load_xdf can be found at
%
% https://github.com/sccn/xdf
% 
% The importer will load a cell array with 1 cell per data stream. Each
%data stream is stored as a struct with 3 fields:
%
%   .info - All metadata of the stream including channel types and names.
%       In turn, this is a struct with many fields. Some relevant ones
%       are:
%       .name - String. The stream name e.g. 'gaze_position_3d'
%       .type - String. The stream type e.g. 'eye_tracker'
%       .channel_count - String but contains a number e.g. '5'
%           This is the number of channels in main field .time_series
%       .channel_format - String. The data format for main field .time_series
%       .desc - Struct. It includes at least the following fields:
%           .channels - Struct. It includes at least the following fields:
%               .channel - Cell array sized <1xnChannels>. Each cell is
%                   a struct that includes at least the fields:
%                   .name - The channel name
%                   .unit - The unit in which the time_series is encoded
%                   .type - The channel type .e.g. 'marker'
%       .session_id - String. A session identifier.
%       .first_timestamp - String but contains a number. The first
%           timestamp. Should coincide with .time_stamps(1)
%       .last_timestamp - String but contains a number. The first
%           timestamp. Should coincide with .time_stamps(end)
%   .time_series - An <nChannels x nSamples> matrix with the data
%       in the format indicated by .info.channel_format. The number of
%       channels should match the value in .info.channel_count
%   .time_series - An <1 x nSamples> matrix with the timestamps of the
%       samples in double precision.
% 
%
%
%
%% Remarks
%
% No effort is currently made in checking whether the file is
% an original LSL data file. This is simply assumed to be true.
%
%% Parameters
%
% filename - A LSL data file to import
%
% 
% Copyright 2021
% @date: 23-Aug-2021
% @author: Felipe Orihuela-Espina
%
%
% See also import, convert
%




%% Log
%
% 23-Aug-2021 (FOE): 
%	File created.
%

%Delegate in standard importer load_xdf
obj.data = load_xdf(filename);
end


