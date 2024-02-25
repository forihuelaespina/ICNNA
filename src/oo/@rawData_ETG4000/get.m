function val = get(obj, propName)
% RAWDATA_ETG4000/GET  DEPRECATED Get properties from the specified object
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
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also rawData.get, set
%

%% Log
%
% File created: 13-Jun-2008
% File last modified (before creation of this log): 30-Dec-2012
%
% 3-Dec-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%   Bug fixed:
%   + Errors code updated from 'ICNA' to 'ICNNA'.
%   + Legacy support for attribute version (previously deprecated)
%   no longer active.
%

warning('ICNNA:rawData_ETG4000:get:Deprecated',...
        ['DEPRECATED (v1.2.1). Use struct like syntax for accessing the attribute ' ...
         'e.g. rawData_ETG4000.' lower(propName) '.']); 
    %Maintain method by now to accept different capitalization though.


switch lower(propName)
% case 'version' %DEPRECATED
%    val = obj.fileVersion;
%    warning('ICNNA:rawData_ETG4000:get:Deprecated',...
%            ['The use of ''version'' has been deprecated. ' ...
%             'Please use ''fileVersion'' instead.']);
case 'fileversion'
   val = obj.fileVersion;
%Patient information
case 'subjectname'
   val = obj.userName;
case 'subjectsex'
   val = obj.userSex;
case 'subjectbirthdate'
   val = obj.userBirthDate;
case 'subjectage'
   val = obj.userAge;
%Analysis information (for presentation only)
case 'analyzemode'
   val = obj.analyzeMode;
case 'pretime'
   val = obj.preTime;
case 'posttime'
   val = obj.postTime;
case 'recoverytime'
   val = obj.recoveryTime;
case 'basetime'
   val = obj.baseTime;
case 'fittingdegree'
   val = obj.fittingDegree;
case 'hpf'
   val = obj.hpf;
case 'lpf'
   val = obj.hpf;
case 'movingaverage'
   val = obj.movingAvg;
%Measure information
case 'wLengths'
   val = obj.wLengths;
case 'nominalwavelengthset'
   val = obj.wLengths;
   warning('ICNNA:rawData_ETG4000:get:Deprecated',...
           ['The use of ''nominalwavelengthset'' has been deprecated. ' ...
            'Please use ''wLengths'' instead.']);
case 'nprobes'
   %val = obj.nProbes; %DEPRECATED
   val = length(obj.probesetInfo);
   warning('ICNNA:rawData_ETG4000:get:Deprecated',...
           ['The use of ''nProbes'' has been deprecated. ' ...
            'Please use ''nProbeSets'' instead.']);
case 'nprobesets'
   val = length(obj.probesetInfo);
case 'nchannels'
    %Total number of channels across all probes.
   %val = sum(obj.nChannels); %DEPRECATED
nProbeSets=length(obj.probesetInfo);
nCh=0;
for ps=1:nProbeSets
    if obj.probesetInfo(ps).read %Count only those which have been imported
        pMode=obj.probesetInfo(ps).mode;
        switch (pMode)
            case '3x3'
                nCh =nCh+24;
            case '4x4'
                nCh =nCh+24;
            case '3x5'
                nCh =nCh+22;
            otherwise
                error('ICNNA:rawData_ETG4000:get:UnexpectedProbeSetMode',...
                    'Unexpected probe set mode.');
        end
    end
end
   val=nCh;
   
% case 'channels'
%    val = obj.nChannels; %The vector of channels at each optode array or probe
case 'samplingperiod'
   val = obj.samplingPeriod;
case 'samplingrate'
   val = 1/obj.samplingPeriod;
case 'nblocks' %DEPRECATED
   val = obj.repeatCount;
   warning('ICNNA:rawData_ETG4000:get:Deprecated',...
           ['The use of ''nBlocks'' has been deprecated. ' ...
            'Please use ''repeatCount'' instead.']);
case 'repeatcount'
   val = obj.repeatCount;
%The data itself!!
case 'lightrawdata'
   val = obj.lightRawData;%The raw light intensity data.
case 'marks'
   val = obj.marks;%The stimulus marks.
case 'timestamps'
   val = obj.timestamps;
case 'bodymovement'
   val = obj.bodyMovement;
case 'removalmarks'
   val = obj.removalMarks;
case 'prescan'
   val = obj.preScan;

   
otherwise
   val = get@rawData(obj, propName);
end