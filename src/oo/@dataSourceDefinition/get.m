function val = get(obj, propName)
% DATASOURCEDEFINITION/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
% Copyright 2008
% @date: 21-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also dataSourceDefinition, set
%
%% Log
%
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 20-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the dataSourceDefinition class.
%   + We create a dependent property inside of the dataSourceDefinition class 
%
% 24-March-2022 (ESR): Lowercase
%   + These cases are to convert the capitalization to lower case so that 
%   they can all be called correctly.
%
    tmp = lower(propName);
    
    switch (tmp)
        
           case 'id'
                val = obj.id;  
           case 'type'
                val = obj.type;
           case 'devicenumber'
                val = obj.deviceNumber; 
        
        otherwise 
            error([propName,' is not a valid property'])
    end
end