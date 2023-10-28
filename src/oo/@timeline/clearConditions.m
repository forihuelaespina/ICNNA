function obj=clearConditions(obj)
% SUBJECT/CLEARCONDITIONS Removes all existing conditions (and their events) from the timeline
%
% obj=clearConditions(obj) Removes all existing conditions (and their events) from the timeline.
%
% Copyright 2023
% @author Felipe Orihuela-Espina
%
% See also addSession, setSession, removeSession
%




%% Log
%
% 13-May-2023: FOE
%   + Method created
%       Incredible as it is, I did not have this method defined before!
%



obj.conditions=cell(1,0);
obj.exclusory=zeros(0,0);
assertInvariants(obj);


end