function obj = set(obj,varargin)
% DATASOURCE/SET Set object properties and return the updated object
%
% Copyright 2008
% @date: 12-May-2008
% @author Felipe Orihuela-Espina
%
% See also get
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
            %e.g. will pass all of the above (except the ~ischar)
            obj.id = val;
        else
            error('Value must be a positive scalar natural/integer');
        end
 
    case 'Name'
        if (ischar(val))
            obj.name = val;
        else
            error('Value must be a string');
        end

    case 'DeviceNumber'
        if (isscalar(val) && isreal(val) && ~ischar(val) ...
            && (val==floor(val)) && (val>0))
            %Note that a char which can be converted to scalar
            %e.g. will pass all of the above (except the ~ischar)
            obj.deviceNumber = val;
        else
            error('Value must be a positive scalar natural/integer');
        end
 
    case 'Lock'
        obj.lock=true;
        if (~val) obj.lock=false; end

    case 'ActiveStructured'
        if (isscalar(val) && (val==floor(val)) ...
                && (val>0) && (val<=length(obj.structured)) ...
                && ismember(val,getStructuredDataList(obj)))
            obj.activeStructured = val;
        else
            error('Value must be a positive integer');
        end
 

    otherwise
      error(['Property ' prop ' not valid.'])
   end
end
assertInvariants(obj);