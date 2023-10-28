function val = get(obj, propName)
% SUBJECT/GET  DEPRECATED. Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
%
% 'ID' - A numeric identifier
% 'Name' - Subject's name
% 'Age' - Subject's age
% 'Sex' - Subject's sex. 'M'ale/'F'emale/'U'nknown
% 'Hand' - Subject's handedness. 'R'ight/'L'eft/'A'mbidextroux/'U'nknown
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also subject, set
%



%% Log
%
% File created: 16-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%   Bug fixed:
%   + 1 error was still not using error code.
%

warning('ICNNA:subject:get:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for accessing the attribute ' ...
         'e.g. subject.' lower(propName) '.']); 
    %Maintain method by now to accept different capitalization though.


switch lower(propName)
case 'id'
   val = obj.id;
case 'name'
   val = obj.name;
case 'age'
   val = obj.age;
case 'sex'
   val = obj.sex;
case 'hand'
   val = obj.hand;
otherwise
   error('ICNNA:subject:get:InvalidProperty',...
        [propName,' not found.'])
end



end