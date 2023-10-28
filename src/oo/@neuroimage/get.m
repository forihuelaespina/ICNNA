function val = get(obj, propName)
%NEUROIMAGE/GET DEPRECATED. Get properties from the specified object
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
% Copyright 2012-23
% @author Felipe Orihuela-Espina
%
% See also neuroimage
%



%% Log
%
%
% File created: 22-Dec-2012
% File last modified (before creation of this log): N/A. This method
%   had never been updated since creation.
%
% 20-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%


warning('ICNNA:neuroimage:get:Deprecated',...
        ['DEPRECATED. Use struct like syntax for accessing the attribute ' ...
         'e.g. neuroimage.' lower(propName) '.']); 
    %Maintain method by now to accept different capitalization though.



switch lower(propName)
case 'channellocationmap'
    val = obj.chLocationMap;
otherwise
    val =get@structuredData(obj,propName);
end