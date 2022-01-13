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

switch propName
case 'ID'
   val = obj.id;
case 'Name'
   val = obj.name;
case 'Area'
   val = obj.area;
otherwise
   error([propName,' is not a valid property'])
end