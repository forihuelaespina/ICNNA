function [R] = getActivityMatrix(db,options)
%Computes the activity matrix
%
% [R] = icnna.op.getActivityMatrix(db,options)
%
%   This function supersedes function getActivityMatrix
%
%
% The activity matrix is the outcome of a classical block design
% Task-Baseline analysis of neuroimaging data. Whilst less sophisticated
% than a full GLM-based analysis, but it remains a popular analysis because
% it excels in simplicity.
%
%
%% Remarks
%
% This function replicates (and updates) the behaviour of the legacy ICNNA
% getActivityMatrix but operates on the ICNNA database format
% from ICNNA v.1.3.1
%
% In v1.3.1 when moving from the old @experiemntSpace to the new
% @experimentBundle, ICNNA also evolved the way it encoded the database
% for subsequent statistical analysis.
%   + Originally, the information was split into a .csv strictly
%   containing numerical data e.g. all categorical were also replaced
%   by numerical proxies, and a .companion .txt file with information
%   about the columns headers and the constants used
%   + In the modern version, the database is a self contained .csv where
%   the headers are already in the .csv plus it also contains explicit
%   categorical strings.
%   + In addition, ALSO the number of columns between both versions of
%   the database has changed substantially with the new bundle being more
%   flexible and scalable.
% 
% The former database was read using 'load' whereas the new database
% is read using readtable BEFORE calling this method to calculate the
% activity matrix from the database.
% 
% Unlike the legacy function, this implementation uses column names for
% indexing.
%
%
% In contrast to the original method, this method no longer plots
% nor saves the activity matrix. Instead, this is return in the output
% parameters and other code will be responsible for plotting and saving.
%
%
%   +=========================================================+
%   | This function requires MATLAB's Statistics toolbox.     |
%   +=========================================================+
%
%
%% The activity patterns
%
% The activity patterns depend on the activity matrix type:
%
% A) For 'Combined' activity matrix i.e. using both Oxy and Deoxy data
%
% 25 activity patterns can be distinguish in total (+1 for missing):
%
%   HbO2\HHb | ++| + | 0 | - | --|
%      ------+---+---+---+---+---+
%         ++ |  1|  2|  3|  4|  5|
%      ------+---+---+---+---+---+
%          + |  6|  7|  8|  9| 10|
%      ------+---+---+---+---+---+
%          0 | 11| 12| 13| 14| 15|
%      ------+---+---+---+---+---+
%          - | 16| 17| 18| 19| 20|
%      ------+---+---+---+---+---+
%         -- | 21| 22| 23| 24| 25|
%      ------+---+---+---+---+---+
%
% Missing data is encoded as pattern 26
%
%  ++ - Increment reached statistical significance
%   + - Increment did not reach statistical significance
%   0 - No change
%   - - Decrement did not reach statistical significance
%  -- - Decrement reached statistical significance
%
%
% Thus:
%  + Pattern 5 is classical activation
%  + Pattern 21 is classical deactivation
%
%
%
% B) For signal specific activity matrices i.e. 'HbO', 'HbR', 'HbT' etc,
% 6 activity patterns can be distinguish in total:
%
%   Signal   | ++| + | 0 | - | --| Missing |
%      ------+---+---+---+---+---+---------+
%            | 1 | 2 | 3 | 4 | 5 |  6      |      
%      ------+---+---+---+---+---+---------+
%
%  ++ - Increment reached statistical significance
%   + - Increment did not reach statistical significance
%   0 - No change
%   - - Decrement did not reach statistical significance
%  -- - Decrement reached statistical significance
% Missing - Missing data
%
% Note that this expands the old 4(+1 for missing) patterns for older
% versions of ICNNA
%
%% Input Parameters
%
%  db - Table.
%   A tabulated database of descriptive statistics from an the 
%   experiment bundle S, where each row is an association in the bundle 
%   projection S.p. This can be generated using function:
%
%       iccna.op.generateDB
%
%       For each space of the total space the following statistics are 
%   calculated;
%       - Average (Mean)
%       - Median
%       - Standard deviation (Bessel corrected)
%       - Inter quantile range
%       - Time to peak (note that this assumes that entries
%       of the total space are time-series like) - expressed in samples
%       - Time to nadir (note that this assumes that entries
%       of the total space are time-series like) - expressed in samples
%       - Area under curve (note that this assumes that entries
%       of the total space are time-series like and the samples
%       are equally spaced)
%
% options - struct
%    An struct of options with the following fields:
%   .blockAveraging - Bool. Default is true
%       Boolean flag to indicate whether stats are to be computed
%       directly or first averaging across blocks/trials.
%
%       Note that block averaging may have also been previously
%       carried out at the time of computing the experimentBundle but
%       this function is oblivious to that.
%
%   .level - char[]. Default is 'unit'
%       Indicates whether analysis is conducted at experimental unit
%       level or at group level.
%       + 'unit' - Default. Conduct experimental unit level analysis.
%       + 'subject' - Reserved for future use. Conduct subject level analysis.
%           In principle, for most experiments, the subject is the experimental
%           unit, and hence this shall equate to 'unit' level analysis. But note
%           that in some cases unit and subject differ, e.g. in hyperscanning
%           experiments the experimental unit is not the  individual subject,
%           but the dyad. Right now, the experimentBundle does NOT permit
%           differentiation of the sub-unit level e.g. the subject, but this
%           is reserved for future use.
%       + 'group' - Conduct experimental group level analysis.
%
%   .multipleCorrection - char[]. Default is 'none'
%       Indicates whether corrections for multiple testing should be
%       applied. 
%       Multiple comparison correction is applied across channels within each
%       row (i.e. per unit/session/condition[/trial]). The correction is
%       applied independently per signal prior to establishing the activity
%       pattern. In the combined case, HbO and HbR are corrected separately
%       before joint pattern mapping. 
%       Valid options are:
%       + 'none' - no correction (default behaviour for historical
%           compatibility reasons)
%       + 'bonferroni' - Very strict, controls family-wise error rate (FWER)
%       + 'fdr' (Benjamini-Hochberg) - Less conservative than Bonferroni. It
%           controls for the false discovery rate. Althouhg this is not the
%           default for historical reasons of ICNNA, but this is the one
%           recommended in many neuroimaging contexts).
%
%   .significanceLevel -  Perform statistical tests at the indicated
%       significance level. Default values is 0.05 i.e. alpha=5% (p<0.05)
%
%   .test - char[]. Default is signrank.
%       The statistical test to be used. Possible values are:
%       + 'signrank' - Default. Wilcoxon Sing Rank test
%       + 'ttest' - PENDING
%       + 'ttest2' - PENDING
%
%
%% Ouput
%
% R - Struct
%   Structured container holding the activity analysis results.
%   One field per signal (e.g. 'HbO', 'HbR', 'HbT', etc.), and an
%   additional field 'combined' when both HbO and HbR are present.
%
%   Each signal field R.(signal) contains:
%
%       .patterns      % Table [nRows x nChannels]
%                      % Numeric activity pattern identifiers.
%
%       .labels        % Table [nRows x nChannels]
%                      % Human-readable pattern labels.
%
%       .sign          % Table [nRows x nChannels]
%                      % Direction of change:
%                      %   +1 = increase (mean(Task - Baseline) > 0)
%                      %    0 = no change
%                      %   -1 = decrease (mean(Task - Baseline) < 0)
%
%       .p_raw         % Table [nRows x nChannels]
%                      % Raw (uncorrected) p-values from statistical tests.
%
%       .p             % Table [nRows x nChannels]
%                      % Corrected p-values after multiple comparison correction.
%
%       .q             % Table [nRows x nChannels]
%                      % Q-values (only valid if 'fdr' correction is used).
%                      % Otherwise NaN.
%
%       .effect        % Table [nRows x nChannels]
%                      % Effect size per channel.
%                      % Definition depends on the statistical test:
%                      %   - signrank -> robust median/MAD approximation
%                      %   - ttest    -> Cohen's d (paired)
%                      %   - ttest2   -> Cohen's d (independent)
%
%       .significant   % Table [nRows x nChannels]
%                      % Boolean matrix indicating statistical significance:
%                      %   true  if p < alpha
%                      %   false otherwise
%
%
%   Combined case: R.combined
%
%       .patterns      % Table [nRows x nChannels]
%                      % 25-pattern encoding combining HbO and HbR
%                      % (+1 pattern for missing data)
%
%       .labels        % Table [nRows x nChannels]
%                      % Labels of the form:
%                      %   "HbO:<state> | HbR:<state>"
%
%       .sign          % Table [nRows x (2*nChannels)]
%                      % Concatenated sign matrix:
%                      %   [HbO_sign ; HbR_sign]
%
%       .p_raw         % Table [nRows x (2*nChannels)]
%                      % Raw p-values for HbO and HbR
%                      % columns = signals (HbO, HbR)
%
%       .p             % Table [nRows x (2*nChannels)]
%                      % Corrected p-values for HbO and HbR
%                      % columns = signals (HbO, HbR)
%
%       .q             % Table [nRows x (2*nChannels)]
%                      % Q-values (if applicable)
%                      % columns = signals (HbO, HbR)
%
%       .effect        % Table [nRows x nChannels]
%                      % Not defined for combined patterns (NaN)
%
%       .significant   % Table [nRows x (2*nChannels)]
%                      % Per-signal significance
%                      % columns = signals (HbO, HbR)
%
%       .jointSignificant   % Table [nRows x nChannels]
%                      % Per-pattern significance
%                      % A channel is "joint significant" if:
%                      % + HbO significant AND HbR significant
%                      % + AND directions are opposite
%                      % At present, this is a heuristic indicator of
%                      % canonical neurovascular coupling, not a formal joint
%                      % statistical test, but it is reserved to be
%                      % replaced for a proper mutivariate test in the
%                      % future.
%
%   Meta-data:
%
%       R.meta.options   % Options used for computation
%       R.meta.channels  % Channel IDs
%       R.meta.rowNames  % Row identifiers (unit/session/condition/trial)
%
%   Notes:
%       - Rows correspond to experimental units (or groups), sessions,
%       conditions, and optionally trials depending on options.
%       - Multiple comparison correction is applied across channels
%         independently per signal before pattern classification.
%       - Combined patterns are derived after per-signal correction.
%
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.experimentBundle, icnna.io.exportActivityMatrix
%


