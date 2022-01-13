function val = get(obj, propName)
% EXPERIMENTSPACE/GET Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%
%% Properties
%
%   'ID' - The experimentSpace identifier
%   'Name' - A name for the experimentSpace
%   'Description' -  A brief description of the experimentSpace
%   'SessionNames' - A struct with the session names
%   'RunStatus' - True if the experimentSpace has been computed
%       with the current configuration.
%   'Resampled' - True if resampling stage takes place. False otherwise
%   'Averaged' - True if averaging stage takes place. False otherwise
%   'Windowed' - DEPRECATED. True if window selection stage takes place.
%       False otherwise
%   'Normalized' - True if normaliztion stage takes place. False otherwise
%
%   'BaselineSamples' - Number of samples to be collected in
%       the baseline during the block splitting stage.
%   'RestSamples' - Maximum number of samples to be collected from
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
%   'WS_BreakDelay' - Window selection stage break delay of the window.
%   'NormalizationMethod' - Window normalization stage method.
%   'NormalizationMean' - Window normalization stage mean value
%       after normalization. Only valid if normalization method
%       is set to 'normal'.
%   'NormalizationVar' - Window normalization stage variance value
%       after normalization. Only valid if normalization method
%       is set to 'normal'.
%   'NormalizationMin' - Window normalization stage range minimum
%       value after normalization. Only valid if normalization method
%       is set to 'range'.
%   'NormalizationMax' - Window normalization stage range maximum
%       value after normalization. Only valid if normalization method
%       is set to 'range'.
%   'NormalizationScope' - Window normalization stage scope.
%   'NormalizationDimension' - Window normalization stage dimension.
%
% ==Derived attributes
%   'NumPoints' - DEPRECATED Get the number of points in the Experiment Space
%       Please use get(obj,'nPoints') instead.
%   'nPoints' - Get the number of points in the Experiment Space
%
%
% Copyright 2008-13
% @date: 12-Jun-2008
% @author Felipe Orihuela-Espina
% @modified: 4-Jan-2013
%
% See also experimentSpace, set
%

switch lower(propName)
    case 'id'
        val = obj.id;
    case 'name'
        val = obj.name;
    case 'description'
        val = obj.description;
    case 'sessionnames'
        val = obj.sessionNames;
    case 'runstatus'
        val = obj.runStatus;
    case 'averaged'
        val = obj.performAveraging;
    case 'resampled'
        val = obj.performResampling;
    case 'windowed'
        val = obj.performFixWindow;
        warning('ICNA:experimentSpace:set',...
                  ['This has been DEPRECATED. ' ...
                  'Please refer to experimentSpace class ' ...
                  'documentation.']);
    case 'normalized'
        val = obj.performNormalization;
    case 'baselinesamples'
        val = obj.baselineSamples;
    case 'restsamples'
        val = obj.restSamples;
    case 'rs_baseline'
        val = obj.rsBaseline;
    case 'rs_task'
        val = obj.rsTask;
    case 'rs_rest'
        val = obj.rsRest;
    case 'ws_onset'
        val = obj.fwOnset;
    case 'ws_duration'
        val = obj.fwDuration;
    case 'ws_breakdelay'
        val = obj.fwBreakDelay;
    case 'normalizationmethod'
        val = obj.normalizationMethod;
    case 'normalizationmean'
        val = obj.normalizationMean;
    case 'normalizationvar'
        val = obj.normalizationVar;
    case 'normalizationmin'
        val = obj.normalizationMin;
    case 'normalizationmax'
        val = obj.normalizationMax;
    case 'normalizationscope'
        val = obj.normalizationScope;
    case 'normalizationdimension'
        val = obj.normalizationDimension;
% ==Derived attributes
    case 'numpoints'
        warning('ICNA:experimentSpace:get:Deprecated',...
            ['The use of numPoints has now been deprecated. ' ...
            'Please use get(obj,''nPoints'') instead.']);
        val = size(obj.Findex,1);
    case 'npoints'
        val = size(obj.Findex,1);
    otherwise
        error('ICNA:experimentSpace:get',...
            [propName,' is not a valid property']);
end