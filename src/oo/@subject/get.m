function val = get(obj, propName)
% SUBJECT/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
%
% 'ID' - A numeric identifier
% 'Name' - Subject's name
% 'Age' - Subject's age
% 'Sex' - Subject's sex. 'M'ale/'F'emale/'U'nknown
% 'Hand' - Subject's handedness. 'R'ight/'L'eft/'A'mbidextroux/'U'nknown
%
%
% Copyright 2008
% @date: 16-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also subject, set
%

%% Log
%
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 31-January-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the subject class.
%
   %val = obj.(lower(propName)); %Ignore case
   
   tmp = lower(propName);
    
    switch (tmp)

            case 'age'
                val = obj.age;
            case 'hand'
                val = obj.hand;
            case 'id'
                val = obj.id;  
            case 'name'
                val = obj.name;
            case 'sex'
                val = obj.sex;

        otherwise 
            error([propName,' is not a valid property'])
    end
end