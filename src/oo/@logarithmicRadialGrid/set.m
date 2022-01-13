function obj = set(obj,varargin)
%LOGARITHMICRADIALGRID/SET Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%Modifying the image data also adjusts the timeline and the
%integrity status as appropriate.
%
% Copyright 2008
% @date: 15-Aug-2008
% @author Felipe Orihuela-Espina
%
% See also grid, get
%

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    switch prop
      case 'MinimumRadius'
        if (isscalar(val) && isreal(val) && ~ischar(val) ...
             && (val>0))
            obj.minR = val;
        else
            error('ICNA:logarithmicRadialGrid:set:InvalidPropertyValue',...
                  'Value must be a positive integer.');
        end

      case 'MaximumRadius'
        if (isscalar(val) && isreal(val) && ~ischar(val) ...
             && (val>0))
            obj.maxR = val;
        else
            error('ICNA:logarithmicRadialGrid:set:InvalidPropertyValue',...
                  'Value must be a positive integer.');
        end

      case 'NRings'
        if (isscalar(val) && isreal(val) && ~ischar(val) ...
             && (val==floor(val)) && (val>=0))
            obj.nRings = val;
        else
            error('ICNA:logarithmicRadialGrid:set:InvalidPropertyValue',...
                  'Value must be a positive integer.');
        end

      case 'NAngles'
        if (isscalar(val) && isreal(val) && ~ischar(val) ...
             && (val==floor(val)) && (val>=0))
            obj.nAngles = val;
        else
            error('ICNA:logarithmicRadialGrid:set:InvalidPropertyValue',...
                  'Value must be a positive integer.');
        end

      otherwise
            obj=set@menaGrid(obj,prop,val);
    end
end
assertInvariants(obj);