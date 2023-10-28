function val = get(obj, propName)
% SESSIONDEFINITION/GET DEPRECATED. Get properties from the specified object
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



%% Log
%
% File created: 10-Jul-2008
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

warning('ICNNA:sessionDefinition:get:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for accessing the attribute ' ...
         'e.g. sessionDefinition.' lower(propName) '.']); 
    %Maintain method by now to accept different capitalization though.


switch lower(propName)
case 'id'
   val = obj.id;
case 'name'
   val = obj.name;
case 'description'
   val = obj.description;
otherwise
   error([propName,' is not a valid property'])
end



end