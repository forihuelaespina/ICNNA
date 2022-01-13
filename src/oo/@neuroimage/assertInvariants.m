function assertInvariants(obj)
%NEUROIMAGE/ASSERTINVARIANTS Ensures the class invariants are met
%
% assertInvariants(obj) Asserts the invariants
%
%% Invariants
%
%   Invariant: The number of channels in the channelLocationMap
%       matches the number of channels in the data.
%           get(obj.chLocationMap,'nChannels')==get(obj,'nChannels')
%
%
% Copyright 2012
% @date: 22-Dec-2012
% @author: Felipe Orihuela-Espina
% @modified: 22-Dec-2012
%
% See also neuroimage
%


assertInvariants@structuredData(obj);

assert(get(obj.chLocationMap,'nChannels')==get(obj,'nChannels'),...
	 ['Defined number of channel locations mismatches the ' ...
      'existing number of channels.']);
