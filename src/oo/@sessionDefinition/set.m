function obj = set(obj,varargin)
% SESSIONDEFINITION/SET DEPRECATED. Set object properties and return the updated object
%
% obj = set(obj,'PropertyName',propertyValue) Set object properties and
%   return the updated object
%
%% Properties
%
% 'ID' - The object's numeric identifier
% 'Name' - A name
% 'Description' - A short description
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also sessionDefinition, get
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
%   + Added error codes.
%



warning('ICNNA:sessionDefinition:set:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for setting the attribute ' ...
         'e.g. sessionDefinition.' lower(varargin{1}) ' = ... ']); 


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
        %     error('ICNNA:sessionDefinition:set:InvalidParameterValue',...
        %           'Value must be a scalar natural/integer');
        % end
 
    case 'name'
        obj.name = val;
        % if (ischar(val))
        %     obj.name = val;
        % else
        %     error('ICNNA:sessionDefinition:set:InvalidParameterValue',...
        %           'Value must be a string');
        % end

    case 'description'
        obj.description = val;
        % if (ischar(val))
        %     obj.description = val;
        % else
        %     error('ICNNA:sessionDefinition:set:InvalidParameterValue',...
        %           'Value must be a string');
        % end

    otherwise
      error('ICNNA:sessionDefinition:set:InvalidProperty',...
            ['Property ' prop ' not found.'])
   end
end



end