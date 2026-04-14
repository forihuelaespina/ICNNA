function [db]=generateDB(S,options)
%Generates a database for an icnna.data.core.experimentBundle
%
% [db]=generateDB(S)
%
%
% Generates a descriptive statistics database for further analysis.
%
%% Remarks
%
%   The term "database" here is used in the
%   terms of a social science (barely a table) and not a
%   computer science fully ER 3rd normal form DB.
%
% The number of cases (rows) of the database depends on the
% experimentBundle projection p. There will be 1 entry (case) per
% association in the projection. Note that;
%   + Base points with no preimage in the total space will produce
% no entry in the database.
%   + Base points with more than one preimage in the total space will
% produce just as many entries in the database.
%
%% Parameters:
%
% S - An icnna.data.core.experimentBundle
%
% options - A struct of options
%   .outputFilename - char array.
%       Output filename for the database. Database will
%       be saved to a file if this option is provided. Output format is
%       .csv
%
%% Output
%
%  db - Table.
%   A tabulated database of descriptive statistics from an
%   the experiment bundle S, where each row is an association
%   in the bundle projection S.p.
%
%       For each space of the total space the following
%   statistics are calculated;
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
%
% * The area under the curve is computed with the trapezoidal approach
% (see MATLAB's trapz function)
%
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.experimentBundle
%


%% Log
%
%  -- ICNNA v1.3.1
%
% 7-Aug-2025: FOE
%   + File created. Reused some code from old function
%   generateDB_withBreak
%


%% Deal with options
opt.save=false;
opt.outputFilename=['.' filesep 'data' filesep S.name '_DB.csv'];
if exist('options','var')
    if isfield(options,'outputFilename')
        opt.save=true;
        opt.outputFilename=options.outputFilename;
    end
end


%% Some preliminaries

nStats   = 7; %Number of statistics per total space
%       - Average (Mean)
%       - Median
%       - Standard deviation (Bessel corrected)
%       - Inter quantile range
%       - Time to peak (note that this assumes that entries
%       of the total space are time-series like)
%       - Time to nadir (note that this assumes that entries
%       of the total space are time-series like)
%       - Area under curve (note that this assumes that entries
%       of the total space are time-series like)
[nFamilySpaces,nSpacesPerFamily] = size(S.E); %Each row is a family of spaces
totalSpacesNames = S.E.Properties.VariableNames;
[nBasePoints,  nBaseDescriptors] = size(S.B);
[nAssociations] = size(S.p,1);

nDBDescriptors = nBaseDescriptors + 1; %The +1 is for the total space preimage
nDBFeatures    = nStats*nSpacesPerFamily;

colnames = cell(1,nDBDescriptors + nDBFeatures);
coltypes = cell(1,nDBDescriptors + nDBFeatures);
colNames(1:nDBDescriptors) = [S.B.Properties.VariableNames, ...
                              {'TotalSpacePreimage'}];
colTypes(1:nDBDescriptors) = [S.B.Properties.VariableTypes, ...
                              {'uint32'}];

k = nDBDescriptors;
for iSpace = 1:nSpacesPerFamily
    colNames(k+1) = {[totalSpacesNames{iSpace} '_Avg']};
    colNames(k+2) = {[totalSpacesNames{iSpace} '_Median']};
    colNames(k+3) = {[totalSpacesNames{iSpace} '_Std']};
    colNames(k+4) = {[totalSpacesNames{iSpace} '_IQR']};
    colNames(k+5) = {[totalSpacesNames{iSpace} '_TTP']};
    colNames(k+6) = {[totalSpacesNames{iSpace} '_TTN']};
    colNames(k+7) = {[totalSpacesNames{iSpace} '_AUC']};

    colTypes(k+1) = {'double'};
    colTypes(k+2) = {'double'};
    colTypes(k+3) = {'double'};
    colTypes(k+4) = {'double'};
    colTypes(k+5) = {'double'};
    colTypes(k+6) = {'double'};
    colTypes(k+7) = {'double'};

    k = k + nStats;
end

db = table('Size',[nAssociations nDBDescriptors + nDBFeatures],...
           'VariableTypes',colTypes,...
           'VariableNames',colNames);
db{:,nDBDescriptors+1:end} = nan;
    %By default, values are initialized to 0. So switch to NaN
    %for uncalculated values.

%% Main loop
tic
for iP = 1:nAssociations
    %find all preimages
    totalPointIdx = S.p{iP,'FamilyOfSpaces'};
    basePointIdx  = S.p{iP,'BaseSpacePoint'};


    %Entry the association of the projection
    db(iP,1:nBaseDescriptors)   = S.B(basePointIdx,:);
    db(iP,nDBDescriptors)     = {totalPointIdx};

    k = nDBDescriptors+1;
    for iSpace = 1:nSpacesPerFamily
    
        %Calculate the stats
        theVector       = S.E{totalPointIdx,iSpace}{:};
                    %Double unpacking; first access the cell, then
                    %access the content of the cell i.e. the vecto
                    %itself
        theStats.avg    = mean(theVector,  'omitnan');
        theStats.median = median(theVector,'omitnan');
        theStats.std    = std(theVector,0, 'omitnan'); %Bessel corrected
        theStats.iqr    = iqr(reshape(theVector,numel(theVector),1));

        [~,tmp]         = max(theVector);
        theStats.ttp    = tmp;
        [~,tmp]         = min(theVector);
        theStats.ttn    = tmp;
        theStats.auc    = trapz(theVector);
        %Entry the stats
        db{iP,k:k+nStats-1} = struct2array(theStats);
        k = k + nStats;
    end
end
toc

%% Saving to file if requested
if (opt.save)
    writetable(db,opt.outputFilename,...
                'FileType','text',...
                'Delimiter',',',...
                'WriteRowNames',true);
end

end