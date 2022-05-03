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

%% Log
%
% 20-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the experimentSpace class.
%   + We create a dependent property inside the experimentSpace class 
%
% 24-March-2022 (ESR): Lowercase
%   + These cases are to convert the capitalization to lower case so that 
%   they can all be called correctly.
    tmp = lower(propName);
    
    switch (tmp)

           case 'baselinesamples'
                val = obj.baselineSamples;
           case 'description'
                val = obj.description;  
           case {'ws_onset','fwonset'}
                val = obj.fwOnset;
           case {'ws_duration','fwduration'}
                val = obj.fwDuration;
           case {'ws_breakdelay','fwbreakdelay'}
                val = obj.fwBreakDelay;
           case 'id'
                val = obj.id;
           case 'name'
                val = obj.name;
           case 'normalizationdimension'
                val = obj.normalizationDimension;
           case 'normalizationmethod'
                val = obj.normalizationMethod;     
           case 'normalizationmean'
                val = obj.normalizationMean;
           case 'normalizationmin'
                val = obj.normalizationMin;
           case 'normalizationmax'
                val = obj.normalizationMax;
           case 'numpoints'
                val = obj.numPoints;     
           case 'npoints'
                val = obj.nPoints;     
           case 'normalizationscope'
                val = obj.normalizationScope;
           case 'normalizationvar'
                val = obj.normalizationVar;
           case {'averaged','performaveraging'}
                val = obj.performAveraging;
           case 'resampled'
                val = obj.performResampling; 
           case {'windowed','performfixwindow'}
                val = obj.performFixWindow;
           case {'normalized','performnormalization'}
                val = obj.performNormalization;
           case 'restsamples'
                val = obj.restSamples; 
           case {'rs_baseline','rsbaseline'}
                val = obj.rsBaseline;
           case {'rs_task','rstask'}
                val = obj.rsTask; 
           case {'rs_rest','rsrest'}
                val = obj.rsRest;
           case 'runstatus'
                val = obj.runStatus;
           case 'sessionnames'
                val = obj.sessionNames; 

        otherwise 
            error('ICNA:experimentSpace:get',...
            [propName,' is not a valid property']);
    end
end