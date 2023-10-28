function obj = set(obj,varargin)
% DATASOURCE/SET DEPRECATED (v1.2). Set object properties and return the updated object
%
%% Properties
%
% 'ID' - The object identifier
% 'Name' - The name
% 'Device number' - A number identifying the device from which the data
%   originated
% 'Type' - The type of the data source. See dataSource for more
%   information on this attribute.
% 'Lock' - Whether existing the structured data arise from the
%   defined raw data.
% 'RawData' - The raw Data if defined or an empty matrix if not defined.
% 'ActiveStructured' - The ID of the currently active structuredData
%
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also get
%





%% Log
%
% File created: 12-May-2008
% File last modified (before creation of this log): /A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED (v1.2).
%



warning('ICNNA:dataSource:set:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for setting the attribute ' ...
         'e.g. dataSource.' lower(varargin{1}) ' = ... ']); 


propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch lower(prop)
    case 'id'
        obj.id = val;
        % if (isscalar(val) && isreal(val) && ~ischar(val) ...
        %     && (val==floor(val)) && (val>0))
        %     %Note that a char which can be converted to scalar
        %     %e.g. will pass all of the above (except the ~ischar)
        %     obj.id = val;
        % else
        %     error('Value must be a positive scalar natural/integer');
        % end
 
    case 'name'
        obj.name = val;
        % if (ischar(val))
        %     obj.name = val;
        % else
        %     error('Value must be a string');
        % end

    case 'devicenumber'
        obj.deviceNumber = val;
        % if (isscalar(val) && isreal(val) && ~ischar(val) ...
        %     && (val==floor(val)) && (val>0))
        %     %Note that a char which can be converted to scalar
        %     %e.g. will pass all of the above (except the ~ischar)
        %     obj.deviceNumber = val;
        % else
        %     error('Value must be a positive scalar natural/integer');
        % end
 
    case 'lock'
        obj.lock=val;
        % obj.lock=true;
        % if (~val) obj.lock=false; end

    case 'activestructured'
        obj.activeStructured = val;
        % if (isscalar(val) && (val==floor(val)) ...
        %         && (val>0) && (val<=length(obj.structured)) ...
        %         && ismember(val,getStructuredDataList(obj)))
        %     obj.activeStructured = val;
        % else
        %     error('Value must be a positive integer');
        % end
 

    otherwise
      error('ICNNA:dataSource:set:InvalidProperty',...
            ['Property ' prop ' not found.'])
   end
end
%assertInvariants(obj);



end