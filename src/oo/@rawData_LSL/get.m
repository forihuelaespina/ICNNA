function val = get(obj, propName)
% RAWDATA_LSL/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%This method extends the superclass get method
%
%% Changeable Properties
%
%  == Inherited
% 'Description' - Changes the description of the object
% 'Date' - Changes the date associated with the object.
%
%  == The data
% 'RawData' - The raw data
%
%
%
%
%
% Copyright 2013-2018
% @date: 23-Aug-2021
% @author: Felipe Orihuela-Espina
%
% See also rawData.get, set
%




%% Log
%
% 23-Aug-2021 (FOE): 
%	File created.
%
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 13-February-2022 (ESR): We simplify the code
%   + All cases are in the rawData_LSL class.
%   + We create a dependent property inside the rawData_LSL.    
%

     val = obj.(lower(propName)); %Ignore case
end