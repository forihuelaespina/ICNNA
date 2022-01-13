function val = get(obj, propName)
% NIRS_NEUROIMAGE/GET Get properties from the specified object
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
% 'ChannelLocationMap' - The channel location map
%
% == Self defined
% 'ProbeMode' - DEPRECATED. The OT probe mode, e.g. '3x3' or '4x4', etc...
%       See inherited property .channelLocationMap
%
% Copyright 2008-12
% @date: 27-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 22-Dec-2012
%
% See also nirs_neuroimage
%

switch lower(propName)
case 'probemode'
    warning('ICNA:nirs_neuroimage:get:Deprecated',...
            ['Use of probeMode has now been deprecated. ' ...
            'Please refer to neuroimage.channelLocationMap.']);
    val = obj.probeMode;
otherwise
    val =get@neuroimage(obj,propName);
end