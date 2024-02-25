function obj = set(obj,varargin)
% RAWDATA_ETG4000/SET DEPRECATED. Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%
%This method extends the superclass set method
%
%% Properties
%
%== Inherited
% 'Description' - Changes the description of the object
% 'Date' - Changes the date associated with the object.
%
% == Others
% 'Version' - DEPRECATED. Version of data structure of the ETG-4000 file
%       Use 'FileVersion' instead.
% 'FileVersion' - Version of data structure of the ETG-4000 file
% 'SubjectName' - The subject's name
% 'SubjectSex' - The subject's sex
% 'SubjectBirthDate' - The subject's birth date
% 'SubjectAge' - The subject's age in years
% 'AnalyzeMode' - Analyze mode
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
% 'SamplingPeriod' - Sampling Period in [s]
% 'SamplingRate' - Sampling Rate in [Hz]
% 'nBlocks' - DEPRECATED. Number of times the stimulus train sequence is repeated
%       Use 'RepeatCount' instead.
% 'RepeatCount' - Number of times the stimulus train sequence is repeated
% 'LightRawData' - The light intensitites recorded
% 'Marks' - Stimulus marks representing the timeline
%       One column per probe set.
% 'Timestamps' - Vector of sample acquisition timestamps in [s]
%       Relative to the object's Date. Note that no check
%       is done regarding the validity of the timestamps.
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
% Copyright 2008-17
% @date: 13-Jun-2008
% @author Felipe Orihuela-Espina
% @modified: 28-Jul-2017
%
% See also rawData.set, get
%




%% Log
%
% File created: 16-Apr-2008
% File last modified (before creation of this log): 29-Dec-2012
%
% 28-Jul-2017 (FOE): Bug fixed.
%   When setting the value of the moving average it was expecting
%   an integer, but this value is expressed in seconds and thus
%   it may actually be a real number.
%
% 14-Jan-2016 (FOE): Bug fixed.
%   When setting the lightRawData check for input size now properly
%   checks the match in size with the number of probe sets declared
%   instead of expecting a 3D matrix.
%
% 21-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%   + Legacy support for attribute version (previously deprecated)
%   no longer active.
%



warning('ICNNA:rawData_ETG4000:set:Deprecated',...
        ['DEPRECATED (v1.2.1). Use struct like syntax for setting the attribute ' ...
         'e.g. rawData_ETG4000.' lower(varargin{1}) ' = ... ']); 




propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch lower(prop)
    % case 'version' %DEPRECATED
    %     if (ischar(val))
    %         obj.fileVersion = val;
    %         warning('ICNA:rawData_ETG4000:set:Deprecated',...
    %                 ['The use of ''version'' has been deprecated. ' ...
    %                 'Please use ''fileVersion'' instead.']);
    %     else
    %         error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
    %               'Value must be a string');
    %     end

    case 'fileversion'
        obj.fileVersion = val;
        % if (ischar(val))
        %     obj.fileVersion = val;
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a string');
        % end

%Patient information
    case 'subjectname'
        obj.userName = val;
        % if (ischar(val))
        %     obj.userName = val;
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a string');
        % end

    case 'subjectsex'
        obj.userSex = val;
        % if (ischar(val))
        %     obj.userSex = val;
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a string');
        % end

    case 'subjectbirthdate'
        obj.userBirthDate = datenum(val);
        % if (ischar(val) || isvector(val) || isscalar(val))
        %     obj.userBirthDate = datenum(val);
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a date (whether a string, datevec or datenum).');
        % end

    case 'subjectage'
        obj.userAge = val;
        % if (isscalar(val) && isreal(val))
        %     obj.userAge = val;
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be numeric');
        % end
        
