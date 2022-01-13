function obj = set(obj,varargin)
% SESSIONDEFINITION/SET Set object properties and return the updated object
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
% Copyright 2008
% @date: 10-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also sessionDefinition, get
%
propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
    case 'ID'
        if (isscalar(val) && isreal(val) && ~ischar(val) ...
            && (val==floor(val)) && (val>0))
            %Note that a char which can be converted to scalar
            %e.g. will pass all of the above (except the ~ischar
            obj.id = val;
        else
            error('Value must be a scalar natural/integer');
        end
 
    case 'Name'
        if (ischar(val))
            obj.name = val;
        else
            error('Value must be a string');
        end

    case 'Description'
        if (ischar(val))
            obj.description = val;
        else
            error('Value must be a string');
        end

    otherwise
      error(['Property ' prop ' not valid.'])
   end
end