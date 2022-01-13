function assertInvariants(obj)
%RAWDATA_UCLWIRELESS/ASSERTINVARIANTS Ensures the class invariants are met
%
% assertInvariants(obj) Asserts the invariants
%
%% Invariants
%
%   Invariant: The size (number of samples and number of channels) of raw
%       data samples for oxy matches size of raw data samples for deoxy
%           all(size(obj.oxyRawData)==size(obj.deoxyRawData))
%
%
%
%
%
% Copyright 2012-2016
% Copyright 2016
% @date: 1-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 1-Sep-2016
%
% See also rawData_UCLWireless
%



%assertInvariants@rawData(obj);

assert(all(size(obj.oxyRawData)==size(obj.deoxyRawData)),...
	  'Size of oxy and deoxy raw data mismatch.');

end