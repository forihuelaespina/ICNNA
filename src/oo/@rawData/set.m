function obj = set(obj,varargin)
% RAWDATA/SET Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%% Properties
%
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
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 17-February-2022 (ESR): We simplify the code
%   + All cases are in the rawData class.
%
        propertyArgIn = varargin;
    while (length(propertyArgIn) >= 2)
           prop = propertyArgIn{1};
           val = propertyArgIn{2};
           propertyArgIn = propertyArgIn(3:end);

           obj.(lower(prop)) = val; %Ignore case
    end
end