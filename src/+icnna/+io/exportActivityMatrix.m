function exportActivityMatrix(R, options)
% Saves the activity matrix results to Excel or CSV files
%
% icnna.io.exportActivityMatrix(R, options)
%
%   This function exports the results of the activity matrix analysis
% (contained in the struct R) to either an Excel file (.xlsx) or
% a collection of CSV files, depending on the specified options.
% Each substruct of R will be saved to a different sheet if exporting
% to Excel, or a separate CSV file for each signal if exporting to CSV.
%
%   The function supports the specification of a destination folder
% for saving the output file(s), and allows the user to choose the
% output format (Excel or CSV).
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
%   .destinationFolder - char. Default is './'.
%       Specifies the folder where the output file(s) should be saved.
%
%   .outputFormat - char. Default is 'xlsx'.
%       Determines the format to save:
%     + 'xlsx' - Excel file with multiple sheets.
%     + 'csv' - Collection of CSV files, one per signal.
%
%   .includeMetaData - bool. Default is false.
%       If true, includes the metadata fields in the output (R.meta.options,
%   R.meta.channels, etc.).
%
%   .rowNames - bool. Default is true.
%       If true, row names are included in the output files.
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
opt.destinationFolder = ['.' filesep];   % Folder to save the output file(s)
opt.outputFormat      = 'xlsx'; % Output format: 'xlsx' or 'csv'
opt.includeMetaData   = false;  % Include meta-data in output
opt.rowNames          = true;   % Include row names in output files
if nargin > 1
    if isfield(options, 'destinationFolder')
        opt.destinationFolder = options.destinationFolder;
    end
    if isfield(options, 'outputFormat')
        opt.outputFormat = lower(options.outputFormat);
    end
    if isfield(options, 'includeMetaData')
        opt.includeMetaData = options.includeMetaData;
    end
    if isfield(options, 'rowNames')
        opt.rowNames = options.rowNames;
    end
end

% Ensure destination folder exists
if ~exist(opt.destinationFolder, 'dir')
    mkdir(opt.destinationFolder);
end

%% Main loop
signalFields = fieldnames(R);
if strcmp(opt.outputFormat, 'xlsx')
    outputFile = fullfile(opt.destinationFolder, 'activityMatrix.xlsx');
    
    for i = 1:length(signalFields)
        signal = signalFields{i};
        signalData = R.(signal);  % Collect data from the current signal substruct
        if ~strcmp(signal,'meta')
            writeToExcel(signal, signalData, outputFile, opt);  % Write to Excel sheet
        end
    end
    
    % Optionally save meta-data
    if opt.includeMetaData
        writetable(struct2table(R.meta.options), outputFile, ...
                'Sheet', 'MetaData_Options', 'WriteRowNames', opt.rowNames);
        writetable(array2table(R.meta.channels), outputFile, ...
                'Sheet', 'MetaData_Channels', 'WriteRowNames', opt.rowNames);
        writetable(cell2table(R.meta.rowNames), outputFile, ...
                'Sheet', 'MetaData_RowNames', 'WriteRowNames', opt.rowNames);
    end
end

%% Export to CSV
if strcmp(opt.outputFormat, 'csv')
    for i = 1:length(signalFields)
        signal = signalFields{i};
        signalData = R.(signal);  % Collect data from the current signal substruct
        
        if ~strcmp(signal,'meta')
            % Prepare the destination file path
            csvFileName = fullfile(opt.destinationFolder, ...
                                    ['ActivityMatrix_' signal '.csv']);
            writeToCSV(signal, signalData, csvFileName, opt);
        end
    end
    
    % Optionally save meta-data
    if opt.includeMetaData
        writetable(struct2table(R.meta.options), fullfile(opt.destinationFolder, ...
                'ActivityMatrix_MetaData_Options.csv'),...
                'WriteRowNames', opt.rowNames);
        writetable(array2table(R.meta.channels), fullfile(opt.destinationFolder, ...
                'ActivityMatrix_MetaData_Channels.csv'),...
                'WriteRowNames', opt.rowNames);
        writetable(cell2table(R.meta.rowNames), fullfile(opt.destinationFolder, ...
                'ActivityMatrix_MetaData_RowNames.csv'),...
                'WriteRowNames', opt.rowNames);
    end
