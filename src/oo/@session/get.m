function val = get(obj, propName)
% SESSION/GET DEPRECATED (v1.2). Get properties from the specified object
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
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also session, set
%



%% Log
%
% File created: 12-May-2008
% File last modified (before creation of this log): 12-Jun-2012
%
% 24-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Started to update get/set methods for struct like access
%   + Declare method as DEPRECATED (v1.2).
%   Bug fixed:
%   + 1 error was still not using error code.
%

warning('ICNNA:session:get:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for accessing the attribute ' ...
         'e.g. session.' lower(propName) '.']); 
    %Maintain method by now to accept different capitalization though.



switch lower(propName)
case 'definition'
   val = obj.definition;
case 'date'
   val = obj.date;

%From the definition
case 'id'
    tmp = obj.definition;
    val = tmp.id;
case 'name'
    tmp = obj.definition;
    val = tmp.name;
case 'description'
    tmp = obj.definition;
    val = tmp.description;
        
otherwise
   error('ICNNA:session:get:InvalidProperty',...
        [propName,' is not a valid property'])
end


end