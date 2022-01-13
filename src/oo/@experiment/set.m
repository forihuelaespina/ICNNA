function obj = set(obj,varargin)
% EXPERIMENT/SET Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%----------------
% The properties
%----------------
% * 'Name' - A string with the experiment name
% * 'Descrition' - A string with the experiment
%           description
% * 'Date' - A date string
%
%
%
% Copyright 2008
% @date: 16-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also experiment, get
%

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
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

    case 'Date'
      obj.date=val;

    otherwise
      error(['Property ' prop ' not valid.'])
   end
end
assertInvariants(obj);