%% Log
%
%  -- ICNNA v1.4.1
%
% 19-Mar-2026: FOE
%   + File created. Refactored some code from old function
%   getActivityMatrix
%   + Added support for block averaging and analysis level (unit/group)
%   + Generalized to retrieve an activity matrix per signal available
%   in the database (and dropped option .type which is no longer needed)
%   + Note that the output types are now struct of tables rather than
%   arrays.
%   + Added outputs;
%       * L with activity decoded labels,
%       * Q with Q values in case of FDR multiple corrections
%       * P_raw to expose raw p values in case of multiple corrections
%       * E with effect size (which effect size is computed depends on
%           the statistical test.
%   + Refactored all outputs under R
%





% -------------------------------------------------------------------------
% NOTES / FUTURE EXTENSIONS
% -------------------------------------------------------------------------
% - Future:
%       * Hotelling T² (joint HbO/HbR inference)
%       * ANOVA / ANCOVA across groups
%       * Mixed-effects models (subject-level variance)
%
% - Region of interest analysis
%



%% Deal with options
opt.blockAveraging = true; %Indicated whether to carry out (or not) block averaging
opt.level = 'unit';    %Experimental unit vs Subject vs Group level analysis
opt.multipleCorrection = 'none'; 
opt.significanceLevel = 0.05;
opt.test = 'signrank';   % Choice of test

if nargin > 1
    if isfield(options,'blockAveraging')
        opt.blockAveraging = options.blockAveraging;
    end
    if isfield(options,'level')
        opt.level = lower(options.level);
    end
    if isfield(options,'multipleCorrection')
        opt.multipleCorrection = lower(options.multipleCorrection);
    end
    if isfield(options,'significanceLevel')
        opt.significanceLevel = options.significanceLevel;
    end
    if isfield(options,'test')
        opt.test = lower(options.test);
    end
end


%% -- Retrieve list of signals
signalNames = unique(db.("Signal.name"))';
signalIDs   = containers.Map;

for iSig = 1:length(signalNames)
    sig = signalNames{iSig};
    tmp = db(strcmp(db.("Signal.name"),sig),:);
    assert(isscalar(unique(tmp.("Signal.id"))),...
        ['Signal |id| inconsistent for ' sig]);
    signalIDs(sig) = tmp.("Signal.id")(1);
end


% Check whether the combined case (HbO + HbR) has to be added
hasHbO = isKey(signalIDs,'HbO');
hasHbR = isKey(signalIDs,'HbR');



%% -- EXTRACT DIMENSIONS --------------------
sessions  = unique(db.("Session.id"))';
channels  = unique(db.("SamplingSite.id"))';

nChannels = length(channels);

% Prepare storage 
R = struct();
rowNames = {}; %Cell array
rowIdx = 0;


allOutputs = [signalNames];
if hasHbO && hasHbR
    allOutputs{end+1} = 'combined';
end



for out = allOutputs %(cell-based before conversion to table)
    field = matlab.lang.makeValidName(out{1});

    R.(field).patterns = {};
    R.(field).labels   = {};
    R.(field).sign     = {};

    R.(field).p        = {};
    R.(field).p_raw    = {};
    R.(field).q        = {};
    R.(field).effect   = {};
    R.(field).significant = {};
end



%% -- Main loop --------------------
for sess = sessions
    db_sess = db(db.("Session.id")==sess,:);

    % Decide grouping depending on level
    switch opt.level
        case 'unit'
            units = unique(db_sess.("ExperimentalUnit.id"))';
        case 'group'
            units = unique(db_sess.("Group.id"))';
        otherwise
            error('Unsupported level.');
    end



    for unit = units

        
        % Filter unit WITH session explicitly (correctness fix)
        switch opt.level
            case 'unit'
                db_unit = db_sess(db.("ExperimentalUnit.id")==unit,:);
                unit_name = string(unique(db_unit.("ExperimentalUnit.name")));
            case 'group'
                db_unit = db_sess(db.("Group.id")==unit,:);
                unit_name = string(unique(db_unit.("Group.name")));
        end
        
        
        cond_list = unique(db_unit.("Condition.id"))';

        for cond = cond_list
            db_cond   = db_unit(db_unit.("Condition.id")==cond,:);
            cond_name = string(unique(db_cond.("Condition.name")));


            % Block handling
            if opt.blockAveraging
                trials = -1;
            else
                trials = unique(db_cond.("Trial"))';
            end


            %Estimate number of rows for pre allocation
            %nRows_est = length(sessions)*length(cond_list)*length(units)*length(trials);
            %Not currently being used...

            for tr = trials

                if opt.blockAveraging
                    db_sel = db_cond;
                    suffix = "avg";
                else
                    db_sel = db_cond(db_cond.("Trial")==tr,:);
                    suffix = "tr:" + string(tr);
                end

                sess_name = string(unique(db_sel.("Session.name")));
                cond_name = string(unique(db_sel.("Condition.name")));

                %Row name follows structured delimiter JSON-like encoding robust for downstream parsing
                rowName = sprintf("U[%d|%s]_S[%d|%s]_C[%d|%s]_%s", ...
                                unit, unit_name, sess, sess_name, ...
                                cond, cond_name, suffix);

                rowIdx = rowIdx + 1;
                rowNames{rowIdx,1} = char(rowName);


                % Per-signal statistical calculations
                signalResults_sign  = struct();
                signalResults_p     = struct();
                signalResults_p_raw = struct();
                signalResults_q     = struct();
                signalResults_e     = struct();

                for sig = signalNames

                    sigName  = sig{1};
                    sigID    = signalIDs(sigName);

                    chSign   = nan(1,nChannels);
                    chP      = nan(1,nChannels);
                    chEffect = nan(1,nChannels);

                    for chIdx = 1:nChannels
                        ch = channels(chIdx);

                        idx = db_sel.("SamplingSite.id")==ch & ...
                              db_sel.("Signal.id")==sigID;

                        tmp = db_sel(idx,:);

                        if ~isempty(tmp)
                            diff = tmp.Task_Avg - tmp.Baseline_Avg;
                        
                            chSign(chIdx) = sign(mean(diff));
                            chP(chIdx) = computePvalue(tmp.Task_Avg,...
                                                       tmp.Baseline_Avg,opt);
                        
                            chEffect(chIdx) = computeEffectSize(tmp.Task_Avg,...
                                                                tmp.Baseline_Avg,...
                                                                opt);
                        end
                    end

                    field = matlab.lang.makeValidName(sigName);
                    signalResults_sign.(field)  = chSign;
                    signalResults_p_raw.(field) = chP;
                    signalResults_e.(field)     = chEffect;
                end


                % Pattern matching
                for sig = signalNames
                    field = matlab.lang.makeValidName(sig{1});

                    p_raw = signalResults_p_raw.(field);
                    [p_corr,q_vals] = applyMultipleCorrection(p_raw, ...
                                                  opt.multipleCorrection);
                    patterns = getPatterns_Single(signalResults_sign.(field),...
                                                  p_corr,...
                                                  opt.significanceLevel);
                    
                    
                    signalResults_p.(field) = p_corr; % Replace raw p-values
                                                      % with corrected
                                                      % ones.
                    signalResults_q.(field) = q_vals;

                    R.(field).patterns{rowIdx,1}     = patterns;
                    R.(field).labels{rowIdx,1}       = decodePatterns_Single(patterns);
                    R.(field).sign{rowIdx,1}         = signalResults_sign.(field);
                    R.(field).p{rowIdx,1}            = p_corr;
                    R.(field).p_raw{rowIdx,1}        = p_raw;
                    R.(field).q{rowIdx,1}            = q_vals;
                    R.(field).effect{rowIdx,1}       = signalResults_e.(field);
                    R.(field).significant{rowIdx,1}  = p_corr < opt.significanceLevel;
                end


                % -- Combined HbO/HbR
                if hasHbO && hasHbR
                    if ~isfield(signalResults_p,'HbO') || ~isfield(signalResults_p,'HbR')
                        warning("Missing HbO/HbR at row %d", rowIdx);
                    end

                    oxy   = matlab.lang.makeValidName('HbO');
                    deoxy = matlab.lang.makeValidName('HbR');

                    p_oxy_raw   = signalResults_p_raw.(oxy);
                    p_deoxy_raw = signalResults_p_raw.(deoxy);

                    %Retrieve the corrected p-values and q-values before stacking
                    p_oxy   = signalResults_p.(oxy);
                    p_deoxy = signalResults_p.(deoxy);
                    
                    q_oxy   = signalResults_q.(oxy);
                    q_deoxy = signalResults_q.(deoxy);

                    Mp_raw  = [p_oxy_raw; p_deoxy_raw];
                    Mp_corr = [p_oxy; p_deoxy];
                    Mq      = [q_oxy; q_deoxy];
                    Ms      = [signalResults_sign.(oxy); ...
                               signalResults_sign.(deoxy)];

                    %Combined patterns reflect already-corrected single-signal inference
                    patterns = getPatterns_Combined(Ms, Mp_corr, ...
                                                    opt.significanceLevel);

                    R.combined.patterns{rowIdx,1} = patterns;
                    R.combined.labels{rowIdx,1}   = decodePatterns_Combined(patterns);
                    R.combined.sign{rowIdx,1}     = Ms(:)';  % 1 x (2*nChannels)
                    R.combined.p{rowIdx,1}        = Mp_corr(:)';
                    R.combined.p_raw{rowIdx,1}    = Mp_raw(:)';
                    R.combined.q{rowIdx,1}        = Mq(:)';
                    R.combined.effect{rowIdx,1}   = nan(1,nChannels);
                        %Effect size not defined for combined patterns
                    R.combined.significant{rowIdx,1} = (Mp_corr < opt.significanceLevel);
                        %This gives per-signal significance, not per-pattern
                        %significance. See also jointSignficance below
                    R.combined.significant{rowIdx,1} = R.combined.significant{rowIdx,1}(:)';%...and unfold

                    %Combined specific subfields
                    sign_HbO = Ms(1,:);
                    sign_HHb = Ms(2,:);
                    R.combined.consistent{rowIdx,1} = ...
                        (p_oxy < opt.significanceLevel) & ...
                        (p_deoxy < opt.significanceLevel) & ...
                        (sign_HbO > 0) & ...
                        (sign_HHb < 0);
                    isJointSig = (Mp_corr < opt.significanceLevel);
                    R.combined.jointSignificant{rowIdx,1} = ...
                            (isJointSig(1,:) & isJointSig(2,:));
                        %This helps distinguish:
                        % - both significant but same direction (physiologically odd)
                        % vs
                        % - true neurovascular coupling pattern

                end

            end
        end
    end

end



%% Convert to tables

fields = fieldnames(R);

for f = 1:length(fields)
    field = fields{f};

    if strcmp(field,'meta')
        continue;
    end

    %The 'combined' makes things assymetric with some
    %entries having length nChannels and other having lenght 2*nChannels
    chNames  = compose("Ch%d",channels);
    varNames = chNames;
    if strcmp(field,'combined')
        varNames = [compose("HbO_Ch%d",channels), ...
                    compose("HbR_Ch%d",channels)];
    end

    if isempty(R.(field).patterns)
        continue;
    end

    % Core outputs
    R.(field).patterns = array2table(cell2mat(R.(field).patterns),...
        'VariableNames',chNames,...
        'RowNames',rowNames);

    R.(field).labels = array2table(vertcat(R.(field).labels{:}),...
        'VariableNames',chNames,...
        'RowNames',rowNames);

    R.(field).sign = array2table(cell2mat(R.(field).sign),...
        'VariableNames',varNames,...
        'RowNames',rowNames);

    % Stats block
    R.(field).p = array2table(cell2mat(R.(field).p),...
        'VariableNames',varNames,...
        'RowNames',rowNames);

    R.(field).p_raw = array2table(cell2mat(R.(field).p_raw),...
        'VariableNames',varNames,...
        'RowNames',rowNames);

    R.(field).q = array2table(cell2mat(R.(field).q),...
        'VariableNames',varNames,...
        'RowNames',rowNames);

    R.(field).effect = array2table(cell2mat(R.(field).effect),...
        'VariableNames',chNames,...
        'RowNames',rowNames);

    R.(field).significant = array2table(cell2mat(R.(field).significant),...
        'VariableNames',varNames,...
        'RowNames',rowNames);

    if strcmp(field,'combined')
        R.(field).consistent = array2table(cell2mat(R.(field).consistent),...
            'VariableNames',chNames,...
            'RowNames',rowNames);

        R.(field).jointSignificant = array2table(cell2mat(R.(field).jointSignificant),...
            'VariableNames',chNames,...
            'RowNames',rowNames);

    end
end

%% Add meta data

R.meta.options  = opt;
R.meta.channels = channels;
R.meta.rowNames = rowNames;


end



%% AUXILIARY FUNCTIONS

function p=getPatterns_Single(Ms,Mp,alpha)
%Convert change directions and p values to patterns
%
% 6 activity patterns can be distinguish in total:
%
%   Signal   | ++| + | 0 | - | --| Missing |
%      ------+---+---+---+---+---+---------+
%            | 1 | 2 | 3 | 4 | 5 |  6      |      
%      ------+---+---+---+---+---+---------+
%
%  ++ - Increment reached statistical significance
%   + - Increment did not reach statistical significance
%   0 - No change
%   - - Decrement did not reach statistical significance
%  -- - Decrement reached statistical significance
% Missing - Missing data
%
%% Input parameters
%
% Ms - Vector of sign (direction of change)
% Mp - Vector of p values (statistical significance)
% alpha - Optional. Statistical significance threshold (Default 0.05)
%
%% Output
%
% p - Vector of patterns
% 

if ~exist('alpha','var')
    alpha = 0.05;
end

n = length(Ms);
p = zeros(1,n);

isSig = Mp < alpha;

for i = 1:n

    % Explicit missing data handling
    if isnan(Ms(i)) || isnan(Mp(i))
        p(i) = 6; % Missing
        continue;
    end

    % Explicit no-change handling
    if Ms(i) == 0
        p(i) = 3; % 0
        continue;
    end

    % Positive change
    if Ms(i) > 0 && isSig(i)
        p(i) = 1; % ++
    elseif Ms(i) > 0 && ~isSig(i)
        p(i) = 2; % +
    end

    % Negative change
    if Ms(i) < 0 && ~isSig(i)
        p(i) = 4; % -
    elseif Ms(i) < 0 && isSig(i)
        p(i) = 5; % --
    end

end


end







function p = getPatterns_Combined(Ms,Mp,alpha)
%Convert change directions and p values to patterns
%
% 25 activity patterns can be distinguish in total (+1 for missing):
%
%   HbO2\HHb | ++| + | 0 | - | --|
%      ------+---+---+---+---+---+
%         ++ |  1|  2|  3|  4|  5|
%      ------+---+---+---+---+---+
%          + |  6|  7|  8|  9| 10|
%      ------+---+---+---+---+---+
%          0 | 11| 12| 13| 14| 15|
%      ------+---+---+---+---+---+
%          - | 16| 17| 18| 19| 20|
%      ------+---+---+---+---+---+
%         -- | 21| 22| 23| 24| 25|
%      ------+---+---+---+---+---+
%
% Missing data is encoded as pattern 26
%
%  ++ - Increment reached statistical significance
%   + - Increment did not reach statistical significance
%   0 - No change
%   - - Decrement did not reach statistical significance
%  -- - Decrement reached statistical significance
%
% Thus:
%  + Pattern 5 is classical activation
%  + Pattern 21 is classical deactivation
%
%% Input parameters
%
% Ms - Matrix of sign (direction of change)
%       size: [2 x nChannels]
% Mp - Matrix of p values (statistical significance)
%       size: [2 x nChannels]
% alpha - Optional. Statistical significance threshold (Default 0.05)
%
%% Output
%
% p - Vector of patterns
% 

if ~exist('alpha','var')
    alpha = 0.05;
end

n = size(Ms,2);
p = zeros(1,n);

% Extract signals
sign_HbO = Ms(1,:);
sign_HHb = Ms(2,:);

p_HbO = Mp(1,:);
p_HHb = Mp(2,:);

sig_HbO = p_HbO < alpha;
sig_HHb = p_HHb < alpha;

% Helper classification:
% 1=++, 2=+, 3=0, 4=-, 5=--
class_HbO = zeros(1,n);
class_HHb = zeros(1,n);

for i = 1:n

    % Explicit missing data handling (if ANY component missing)
    if any(isnan([sign_HbO(i), sign_HHb(i), p_HbO(i), p_HHb(i)]))
        p(i) = 26;
        continue;
    end

    % ---------------- HbO classification ----------------
    if sign_HbO(i) == 0
        class_HbO(i) = 3; % 0
    elseif sign_HbO(i) > 0 && sig_HbO(i)
        class_HbO(i) = 1; % ++
    elseif sign_HbO(i) > 0 && ~sig_HbO(i)
        class_HbO(i) = 2; % +
    elseif sign_HbO(i) < 0 && ~sig_HbO(i)
        class_HbO(i) = 4; % -
    elseif sign_HbO(i) < 0 && sig_HbO(i)
        class_HbO(i) = 5; % --
    end

    % ---------------- HbR classification ----------------
    if sign_HHb(i) == 0
        class_HHb(i) = 3; % 0
    elseif sign_HHb(i) > 0 && sig_HHb(i)
        class_HHb(i) = 1; % ++
    elseif sign_HHb(i) > 0 && ~sig_HHb(i)
        class_HHb(i) = 2; % +
    elseif sign_HHb(i) < 0 && ~sig_HHb(i)
        class_HHb(i) = 4; % -
    elseif sign_HHb(i) < 0 && sig_HHb(i)
        class_HHb(i) = 5; % --
    end

    % Combine (row-major mapping)
    % Pattern index:
    %   p = (row-1)*5 + col
    % where:
    %   row = HbO class
    %   col = HbR class

    p(i) = (class_HbO(i)-1)*5 + class_HHb(i);

end

end




function labels = decodePatterns_Single(p)
%Convert numeric patterns into human-readable labels.
%
% This function maps the 6-pattern encoding into descriptive labels:
%
%   Pattern | Label
%   --------+-------------------------------
%      1    | ++  (Increase, significant)
%      2    | +   (Increase, non-significant)
%      3    | 0   (No change)
%      4    | -   (Decrease, non-significant)
%      5    | --  (Decrease, significant)
%      6    | Missing
%
%% Input parameters
%
% p -  Vector of numeric pattern identifiers
%
%% Output
%
% labels - string[]
%   The output is a string array of the same size as p.
%
%

labels = strings(size(p));

for i = 1:numel(p)
    switch p(i)
        case 1
            labels(i) = "++";
        case 2
            labels(i) = "+";
        case 3
            labels(i) = "0";
        case 4
            labels(i) = "-";
        case 5
            labels(i) = "--";
        case 6
            labels(i) = "Missing";
        otherwise
            labels(i) = "Unknown";
    end
end

end




function labels = decodePatterns_Combined(p)
%Convert numeric combined patterns into human-readable labels
%
% This function maps the 26-pattern encoding into compositional labels:
%
%   HbO:<state> | HbR:<state>
%
% Where <state> \in {++, +, 0, -, --}
%
% Pattern 26 is reserved for Missing data.
%
% This representation is:
%   - Fully deterministic
%   - Human-readable
%   - Easily parsable
%
% Example:
%   Pattern 5  -> "HbO:++ | HbR:--" (canonical activation)
%   Pattern 21 -> "HbO:-- | HbR:++" (canonical deactivation)
%
%% Input parameters
%
% p -  Vector of numeric pattern identifiers
%
%% Output
%
% labels - string[]
%   The output is a string array of the same size as p.
%
%

states = ["++","+","0","-","--"];
labels = strings(size(p));

for i = 1:numel(p)

    if p(i) == 26
        labels(i) = "Missing";
        continue;
    end

    % Row-major decoding
    row = ceil(p(i)/5);
    col = mod(p(i)-1,5) + 1;

    labels(i) = "HbO:" + states(row) + " | HbR:" + states(col);

end

end








function p = computePvalue(task, baseline, opt)
%Abstracted statistical test interface
%
% This wrapper allows easy extension to:
%   - Hotelling T2
%   - ANOVA / ANCOVA
%   - Mixed models

switch opt.test

    case 'signrank'
        p = signrank(task, baseline);
            %Note that signrank does not use the alpha.

    case 'ttest'
        [~,p] = ttest(task, baseline,...
            'alpha',opt.significanceLevel);

    case 'ttest2'
        [~,p] = ttest2(task, baseline,...
            'Alpha',opt.significanceLevel);

    otherwise
        error('icnna:op:getActivityMatrix:InvalidTest',...
                'Unknown statistical test.');
end

end



function [p_adj,q] = applyMultipleCorrection(p,method)
%Apply multiple comparison correction.
%
% Supported methods:
%   'none'        - No correction
%   'bonferroni'  - Bonferroni correction (FWER control)
%   'fdr'         - Benjamini-Hochberg FDR correction
%
%% Input parameters
%
% p - Vector of raw p-values (1 x nChannels)
% method - Correction method
%
%% Output
%
% p_adj - Adjusted p-values
% q - Q values (only meaningful for FDR, otherwise NaN)
%

p_adj = p;
q = nan(size(p)); % Default: no q-values

validIdx = ~isnan(p);
p_valid = p(validIdx);

m = numel(p_valid);

switch method

    case 'none'
        return;

    case 'bonferroni'
        p_valid = p_valid * m;
        p_valid(p_valid > 1) = 1;

    case 'fdr'
        % Benjamini-Hochberg
        [p_sorted, sortIdx] = sort(p_valid);
        ranks = (1:m);

        q_sorted = p_sorted .* m ./ ranks;

        % Enforce monotonicity
        for i = m-1:-1:1
            q_sorted(i) = min(q_sorted(i), q_sorted(i+1));
        end

        % Reorder
        tmp = zeros(size(p_valid));
        tmp(sortIdx) = q_sorted;

        q(validIdx) = tmp;

        % In BH, adjusted p-values == q-values
        p_valid = tmp;

    otherwise
        error('icnna:op:getActivityMatrix:InvalidCorrection',...
              'Unknown multiple comparison correction method.');
end

p_adj(validIdx) = p_valid;

end




function e = computeEffectSize(task, baseline, opt)
%Compute effect size depending on statistical test
%
% Supported:
%   signrank -> robust Rank-biserial correlation (r) (median/MAD approximation)
%   ttest    -> Cohen's d (paired)
%   ttest2   -> Cohen's d (independent)
%

diff = task - baseline;

switch opt.test

    case 'signrank'
        % Robust non-parametric effect size
        if all(diff==0) || numel(diff)<2
            e = 0;
        else
            % r = Z / sqrt(N)
            % ...but since matlab does not expose Z, we approximate:
            denominator = mad(diff,1);
            if denominator == 0
                e = 0;
            else
                e = median(diff) / denominator;
            end
        end

    case 'ttest'
        if std(diff)==0
            e = 0;
        else
            % Cohen's d (paired)
            e = mean(diff) / std(diff);
        end

    case 'ttest2'
        s1 = var(task);
        s2 = var(baseline);
        n1 = numel(task);
        n2 = numel(baseline);

        pooled_std = sqrt(((n1-1)*s1 + (n2-1)*s2)/(n1+n2-2));

        if pooled_std==0
            e = 0;
        else
            % Cohen's d (independent)
            e = (mean(task) - mean(baseline)) / pooled_std;
        end

    otherwise
        e = NaN;
end

end