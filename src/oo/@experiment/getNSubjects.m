function n=getNSubjects(obj)
%EXPERIMENT/GETNSUBJECTS DEPRECATED. Gets the number of subjects
%
% n=getNSubjects(obj) Gets the number of subjects defined in the
%       experiment dataset
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getSubjectList
%


%% Log
%
% File created: 16-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%


warning('ICNNA:experiment:getNSubjects:Deprecated',...
        ['Method DEPRECATED (v1.2). Use experiment.nSubjects instead.']); 
    %Maintain method by now to accept different capitalization though.


%n=length(obj.subjects);
n = obj.nSubjects;

end