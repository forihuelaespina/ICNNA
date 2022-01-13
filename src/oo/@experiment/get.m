function val = get(obj, propName)
% EXPERIMENT/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
% Copyright 2008
% @date: 16-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also experiment
%

switch propName
case 'Name'
   val = obj.name;
case 'Description'
   val = obj.description;
case 'Version'
   val = obj.version;
case 'Date'
   val = obj.date;
case 'Dataset'
   val = obj.dataset;
otherwise
   error([propName,' is not a valid property'])
end