function val = getStream(obj, k)
% RAWDATA_LSL/GETSTREAM Get the k-th stream from the raw data
%
% theStream = get(obj, k) Gets the k-th stream from the raw data
%
%
%% Input parameters
%
% k - The index to the desired stream in the raw data property.
%
%
%% Output parameters
%
% theStream - A LSL-like struct with 1 stream of data. Each stream
%   of data contains three fields:
%       .info - All metadata of the stream including channel types and names.
%           For a more detailed description see method import.
%       .time_series - An <nChannels x nSamples> matrix with the data
%           in the format indicated by .info.channel_format. The number of
%           channels should match the value in .info.channel_count
%       .time_series - An <1 x nSamples> matrix with the timestamps of the
%           samples in double precision.
%
%
% Copyright 2013-2018
% @date: 23-Aug-2021
% @author: Felipe Orihuela-Espina
%
% See also rawData.get, set
%





%% Log
%
% 23-Aug-2021 (FOE): 
%	File created.
%       
%


val = obj.data{k};

end