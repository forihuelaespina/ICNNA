function obj = set(obj,varargin)
% EXPERIMENTSPACE/SET Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%% Properties
%
%   'ID' - The experimentSpace identifier
%   'Name' - A name for the experimentSpace
%   'Description' -  A brief description of the experimentSpace
%   'SessionNames' - A struct with the session names
%
% Modifying any of the following sets run status to false.
%
%   'Resampled' - True if resampling stage takes place. False otherwise
%   'Averaged' - True if averaging stage takes place. False otherwise
%   'Windowed' - DEPRECATED. True. A warning is issued if
%       this value is attempted to be written.
%   'Normalized' - True if normalization stage takes place.
%       False otherwise
%
%   'BaselineSamples' - Number of samples to be collected in
%       the baseline during the block splitting stage.
%   'RestSamples' - Maximum number of samples to be collected for
%       the rest during the block splitting stage.
%   'RS_Baseline' - Resampling stage number of samples for the baseline
%       in each block.
%   'RS_Task' - Resampling stage number of samples for the task
%       in each block.
%   'RS_Rest' - Resampling stage number of samples for the
%       rest in each block.
%   'WS_Onset' - Window selection stage number of samples from the
%       onset of the task in the block to start the window.
%   'WS_Duration' - Window selection stage duration of the window.
%   'WS_BreakDelay' - Window selection stage break delay ignored
%       samples from the stimulus onset.
%   'NormalizationMethod' - Normalization stage parameter.
%       Indicates normalization method; either 'normal' or
%       'range'.
%   'NormalizationMean' - Normalization stage parameter.
%       Indicates the desired mean after normalization.
%       This is only valid if the normalization method is 'normal'.
%   'NormalizationVar' - Normalization stage parameter.
%       Indicates the desired variance after normalization.
%       This is only valid if the normalization method is 'normal'.
%   'NormalizationMin' - Normalization stage parameter.
%       Indicates the desired range minimum after normalization.
%       This is only valid if the normalization method is 'range'.
%   'NormalizationMax' - Normalization stage parameter.
%       Indicates the desired range maximum after normalization.
%       This is only valid if the normalization method is 'range'.
%   'NormalizationScope' - Normalization stage parameter.
%       Indicates normalization scope; either 'individual' or
%       'collective'.
%   'NormalizationDimension' - Normalization stage parameter.
%       Indicates normalization dimesion; either 'channel',
%       'signal', or 'combined'.
%
% Copyright 2008-9
% @date: 13-Jun-2008
% @author Felipe Orihuela-Espina
%
% See also experimentSpace, get
%

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch lower(prop)
    case 'id'
        if (isscalar(val) && isreal(val) && ~ischar(val) ...
            && (val==floor(val)) && (val>0))
            %Note that a char which can be converted to scalar
            %e.g. will pass all of the above (except the ~ischar)
            obj.id = val;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer.');
        end
        
    case 'name'
        if (ischar(val))
            obj.name = val;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be a string');
        end

    case 'description'
        if (ischar(val))
            obj.description = val;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be a string');
        end

    case 'sessionnames'
        if (isstruct(val) && isfield(val,'sessID') && isfield(val,'name'))
            obj.sessionNames = val;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be a struct with fields .sessID and .name');
        end

