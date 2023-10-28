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
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also nirs_neuroimage
%




%% Log
%
%
% File created: 27-Apr-2008
% File last modified (before creation of this log): 22-Dec-2012
%
% 20-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%


warning('ICNNA:nirs_neuroimage:get:Deprecated',...
        ['DEPRECATED. Use struct like syntax for accessing the attribute ' ...
         'e.g. nirs_neuroimage.' lower(propName) '.']); 
    %Maintain method by now to accept different capitalization though.




switch lower(propName)
case 'probemode'
    val = obj.probeMode;
otherwise
    val =get@neuroimage(obj,propName);
end


end