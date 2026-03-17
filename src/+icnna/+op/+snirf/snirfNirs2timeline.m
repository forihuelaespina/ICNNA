function t = snirfNirs2timeline(obj,options)
%SNIRFNIRS2TIMELINE Extract timeline from SNIRF dataset
%
% t = icnna.op.snirf.snirfNirs2timeline(obj,options)
%
% Extracts timestamps and experimental conditions from a SNIRF dataset
% and returns a timeline object.
%
% The output can be either:
%   - @timeline
%   - @icnna.data.core.timeline
%
% The SNIRF stimuli are converted into timeline conditions/events.
%
%
%% Input Parameters
%
% obj - A SNIRF dataset object:
%       @icnna.data.snirf.snirf | @icnna.data.snirf.nirs
%
% options - Optional. Struct with fields:
%   .nirsDatasetIndex  - int. Default is 1.
%       Dataset index to use if obj is of class @icnna.data.snirf.snirf.
%
%   .outputClass - char[]. Default is 'icnna.data.core.timeline'
%       Type of timeline output. Options are:
%       * 'timeline' - DEPRECATED CLASS
%       * 'icnna.data.core.timeline'
%
%   .allowOverlappingConditions - bool. Default is true
%       Initialize the conditions overlapping behaviour.
%       See class @timeline | @icnna.data.core.timeline for further
%       details.
%
%       +=====================================================+
%       | WATCH OUT!! This flag is "inverted" with regards to |
%       | timeline's exclusory property. Allowing overlapping |
%       | conditions i.e. this property being 'true', means   |
%       | that timeline exclusory will be set to false, and   |
%       | viceversa.                                          |
%       +=====================================================+
%
%
%% Output
% 
% t - @icnna.data.core.timeline | @timeline
%   The timeline object containing timestamps and conditions/events.
%
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also icnna.data.core.timeline, timeline
%

%% Log
%
% -- ICNNA v1.4.1
%
% 5-Mar-2026: FOE
%   + File created.
%
% 14-Mar-2026: FOE
%   + Bug fixed: Conditions were being created but not saved back to the
%   timeline, so timeline was being returned basically empty.
%   + Bug fixed: All conditions were being created with |id|=1 hence
%   upon trying to add a second conditions, the subsequent invariants
%   check on the timeline failed as conditions are meant to have
%   different |id|.
%   + Bug fixed: I was not correctly "inverting" the
%   allowOverlappingConditions to correctly set the exclusory behaviour.
%   + Bug fixed: Timeline was being created in 'samples' instead of
%   'seconds' (note that snirf ALWAYS uses some multiple of seconds,
%   and never uses 'samples').
%   + Bug fixed: When checking the dataLabels, I was checking the
%   presence of 'dataLabels' using isfield rather than isprop despite
%   the stim being an object and not a struct.
%


%% Deal with options
opt = struct();
opt.allowOverlappingConditions = true;
opt.nirsDatasetIndex           = 1;
opt.outputClass                = 'icnna.data.core.timeline';
if exist('options','var') && isstruct(options)
    if isfield(options,'allowOverlappingConditions')
        opt.allowOverlappingConditions = options.allowOverlappingConditions;
    end
    if isfield(options,'nirsDatasetIndex')
        opt.nirsDatasetIndex = options.nirsDatasetIndex;
    end
    if isfield(options,'outputClass')
        opt.outputClass = lower(options.outputClass);
    end
end

% Validate outputClass
if ~ismember(opt.outputClass,{'timeline','icnna.data.core.timeline'})
    error('icnna:op:snirfNirs2timeline:InvalidOption',...
        'Option .outputClass must be either ''icnna.data.core.timeline'' or ''timeline''.');
end

% Validate allowOverlappingConditions
if ~ismember(opt.allowOverlappingConditions,[false,true])
    error('icnna:op:snirfNirs2timeline:InvalidOption',...
        'Option .allowOverlappingConditions must be false or true.');
end


%% Resolve dataset
if isa(obj,'icnna.data.snirf.snirf')
    if opt.nirsDatasetIndex > length(obj.nirs) || opt.nirsDatasetIndex <= 0
        error('icnna:op:snirfNirs2timeline:InvalidOption',...
            ['Dataset ' num2str(opt.nirsDatasetIndex) ' not found in SNIRF container.']);
    end
    tmpNirs = obj.nirs(opt.nirsDatasetIndex);

