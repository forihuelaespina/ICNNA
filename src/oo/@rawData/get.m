function val = get(obj, propName)
% RAWDATA/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
%
% 'Description' - Changes the description of the object
% 'Date' - Changes the date associated with the object.
%
%
% Copyright 2008
% @date: 12-May-2008
% @author Felipe Orihuela-Espina
%
% See also rawData, set
%

switch propName
case 'ID'
   val = obj.id;
case 'Description'
   val = obj.description;
case 'Date'
   val = obj.date;
otherwise
   error([propName,' is not a valid property'])
end