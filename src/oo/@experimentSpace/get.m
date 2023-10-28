function val = get(obj, propName)
% EXPERIMENTSPACE/GET DEPRECATED (v1.2). Get properties from the specified object
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
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also experimentSpace, set
%



%% Log
%
% File created: 12-Jun-2008
% File last modified (before creation of this log): 4-Jan-2013
%
% 7-Jun-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%   + Error codes changed from ICNA to ICNNA.
%

warning('ICNNA:experimentSpace:get:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for accessing the attribute ' ...
         'e.g. experimentSpace.' lower(propName) '.']); 
    %Maintain method by now to accept different capitalization though.



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
    case 'windowed' %THIS HAS NOT BEEN TRANSLATED TO STRUCT LIKE SYNTAX INTENTIONALLY AS IT WAS ALREADY DEPRECATED.
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
        val = obj.rs_baseline;
    case 'rs_task'
        val = obj.rs_task;
    case 'rs_rest'
        val = obj.rs_rest;
    case 'ws_onset'
        val = obj.ws_onset;
    case 'ws_duration'
        val = obj.ws_duration;
    case 'ws_breakdelay'
        val = obj.ws_breakDelay;
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
        val = obj.numPoints;
    case 'npoints'
        val = obj.nPoints;
    otherwise
        error('ICNNA:experimentSpace:get',...
            [propName,' is not a valid property']);
end



end