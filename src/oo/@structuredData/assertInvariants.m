function assertInvariants(obj)
%STRUCTUREDDATA/ASSERTINVARIANTS Ensures the class invariants are met
%
% assertInvariants(obj) Asserts the invariants
%
%% Invariants
%
%   Invariant: The length of the timeline is equal to
%       the number of temporal elements (time samples).
%
%   Invariant: Number of integrity elements matches
%       the number of spatial elements (picture elements).
%
%   Invariant: The number of signal tags matches the number
%       of signals present in the data.
%
% Copyright 2008
% date: 27-Apr-2008
% Author: Felipe Orihuela-Espina
%
% See also structuredData
%


tlength=get(obj.timeline,'Length');
dlength=size(obj.data,1);
assert(tlength==dlength,...
	['Length of the timeline does not correspond ' ...
     'the number of time samples']);
 
tlength=getNElements(obj.integrity);
dlength=get(obj,'NChannels');
assert(tlength==dlength,...
	['Number of integrity elements does not correspond ' ...
     'to the number of channels']);

tlength=length(obj.signalTags);
dlength=get(obj,'NSignals');
assert(tlength==dlength,...
	['Number of signal tags does not correspond ' ...
     'to the number of signals in the data']);

