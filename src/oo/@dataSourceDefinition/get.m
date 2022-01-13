function val = get(obj, propName)
% DATASOURCEDEFINITION/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also dataSourceDefinition, set
%

switch propName
case 'ID'
   val = obj.id;
case 'Type'
   val = obj.type;
case 'DeviceNumber'
   val = obj.deviceNumber;
otherwise
   error([propName,' is not a valid property'])
end