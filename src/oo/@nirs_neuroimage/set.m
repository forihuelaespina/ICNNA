function obj = set(obj,varargin)
% NIRS_NEUROIMAGE/SET Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%Modifying the image data also adjusts the timeline and the
%integrity status as appropriate.
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
% See also nirs_neuroimage, get
%
%% Log
%
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 17-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the timeline class.
%   + Creation of the .cropOrRemoveEvents object:
%   the Auxiliar Nested functions are inside.
%

    propertyArgIn = varargin;
    while (length(propertyArgIn) >= 2)
       prop = propertyArgIn{1};
       val = propertyArgIn{2};
       propertyArgIn = propertyArgIn(3:end);

       tmp = lower(prop);
    
        switch (tmp)

            case 'probemode'
                obj.probeMode = val;

            otherwise
                obj=set@neuroimage(obj,prop,val);
        end
    end
end