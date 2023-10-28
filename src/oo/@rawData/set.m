function obj = set(obj,varargin)
% RAWDATA/SET DEPRECATED. Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%% Properties
%
% 'ID' - Object identifier
% 'Description' - Changes the description of the object
% 'Date' - Changes the date associated with the object.
%
%
% Copyright 2008
% @date: 12-May-2008
% @author Felipe Orihuela-Espina
%
% See also rawData, get


%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): N/A This method had
%   not been updated since creation.
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%   + Added support for proerty |id| that surprisingly it was not provided. 
%   


warning('ICNA:rawData:set:Deprecated',...
        ['DEPRECATED. Use struct like syntax for setting the attribute ' ...
         'e.g. rawData.' lower(varargin{1}) ' = ... ']); 




propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch lower(prop)
       case 'id'
           obj.id = val;
    case 'description'
        if (ischar(val))
            obj.description = val;
        else
            error('ICNA:rawData:set:Description',...
                  'Value must be a string');
        end

    case 'date'
      obj.date=val;

    otherwise
      error('ICNA:rawData:set:InvalidProperty',...
            ['Property ' prop ' not valid.'])
   end
end