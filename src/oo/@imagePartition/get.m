function val = get(obj, propName)
% IMAGEPARTITION/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
%
% 'ID' - A numeric identifier
% 'Name' - Image Partition's name
% 'Size' - Size of the image as a pair [width height] in pixels
% 'Width' - Width of the image. This is the first element
%       of the size.
% 'Height' - Height of the image. This is the second element
%       of the size.
% 'ScreenResolution' - Screen resolution [width height] in pixels
% 'AssociatedFile' - Name of the associated image file
%
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also imagePartition, set
%

switch propName
case 'ID'
   val = obj.id;
case 'Name'
   val = obj.name;
case 'Size'
   val = obj.size;
case 'Width'
   val = obj.size(1);
case 'Height'
   val = obj.size(2);
case 'ScreenResolution'
   val = obj.screenResolution;
case 'AssociatedFile'
   val = obj.associatedFile;
otherwise
   error([propName,' is not a valid property'])
end