function assertInvariants(obj)
%EXPERIMENTSPACE/ASSERTINVARIANTS Ensures the invariants are met
%
% assertInvariants(obj) Asserts the invariants
%
%% Invariants
%
%   Invariant: Number of points in Fvectors and Findex
%       must be coincident.
%
%
%%%NOTE: The following 2 invariants are incorrect. They will not hold
%%%if some sessions do not have any data associated with them
%   Invariant: Length of sessionNames matches number of
%       distinct sessions in Findex(:,experimentSpace.DIM_SESSION)
%
%   Invariant: Identifiers in sessionNames matches
%       distinct sessions in Findex(:,experimentSpace.DIM_SESSION)
%
%
%
%
% Copyright 2008-12
% @date: 20-Apr-2008
% @author: Felipe Orihuela-Espina
% @modified: 11-Nov-2012
%
% See also experimentSpace
%

    
%Number of points in Fvectors (cols) and the number of
%points i Findex (rows) must be coincident.
assert(length(obj.Fvectors)==size(obj.Findex,1),...
        'experimentSpace.assertInvariants: Corrupted number of points.');
    
    
% %Length of sessionNames matches number of
% %distinct sessions in Findex(:,experimentSpace.DIM_SESSION)
% sessions=unique(obj.Findex(:,obj.DIM_SESSION))';
% nSessions=length(obj.sessionNames);
% assert(nSessions==length(sessions),...
%         'experimentSpace.assertInvariants: Corrupted session names.');
% 
% %Identifiers in sessionNames matches
% %distinct sessions in Findex(:,experimentSpace.DIM_SESSION)
% for ss=1:nSessions
%     id=obj.sessionNames(ss).sessID;
%     assert(ismember(id,sessions),...
%         'experimentSpace.assertInvariants: Corrupted session names.');
%     
% end



end
