function val = get(obj, propName)
%CHANNELLOCATIONMAP/GET DEPRECATED. Get properties from the specified object
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
% Copyright 2012-23
% @author: Felipe Orihuela-Espina
%
% See also set, display
%


%% Log
%
%
% File created: 26-Nov-2012
% File last modified (before creation of this log): 8-Sep-2013
%
% 8-Sep-2013: Support for retrieving the number of optodes
%
% 20-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%


warning('ICNNA:channelLocationMap:get:Deprecated',...
        ['DEPRECATED. Use struct like syntax for accessing the attribute ' ...
         'e.g. channelLocationMap.' lower(propName) '.']); 
    %Maintain method by now to accept different capitalization though.




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