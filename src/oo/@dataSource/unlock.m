function obj=unlock(obj)
% DATASOURCE/UNLOCK Unlocks raw and processed data
%
% obj=unlock(obj) Unlocks raw data and processed data.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also isLock, set, get, lock
%



%% Log
%
% File created: 13-May-2008
% File last modified (before creation of this log): 16-Sep-2010
%
% 23-May-2023: FOE
%   + Added this log. Got rid of old labeld @date and @modified.
%   + Started to use get/set methods for struct like access.
%

obj.lock = false;

end
