function obj = set(obj,varargin)
%NEUROIMAGE/SET Set object properties and return the updated object
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
%
% == Self defined
% 'ChannelLocationMap' - The channel location map
%
% Copyright 2012
% @date: 22-Dec-2012
% @author Felipe Orihuela-Espina
% @modified: 28-Dec-2012
%
% See also neuroimage, get
%

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    switch lower(prop)
        case 'channellocationmap'
           if (isa(val,'channelLocationMap'))
               obj.chLocationMap = channelLocationMap(val);
                    %Note that the channelLocationMap should
                    %have the same number of channels that the
                    %data, and if this is not the case, the
                    %assertInvariants will issue an error.
           else
               error('ICNA:neuroimage:set:InvalidPropertyValue',...
                     'Value must be of class channelLocationMap.');
           end

        case 'data'
            %Setting the data may alter the size of it (i.e. the
            %number of channels. If I call the set method directly
            %it will evaluate the assertInvariants method -of the
            %neuroimage class!! regardless of whether it is call
            %as obj=set@structuredData(...)- BEFORE the 
            %channelLocationMap has adjusted its size. Thus, the
            %neuroimage.assertInvariants will yield an error because
            %the channel capacity of the channelLocationMap mismatches
            %the channel capacity of the data. To avoid this
            %error, it is necessary to set the size of the
            %channelLocationMap BEFORE setting the data, so that
            %when the assertInvariants is called, the channelLocationMap
            %already has the appropriate size.
            try
                %ensure that the channelLocationMap has the appropriate
                %size
                obj.chLocationMap = ...
                    set(obj.chLocationMap,'nChannels',size(val,2));
                %...and only then, set the data
                obj=set@structuredData(obj,'Data',val);
            catch
               error('ICNA:neuroimage:set:InvalidPropertyValue',...
                     'Data must be a numeric.');
            end
            
        otherwise
            obj=set@structuredData(obj,prop,val);
    end
end
assertInvariants(obj);