function val = get(obj, propName)
% SESSIONDEFINITION/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
%
% 'ID' - The object's numeric identifier
% 'Name' - A name
% 'Description' - A short description
%
% Copyright 2008
% @date: 10-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also sessionDefinition, set
%

%% Log
%
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 13-February-2022 (ESR): We simplify the code
%   + All cases are in the sessionDefinition class.
%

    %val = obj.(lower(propName)); %Ignore case
    
     tmp = lower(propName);
    
    switch (tmp)

           case 'description'
                val = obj.description;
           case 'id'
                val = obj.id;  
           case 'name'
                val = obj.name;  
        
        otherwise 
            error([propName,' is not a valid property'])
    end

end