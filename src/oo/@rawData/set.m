function obj = set(obj,varargin)
% RAWDATA/SET Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
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
% See also rawData, get

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
    case 'Description'
        if (ischar(val))
            obj.description = val;
        else
            error('ICNA:rawData:set:Description',...
                  'Value must be a string');
        end

    case 'Date'
      obj.date=val;

    otherwise
      error('ICNA:rawData:set',...
            ['Property ' prop ' not valid.'])
   end
end