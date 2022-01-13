function val = get(obj, propName)
% SUBJECT/GET Get properties from the specified object
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
% Copyright 2008
% @date: 16-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also subject, set
%

switch propName
case 'ID'
   val = obj.id;
case 'Name'
   val = obj.name;
case 'Age'
   val = obj.age;
case 'Sex'
   val = obj.sex;
case 'Hand'
   val = obj.hand;
otherwise
   error([propName,' is not a valid property'])
end