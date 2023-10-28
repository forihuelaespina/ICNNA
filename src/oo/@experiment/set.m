function obj = set(obj,varargin)
% EXPERIMENT/SET DEPRECATED. Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%% Properties
%
% * 'Name' - A string with the experiment name
% * 'Description' - A string with the experiment description
% * 'Date' - A date string
%
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also experiment, get
%





%% Log
%
% File created: 16-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%



warning('ICNNA:experiment:set:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for setting the attribute ' ...
         'e.g. experiment.' lower(varargin{1}) ' = ... ']); 



propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch lower(prop)
    case 'name'
        obj.name = val;
        % if (ischar(val))
        %     obj.name = val;
        % else
        %     error('Value must be a string');
        % end

    case 'description'
        obj.description = val;
        % if (ischar(val))
        %     obj.description = val;
        % else
        %     error('Value must be a string');
        % end

    case 'date'
      obj.date=val;

    otherwise
      error('ICNNA:experiment:set:InvalidPropertyName',...
            ['Property ' prop ' not found.'])
   end
end
assertInvariants(obj);



end