function val = get(obj, propName)
% DATASOURCEDEFINITION/GET DEPRECATED (v1.2). Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also dataSourceDefinition, set
%



%% Log
%
% File created: 21-Jul-2008
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

warning('ICNNA:dataSourceDefinition:get:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for accessing the attribute ' ...
         'e.g. dataSourceDefinition.' lower(propName) '.']); 
    %Maintain method by now to accept different capitalization though.


switch lower(propName)
case 'id'
   val = obj.id;
case 'type'
   val = obj.type;
case 'devicenumber'
   val = obj.deviceNumber;
otherwise
   error('ICNNA:dataSourceDefinition:get:InvalidProperty',...
        [propName,' not found.'])
end


end