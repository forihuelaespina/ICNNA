%A setup script...
%
%
% Copyright 2007-2026
% @date: 1-Apr-2007
% @author Felipe Orihuela-Espina
%



%% Log
%
% 25-Apr-2018: FOE. Included scripts/ folder
%
% 30-Oct-2019: FOE.
%   Remove personal folders for cleaner release.
%   Folder separations now use filesep
%
% 13-Jan-2022: FOE.
%   + ICNNA separated from the rest of my code and moved to GitHub.
%	This further permits using genpath. All subdirectories are now included
%	using genpath which simplifies the previous "manual"
%	one-folder-at-a-time approach.
%   + Removed the @modified tag
%
% 23-Dec-2025: FOE.
%   + Added test for required toolboxes
%
% -- ICNNA v1.4.2
%
% 7-Jul-2026: FOE.
%   + Fixed minimal MATLAB version for ICNNA to R2021a (v9.10)
%


%% Check for required MATLAB version
%  Since ICNNA v1.4.2, ICNNA requires MATLAB R2021a (v9.10)
% or later.
if verLessThan('matlab','9.10')
    warning('icnna:icnna_startup:OldMatlabVersion', ...
        ['Since ICNNA v1.4.2 MATLAB R2021a (v9.10) or ' ...
        'later is required. ' ...
        'You are running %s. Some ICNNA features may be ' ...
        'unavailable or behave unexpectedly.'], version);
end



%% Check for required toolboxes
requiredToolboxes = {'statistics_toolbox'};
    %See toolbox feature names here:
    % https://uk.mathworks.com/matlabcentral/answers/377731-how-do-features-from-license-correspond-to-names-from-ver#answer_300675
for iTB = 1:numel(requiredToolboxes)
    tbName = requiredToolboxes{iTB};
    if ~ license('test',tbName)
        warning('icnna:icnna_startup:MissingToolbox',...
            ['Matlab toolbox ' tbName ' not found. Some ICNNA functions may be unavailable or not work as expected.'])
    end
end


%% Setup path
mypath=[pwd filesep];
addpath(genpath(mypath));
cd(mypath);
clear mypath
