function s=getRawData(obj)
%DATASOURCE/GETRAWDATA Gets the raw data
%
% s=getRawData(obj) gets the raw data or an empty matrix
%   if no raw data has been defined.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also setRawData
%


%% Log
%
% File created: 20-Jun-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 23-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to update get/set methods for struct like access
%



%s=get(obj,'RawData');
s=obj.rawData;

end
