function obj = set(obj,varargin)
% DATASOURCEDEFINITION/SET Set object properties and return the updated object
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also dataSourceDefinition, get
%

%% Log
%
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 20-February-2022 (ESR): We simplify the code
%   + All cases are in the dataSourceDefinition class.
%   + We create a dependent property inside the dataSourceDefinition class.
%
% 24-March-2022 (ESR): Lowercase
%   + These cases are to convert the capitalization to lower case so that 
%   they can all be called correctly.


propertyArgIn = varargin;
    while (length(propertyArgIn) >= 2)
       prop = propertyArgIn{1};
       val = propertyArgIn{2};
       propertyArgIn = propertyArgIn(3:end);
       
       tmp = lower(prop);
    
        switch (tmp)

            case 'id'
                obj.id = val;  
           case 'type'
                obj.type = val;
           case 'devicenumber'
                obj.deviceNumber = val; 

            otherwise
                 error(['Property ' prop ' not valid.'])
        end
    end
    
end