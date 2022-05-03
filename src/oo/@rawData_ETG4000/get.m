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
% 'Description' - Gets the object's description
% 'Date' - Gets the date associated with the object.
%       See also timestamps
%
% == Others
% 'Version' - DEPRECATED. Version of data structure of the ETG-4000 file
%       Use 'FileVersion' instead.
% 'FileVersion' - Version of data structure of the ETG-4000 file
% 'SubjectName' - The subject's name
% 'SubjectSex' - The subject's sex
% 'SubjectBirthDate' - The subject's birth date as a datenum
% 'SubjectAge' - The subject's age in years
% 'AnalyzeMode' -  Analyze mode
% 'PreTime' - Pre time
% 'PostTime' - Post time
% 'RecoveryTime' - Recovery time
% 'BaseTime' - Baseline time
% 'FittingDegree' - Degree of the polynolmial function for detrending
% 'HPF' - High Pass Filter
% 'LPF' - Low Pass Filter
% 'MovingAverage' - Number of seconds of a moving average filter
% 'NominalWavelengthSet' - Set of wavelength at which the device operates
%       assuming no error
% 'nProbes' - DEPRECATED. Number of probe sets declared (whether read
%       or not). Please use 'nProbeSets' instead.
% 'nProbeSets' - Number of probe sets declared (whether read or not).
%       Note that there may be intermediate probe sets which might
%       have not been imported.
% 'nChannels' - Total number of channels across all probe sets
% 'SamplingPeriod' - Sampling Rate in [s]
% 'SamplingRate' - Sampling Rate in [Hz]
% 'nBlocks' - DEPRECATED. Number of times the stimulus train sequence is repeated
%       Use 'RepeatCount' instead.
% 'RepeatCount' - Number of times the stimulus train sequence is repeated
% 'LightRawData' - The light intensitites recorded
% 'Marks' - Stimulus marks. To some extent this is seed for the timeline.
%       One column per probe set.
% 'Timestamps' - Sample acquisition timestamps relative
%       to object's date (inherited). 
%       One column per probe set.
% 'BodyMovement' - Body movement artifacts as determined by the ETG-4000
%       One column per probe set.
% 'RemovalMarks' - Removal marks
%       One column per probe set.
% 'preScan' - preScan stamps
%       One column per probe set.
%
%
%
%
%
% Copyright 2008-12
% @date: 13-Jun-2008
% @author Felipe Orihuela-Espina
% @modified: 30-Dec-2012
%
% See also rawData.get, set
%
%

%% Log
%
%
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 17-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the rawData_ETG4000 class.
%   + We create a dependent property inside the rawData_ETG4000 class.
%

   tmp = lower(propName);
    
    switch (tmp)

           case 'analyzemode'
                val = obj.analyzeMode;
           case 'basetime'
                val = obj.baseTime;
           case 'bodymovement'
                val = obj.bodyMovement; 
           case 'fileversion'
                val = obj.fileVersion;
           case 'fittingdegree'
                val = obj.fittingDegree;
           case 'hpf'
                val = obj.hpf;
           case {'wlengths','nominalwavelengthset'}
                val = obj.wLengths;
           case 'lpf'
                val = obj.lpf;
           case 'lightrawdata'
                val = obj.lightRawData;
           case 'movingaverage'
                val = obj.movingAvg;
           case 'marks'
                val = obj.marks;
           case 'nblocks'
                val = obj.nBlocks;
           case 'nprobes'
                val = obj.nProbes;
           case 'nprobesets'
                val = obj.nProbeSets;
           case 'nchannels'
                val = obj.nChannels;
           case 'prescan'
                val = obj.preScan;
           case 'pretime'
                val = obj.preTime;
           case 'posttime'
                val = obj.postTime;
           case 'recoverytime'
                val = obj.recoveryTime; 
           case 'repeatcount'
                val = obj.repeatCount;
           case 'removalmarks'
                val = obj.removalMarks;
           case 'samplingperiod'
                val = obj.samplingPeriod; 
           case 'samplingrate'
                val = obj.samplingRate;
           case 'timestamps'
                val = obj.timestamps;
           case 'subjectname'
                val = obj.userName;
           case 'subjectsex'
                val = obj.userSex;
           case 'subjectbirthdate'
                val = obj.userBirthDate;
           case 'subjectage'
                val = obj.userAge;
           case 'version'
                val = obj.version;
        otherwise 
            val = get@rawData(obj, propName);
    end
end