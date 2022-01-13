function obj=clearRawData(obj)
% DATASOURCE/CLEARRAWDATA Deletes the raw data if exist
%
% obj=clearRawData(obj) Deletes the raw data if exist.
%
%   #===========================================================#
%   | If dataSource is lock, all existing structured data       |
%   | will also be removed!!                                    |
%   #===========================================================#
%
%
% Copyright 2008
% @date: 13-Jun-2008
% @author Felipe Orihuela-Espina
%
% See also assertInvariants, setRawData, clearStructuredData
%

obj.rawData=[];
if (obj.lock)
    obj=clearStructuredData(obj);
end
assertInvariants(obj);