function val = get(obj, propName)
% EXPERIMENT/GET DEPRECATED. Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also experiment
%



%% Log
%
% File created: 16-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%   Bug fixed:
%   + Comment for property nConditions was inaccurate.
%   + 1 error was still not using error code.
%   + Error codes using 'ICNA' have been updated to 'ICNNA'.
%

warning('ICNNA:experiment:get:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for accessing the attribute ' ...
         'e.g. experiment.' lower(propName) '.']); 
    %Maintain method by now to accept different capitalization though.


switch lower(propName)
case 'name'
   val = obj.name;
case 'description'
   val = obj.description;
case 'version'
   val = obj.version;
case 'date'
   val = obj.date;
case 'dataset'
   val = obj.dataset;
otherwise
   error('ICNNA:experiment:get:InvalidPropertyName',...
        [propName,' not found.'])
end



end