function obj = set(obj,varargin)
% SESSIONDEFINITION/SET Set object properties and return the updated object
%
% obj = set(obj,'PropertyName',propertyValue) Set object properties and
%   return the updated object
%
%% Properties
%
% 'ID' - The object's numeric identifier
% 'Name' - A name
% 'Description' - A short description
%
%
% Copyright 2008
% @date: 10-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also sessionDefinition, get
%
%

%% Log
%
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 13-February-2022 (ESR): We simplify the code
%   + All cases are in the sessionDefinition class.
%   

propertyArgIn = varargin;
    while (length(propertyArgIn) >= 2)
       prop = propertyArgIn{1};
       val = propertyArgIn{2};
       propertyArgIn = propertyArgIn(3:end);
       
       %%obj.(lower(prop)) = val; %Ignore case
       
       tmp = lower(prop);
    
        switch (tmp)

            case 'description'
               obj.description = val;
            case 'id'
                obj.id = val;
            case 'name'
                obj.name = val;
                
            otherwise
                error(['Property ' prop ' not valid.'])
        end

    end
end