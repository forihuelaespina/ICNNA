function assertInvariants(obj)
%IMAGEPARTITION/ASSERTINVARIANTS Ensures the invariants of the class is met
%
% assertInvariants(obj) Asserts the invariants
%
%% Invariants
%
%   Invariant: For all ROI r, their ID is different
%       r(i).ID~=r(j).ID
%
%
% Copyright 2008
% date: 22-Dec-2008
% Author: Felipe Orihuela-Espina
%
% See also imagePartition, roi
%
nElements=length(obj.rois);
ids=zeros(1,nElements);
%Collect IDs
for ii=1:nElements
    ids(ii)=get(obj.rois{ii},'ID');
end
%And check that there are no repetitions
assert(length(ids)==length(unique(ids)), ...
         'ICNA:imagePartition:assertInvariants: Repeated session IDs.');
