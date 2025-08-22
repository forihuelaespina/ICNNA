function [status]=icnna_generateUML(destinationDir, options)
%Generates the UML documentation of ICNNA in PlantUML
%
% [status]=icnna_generateUML(destinationDir) - Generates the UML
%   documentation of ICNNA in PlantUML
%
%
%   NOT YET WORKING
%
%
%
%% Remarks
%
% This function uses external Matlab Central's m2uml toolbox;
%
% https://uk.mathworks.com/matlabcentral/fileexchange/59722-m2uml
%
%
%
%% Input parameters
%
% destinationDir - Char array. Destination folder.
%   Strictly speaking this will be the parent folder of the real
%   destination folder.
%
% options - Struct. A struct of options
%   .version - char array. e.g. '1.3.1' Default is empty ''.
%       The ICNNA version for which the documentation is being generated.
%       If provided, the output folder will be suffixed with this string.
%   .verbose - Int. Default 0.
%       Controls the level of verbosity.
%
%% Outputs
%
% status - Int. 1 if successful
% 
% In addition, a collection of files are generated in the
% destinationDir/u2uml_*/ containing the different UML diagrams as
% a .puml file. PlantUML can be rendered it using PlantUML standalone
% VS Code extensions or exported to LateX.
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
% 
% See also icnna_releaseVersion
%

%% Log
%
%
% File created: 24-Jun-2025
%
% 25-Apr-2018: FOE. 
%   + File created (with the help of Windows Copilot)
%   + Available since v1.3.1
%


disp('FUNCTION NOT YET WORKING. Sorry for the inconvenience.');
return



%% Deal with options
opt.version = '';
opt.verbose = 0;
if exist('options','var')
    if isfield(options,'version')
        opt.version = options.version;
    end
    if isfield(options,'verbose')
        opt.verbose = options.verbose;
    end

end


status = 0;

% -------------------------------------------------------------------------
% MATLAB Script to Generate UML Class Diagrams from the ICNNA Codebase
% Requires: m2uml toolbox from MATLAB Central
% -------------------------------------------------------------------------

% 1. Set the ICNNA source path
projectName = 'ICNNA';
icnnaFolder = icnna_rootDirectory();

% 2. Add source to MATLAB path
%addpath(genpath(srcFolder));

% 3. Optional: Clean m2uml cache if needed
umlDir = 'm2uml_output';
if ~isempty(opt.version)
    umlDir = ['m2uml_ICNNAv' opt.version];
end

finalFolder = fullfile(destinationDir,  umlDir);
try
    if exist(finalFolder, 'dir')
        rmdir(finalFolder, 's');
    end
    mkdir(finalFolder);
catch
    status = 0;
    cd(finalFolder);
    error('ICNNA:icnna_generateUML',...
        'Unable to generate destination folder.')
end

% 4. Call m2uml
%m2uml(projectName, icnnaFolder);

%Ignore the "external/m2uml" folder
classList = autodiscoverClasses(icnnaFolder);
if (opt.verbose >= 1)
    % Display results
    disp('Discovered class definitions:');
    disp(classList');
end
tmpFolder = pwd;
try
    cd(finalFolder);
    puml_script = m2uml.create_PlantUML_script('Title','ICNNA_UML',...
                                            'Classes', classList,...
                                            'UserOptions', simple_doc_options);
    cd(tmpFolder);
catch ME
    cd(tmpFolder);
    rethrow(ME);
end

% Output: A .puml file will be generated in destinationDir/m2uml_output folder
% You can render it using PlantUML standalone or with VS Code extensions

graphic_file = m2uml.puml2graphic( 'PlantUmlScript',puml_script, 'GraphicFormat','png' );
m2uml.display_class_diagram( 'GraphicFile',graphic_file );


if (opt.verbose >= 1)
    fprintf(['UML generation complete. Check ' ...
                finalFolder ' for .puml diagrams.\n']);
end

status = 1;

end



%% AUXILIARY FUNCTIONS
function [classList] = autodiscoverClasses(srcFolder)
%Auto-discover MATLAB class definitions in a folder for m2uml
%
%
%

% Recursively find all .m files
mFiles = dir(fullfile(srcFolder, '**', '*.m'));

mFiles(contains({mFiles.folder},'external','IgnoreCase',true)) = [];


% Filter only class definition files (by inspecting content)
classList = {};
for k = 1:length(mFiles)
    filePath = fullfile(mFiles(k).folder, mFiles(k).name);
    
    % Quick check for "classdef" in first few lines
    fid = fopen(filePath, 'r');
    header = fread(fid, 1024, '*char')';
    fclose(fid);

    if contains(header, 'classdef')
        % Extract relative path and convert to class name
        relativePath = erase(filePath, [srcFolder, filesep]);
        parts = strsplit(relativePath, filesep);
        parts{end} = erase(parts{end}, '.m');  % Remove extension
        
        % % Handle packages
        for j = length(parts)-1:-1:1
            if startsWith(parts{j}, '+')
                parts{j} = erase(parts{j}, '+');
            else
                parts(j) = [];
            end
        end

        className = strjoin(parts, '.');
        classList{end+1} = className;
    end
end

end