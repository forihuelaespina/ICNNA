function obj = set(obj,varargin)
% ROI/SET Set object properties and return the updated object
%
% obj = set(obj,'PropertyName',propertyValue)
%
%% Properties
%
% 'ID' - A numeric identifier
% 'Name' - ROI's name
%
%
%
% Copyright 2008
% @date: 22-Dec-2008
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
            error('ICNA:ROI:set:InvalidPropertyValue',...
                  'Value must be a positive integer.');
        end
 
    case 'Name'
        if (ischar(val))
            obj.name = val;
        else
            error('ICNA:ROI:set:InvalidPropertyValue',...
                  'Value must be a string.');
        end

    otherwise
      error('ICNA:ROI:set:InvalidPropertyName',...
            ['Property ' prop ' not valid.'])
   end
end