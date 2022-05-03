function obj = set(obj,varargin)
% IMAGEPARTITION/SET Set object properties and return the updated object
%
% obj = set(obj,'PropertyName',propertyValue)
%
%% Properties
%
% 'ID' - A numeric identifier
% 'Name' - ImagePartition's name
% 'Size' - Size of the image as a pair [width height] in pixels
% 'Width' - Width of the image. This is the first element
%       of the size.
% 'Height' - Height of the image. This is the second element
%       of the size.
% 'ScreenResolution' - Screen resolution as a pair [width height] in pixels
% 'AssociatedFile' - Name of the associated image file. Updatnig the
%       associated file also updates the image size.
%
%
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also get
%
%% Log
%
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 20-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the imagePartition class.
%   + We create a dependent property inside the imagePartition class.
%   + The Height and Width properties are inside of
%   imagePartition class.
%
% 24-March-2022 (ESR): Lowercase
%   + These cases are to convert the capitalization to lower case so that 
%   they can all be called correctly.
%

propertyArgIn = varargin;
    while (length(propertyArgIn) >= 2)
           prop = propertyArgIn{1};
           val = propertyArgIn{2};
           propertyArgIn = propertyArgIn(3:end);

           tmp = lower(prop);
    
        switch (tmp)

           case 'associatedfile'
                obj.associatedFile = val;
           case 'id'
                 obj.id = val;  
           case 'name'
                obj.name = val;
           case 'screenresolution'
                obj.screenResolution = val;
           case 'size'
                obj.size = val;
           case 'height'
                obj.height = val;
           case 'width'
                obj.width = val;

        otherwise
                error('ICNA:imagePartition:set:InvalidPropertyName',...
                ['Property ' prop ' not valid.'])
        end
    end
end