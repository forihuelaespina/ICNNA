function obj = set(obj,varargin)
% SESSION/SET Set object properties and return the updated object
%
% obj = set(obj,varargin) Set object properties and return 
%   the updated object
%
%% Properties
%
% 'Definition' - Session definition
% 'Date' - Date
%
% == Extracted from the sessionDefinition
% 'ID' - The session ID
% 'Name' - The session name
% 'Description' - The session description
%
% Copyright 2008-12
% @date: 12-May-2008
% @author Felipe Orihuela-Espina
% @modified: 12-Jun-2012
%
% See also session, get
%
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
% 15-February-2022 (ESR): We simplify the code
%   + All cases are in the session class.
%   + We create a dependent property inside the session class on line 50.
%   + The Name, ID and Description properties are in the
%   session class.
%
propertyArgIn = varargin;
while (length(propertyArgIn) >= 2)
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   
   obj.(lower(prop)) = val; %Ignore case
  
end
    assertInvariants(obj);
end