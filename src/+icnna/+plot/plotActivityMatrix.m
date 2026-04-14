function [hFig] = plotActivityMatrix(R, options)
% Plot the activity matrix (R).
%
% [hFig] = icnna.plot.plotActivityMatrix(R, options)
%
%   This function generates a series of subplots for each signal's
% activity patterns, and other related data. Each signal will be plotted
% on its own figure with subplots that visualize the activity matrix,
% with color-coded patterns, statistical significance, and other
% relevant data.
%
%% Input Parameters
%
% R - struct.
%   The output struct from icnna.op.getActivityMatrix, which contains
%   the activity patterns and other stats for each signal (e.g. 'HbO',
%   'HbR', 'HbT', etc.), along with 'combined' bivariate case if both
%   HbO and HbR are present.
%
%   Check icnna.op.getActivityMatrix for further help on the struct R
%   as well as on the meaning of the patterns, but in summary, R will
%   be expected to contain the following fields for each signal:
%   - .patterns
%   - .labels
%   - .sign
%   - .p_raw
%   - .p
%   - .q
%   - .effect
%   - .significant
%
%   ...plus some others for the combined case
%
%       For instance: R.HbO.patterns
%
%
% options - struct.
%   A struct containing options for the function:
%   .colormap - colormap name or matrix. Default is 'jet'.
%       Colormap for the plots, can be set to a specific colormap or
%       a custom one for pattern visualization.
%
%   .destinationFolder - char. Default is './'.
%       Specifies the folder to save the figure(s) to.
%
%   .fontSize - numeric. Default is 12.
%       Controls the font size for titles, axis labels, and legends.
%
%   .patternThreshold - numeric. Default is 0.1.
%       Threshold to highlight significant patterns (e.g., above 0.1).
%
%   .rowNames - bool. Default is true.
%       Whether to display row names in the plots.
%
%   .save - bool. Default is false.
%       If true, saves the figures to both `.fig` and `.png` formats.
%
%% Output
%
% hFig - handles[]
%   Handles to the figures.
%
%
%
%
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.experimentBundle, icnna.op.getActivityMatrix
%

%% Log
%
%  -- ICNNA v1.4.1
%
% 20-Mar-2026: FOE
%   + File created.
%

%% Deal with options
opt.colormap          = 'jet';          % Default colormap
opt.destinationFolder = ['.' filesep];  % Folder to save the figure(s)
opt.fontSize          = 12;             % Font size for titles, labels, etc.
opt.patternThreshold  = 0.1;            % Default pattern threshold
opt.rowNames          = true;           % Option to include row names in the figure
opt.save              = false;          % Option to save the figure(s)

if nargin > 1
    if isfield(options, 'destinationFolder')
        opt.destinationFolder = options.destinationFolder;
    end
    if isfield(options, 'save')
        opt.save = options.save;
    end
    if isfield(options, 'fontSize')
        opt.fontSize = options.fontSize;
    end
    if isfield(options, 'colormap')
        opt.colormap = options.colormap;
    end
    if isfield(options, 'patternThreshold')
        opt.patternThreshold = options.patternThreshold;
    end
    if isfield(options, 'rowNames')
        opt.rowNames = options.rowNames;
    end
end

% Ensure the destination folder exists
if ~exist(opt.destinationFolder, 'dir')
    mkdir(opt.destinationFolder);
end

%% Plot activity matrix
signalFields = fieldnames(R);
hFig = zeros(1, length(signalFields)); % Initialize the figure handles
for iSignal = 1:length(signalFields)

    signal = signalFields{iSignal};

    if strcmp(signal,'meta') %Ignore metadata
        continue
    end
    
    signalData = R.(signal);  % Collect data for the current signal

    % Convert the tables to numeric arrays
    patterns    = table2array(signalData.patterns);  % Numeric pattern data
    labels      = table2cell(signalData.labels);  % Human-readable patterns
    pValues     = table2array(signalData.p);  % Corrected p-values
    effectSize  = table2array(signalData.effect);  % Effect size
    significant = table2array(signalData.significant);  % Significant mask data

    %% Create individual figures for each field

    % Patterns Plot
    hFig(iSignal) = figure;
    imagesc(patterns);
    if strcmp(signal, 'combined')
        % Custom colormap for combined patterns (25 patterns, 8 distinct colors)
        customColormap = [flipud([1,0,0; 1,0.5,0; 1,0.75,0; 1,1,1; 0.75,1,0; 0.5,1,0.5; 0,0.75,1; 0,0,1]); 0, 0, 0]; % Red-blue scheme
        colormap(customColormap);
        caxis([1 26]);  % Range for combined patterns
    else
        % Regular signal patterns (6 distinct colors)
        customColormap = [0, 0, 0; 0, 0.8, 0; 0, 0, 1; 1, 0, 0; 1, 0.8, 0; 1, 1, 1]; % Black, Green, Blue, Red, Orange, White
        colormap(customColormap);
        caxis([1 6]);  % Range for regular signal patterns
    end
    title([signal ': Patterns'], 'FontSize', opt.fontSize);
    colorbar;
    axis tight;

    % Add row/column names as axis labels
    if opt.rowNames && isfield(R.meta, 'rowNames') && isfield(R.meta, 'channels')
        rowNames = R.meta.rowNames;
        colNames = R.meta.channels;
        set(gca, 'XTick', 1:numel(colNames), 'XTickLabel', colNames, 'FontSize', opt.fontSize);
        set(gca, 'YTick', 1:numel(rowNames), 'YTickLabel', rowNames, 'FontSize', opt.fontSize);
    end

    % Save the figure if required
    if opt.save
        saveFileName = fullfile(opt.destinationFolder, [signal ':Patterns']);
        mySaveFig(hFig(iSignal), saveFileName);
    end

    %% Significant Mask Plot
    if ~isempty(significant)
        hFig(iSignal+1) = figure;
        imagesc(significant);
        title([signal ': Significant Mask'], 'FontSize', opt.fontSize);
        colorbar;
        colormap('gray');  % Highlight significant patterns with a distinct color
        axis tight;

        % Save the figure if required
        if opt.save
            saveFileName = fullfile(opt.destinationFolder, [signal ':SignificantMask']);
            mySaveFig(hFig(iSignal+1), saveFileName);
        end
    end

    %% p-Values Plot (log scale)
    if ~isempty(pValues)
        hFig(iSignal+2) = figure;
        imagesc(pValues);
        set(gca, 'ColorScale', 'log');  % Logarithmic color scale for p-values
        title([signal ': p-values'], 'FontSize', opt.fontSize);
        colorbar;
        colormap('hot');
        axis tight;

        % Save the figure if required
        if opt.save
            saveFileName = fullfile(opt.destinationFolder, [signal ':pValues']);
            mySaveFig(hFig(iSignal+2), saveFileName);
        end
    end

    %% Effect Size Plot
    if ~isempty(effectSize)
        hFig(iSignal+3) = figure;
        imagesc(effectSize);
        title([signal ': Effect Size'], 'FontSize', opt.fontSize);
        colorbar;
        colormap(parula);  % Linear color scale
        axis tight;

        % Save the figure if required
        if opt.save
            saveFileName = fullfile(opt.destinationFolder, [signal ':EffectSize']);
            mySaveFig(hFig(iSignal+3), saveFileName);
        end
    end
end


end