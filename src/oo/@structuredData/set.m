function obj = set(obj,varargin)
%STRUCTUREDDATA/SET Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%Modifying the underlying data also adjusts the timeline as appropriate.
%
%% Properties
% ID - Numerical ID
% Description - Description string
% Timeline - A timeline
% NSamples - Update the current number of samples
%   Data and timeline are cropped or zero padded as necessary
% NChannels - Update the current number of channels
%   Data and timeline are cropped or zero padded as necessary
% NSignals - Update the current number of signals
%   Data and timeline are cropped or zero padded as necessary
% Data - The full data. 3D matrix holding <samples,channels,signals>
% Integrity - An integrityStatus
%
%
% Copyright 2008-12
% @date: 27-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 22-Dec-2012
%
% See also structuredData, get
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
%   + All cases are in the structuredData class.
%   + We create a dependent property inside the structuredData class on line 143.
%   + The nSamples, nChannels and nSignals properties are in the
%   structuredData class.

propertyArgIn = varargin;
while (length(propertyArgIn) >= 2)
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   
   obj.(lower(prop)) = val; %Ignore case
  
end
    assertInvariants(obj);
end