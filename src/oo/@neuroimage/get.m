function val = get(obj, propName)
%NEUROIMAGE/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%% Properties
%
% == Inherited
% 'ID' - The neuroimage ID.
% 'Description' - A short description of the image
% 'NSamples' - Number of samples 
% 'NChannels' - Number of picture elements (e.g. channels)
% 'NSignals' - Number of signals
% 'Timeline' - The image timeline
% 'Integrity' - The image integrity status per picture element
% 'Data' - The image data itself
%
% == Self defined
% 'ChannelLocationMap' - The channel location map
%
%
% Copyright 2012
% @date: 22-Dec-2012
% @author Felipe Orihuela-Espina
% @modified: 22-Dec-2012
%
% See also neuroimage
%

switch lower(propName)
case 'channellocationmap'
    val = obj.chLocationMap;
otherwise
    val =get@structuredData(obj,propName);
end