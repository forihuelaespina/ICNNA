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
propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
    case 'ID'
        if (isscalar(val) && isreal(val) && ~ischar(val) ...
            && (val==floor(val)) && (val>0))
            %Note that a char which can be converted to scalar
            %e.g. will pass all of the above (except the ~ischar)
            obj.id = val;
        else
            error('ICNA:imagePartition:set:InvalidPropertyValue',...
                  'Value must be a positive integer.');
        end
 
    case 'Name'
        if (ischar(val))
            obj.name = val;
        else
            error('ICNA:imagePartition:set:InvalidPropertyValue',...
                  'Value must be a string.');
        end

    case 'Size'
        if (numel(val)==2  && ~ischar(val) ...
             && all(val==floor(val)) && all(val>=0))
            obj.size = reshape(val,1,2);
        else
            error('ICNA:imagePartition:set:InvalidPropertyValue',...
                  'Size must be a pair [width height].');
        end

    case 'Width'
        if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (floor(val)==val) && val>=0)
            obj.size(1) = val;
        else
            error('ICNA:imagePartition:set:InvalidPropertyValue',...
                  'Value must be a positive integer or 0.');
        end

    case 'Height'
        if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (floor(val)==val) && val>=0)
            obj.size(2) = val;
        else
            error('ICNA:imagePartition:set:InvalidPropertyValue',...
                  'Value must be a positive integer or 0.');
        end

    case 'ScreenResolution'
        if (numel(val)==2 && ~ischar(val) ...
             && all(val==floor(val)) && all(val>=0))
            obj.screenResolution = reshape(val,1,2);
        else
            error('ICNA:imagePartition:set:InvalidPropertyValue',...
                  'Size must be a pair [width height].');
        end

    case 'AssociatedFile'
        if (ischar(val))
            obj.associatedFile = val;
            try
            	A=imread(obj.associatedFile);
                w=size(A,2);
                h=size(A,1);
                obj.size=[w h];
                clear A
            catch ME
                error('ICNA:imagePartition:set:InvalidPropertyValue',...
                  ['File ' obj.associatedFile ' not found.']);
            end
            
        else
            error('ICNA:imagePartition:set:InvalidPropertyValue',...
                  'Value must be a string.');
        end


    otherwise
      error('ICNA:imagePartition:set:InvalidPropertyName',...
            ['Property ' prop ' not valid.'])
   end
end