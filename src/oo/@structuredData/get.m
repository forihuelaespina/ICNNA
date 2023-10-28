function val = get(obj, propName)
%STRUCTUREDDATA/GET DEPRECATED. Get properties from the specified object
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
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also structuredData, getBlock, getSample, getChannel, getSignal
%



%% Log
%
% File created: 27-Apr-2008
% File last modified (before creation of this log): 22-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%   Bug fixed:
%   + 1 error was still not using error code.
%

warning('ICNNA:structuredData:get:Deprecated',...
        ['DEPRECATED. Use struct like syntax for accessing the attribute ' ...
         'e.g. structuredData.' propName '.']); 
    %Maintain method by now to accept different capitalization though.




switch lower(propName)
case 'id'
   val = obj.id;
case 'description'
   val = obj.description;
case 'nsamples'
   val = size(obj.data,1);
case 'nchannels'
   val = size(obj.data,2);
case 'nsignals'
   val = size(obj.data,3);
case 'timeline'
   val = obj.timeline;
case 'data'
   val = obj.data;
case 'integrity'
   val = obj.integrity;
case 'signaltags'
   val = obj.signalTags;
otherwise
   error('ICNNA:structuredData:get:InvalidProperty',...
             [propName,' is not a valid property'])
end