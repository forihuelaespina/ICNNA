function val = get(obj, propName)
% SESSION/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
%
% 'Definition' - Session definition
% 'Date' - Date
%
% == Extracted from the sessionDefinition
% 'ID' - The session ID
% 'Name' - The session name
% 'Description' - The session description
%
% Copyright 2008-12
% @date: 12-May-2008
% @author Felipe Orihuela-Espina
% @modified: 12-Jun-2012
%
% See also session, set
%

switch lower(propName)
case 'definition'
   val = obj.definition;
case 'date'
   val = obj.date;

%From the definition
case 'id'
   val = get(obj.definition,'ID');
case 'name'
   val = get(obj.definition,'Name');
case 'description'
   val = get(obj.definition,'Description');
        
otherwise
   error([propName,' is not a valid property'])
end