%Analysis information (for presentation only)
    case 'analyzemode'
        obj.analyzeMode = val;
        % if (ischar(val))
        %     obj.analyzeMode = val;
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a string');
        % end
        
    case 'pretime'
        obj.preTime = val;
        % if (isscalar(val) && (floor(val)==val) && val>0)
        %     obj.preTime = val;
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a positive integer');
        % end

    case 'posttime'
        obj.postTime = val;
        % if (isscalar(val) && (floor(val)==val) && val>0)
        %     obj.postTime = val;
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a positive integer');
        % end

    case 'recoverytime'
        obj.recoveryTime = val;
        % if (isscalar(val) && (floor(val)==val) && val>0)
        %     obj.recoveryTime = val;
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a positive integer');
        % end

    case 'basetime'
        obj.baseTime = val;
        % if (isscalar(val) && (floor(val)==val) && val>0)
        %     obj.baseTime = val;
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a positive integer');
        % end

    case 'fittingdegree'
        obj.fittingDegree = val;
        % if (isscalar(val) && (floor(val)==val) && val>0)
        %     obj.fittingDegree = val;
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a positive integer');
        % end

    case 'hpf'
        obj.hpf = val;
        
    case 'lpf'
        obj.hpf = val;
        
    case 'movingaverage'
        obj.movingAvg = val;
        % if (isscalar(val) && val>0)
        %     obj.movingAvg = val;
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a positive real number in [s].');
        % end

%Measure information
    case 'wlengths'
        obj.wLengths = val;
    case 'nominalwavelenghtset'
        obj.wLengths = val;
            warning('ICNA:rawData_ETG4000:set:Deprecated',...
                    ['The use of ''nominalWavelenghtSet'' has been deprecated. ' ...
                    'Please use ''wLengths'' instead.']);
        % if (isvector(val) && isreal(val))
        %     obj.wLengths = val;
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a vector of wavelengths in nm.');
        % end

%     case 'probemode'
%         if (ischar(val))
%             obj.probeMode = val;
%         else
%             error('Value must be a string');
%         end
% 
%     case 'nchannels'
%         if (isscalar(val) && (floor(val)==val) ...
%                 && val>0)
%             obj.nChannels = val;
%         else
%             error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
%                  'Value must be a positive integer');
%         end


    case 'samplingperiod'
        obj.samplingPeriod = val;
        % if (isscalar(val) && isreal(val) && val>0)
        %     obj.samplingPeriod = val;
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a positive real');
        % end

    case 'samplingrate'
        obj.samplingPeriod = 1/val;
        % if (isscalar(val) && isreal(val) && val>0)
        %     obj.samplingPeriod = 1/val;
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a positive real');
        % end
        
	case 'nblocks'
        obj.repeatCount = val;
        % if (isscalar(val) && (floor(val)==val) && val>0)
        %     obj.repeatCount = val;
            warning('ICNA:rawData_ETG4000:set:Deprecated',...
                    ['The use of ''nBlocks'' has been deprecated. ' ...
                    'Please use ''repeatCount'' instead.']);
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a positive integer.');
        % end
        
    case 'repeatcount'
        obj.repeatCount = val;
        % if (isscalar(val) && (floor(val)==val))
        %     obj.repeatCount = val;
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a positive integer or 0.');
        % end
        
%The data itself!!
    case 'lightrawdata'
        if (isreal(val) && size(val,3)==length(obj.probesetInfo))
            obj.lightRawData = val;
                %Note that the size along the 3rd dimension is expected to
                %match the number of probes sets declared.
                %See assertInvariants
        else
            error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Size of data is expected to match the number of probes sets declared.');
        end
        
    case 'marks'
        if (all(floor(val)==val) && all(val>=0))
            obj.marks = val;
                %Note that the number of columns is expected to
                %match the number of probes sets declared.
                %See assertInvariants
        else
            error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a matrix positive integer.');
        end

    case 'timestamps'
        if (all(val>=0))
            obj.timestamps = val;
                %Note that the number of columns is expected to
                %match the number of probes sets declared.
                %See assertInvariants
        else
            error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a matrix positive integer.');
        end

    case 'bodymovement'
        if (all(floor(val)==val) && all(val>=0))
            obj.bodyMovement = val;
                %Note that the number of columns is expected to
                %match the number of probes sets declared.
                %See assertInvariants
        else
            error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a matrix positive integer.');
        end

    case 'removalmarks'
        if (all(floor(val)==val) && all(val>=0))
            obj.removalMarks = val;
                %Note that the number of columns is expected to
                %match the number of probes sets declared.
                %See assertInvariants
        else
            error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a matrix positive integer.');
        end

    case 'prescan'
        if (all(floor(val)==val) && all(val>=0))
            obj.preScan = val;
                %Note that the number of columns is expected to
                %match the number of probes sets declared.
                %See assertInvariants
        else
            error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a matrix positive integer.');
        end



   otherwise
        obj=set@rawData(obj, prop, val);
   end
end
