function assertInvariants(obj)
%LOGARITHMICRADIALGRID/ASSERTINVARIANTS Ensures the class invariants are met
%
% assertInvariants(obj) Asserts the invariants
%
%% Invariants
%
%   Invariant: minR < maxR
%
%   Invariant: nRings>=0 && nAngles>=0
%
% Copyright 2008
% date: 15-Aug-2008
% Author: Felipe Orihuela-Espina
%
% See also logarithmicRadialGrid, grid
%


assert(obj.minR<obj.maxR,...
	 'Minimum radius must be smaller than maximus radius.');
 
assert(obj.nRings>=0,...
	 'Minimum number of radius must be greater or equal to 0.');
assert(obj.nAngles>=1,...
	 'Minimum number of angles must be greater or equal to 0.');
