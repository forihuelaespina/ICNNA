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
% Copyright 2018-23
% @author: Felipe Orihuela-Espina
%
% See also rawData_NIRScout
%



%% Log
%
% File created: 4-Apr-2008
% File last modified (before creation of this log): 25-Apr-2012
%
% 4/25-Apr-2018: FOE. Method created
%
% 13-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%


%assertInvariants@rawData(obj);

assert(all(size(obj.gains)==[obj.nSources, obj.nDetectors]),...
	  'Size of gains mismatches existing number of sources and detectors combinations.');

assert(all(size(obj.sdKey)==[obj.nSources, obj.nDetectors]),...
	  'Size of keys mismatches existing number of sources and detectors combinations.');

assert(all(size(obj.sdMask)==[obj.nSources, obj.nDetectors]),...
	  'Size of mask mismatches existing number of sources and detectors combinations.');

assert(numel(obj.channelDistances)==obj.nChannels,...
	  'Number of channels distances does not match the number of channels.');


end