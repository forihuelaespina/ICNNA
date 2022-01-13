function val = get(obj, propName)
% SESSIONDEFINITION/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
%
% 'ID' - The object's numeric identifier
% 'Name' - A name
% 'Description' - A short description
%
% Copyright 2008
% @date: 10-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also sessionDefinition, set
%

switch propName
case 'ID'
   val = obj.id;
case 'Name'
   val = obj.name;
case 'Description'
   val = obj.description;
otherwise
   error([propName,' is not a valid property'])
end