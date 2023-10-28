function n=getNSources(obj)
%SESSIONDEFINITION/GETNSOURCES DEPRECATED (v1.2). Gets the number of sources of data defined
%
% n=getNSources(obj) Gets the number of sources defined
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getSourceList
%


%% Log
%
% File created: 21-Jul-2008
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


warning('ICNNA:subject:getNSources:Deprecated',...
        'Method DEPRECATED (v1.2). Use sessionDefinition.nDataSources instead.'); 
    %Maintain method by now to accept different capitalization though.


%n=length(obj.sources);
n = obj.nDataSources;



end
