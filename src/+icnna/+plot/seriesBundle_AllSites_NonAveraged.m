function seriesBundle_AllSites_NonAveraged(S,options)
% Series of figures plotting the families of spaces by sampling site and non-block averaged in an icnna.data.core.experimentalBundle
%
% icnna.plot.seriesBundle_AllSites_NonAveraged(S,options)
%
% This function generates a series of figures plotting the families
% of spaces in an icnna.data.core.experimentalBundle by sampling site
% and non-block averaged.
%
% The series iterates over each dimension of the base space i.e.
% experimentalUnit, group, session, etc and an individual figure is
% produce for each of these cases.
%
%% Remarks
%
% This is a loose analogous of the experimentSpace series ACHNBA
% where the channel here is replaced by the site, and the "block"
% average is here referred here as "trial" average (or lack of it).
%
%
%
%
%
%% Input parameters
%
%   S - An @icnna.data.core.experimentalBundle
%
%   options - A struct of options with the following fields.
%
%   .destinationFolder - Destination folder. Default value is
%       '.\<bundleId>_<bundleName>_series\PerSite_NonAveraged\'
%
%   .save - True (default) if you want your figures to be saved. False
%       otherwise. Figures will be saved in MATLAB .fig format
%       and in .png format at 600dpi.
%
%   .whichConditions - Int[]. By default all conditions are included.
%           The list of |id|s for the conditions to be included.
%           If empty i.e. .whichConditions = [], then all elements are
%           included
% 
%   .whichExperimentalUnits - Int[]. By default all units are included.
%           The list of |id|s for the experimental units to be included.
%           If empty i.e. .whichExperimentalUnits = [], then all elements 
%           are included
% 
%   .whichGroups - Int[]. By default all groups are included.
%           The list of |id|s for the groups to be included.
%           If empty i.e. .whichGroups = [], then all elements are
%           included
% 
%   .whichSessions - Int[]. By default all sessions are included.
%           The list of |id|s for the sessions to be included.
%           If empty i.e. .whichSessions = [], then all elements are
%           included
% 
%
%   .whichConditionNames - (String|char)[]. By default
%           all conditions are included.
%           The list of |name|s for the conditions to be included.
%           If empty i.e. .whichConditionNames = [], then all elements are
%           included
%               Cell arrays of values is NOT supported.
% 
%   .whichExperimentalUnitNames - (String|char)[]. By
%           default all units are included.
%           The list of |name|s for the experimental units to be included.
%           If empty i.e. .whichExperimentalUnitNames = [], then all
%           elements are included
%               Cell arrays of values is NOT supported.
% 
%   .whichGroupNames - (String|char)[]. By default
%           all groups are included.
%           The list of |name|s for the groups to be included.
%           If empty i.e. .whichGroupNames = [], then all elements are
%           included
%               Cell arrays of values is NOT supported.
% 
%   .whichSessionNames - (String|char)[]. By default
%           all sessions are included.
%           The list of |name|s for the sessions to be included.
%           If empty i.e. .whichSessionNames = [], then all elements are
%           included
%               Cell arrays of values is NOT supported.
%
%       No assumption is made regarding there is a one-to-one relation
%       between id and names for any of the objects (units, groups,
%       sessions or conditions).
%
%   In addition ALL options of the function icnna.plot.plotBundle_FamilyOfSpaces
%   can be used (passed down) except:
% 
%      .singleAxis - which will be set to true here
%      .topo - which will be set to true here
% 
%   Please refer to function icnna.plot.plotBundle_FamilyOfSpaces 
%   for help on these.
%
%       +=======================================================+
%       | Watch out! While the .whichXXX options here are a list|
%       | of |id| because it refers to identifiable objects, the|
%       | .whichXXX options of the downward                     |
%       | icnna.plot.plotBundle_FamilyOfSpaces are a list of    |
%       | boolean flags because it refers to non-identifiable   |
%       | objects.                                              |
%       +=======================================================+
%       
%
%           
%
%
%% Output
%
% No direct parameter output but a number of figure files
% are generated on the option.destinationFolder.
%
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
%
% See also icnna.data.core.experimentalBundle
%


%% Log
%
% Since v1.3.1
%
% 29-Aug-2025: FOE
%   + File created.
%


%% Deal with options
opt.destinationFolder          = ['.' filesep ...
                                  num2str(S.id,'%04d') '_' S.name ...
                                  '_seriesAllSitesNonAveraged' filesep];
opt.save                       = true;

%If empty -> not used for filter, ergo all elements included
opt.whichConditions            = []; 
opt.whichExperimentalUnits     = [];
opt.whichGroups                = [];
opt.whichSessions              = [];

opt.whichConditionNames        = [];
opt.whichExperimentalUnitNames = [];
opt.whichGroupNames            = [];
opt.whichSessionNames          = [];

if(exist('options','var'))
    %%Options provided
    if(isfield(options,'destinationFolder'))
        opt.destinationFolder = options.destinationFolder;
    end
    if(isfield(options,'save'))
        opt.save = options.save;
    end
    if(isfield(options,'whichConditions'))
        opt.whichConditions = options.whichConditions;
    end
    if(isfield(options,'whichExperimentalUnits'))
        opt.whichExperimentalUnits = options.whichExperimentalUnits;
    end
    if(isfield(options,'whichGroups'))
        opt.whichGroups = options.whichGroups;
    end
    if(isfield(options,'whichSessions'))
        opt.whichSessions = options.whichSessions;
    end
    if(isfield(options,'whichConditionNames'))
        opt.whichConditionNames = options.whichConditionNames;
    end
    if(isfield(options,'whichExperimentalUnitNames'))
        opt.whichExperimentalUnitNames = options.whichExperimentalUnitNames;
    end
    if(isfield(options,'whichGroupNames'))
        opt.whichGroupNames = options.whichGroupNames;
    end
    if(isfield(options,'whichSessionNames'))
        opt.whichSessionNames = options.whichSessionNames;
    end
