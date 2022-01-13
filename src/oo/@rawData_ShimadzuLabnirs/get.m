function val = get(obj, propName)
% RAWDATA_SHIMADZULABNIRS/GET Get properties from the specified object
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
% 'rawData' - The oxyhaemoglobin raw concentrations recorded
% 'Timestamps' - Sample acquisition timestamps relative
%       to experiment onset (inherited). 
% 'nSamples' - Number of temporal samples
% 'nChannels' - Number of channels
% 'preTimeline' - A vector with preTimeline experimntal condition flags
% 'nEvents' - Number of pretimeline-like events
% 'marks' - A vector of marks.
%
%
%
%
%
% Copyright 2016
% @date: 20-Sep-2016
% @author: Felipe Orihuela-Espina
% @modified: 20-Sep-2016
%
% See also rawData.get, set
%

switch lower(propName)
%Measure information
case 'nominalwavelengthset'
   val = obj.wLengths;
case 'nsamples'
   val= size(obj.rawData,1);
case 'nchannels'
   val= size(obj.rawData,2)/3;
    %Three hemoglobin species per channel; oxy, deoxy and total
   
case 'samplingrate'
   val = obj.samplingRate;
%The data itself!!
case 'rawdata'
   val = obj.rawData;%Three hemoglobin species per channel; oxy, deoxy and total
case 'timestamps'
   val = obj.timestamps;
case 'pretimeline'
   val = obj.preTimeline;
case 'nevents'
    idx=find(obj.preTimeline~=0);
   val = length(idx);
case 'marks'
   val = obj.marks;


   
otherwise
   val = get@rawData(obj, propName);
end