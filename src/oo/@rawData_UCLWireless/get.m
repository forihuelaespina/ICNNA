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

%% Log
%
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 13-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the rawData_UCLWireless class.
%   + We create a dependent property inside the rawData_UCLWireless class 
%
%
     %val = obj.(lower(propName)); %Ignore case
     
     tmp = lower(propName);
    
    switch (tmp)

            case 'deoxyrawdata'
                val = obj.deoxyRawData;
            case {'wlengths','nominalwavelengthset'}
                val = obj.wLengths;
            case 'oxyrawdata'
                val = obj.oxyRawData;  
            case 'pretimeline'
                val = obj.preTimeline;
            case 'samplingrate'
                val = obj.samplingRate;
            case 'timestamps'
                val = obj.timestamps;
            case 'nchannels'
                val = obj.nChannels;
            case 'nevents'
                val = obj.nEvents;
            case 'nsamples'
                val = obj.nSamples;
        otherwise 
            val = get@rawData(obj, propName);
    end
end