end


%% Preliminaries

%Create the analysis folder if it does not exist
if ~exist(opt.destinationFolder,'dir')
    mkdir(opt.destinationFolder);
end
if opt.destinationFolder(end) ~= filesep
    opt.destinationFolder = [opt.destinationFolder filesep];
end


%Filter the bundle for the desired cases to be plotted
% Do not assumes a one-to-one relation between id and names for
% any of the objects (units, groups, sessions or conditions).
c = struct('column',{},'logic',{},'value',{});
if ~isempty(opt.whichExperimentalUnits)
    c(end+1).column = 'ExperimentalUnit.id';
    c(end).logic  = 'ismember';
    c(end).value  = opt.whichExperimentalUnits;
end
if ~isempty(opt.whichGroups)
    c(end+1).column = 'Group.id';
    c(end).logic  = 'ismember';
    c(end).value  = opt.whichGroups;
end
if ~isempty(opt.whichSessions)
    c(end+1).column = 'Session.id';
    c(end).logic  = 'ismember';
    c(end).value  = opt.whichSessions;
end
if ~isempty(opt.whichConditions)
    c(end+1).column = 'Condition.id';
    c(end).logic  = 'ismember';
    c(end).value  = opt.whichConditions;
end
if ~isempty(opt.whichExperimentalUnitNames)
    c(end+1).column = 'ExperimentalUnit.name';
    c(end).logic  = 'ismember';
    c(end).value  = opt.whichExperimentalUnitNames;
end
if ~isempty(opt.whichGroupNames)
    c(end+1).column = 'Group.name';
    c(end).logic  = 'ismember';
    c(end).value  = opt.whichGroupNames;
end
if ~isempty(opt.whichSessionNames)
    c(end+1).column = 'Session.name';
    c(end).logic  = 'ismember';
    c(end).value  = opt.whichSessionNames;
end
if ~isempty(opt.whichConditionNames)
    c(end+1).column = 'Condition.name';
    c(end).logic  = 'ismember';
    c(end).value  = opt.whichConditionNames;
end

tmpS = icnna.op.getSubbundle(S,'base',c);



%Get the cases
tmpB = tmpS.B(:,{'ExperimentalUnit.id','Group.id','Session.id',...
                    'Condition.id',...
               'ExperimentalUnit.name','Group.name','Session.name',...
                    'Condition.name' });
    %Do not assume that id and names are paired in any dimension
tmpBcases = unique(tmpB,"rows");
nCases = size(tmpBcases,1);

%% Main loop

for iCase = 1:nCases

    theUnitID        = tmpBcases{iCase,'ExperimentalUnit.id'};
    theGroupID       = tmpBcases{iCase,'Group.id'};
    theSessionID     = tmpBcases{iCase,'Session.id'};
    theConditionID   = tmpBcases{iCase,'Condition.id'};

    theUnitName      = tmpBcases{iCase,'ExperimentalUnit.name'};
    theGroupName     = tmpBcases{iCase,'Group.name'};
    theSessionName   = tmpBcases{iCase,'Session.name'};
    theConditionName = tmpBcases{iCase,'Condition.name'};

    disp(strcat(num2str(iCase),'/',num2str(nCases),': ',...
              'unit',  num2str(theUnitID,'%04i'),        '-', theUnitName, ...
              '; group', num2str(theGroupID,'%04i'),     '-', theGroupName, ...
              '; sess',  num2str(theSessionID,'%04i'),   '-', theSessionName, ...
              '; cond',  num2str(theConditionID,'%04i'), '-', theConditionName));

    %Filter the bundle
    c = struct('column',{},'logic',{},'value',{});
    c(1).column = 'ExperimentalUnit.id';
    c(1).logic  = 'ismember';
    c(1).value  = theUnitID;
    c(2).column = 'Group.id';
    c(2).logic  = 'ismember';
    c(2).value  = theGroupID;
    c(3).column = 'Session.id';
    c(3).logic  = 'ismember';
    c(3).value  = theSessionID;
    c(4).column = 'Condition.id';
    c(4).logic  = 'ismember';
    c(4).value  = theConditionID;
    
    c(5).column = 'ExperimentalUnit.name';
    c(5).logic  = 'ismember';
    c(5).value  = theUnitName;
    c(6).column = 'Group.name';
    c(6).logic  = 'ismember';
    c(6).value  = theGroupName;
    c(7).column = 'Session.name';
    c(7).logic  = 'ismember';
    c(7).value  = theSessionName;
    c(8).column = 'Condition.name';
    c(8).logic  = 'ismember';
    c(8).value  = theConditionName;
    
    tmpS2 = icnna.op.getSubbundle(tmpS,'base',c);

    %Plot
    options.singleAxis = true;
    options.topo       = true;
    [hFig] = icnna.plot.plotBundle_FamilyOfSpaces(tmpS2,options);
    if opt.save
        mySaveFig(hFig,strcat(opt.destinationFolder, ...
              'AllSites_NonAveraged', ...
              '_unit',  num2str(theUnitID,'%04i'),      '-', theUnitName, ...
              '_group', num2str(theGroupID,'%04i'),     '-', theGroupName, ...
              '_sess',  num2str(theSessionID,'%04i'),   '-', theSessionName, ...
              '_cond',  num2str(theConditionID,'%04i'), '-', theConditionName));
    end
    close(gcf);

end

end



