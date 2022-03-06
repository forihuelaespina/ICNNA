function val = get(obj, propName)
% ROI/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
%
% 'ID' - A numeric identifier
% 'Name' - ROI's name
% 'Area' - Cumulative area across all subregions
%
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also roi, set
%
%

%% Log
%
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 13-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the roi class.
%   + We create a dependent property inside of the roi class 
%
     %val = obj.(lower(propName)); %Ignore case
     
     tmp = lower(propName);
    
    switch (tmp)
        
           case 'id'
                val = obj.id;
           case 'name'
                val = obj.name;
           case 'area'
                val = obj.area;
        
        otherwise 
            error([propName,' is not a valid property'])
    end
end