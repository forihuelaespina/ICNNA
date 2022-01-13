function assertInvariants(obj)
%RAWDATA_NIRScout/ASSERTINVARIANTS Ensures the class invariants are met
%
% assertInvariants(obj) Asserts the invariants
%
%% Invariants
%
%   Invariant: The size of gains matches existing number of sources
%       and detectors combinations.
%           all(size(obj.gains)==[obj.nSources, obj.nDetectors]
%
%   Invariant: The size of keys matches existing number of sources
%       and detectors combinations.
%           all(size(obj.sdKey)==[obj.nSources, obj.nDetectors]
%
%   Invariant: The size of mask matches existing number of sources
%       and detectors combinations.
%           all(size(obj.sdMask)==[obj.nSources, obj.nDetectors]
%
%   Invariant: The number of channels distances matches the number
%       of channels.
%           numel(obj.channelDistances)==get(obj,'nChannels')
%
%
%
%
%
%
% Copyright 2018
% @date: 4-Apr-2018
% @author: Felipe Orihuela-Espina
% @modified: 25-Apr-2018
%
% See also rawData_NIRScout
%



%% Log
%
% 4/25-Apr-2018: FOE. Method created
%
%


%assertInvariants@rawData(obj);

assert(all(size(obj.gains)==[obj.nSources, obj.nDetectors]),...
	  'Size of gains mismatches existing number of sources and detectors combinations.');

assert(all(size(obj.sdKey)==[obj.nSources, obj.nDetectors]),...
	  'Size of keys mismatches existing number of sources and detectors combinations.');

assert(all(size(obj.sdMask)==[obj.nSources, obj.nDetectors]),...
	  'Size of mask mismatches existing number of sources and detectors combinations.');

assert(numel(obj.channelDistances)==get(obj,'nChannels'),...
	  'Number of channels distances does not match the number of channels.');


end