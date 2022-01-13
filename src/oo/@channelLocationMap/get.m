function val = get(obj, propName)
%CHANNELLOCATIONMAP/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%
%% Properties
%
% 'ID' - The neuroimage ID.
% 'Description' - A short description of the channelLocationMap
% 'nChannels' - Number of channels supported by the optode array
% 'nOptodes' - Number of optodes supported by the optode array
% 'nReferencePoints' - Number of reference points stored
% 'SurfacePositioningSystem' - A string indicating the surface positioning
%       system used for reference
% 'StereotacticPositioningSystem' - A string indicating the stereotactic
%       positioning system used for reference.
%
%
% Copyright 2012-13
% @date: 26-Nov-2012
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also set, display
%


%% Log
%
% 8-Sep-2013: Support for retrieving the number of optodes
%


switch lower(propName)
case 'id'
   val = obj.id;
case 'description'
   val = obj.description;
case 'nchannels'
   val = obj.nChannels;
case 'noptodes'
   val = obj.nOptodes;
case 'nreferencepoints'
   val = length(obj.referencePoints);
case 'surfacepositioningsystem'
   val = obj.surfacePositioningSystem;
case 'stereotacticpositioningsystem'
   val = obj.stereotacticPositioningSystem;
otherwise
   error('ICNA:channelLocationMap:get:InvalidPropertyName',...
            [propName,' is not a valid property.']);
end