end

end



%% AUXILIARY FUNCTIONS
function writeToExcel(signal, signalData, fileName, options)
% Function to write data to Excel (one sheet per element)
    writetable(signalData.patterns, fileName, ...
        'Sheet', [signal '_Patterns'], 'WriteRowNames', options.rowNames);
    writetable(signalData.labels, fileName, ...
        'Sheet', [signal '_Labels'], 'WriteRowNames', options.rowNames);
    writetable(signalData.sign, fileName, ...
        'Sheet', [signal '_Sign'], 'WriteRowNames', options.rowNames);
    writetable(signalData.p_raw, fileName, ...
        'Sheet', [signal '_Praw'], 'WriteRowNames', options.rowNames);
    writetable(signalData.p, fileName, ...
        'Sheet', [signal '_Pcorrected'], 'WriteRowNames', options.rowNames);
    writetable(signalData.q, fileName, ...
        'Sheet', [signal '_Q'], 'WriteRowNames', options.rowNames);
    writetable(signalData.effect, fileName, ...
        'Sheet', [signal '_EffectSize'], 'WriteRowNames', options.rowNames);
    writetable(signalData.significant, fileName, ...
        'Sheet', [signal '_SignificantMask'], 'WriteRowNames', options.rowNames);
    % Special case for combined (HbO + HbR) data
    if strcmp(signal, 'combined')
        % Save combined data as a separate sheets
        writetable(signalData.consistent, fileName, ...
        'Sheet', [signal '_Consistent'], 'WriteRowNames', options.rowNames);
        writetable(signalData.jointSignificant, fileName, ...
        'Sheet', [signal '_JointSignificant'], 'WriteRowNames', options.rowNames);
    end
end



function writeToCSV(signal, signalData, fileName,options)
% Function to write data to CSV (one file per element)
    [folder, name, ext] = fileparts(fileName);
    tmpFilename = fullfile(folder, [name '_' signal '_Patterns' ext]);
    writetable(signalData.patterns, tmpFilename, 'WriteRowNames', options.rowNames);
    tmpFilename = fullfile(folder, [name '_Labels' ext]);
    writetable(signalData.labels, tmpFilename, 'WriteRowNames', options.rowNames);
    tmpFilename = fullfile(folder, [name '_Sign' ext]);
    writetable(signalData.sign, tmpFilename, 'WriteRowNames', options.rowNames);
    tmpFilename = fullfile(folder, [name '_Praw' ext]);
    writetable(signalData.p_raw, tmpFilename, 'WriteRowNames', options.rowNames);
    tmpFilename = fullfile(folder, [name '_Pcorrected' ext]);
    writetable(signalData.p, tmpFilename, 'WriteRowNames', options.rowNames);
    tmpFilename = fullfile(folder, [name '_Q' ext]);
    writetable(signalData.q, tmpFilename, 'WriteRowNames', options.rowNames);
    tmpFilename = fullfile(folder, [name '_EffectSize' ext]);
    writetable(signalData.effect, tmpFilename, 'WriteRowNames', options.rowNames);
    tmpFilename = fullfile(folder, [name '_SignificantMask' ext]);
    writetable(signalData.significant, tmpFilename, 'WriteRowNames', options.rowNames);
    % Special case for combined (HbO + HbR) data
    if strcmp(signal, 'combined')
        % Save combined data as a separate sheets
        tmpFilename = fullfile(folder, [name '_Consistent' ext]);
        writetable(signalData.consistent, tmpFilename, 'WriteRowNames', options.rowNames);  
        tmpFilename = fullfile(folder, [name '_JointSignificant' ext]);
        writetable(signalData.jointSignificant, tmpFilename, 'WriteRowNames', options.rowNames); 
    end
end