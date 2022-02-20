function obj = set(obj,varargin)
% ROI/SET Set object properties and return the updated object
%
% obj = set(obj,'PropertyName',propertyValue)
%
%% Properties
%
% 'ID' - A numeric identifier
% 'Name' - ROI's name
%
%
%
% Copyright 2008
% @date: 22-Dec-2008
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
% 13-February-2022 (ESR): We simplify the code
%   + All cases are in the roi class.
%   + We create a dependent property inside of the roi class.
%
propertyArgIn = varargin;
    while (length(propertyArgIn) >= 2)
       prop = propertyArgIn{1};
       val = propertyArgIn{2};
       propertyArgIn = propertyArgIn(3:end);

       obj.(lower(prop)) = val; %Ignore case
    end
end