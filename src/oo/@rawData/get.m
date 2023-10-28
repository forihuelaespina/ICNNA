function val = get(obj, propName)
% RAWDATA/GET DEPRECATED. Get properties from the specified object and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
%
% 'ID' - Object identifier
% 'Description' - Changes the description of the object
% 'Date' - Changes the date associated with the object.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also rawData, set
%


%% Log
%
% File created: 12-May-2008
% File last modified (before creation of this log): N/A This method had
%   not been updated since creation.
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%   Bug fixed:
%   + 1 error was still not using error code.
%   


warning('ICNA:rawData:get:Deprecated',...
        ['DEPRECATED. Use struct like syntax for setting the attribute ' ...
         'e.g. rawData.' lower(varargin{1}) '.']); 
    %Maintain method by now to accept different capitalization though.




switch lower(propName)
    case 'id'
       val = obj.id;
    case 'description'
       val = obj.description;
    case 'date'
       val = obj.date;
    otherwise
       error('ICNA:rawData:get:InvalidProperty',...
                 [propName,' is not a valid property']);
end