%     case 'runstatus'
%         if (isscalar(val))
%             obj.runStatus = logical(val);
%         else
%             error('ICNA:experimentSpace:set',...
%                   'Value must be a logical scalar.');
%         end

    case 'averaged'
        if (isscalar(val))
            obj.performAveraging = logical(val);
            obj.runStatus = false;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be a logical scalar.');
        end
    case 'resampled'
        if (isscalar(val))
            obj.performResampling = logical(val);
            obj.runStatus = false;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be a logical scalar.');
        end
    case 'windowed'
        warning('ICNA:experimentSpace:set',...
                  ['This has been DEPRECATED. ' ...
                  '''Windowed'' parameter can no longer ' ...
                  'be set. Please refer to experimentSpace class' ...
                  'documentation.']);
    case 'normalized'
        if (isscalar(val))
            obj.performNormalization = logical(val);
            obj.runStatus = false;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be a logical scalar.');
        end
        
    case 'baselinesamples'
        if (isscalar(val) && isreal(val) ...
                && (floor(val)==val) && val>0)
            obj.baselineSamples = val;
            obj.runStatus = false;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer or 0.');
        end
        
    case 'restsamples'
        if (isscalar(val) && isreal(val) ...
                && (floor(val)==val))
            %Rest samples can be negative; meaning that all samples
            %will be collected until the next onset
            obj.restSamples = val;
            obj.runStatus = false;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer or 0.');
        end
        
    case 'rs_baseline'
        if (isscalar(val) && isreal(val) ...
                && (floor(val)==val) && val>=0)
            obj.rsBaseline = val;
            obj.runStatus = false;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer.');
        end
    case 'rs_task'
        if (isscalar(val) && isreal(val) ...
                && (floor(val)==val) && val>=0)
            obj.rsTask = val;
            obj.runStatus = false;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer or 0.');
        end
    case 'rs_rest'
        if (isscalar(val) && isreal(val) ...
                && (floor(val)==val) && val>=0)
            obj.rsRest = val;
            obj.runStatus = false;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer or 0.');
        end
    case 'ws_onset'
        if (isscalar(val) && isreal(val) ...
                && (floor(val)==val)  && ~ischar(val))
            obj.fwOnset = val;
            obj.runStatus = false;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be an integer scalar.');
        end
    case 'ws_duration'
        if (isscalar(val) && isreal(val) ...
                && (floor(val)==val) && val>=0 && ~ischar(val))
            obj.fwDuration = val;
            obj.runStatus = false;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer or 0.');
        end
        
    case 'ws_breakdelay'
        if (isscalar(val) && isreal(val) && val>=0 ...
                && (floor(val)==val) && ~ischar(val))
            obj.fwBreakDelay = val;
            obj.runStatus = false;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer or 0.');
        end
        
    case 'normalizationmethod'
        switch(lower(val))
            case 'normal'
                obj.normalizationMethod = 'normal';
            case 'range'
                obj.normalizationMethod = 'range';
            otherwise
                error('ICNA:experimentSpace:set',...
                  ['Valid normalization methods are ' ...
                  '''normal'' or ''range''.']);
        end
        obj.runStatus = false;
        
    case 'normalizationmean'
        if (isscalar(val) && isreal(val) && ~ischar(val))
            obj.normalizationMean = val;
            obj.runStatus = false;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be an integer.');
        end
        
    case 'normalizationvar'
        if (isscalar(val) && isreal(val) && val>=0 ...
                && ~ischar(val))
            obj.normalizationVar = val;
            obj.runStatus = false;
        else
            error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer or 0.');
        end
        
    case 'normalizationmin'
        if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && val<obj.normalizationMax)
            obj.normalizationMin = val;
            obj.runStatus = false;
        else
            error('ICNA:experimentSpace:set',...
                  ['Value must be an integer and greater than ' ...
                  'the NormalizationMax.']);
        end
        
    case 'normalizationmax'
        if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && val>obj.normalizationMin)
            obj.normalizationMax = val;
            obj.runStatus = false;
        else
            error('ICNA:experimentSpace:set',...
                  ['Value must be an integer and greater than ' ...
                  'the NormalizationMin.']);
        end
        
    case 'normalizationscope'
        switch(lower(val))
            case 'blockindividual'
                obj.normalizationScope = 'blockindividual';
            case 'individual'
                obj.normalizationScope = 'individual';
            case 'collective'
                obj.normalizationScope = 'collective';
            otherwise
                error('ICNA:experimentSpace:set',...
                  ['Valid normalization scope are ' ...
                  '''individual'' or ''collective''.']);
        end
        obj.runStatus = false;
        
    case 'normalizationdimension'
        switch(lower(val))
            case 'channel'
                obj.normalizationDimension = 'channel';
            case 'signal'
                obj.normalizationDimension = 'signal';
            case 'combined'
                obj.normalizationDimension = 'combined';
            otherwise
                error('ICNA:experimentSpace:set',...
                  ['Valid normalization scope are ' ...
                  '''individual'' or ''collective''.']);
        end
        obj.runStatus = false;

    otherwise
      error('ICNA:experimentSpace:set',...
            ['Property ' prop ' not valid.'])
   end
end
assertInvariants(obj);