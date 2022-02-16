function val = get(obj, propName)
%STRUCTUREDDATA/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
%
% 'ID' - The structuredData ID.
% 'Description' - A short description of the structuredData
% 'NSamples' - Number of samples 
% 'NChannels' - Number of channels
% 'NSignals' - Number of signals
% 'Timeline' - The structuredData timeline
% 'Integrity' - The structuredData integrity status per spatial element
% 'Data' - The data itself
% 'SignalTags' - The list of signal tags
%
% Copyright 2008-12
% @date: 27-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 22-Dec-2012
%
% See also structuredData, getBlock, getSample, getChannel, getSignal
%

%% Log
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 13-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the structuredData class.
%   + We create a dependent property inside the structuredData class on line 143.

    val = obj.(lower(propName)); %Ignore case
end