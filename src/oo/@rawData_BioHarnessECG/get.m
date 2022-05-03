function val = get(obj, propName)
% RAWDATA_ETG4000/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%This method extends the superclass get method
%
%% Properties
%
%== Inherited
% 'ID' - A numerical identifier
% 'Description' - Changes the description of the object
% 'Date' - Changes the date associated with the object.
%
% == Others
% 'StartTime' - Absolute start time as a date vector:
%       [YY, MM, DD, HH, MN, SS]
% 'SamplingRate' - Sampling Rate in [Hz]
% 'Timestamps' - Timestamps in milliseconds relative to the absolute start
%   time
% 'RawData' - The ECG recorded
%
%
%
% Copyright 2009
% @date: 19-Jan-2009
% @author Felipe Orihuela-Espina
%
% See also rawData.get, set
%
%
%% Log
%
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 17-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the rawData_BioHarnessECG class.
%
    tmp = lower(propName);
    
    switch (tmp)
        
           case 'rawdata'
                val = obj.data; 
           case 'samplingrate'
                val = obj.samplingRate;
           case 'starttime'
                val = obj.startTime;
           case 'timestamps'
                val = obj.timestamps;

        otherwise 
        val = get@rawData(obj, propName);
    end
end