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

%% Log
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 20-February-2022 (ESR): We simplify the code
%   + All cases are in the experimentSpace class.
%   + We create a dependent property inside the experimentSpace class.
%   + The nPoints and numPoints  properties are inside of the
%   experimentSpace class.
%
% 24-March-2022 (ESR): Lowercase
%   + These cases are to convert the capitalization to lower case so that 
%   they can all be called correctly.

propertyArgIn = varargin;
    while (length(propertyArgIn) >= 2)
       prop = propertyArgIn{1};
       val = propertyArgIn{2};
       propertyArgIn = propertyArgIn(3:end);
       
       tmp = lower(prop);
    
        switch (tmp)

           case 'baselinesamples'
                obj.baselineSamples = val;
           case 'description'
                obj.description = val;  
           case {'ws_onset','fwonset'}
                obj.fwOnset = val;
           case {'ws_duration','fwduration'}
                obj.fwDuration = val;
           case {'ws_breakdelay','fwbreakdelay'}
                obj.fwBreakDelay = val;
           case 'id'
                obj.id = val;
           case 'name'
                obj.name = val;
           case 'normalizationdimension'
                obj.normalizationDimension = val;
           case 'normalizationmethod'
                obj.normalizationMethod = val;     
           case 'normalizationmean'
                obj.normalizationMean = val;
           case 'normalizationmin'
                obj.normalizationMin = val;
           case 'normalizationmax'
                obj.normalizationMax = val;  
           case 'normalizationscope'
                obj.normalizationScope = val;
           case 'normalizationvar'
                obj.normalizationVar = val;
           case {'averaged','performaveraging'}
                obj.performAveraging = val;
           case {'resampled','performresampling'}
                obj.performResampling = val; 
           case {'windowed','performfixwindow'}
                obj.performFixWindow = val;
           case {'normalized','performnormalization'}
                obj.performNormalization = val;
           case 'restsamples'
                obj.restSamples = val; 
           case {'rs_baseline','rsbaseline'}
                obj.rsBaseline = val;
           case {'rs_task','rstask'}
                obj.rsTask = val; 
           case {'rs_rest','rsrest'}
                obj.rsRest = val;
           case 'sessionnames'
                obj.sessionNames = val; 

            otherwise
                error('ICNA:experimentSpace:set',...
                ['Property ' prop ' not valid.'])
        end
    end
    assertInvariants(obj);
end
