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
% Copyright 2008
% @date: 16-Apr-2008
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
% 31-January-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the subject class.
%   
%

propertyArgIn = varargin;
while (length(propertyArgIn) >= 2)
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   
   %obj.(lower(prop)) = val; %Ignore case
   
    tmp = lower(prop);
    
    switch (tmp)

        case 'age'
           obj.age = val;
        case 'hand'
            obj.hand = val;
        case 'id'
            obj.id = val;
        case 'name'
            obj.name = val;
        case 'sex'
            obj.sex = val;

        otherwise
            error('ICNA:subject:set:InvalidPropertyName',...
            ['Property ' prop ' not valid.'])
    end
end
    assertInvariants(obj);
end