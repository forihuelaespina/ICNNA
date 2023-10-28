function assertInvariants(obj)
%STRUCTUREDDATA/ASSERTINVARIANTS Ensures the class invariants are met
%
% assertInvariants(obj) Asserts the invariants
%
%
%
%% Remarks
%
%   +=====================================================+
%   | WATCH OUT!!! Because of the limitations of Matlab's |
%   | support with the struct like syntax correct (e.g.   |
%   | for these specific get/set methods, Matlab does not |
%   | support overriding), maintenance of interdependent  |
%   | properties becomes more difficult. This is because  |
%   | it is now not possible to transiently violate       |
%   | postconditions  invariants. Although, there may be  |
%   | ah-doc solutions for some specific invariants which |
%   | have been implemented, but we have not been able to |
%   | solve the problem in general. Hence, from version   |
%   | 1.2, some of ICNNA's traditional hard class         |
%   | invariants have been relaxed and changed from       |
%	| errors into warnings, or simply removed.            |
%   +=====================================================+
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
% Copyright 2008-23
% @author: Felipe Orihuela-Espina
%
% See also structuredData
%




%% Log
%
% File created: 27-Apr-2008
% File last modified (before creation of this log): N/A This method was
%   never updated since creation
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%
% 21-May-2023: FOE
%   + Some class invariants have been relaxed to warnings or removed.
%   + Added missing error codes.
%   + Improved some comments.
%





tlength=obj.timeline.length;
dlength=obj.nSamples;
assert(tlength==dlength,...
	['ICNNA:structuredData:assertInvariants:InvariantViolation ' ...
     'Length of the timeline does not correspond ' ...
     'the number of time samples']);
 
tlength=getNElements(obj.integrity);
dlength=obj.nChannels;
assert(tlength==dlength,...
	['ICNNA:structuredData:assertInvariants:InvariantViolation ' ...
     'Number of integrity elements does not correspond ' ...
     'to the number of channels']);

tlength=length(obj.signalTags);
dlength=obj.nSignals;
assert(tlength==dlength,...
	['ICNNA:structuredData:assertInvariants:InvariantViolation ' ...
     'Number of signal tags does not correspond ' ...
     'to the number of signals in the data']);


end

