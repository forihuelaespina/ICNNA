function obj=unlock(obj)
% DATASOURCE/UNLOCK Unlocks raw and processed data
%
% obj=unlock(obj) Unlocks raw data and processed data.
%
%
% Copyright 2008-10
% @date: 13-May-2008
% @author Felipe Orihuela-Espina
% @modified: 16-Sep-2010
%
% See also isLock, set, get, lock
%

obj=set(obj,'Lock',false);
