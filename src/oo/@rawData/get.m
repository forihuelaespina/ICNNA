function val = get(obj, propName)
% RAWDATA/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
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
% See also rawData, set
%

%% Log
%
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 17-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the rawData class.
%
    val = obj.(lower(propName)); %Ignore case
end