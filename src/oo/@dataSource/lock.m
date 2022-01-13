function obj=lock(obj)
% DATASOURCE/LOCK Locks raw and processed data
%
% obj=lock(obj) Locks raw data and processed data so that processed
%   data are derived from the raw data only.
%
%
% Copyright 2008-10
% @date: 13-May-2008
% @author Felipe Orihuela-Espina
% @modified: 16-Sep-2010
%
% See also isLock, get, unlock
%

obj=set(obj,'Lock',true);