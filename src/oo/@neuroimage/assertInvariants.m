function assertInvariants(obj)
%NEUROIMAGE/ASSERTINVARIANTS Ensures the class invariants are met
%
% assertInvariants(obj) Asserts the invariants
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
%   Invariant: The number of channels in the channelLocationMap
%       matches the number of channels in the data.
%           get(obj.chLocationMap,'nChannels')==get(obj,'nChannels')
%
%
% Copyright 2012-23
% @author: Felipe Orihuela-Espina
%
% See also neuroimage
%


%% Log
%
%
% File created: 22-Dec-2012
% File last modified (before creation of this log): N/A. This method
%   had not been updated since creation.
%
% 20-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%
% 21-May-2023: FOE
%   + Some class invariants have been relaxed to warnings or removed.
%   + Added missing error codes.
%   + Improved some comments.
%



assertInvariants@structuredData(obj);

tmp = obj.chLocationMap;
assert(tmp.nChannels == obj.nChannels,...
	 ['ICNNA:neuroimage:assertInvariants:InvariantViolation ' ...
      'Defined number of channel locations mismatches the ' ...
      'existing number of channels.']);

end