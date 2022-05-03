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

%% Log
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 20-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the logarithmicRadialGrid class.
%
% 24-March-2022 (ESR): Lowercase
%   + These cases are to convert the capitalization to lower case so that 
%   they can all be called correctly.
%

propertyArgIn = varargin;
while (length(propertyArgIn) >= 2)
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);

   tmp = lower(prop);
    
    switch (tmp)

        case 'minimumradius'
                obj.minR = val;
           case 'maximumradius'
                obj.maxR = val;
           case 'nangles'
                obj.nAngles = val;
           case 'nrings'
                obj.nRings = val;  
          
        otherwise
            obj=set@menaGrid(obj,prop,val);
    end
end
    assertInvariants(obj);
end
