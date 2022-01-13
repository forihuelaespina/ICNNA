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

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    switch lower(prop)
        case 'probemode'
            warning('ICNA:nirs_neuroimage:set:Deprecated',...
                ['Use of probeMode has now been deprecated. ' ...
                'Please refer to neuroimage.channelLocationMap.']);
            if ischar(val)
                switch(val)
                    case '3x3'
                        obj.probeMode = '3x3';
                    case '4x4'
                        obj.probeMode = '4x4';
                    case '3x5'
                        obj.probeMode = '3x5';
                    otherwise
                        error('ICNA:nirs_neuroimage:set:InvalidParameterValue',...
                              'ProbeMode must be a string ''3x3'', ''4x4'' etc.');
                end
            else
                error('ICNA:nirs_neuroimage:set:InvalidParameterValue',...
                      'ProbeMode must be a string ''3x3'', ''4x4'' etc.');
            end
        otherwise
            obj=set@neuroimage(obj,prop,val);
    end
end
%assertInvariants(obj);