function assertInvariants(obj)
%ANALYSIS/ASSERTINVARIANTS Ensures the invariants are met
%
% assertInvariants(obj) Asserts the invariants
%
%% INVARIANTS
%
%   Invariant: For all clusters c, their ID is different
%       c(i).ID~=c(j).ID
%
%   Invariant: At all moments the number of patterns is unique
%       and therefore:
%           size(H,1) == size(I,1)
%
%
%   Invariant: The projection space is either empty or has the
%       same number of patterns than the analysis (depending
%       on whether the analysis has been run or not.
%           if runStatus==true => (size(H,1) == size(Y,1))
%           if runStatus==false => ((0 == size(Y,1))
%
%   Invariant: if runStatus==true then size(Y,2)==projectionDimensionality
%
%   Invariant: The matrix of pairwiase distances is either empty or
%       has the same number of patterns than the analysis (depending
%       on whether the analysis has been run or not).
%           if runStatus==true => (size(H,1) == size(D,1))
%           if runStatus==false => ((0 == size(D,1))
%
%   Invariant: At all moments, the matrix of pairwise distances
%       is square
%           size(D,1)==size(D,2)
%
%   Invariant: If the experimentSpace has not been computed, then
%       the runStatus must be false.
%
%
% Copyright 2008-9
% date: 26-May-2008
% Author: Felipe Orihuela-Espina
%
% See also analysis
%
%

nElements=length(obj.clusters);
ids=zeros(1,nElements);
%Collect IDs
for ii=1:nElements
    ids(ii)=get(obj.clusters{ii},'ID');
end
%And check that there are no repetitions
assert(length(ids)==length(unique(ids)), ...
        'analysis.assertInvariants: Repeated cluster IDs.');

%Number of patters must be unique
assert((size(obj.H,1) == size(obj.I,1)), ...
        'analysis.assertInvariants: Number of patterns not unique');
    
%projection space is either empty or has the
%same number of patterns than the analysis (depending
%on whether the analysis has been embedded or not).
if (obj.runStatus)
assert(size(obj.H,1) == size(obj.Y,1), ...
        ['analysis.assertInvariants: Mismatch number of ' ...
         'patterns between Feature Space and Projection Space.']);
else
assert(0 == size(obj.Y,1), ...
        ['analysis.assertInvariants: Mismatch number of ' ...
         'patterns between Feature Space and Projection Space.']);
end

%Matrix of pairwise distances is either empty or has the
%same number of patterns than the analysis (depending
%on whether the analysis has been embedded or not).

assert(size(obj.D,1) == size(obj.D,2), ...
        ['analysis.assertInvariants: Matrix ' ...
         'of pairwise distances is not square.']);

if (obj.runStatus)
assert(size(obj.H,1) == size(obj.D,1), ...
        ['analysis.assertInvariants: Mismatch number of ' ...
         'patterns between Feature Space and the matrix ' ...
         'of pairwise distances.']);
else
assert(0 == size(obj.D,1), ...
        ['analysis.assertInvariants: Mismatch number of ' ...
         'patterns between Feature Space and the matrix ' ...
         'of pairwise distances.']);
end

%Projection dimensionality
if (obj.runStatus)
    assert(size(obj.Y,2)==obj.projectionDimensionality,...
            'analysis.assertInvariants: Corrupt projection dimensionality.');
end

%Run Status is coherent with computed status of the Experiment Space
if get(obj.F,'RunStatus')
    assert(obj.runStatus,...
        'analysis.assertInvariants: Analysis run status is corrupt.');
end