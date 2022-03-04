function val = get(obj, propName)
% SESSION/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
%
% 'Definition' - Session definition
% 'Date' - Date
%
% == Extracted from the sessionDefinition
% 'ID' - The session ID
% 'Name' - The session name
% 'Description' - The session description
%
% Copyright 2008-12
% @date: 12-May-2008
% @author Felipe Orihuela-Espina
% @modified: 12-Jun-2012
%
% See also session, set
%
%% Log
%
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 15-February-2022 (ESR): We simplify the code
%   + All cases are inside the session class in the Set/Get methods.
%

    %val = obj.(lower(propName)); %Ignore case
    
     tmp = lower(propName);
    
    switch (tmp)

           case 'definition'
                val = obj.definition;
           case 'date'
                val = obj.date;
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