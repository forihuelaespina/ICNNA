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

switch propName
case 'MinimumRadius'
   val = obj.minR;
case 'MaximumRadius'
   val = obj.maxR;
case 'NRings'
   val = obj.nRings;
case 'NAngles'
   val = obj.nAngles;
otherwise
   val = get@menaGrid(obj, propName);
end