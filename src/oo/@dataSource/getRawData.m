function s=getRawData(obj)
%DATASOURCE/GETRAWDATA Gets the raw data
%
% s=getRawData(obj) gets the raw data or an empty matrix
%   if no raw data has been defined.
%
% Copyright 2008
% @date: 20-Jun-2008
% @author Felipe Orihuela-Espina
%
% See also setRawData
%

s=get(obj,'RawData');
