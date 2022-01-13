function val = get(obj, propName)
%STRUCTUREDDATA/GET Get properties from the specified object
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
% Copyright 2008-12
% @date: 27-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 22-Dec-2012
%
% See also structuredData, getBlock, getSample, getChannel, getSignal
%

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
   error([propName,' is not a valid property'])
end