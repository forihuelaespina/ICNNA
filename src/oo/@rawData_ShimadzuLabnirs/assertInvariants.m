function assertInvariants(obj)
%RAWDATA_SHIMADZULABNIRS/ASSERTINVARIANTS Ensures the class invariants are met
%
% assertInvariants(obj) Asserts the invariants
%
%% Invariants
%
%   Invariant: The size (number of samples) of timestamps matches the
%       size of raw data.
%           all(length(obj.timestamps)==size(obj.rawData,1))
%
%   Invariant: The size (number of samples) of preTimeline samples
%       matches the size of raw data.
%           all(length(obj.preTimeline)==size(obj.rawData,1))
%
%   Invariant: The size (number of samples) of marks samples
%       matches the size of raw data.
%           all(length(obj.marks)==size(obj.rawData,1))
%
%
%
%
%
% Copyright 2016
% @date: 20-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 20-Sep-2016
%
% See also rawData_ShimadzuLabnirs
%



%assertInvariants@rawData(obj);

assert(all(length(obj.timestamps)==size(obj.rawData,1)),...
	  'Number of timestamps mismatches number of samples.');
assert(all(length(obj.preTimeline)==size(obj.rawData,1)),...
	  'Length of timeline flags vector mismatches number of samples.');
assert(all(length(obj.marks)==size(obj.rawData,1)),...
	  'Length of marks vector mismatches number of samples.');


end