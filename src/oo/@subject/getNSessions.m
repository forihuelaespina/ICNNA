function n=getNSessions(obj)
%SUBJECT/GETNSESSIONS DEPRECATED (v1.2). Gets the number of sessions defined in the subject
%
% n=getNSessions(obj) Gets the number of sessions defined in the subject
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also findSession
%


%% Log
%
% File created: 25-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED (v1.2).
%


warning('ICNNA:subject:getNSessions:Deprecated',...
        ['Method DEPRECATED (v1.2). Use subject.nSessions instead.']); 
    %Maintain method by now to accept different capitalization though.


%n=length(obj.sessions);
n = obj.nSessions;

end