elseif isa(obj,'icnna.data.snirf.nirsDataset')
    tmpNirs = obj;

else
    error('icnna:op:snirfNirs2timeline:InvalidInput',...
        ['Unsupported input type: ' class(obj)]);
end



%% Resolve temporal units
% Default to seconds if no metadata is available
tUnit = 1;

% Check if metaDataTags exist directly in tmpNirs
if isfield(tmpNirs,'metaDataTags') && ...
        isstruct(tmpNirs.metaDataTags) && ...
        isfield(tmpNirs.metaDataTags,'TimeUnit')

    timeUnitStr = tmpNirs.metaDataTags.TimeUnit;

    switch lower(timeUnitStr)
        case 's'
            tUnit = 1;
        case 'ms'
            tUnit = 1e-3;
        case 'us'
            tUnit = 1e-6;
        otherwise
            warning('icnna:op:snirfNirs2timeline:UnknownTemporalUnit', ...
                ['Unknown SNIRF TimeUnit "' timeUnitStr '" - assuming seconds.']);
            tUnit = 1;
    end
end




%% Extract time information
timestamps = tmpNirs.data.time;
nSamples   = length(timestamps);


%% Create timeline object
switch opt.outputClass
    case 'icnna.data.core.timeline'
        t = icnna.data.core.timeline();
    case 'timeline'
        t = timeline(nSamples);
    otherwise
        error('icnna:op:snirfNirs2timeline:InvalidInput',...
            ['Unsupported output type: ' opt.outputClass]);
end
%snirf does not use samples. It always use some multiple of seconds
t.unit = 'seconds';

%% Retrieve timestamps
t.timestamps = timestamps * tUnit; % Apply multiplier to timestamps


%% Determine nominal sampling rate
if isa(t,'icnna.data.core.timeline')
    t.nominalSamplingRate = t.averageSamplingRate;
else
    t.nominalSamplingRate = t.samplingRate;
end


%% Convert SNIRF stimuli to timeline conditions

%Add one stimulus/condition at a time
nStims = length(tmpNirs.stim);
for iStim = 1:nStims
    tmpStim = tmpNirs.stim(iStim);
    cTag = tmpStim.name;

    % Attempt to decipher the semantic of the columns in the stimulus.
    onsetCol    = 1;
    durationCol = 2;
    ampCol      = 3;
    if isprop(tmpStim,'dataLabels') && ~isempty(tmpStim.dataLabels)
        onsetCol    = find(ismember(lower(tmpStim.dataLabels), ...
                                        {'onset', 'starttime'}),1,'first');
        durationCol = find(strcmpi(tmpStim.dataLabels,'duration'),1,'first');
        ampCol      = find(strcmpi(tmpStim.dataLabels,'amplitude'),1,'first');
    end

    if ~isempty(tmpStim.data)
    
        % Extract columns safely
        onsets   = tmpStim.data(:,onsetCol) * tUnit;
        if ~isempty(durationCol) && durationCol <= size(tmpStim.data,2)
            durations = tmpStim.data(:,durationCol) * tUnit;
        else
            durations = zeros(size(onsets));
        end
        if ~isempty(ampCol) && ampCol <= size(tmpStim.data,2)
            amplitudes = tmpStim.data(:,ampCol);
        else
            amplitudes = ones(size(onsets));
        end
    
        % Convert to samples if using legacy timeline
        % or if icnna.data.core.timeline is in samples
        if isa(t,'timeline') || strcmp(t.unit,'samples')
            onsets     = round(onsets * t.nominalSamplingRate);
            durations  = round(durations * t.nominalSamplingRate);
        end
    
    else
        onsets = [];
        durations = [];
        amplitudes = [];
    end

    % Set the exclusory behaviour to the invert of
    % "allowOverlappingConditions"
    tmpExclusory = ~opt.allowOverlappingConditions;

    if isa(t,'icnna.data.core.timeline')
        events       = [onsets durations amplitudes];
        tmpCond      = icnna.data.core.condition();
        tmpCond.id   = iStim;
        tmpCond.name = cTag;
        tmpCond      = tmpCond.addEvents(events);
        
        t = t.addConditions(tmpCond,tmpExclusory);
    else
        events = [onsets durations];
        t = t.addCondition(cTag,events,tmpExclusory);
    end
end

end