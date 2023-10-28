function obj = set(obj,varargin)
% DATASOURCEDEFINITION/SET DEPRECATED (v1.2). Set object properties and return the updated object
%
% obj = set(obj,'PropertyName',propertyValue) Set object properties and
%   return the updated object.
%
% 
%% Properties
%
% 'ID' - The object's numeric identifier
% 'Type' - The type of the dataSource. See attribute 'Type'
%       on dataSource.
% 'Description' - A short description
%
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also dataSourceDefinition, get
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
%   + Declare method as DEPRECATED (v1.2).
%   + Improved comments.
%   Bug fixing
%   + 1 error was not using error codes yet.
%



warning('ICNNA:dataSourceDefinition:set:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for setting the attribute ' ...
         'e.g. dataSourceDefinition.' lower(varargin{1}) ' = ... ']); 



propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch lower(prop)
    case 'id'
        obj.id = val;
        % if (isscalar(val) && isreal(val) && ~ischar(val) ...
        %     && (val==floor(val)) && (val>0))
        %     %Note that a char which can be converted to scalar
        %     %e.g. will pass all of the above (except the ~ischar
        %     obj.id = val;
        % else
        %     error('Value must be a positive scalar natural/integer');
        % end
 
    case 'type'
        obj.type = val;
        % if (ischar(val))
        %     obj.type = val;
        % else
        %     error('Value must be a string');
        % end

       case 'devicenumber'
        obj.deviceNumber = val;
        % if (isscalar(val) && isreal(val) && ~ischar(val) ...
        %     && (val==floor(val)) && (val>0))
        %     %Note that a char which can be converted to scalar
        %     %e.g. will pass all of the above (except the ~ischar
        %     obj.deviceNumber = val;
        % else
        %     error('Value must be a positive scalar natural/integer');
        % end

    otherwise
      error('ICNNA:dataSourceDefinition:set:InvalidProperty',...
           ['Property ' prop ' not valid.'])
   end
end