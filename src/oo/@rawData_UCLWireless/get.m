function val = get(obj, propName)
% RAWDATA_UCLWIRELESS/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%This method extends the superclass get method
%
%% Properties
%
%== Inherited
% 'Description' - Gets the object's description
% 'Date' - Gets the date associated with the object.
%       See also timestamps
%
% == Others
% 'NominalWavelengthSet' - Set of wavelength at which the device operates
%       assuming no error
% 'SamplingRate' - Sampling Rate in [Hz]
% 'OxyRawData' - The oxyhaemoglobin raw concentrations recorded
% 'DeoxyRawData' - The deoxyhaemoglobin raw concentrations recorded
% 'Timestamps' - Sample acquisition timestamps relative
%       to experiment onset (inherited). 
% 'nSamples' - Number of temporal samples
% 'nChannels' - Number of channels
% 'nEvents' - Number of pretimeline-like events
% 'preTimeline' - A struct with preTimeline events
%       One record per event.
%
%
%
%
%
% Copyright 2016
% @date: 1-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 1-Sep-2016
%
% See also rawData.get, set
%

switch lower(propName)
%Measure information
case 'nominalwavelengthset'
   val = obj.wLengths;
case 'nevents'
   val = length(obj.preTimeline);
case 'nsamples'
   val= size(obj.oxyRawData,1);
    %Note that oxyRawData and deoxyRawData have the same size (class invariant)
case 'nchannels'
   val= size(obj.oxyRawData,2);
    %Note that oxyRawData and deoxyRawData have the same size (class invariant)
   
case 'samplingrate'
   val = obj.samplingRate;
%The data itself!!
case 'oxyrawdata'
   val = obj.oxyRawData;%The oxyhaemoglobin raw concentrations data.
case 'deoxyrawdata'
   val = obj.deoxyRawData;%The deoxyhaemoglobin raw concentrations data.
case 'timestamps'
   val = obj.timestamps;
case 'pretimeline'
   val = obj.preTimeline;

   
otherwise
   val = get@rawData(obj, propName);
end