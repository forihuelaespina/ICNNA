function val = get(obj, propName)
% LOGARITHMICRADIALGRID/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
%
% 'MinimumRadius' - The external radius of the central region
% 'MaximusRadius' - The extrenal radius of the outermost region
% 'NRings' - Number of rings in the grid
% 'NAngles' - Number of angular regions in the grid
%
%
% Copyright 2008
% @date: 15-Aug-2008
% @author Felipe Orihuela-Espina
%
% See also grid.get
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
%   + We simplify the code. All cases are in the lagarithmicRadialGrid class.
%
    val = obj.(lower(propName)); %Ignore case
end