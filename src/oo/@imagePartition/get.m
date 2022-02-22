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

%% Log
%
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 20-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the imagePartition class.
%   + We create a dependent property inside of the imagePartition class 
%
%
     val = obj.(lower(propName)); %Ignore case
end