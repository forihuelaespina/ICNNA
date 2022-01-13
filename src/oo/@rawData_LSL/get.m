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
%

switch lower(propName)
%  == The data
%The data itself!!
case 'rawdata'
   val = obj.data;
   
otherwise
   val = get@rawData(obj, propName);  
end
end