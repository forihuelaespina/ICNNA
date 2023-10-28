function obj = set(obj,varargin)
% SUBJECT/SET Set object properties and return the updated object
%
% obj = set(obj,'PropertyName',propertyValue)
%
%% Properties
%
% 'ID' - A numeric identifier
% 'Name' - Subject's name
% 'Age' - Subject's age
% 'Sex' - Subject's sex. 'M'ale/'F'emale/'U'nknown
% 'Hand' - Subject's handedness. 'R'ight/'L'eft/'A'mbidextroux/'U'nknown
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
% File created: 16-Apr-2008
% File last modified (before creation of this log): 29-Dec-2012
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%



warning('ICNNA:timeline:set:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for setting the attribute ' ...
         'e.g. timeline.' lower(varargin{1}) ' = ... ']); 


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
        %     error('ICNA:subject:set:InvalidPropertyValue',...
        %           'Value must be a positive integer.');
        % end
 
    case 'name'
        obj.name = val;
        % if (ischar(val))
        %     obj.name = val;
        % else
        %     error('ICNA:subject:set:InvalidPropertyValue',...
        %           'Value must be a string.');
        % end

    case 'age'
        obj.age = val;
        % if (isscalar(val) && (val==floor(val)) && (val>=0))
        %     obj.age = val;
        % else
        %     error('ICNA:subject:set:InvalidPropertyValue',...
        %           'Value must be a positive integer (or 0).');
        % end

    case 'sex'
        obj.sex=upper(val);
        % val=upper(val);
        % switch (val)
        %     case 'M'
        %         obj.sex = val;
        %     case 'F'
        %         obj.sex = val;
        %     case 'U'
        %         obj.sex = val;
        %     case ''
        %         obj.sex = 'U';
        % otherwise
        %     error('ICNA:subject:set:InvalidPropertyValue',...
        %           ['Value must be a single char. ' ...
        %             '''M''ale/''F''emale/''U''nknown.']);
        % end

    case 'hand'
        obj.hand=upper(val);
        % val=upper(val);
        % switch (val)
        %     case 'L'
        %         obj.hand = val;
        %     case 'R'
        %         obj.hand = val;
        %     case 'A'
        %         obj.hand = val;
        %     case 'U'
        %         obj.hand = val;
        %     case ''
        %         obj.hand = 'U';
        % otherwise
        %     error('ICNA:subject:set:InvalidPropertyValue',...
        %           ['Value must be a single char. ' ...
        %             '''L''eft/''R''ight/''A''mbidextrous/''U''nknown.']);
        % end

    otherwise
      error('ICNNA:subject:set:InvalidPropertyName',...
            ['Property ' prop ' not valid.'])
   end
end

end