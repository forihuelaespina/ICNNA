function [hfig] = plotBundle_FamilyOfSpaces(S,options)
% Plots the families of spaces in an icnna.data.core.experimentalBundle
%
% [f]=icnna.plot.plotBundle_FamilyOfSpaces(S,options) Display a family
%   of spaces from a bundle.
%
% The number of axes in the figure depends on the options:
%
%                       | .topo = False | .topo = True
%  ---------------------+---------------+---------------
%   .singleAxis = False |  nFamilies    | nFamilies x nSamplingSites
%   .singleAxis = True  |  1 axes       | nSamplingSites
%
% where:
%   nFamilies - Is the number of VISIBLE families of sets from the
%       bundle. See option .whichFamilies
%   nSamplingSites - Is the number of VISIBLE sampling sites of sets from
%       the bundle. See option .whichSamplingSites
%
%
%
%% Input parameters
%
%   S - An @icnna.data.core.experimentalBundle
%
%   options - A struct of options with the following fields.
%       .fontSize - Double. By default is set to 13 points.
%           The font size used in the plots. 
%
%       .lineWidth - Double. By default is set to 1.5 points.
%           The line width used in the plots.
%
%       .mainTitle: Char array or string. By default is set to
%           [S.name - 'Family of spaces'].
%           The main title of the figure as a string. 
%
%       .scaling - Bool. By default is false.
%           When multiple axis are used (see option .singleAxis), fix
%           the same range across all axis.
%
%       .singleAxis - Bool. By default is false.
%           Plot all families "linked/concatenated" in a single axis (true)
%           or each one in its own axis.
%
%       .topo - Bool. By default is false.
%           By default, all sampling sites are plot together in the
%           same axis i.e. not separated by sampling site. Set this flag
%           to true if you want each site in separate axis e.g. a
%           topograhical view. When plotting in separate axis, this 
%           function will attempt to retrieve a nominal location for the
%           sites and distribute the axes over the figure based on such
%           locations. If a nominal location cannot be resolved, then
%           separate axes will still be used but they will simply
%           be arranged in a grid.
%
%       .whichFamilies - Bool[]. By default is set to all true.
%           Boolean flags to pick which families to plot, e.g.
%           If the families are [Baseline BreakDelay Task and Recovery]
%           a vector [1 0 1 1] will plot all except the break delay.
%           The length of the vector should match the number of
%           available families in the bundle.
%
%       .whichSamplingSites - Bool[]. By default is set to all true.
%           Boolean flags to pick which sampling sites to plot, e.g.
%           If the sampling sites are [ch1 ch2 ...chN]
%           a vector [1 0 ... 1] will pick the channels to be plot.
%           The length of the vector should match the number of
%           sampling sites in the bundle.
%
%           
%
%
%% Output
%
% f - A figure handle.
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
% 30-Aug-2025: FOE
%   + Added options .topo and .whichSites to plot sampling sites
%   separate. Unfinished.
%
% 2/5-Sep-2025: FOE
%   + Continued working on options .topo and .whichSites.
%   + Added option .scaling
%

%Figure out the total number of families of sets in the bundle
nTotalFamilies      = size(S.E,2);
nSamplingSites = size(S.sites,1);

%% Deal with options
opt.fontSize              = 13;
opt.lineWidth             = 1.5;
opt.mainTitle             = [S.name ' - Family of spaces'];
opt.scaling               = false;
opt.singleAxis            = false;
opt.topo                  = false;
opt.whichFamilies         = ones(1,nTotalFamilies);
opt.whichSamplingSites    = ones(1,nSamplingSites);

if(exist('options','var'))
    %%Options provided
    if(isfield(options,'fontSize'))
        opt.fontSize = options.fontSize;
    end
    if(isfield(options,'lineWidth'))
        opt.lineWidth = options.lineWidth;
    end
    if(isfield(options,'mainTitle'))
        opt.mainTitle = options.mainTitle;
    end
    if(isfield(options,'scaling'))
        opt.scaling = options.scaling;
    end
    if(isfield(options,'singleAxis'))
        opt.singleAxis = options.singleAxis;
    end
    if(isfield(options,'topo'))
        opt.topo = options.topo;
    end
    if(isfield(options,'whichFamilies'))
        opt.whichFamilies = options.whichFamilies;
    end
    if(isfield(options,'whichSamplingSites'))
        opt.whichSamplingSites = options.whichSamplingSites;
    end
end




%% Preliminaries

assert(numel(opt.whichFamilies) == nTotalFamilies, ...
    ['icnna:plot:plotBundle_FamilyOfSpaces:InvalidParameterValue' ...
    ' Length of vector for option .whichFamilies does not match '...
    ' the number of families of spaces in the bundle.']);

assert(numel(opt.whichSamplingSites) == nSamplingSites, ...
    ['icnna:plot:plotBundle_FamilyOfSpaces:InvalidParameterValue' ...
    ' Length of vector for option .whichSamplingSites does not match '...
    ' the number of sampling sites in the bundle.']);


nVisibleFamilies      = sum(opt.whichFamilies);
nVisibleSamplingSites = sum(opt.whichSamplingSites);

familiesIdx = find(opt.whichFamilies);
sitesIdx    = find(opt.whichSamplingSites);

familyNames  = S.E.Properties.VariableNames;




if opt.topo
    sitesLocations = getSitesNominalLocations(S.sites);
end

%Split the bundle by signal.
theSignals = unique(S.B{:,'Signal.id'});
nSignals   = size(theSignals,1);
SS(nSignals) = icnna.data.core.experimentBundle();
for iSignal = 1:nSignals
    c.column  = 'Signal.id';
    c.logic   = '==';
    c.value   = theSignals(iSignal);
    tmpSignal = icnna.op.getSubbundle(S,'base',c);

    tmpStr    = unique(tmpSignal.B(:,'Signal.name'));
    if (numel(tmpStr) ~= 1)
        warning('icnna:plot:plotBundle_FamilyOfSpaces:UnexpectedInput',...
            ['Signals names associated to Signal id=' num2str(iSignal) ...
            ' may not be unique.']);
    end

    SS(iSignal) = tmpSignal;
    clear tmpSignal
end


nMaxTrials = max(S.B{:,'Trial'});



%Attempt to figure out a good colormap
cmap = jet(nSignals);
if nSignals <= 3
    tmp  = [1 0 0; 0 0 1; 0 1 0];
    cmap = tmp(1:nSignals,:);
else
    cmap = cmap(end:-1:1,:);
end




%% Initialize the figure
hfig=figure('Units','normalized','Position',[0.05 0.05 0.9 0.9]);
set(hfig,'NumberTitle','off');
set(hfig,'MenuBar','none'); %Hide MATLAB figure menu
set(hfig,'Visible','off');
set(hfig,'Colormap',cmap);

%Set the axis. The number of axes in the figure depends
% on the options:
%
%                       | .topo = False | .topo = True
%  ---------------------+---------------+---------------
%   .singleAxis = False |  nFamilies    | nFamilies x nSamplingSites
%   .singleAxis = True  |  1 axes       | nSamplingSites
%
% where:
%   nFamilies - Is the number of VISIBLE families of sets from the
%       bundle. See option .whichFamilies
%   nSamplingSites - Is the number of VISIBLE sampling sites of sets from
%       the bundle. See option .whichSamplingSites
%
if (opt.singleAxis && opt.topo)
    %One axis per (visible) sampling site
    nAxis     = nVisibleSamplingSites;
    axWidth   = max(0.1,0.9*(1/nAxis));
    axHeight  = max(0.1,0.9*(1/nAxis));
    axHorzPos = sitesLocations(:,2);
    axVertPos = sitesLocations(:,1);
    hAxis = gobjects(1, nAxis); % Preallocate graphics object array
    for iAxis = 1:nAxis
        hAxis(iAxis) = axes(hfig,'Units','normalize');
        set(hAxis(iAxis),...
            'Colormap',cmap,...
            'OuterPosition',[axHorzPos(iAxis) axVertPos(iAxis) axWidth axHeight]);
    end
elseif (opt.singleAxis && ~opt.topo)
    %One axis for all
    nAxis = 1;
    hAxis = gca();
    set(hAxis,'Units','normalize','Colormap',cmap);

elseif (~opt.singleAxis && opt.topo)
    %One axis per (visible) family and (visible) sampling sites.
    nAxis     = nVisibleSamplingSites * nVisibleFamilies;
    axWidth   = max(0.025,0.1*(1/nVisibleFamilies));
    axHeight  = max(0.1,0.9*(1/nVisibleSamplingSites));
    axHorzPos = sitesLocations(:,2);
    axVertPos = sitesLocations(:,1);
    hAxis = gobjects(nVisibleSamplingSites,nVisibleFamilies);
        % Preallocate graphics object array
    for iAxis = 1:nAxis
        [iSite,iFamily] = ind2sub(size(hAxis),iAxis);
        hAxis(iSite,iFamily) = axes(hfig,'Units','normalize');
        wOffset = 1.1*mod(iFamily-1,3);
        set(hAxis(iAxis),...
            'Colormap',cmap,...
            'OuterPosition',[axHorzPos(iSite) axVertPos(iSite) wOffset*axWidth axHeight]);
    end
else % (~opt.singleAxis && ~opt.topo)
    %One axis per (visible) family
    nAxis     = nVisibleFamilies;
    axWidth   = 0.9*(1/nAxis);
    axHorzPos = 0.02 + (0:(nAxis-1))*axWidth;
    hAxis = gobjects(1, nAxis); % Preallocate graphics object array
    for iAxis = 1:nAxis
        hAxis(iAxis) = axes(hfig,'Units','normalize');
        set(hAxis(iAxis),...
            'Colormap',cmap,...
            'OuterPosition',[axHorzPos(iAxis) 0.02 axWidth 0.96]);
    end
end


%% Render the figure
if (opt.singleAxis && opt.topo)
    %One axis per (visible) sampling site

    nSamples = 0;
    signalStr = cell(1,nSignals);

    hLines = gobjects(nMaxTrials,nSignals,nAxis);
    for iSignal = 1:nSignals

        tmpB = SS(iSignal).B;
        signalStr(iSignal) = {tmpB{1,'Signal.name'}};
        clear tmpB

        for iSite = 1:nVisibleSamplingSites

            site  = S.sites(sitesIdx(iSite),:);
            iAxis = iSite;


            c.column  = 'SamplingSite.id';
            c.logic   = '==';
            c.value   = site{1,'Site.id'};
            tmpSS = icnna.op.getSubbundle(SS(iSignal),'base',c);
                %The bundle for a specific site and signal 
            nTrials = max(tmpSS.B{:,'Trial'});

            %Prepare the data; Concatenate the (visible) families
            tmpE  = tmpSS.E;
            tmpE = table2cell(tmpE); %Note that table2array still yields a cell
                                     %array in this case, so it is clearer to do
                                     %it in 2 steps.
        
            %padding may be needed if vectors do not have the same length
            %see auxiliary function
            [tmpE,nRows,~] = icnna.util.padVectors(tmpE');
            tmpE = cell2mat(tmpE); 
            nSamples = size(tmpE,1);


            %plot
            axes(hAxis(iAxis));

            hold on;
            hLines(1:nTrials,iSignal,iAxis) = ...
                plot(tmpE, 'LineWidth',opt.lineWidth,...
                        'Color',cmap(iSignal,:));

            if (iSignal == nSignals)
                %Add family markers
                tmpSamplesOnInterval = cumsum(nRows);
                tmpSamplesOnInterval(end) = []; 
                tmpYLim = ylim();
                line([tmpSamplesOnInterval tmpSamplesOnInterval]',...
                     repmat([tmpYLim(1) tmpYLim(2)],nTotalFamilies-1,1)',...
                        'Color','k',...
                        'LineStyle','-','LineWidth',opt.lineWidth);

                %xlabel('Time [samples]','FontSize',opt.fontSize);
                %ylabel('Conc.','FontSize',opt.fontSize);
                title (site{1,'Site.name'},'FontSize',opt.fontSize);
                
            end
            

            clear tmpSS2

        end

        clear tmpE
    end

    %Adjust the X axes
    set(hAxis,'XLim',[1 nSamples])
    if opt.scaling
        %Adjust the Y axes; Ensure consistent scaling
        tmpYLim = cell2mat(ylim(hAxis));
        tmpYMin = min(tmpYLim(:,1));
        tmpYMax = max(tmpYLim(:,2));
        set(hAxis,'Ylim',[tmpYMin tmpYMax]);
    end
    %Add legend on first axis
    legend(hLines(1,:,1),signalStr)

    set(hAxis,'Box','on');
    set(hAxis,'XGrid','on','YGrid','on');


elseif (opt.singleAxis && ~opt.topo)
    %One axis for all
    nSamples = 0;

    signalStr = cell(1,nSignals);
    signalLineStyle = {'-','--',':','-.'};

    hLines = gobjects(nMaxTrials,nVisibleSamplingSites,nSignals,nAxis);
    for iSignal = 1:nSignals
        tmpB = SS(iSignal).B;
        signalStr(iSignal) = {tmpB{1,'Signal.name'}};
        nTrials = max(tmpB{:,'Trial'});
        clear tmpB
        
        %Prepare the data; Concatenate the (visible) families
        tmpE = SS(iSignal).E(:,familiesIdx);
        tmpE = table2cell(tmpE); %Note that table2array still yields a cell
        %array in this case, so it is clearer to do
        %it in 2 steps.

        %padding may be needed if vectors do not have the same length
        %see auxiliary function
        [tmpE,nRows,~] = icnna.util.padVectors(tmpE');
        tmpE = cell2mat(tmpE);
        nSamples = size(tmpE,1);

        %plot
        axes(hAxis); hold on;
        hLines(1:nTrials,:,iSignal,1) = ...
            plot(tmpE, ...
                'LineStyle',signalLineStyle{mod(iSignal-1,3)+1},...
                'LineWidth',opt.lineWidth);

        clear tmpE
    end

    %Add family markers
    tmpSamplesOnInterval = cumsum(nRows);
    tmpSamplesOnInterval(end) = [];
    tmpYLim = ylim();
    line([tmpSamplesOnInterval tmpSamplesOnInterval]',...
        repmat([tmpYLim(1) tmpYLim(2)],nTotalFamilies-1,1)',...
        'Color','k',...
        'LineStyle','-','LineWidth',opt.lineWidth);
    %Add the families names on top
    tmpSamplesOnInterval = [1; tmpSamplesOnInterval] + round(0.005*nSamples);
    for iFam = 1:nVisibleFamilies
        text(tmpSamplesOnInterval(iFam),0.9*tmpYLim(2),...
                familyNames(familiesIdx(iFam)),...
                'FontSize',opt.fontSize);
    end

    
    %Adjust the X axes
    set(hAxis,'XLim',[1 nSamples])

    box on, grid on
    xlabel('Time [samples]','FontSize',opt.fontSize);
    ylabel('Concentration','FontSize',opt.fontSize);
    title (opt.mainTitle,'FontSize',opt.fontSize);

    %Add legend on first axis
    legend(hLines(1,1,:,1),signalStr)


    
elseif (~opt.singleAxis && opt.topo)
    %One axis per visible family and sampling sites.

    nSamples = 0;
    signalStr = cell(1,nSignals);

    hLines = gobjects(nMaxTrials,nSignals,nAxis);
    for iSignal = 1:nSignals

        tmpB = SS(iSignal).B;
        signalStr(iSignal) = {tmpB{1,'Signal.name'}};
        clear tmpB

        for iAxis = 1:nAxis

            [iSite,iFamily] = ind2sub(size(hAxis),iAxis);
            axes(hAxis(iSite,iFamily)); hold on;

            site  = S.sites(sitesIdx(iSite),:);

            c.column  = 'SamplingSite.id';
            c.logic   = '==';
            c.value   = site{1,'Site.id'};
            tmpSS = icnna.op.getSubbundle(SS(iSignal),'base',c);
                %The bundle for a specific site and signal 
            nTrials = max(tmpSS.B{:,'Trial'});



            %Prepare the data
            tmpE = tmpSS.E(:,iFamily);
            tmpE = table2cell(tmpE); %Note that table2array still yields a cell
            %array in this case, so it is clearer to do
            %it in 2 steps.

            %padding may be needed if vectors do not have the same length
            %see auxiliary function
            [tmpE,nRows,~] = icnna.util.padVectors(tmpE');
            tmpE = cell2mat(tmpE); 
            nSamples = size(tmpE,1);


            %plot
            axes(hAxis(iAxis));

            hold on;
            hLines(1:nTrials,iSignal,iAxis) = ...
                plot(tmpE, 'LineWidth',opt.lineWidth,...
                        'Color',cmap(iSignal,:));

            if (iSignal == nSignals)
                %xlabel('Time [samples]','FontSize',opt.fontSize);
                %ylabel('Conc.','FontSize',opt.fontSize);
                %title ([site{1,'Site.name'} '-' familyNames{iFamily}],...
                %    'FontSize',opt.fontSize);
                if (iFamily == 1)
                    title ([site{1,'Site.name'}],...
                        'FontSize',opt.fontSize);
                end
            end
            

            clear tmpSS2

        end

        clear tmpE
    end

    %Adjust the X axes
    set(hAxis,'XLim',[1 nSamples])
    if opt.scaling
        %Adjust the Y axes; Ensure consistent scaling
        tmpYLim = cell2mat(ylim(hAxis));
        tmpYMin = min(tmpYLim(:,1));
        tmpYMax = max(tmpYLim(:,2));
        set(hAxis,'Ylim',[tmpYMin tmpYMax]);
    end
    %Add legend on first axis
    legend(hLines(1,:,1),signalStr)

    set(hAxis,'Box','on');
    set(hAxis,'XGrid','on','YGrid','on');

else % (~opt.singleAxis && ~opt.topo)
    %One axis per visible family
    

    signalStr = cell(1,nSignals);
    signalLineStyle = {'-','--',':','-.'};

    hLines = gobjects(nMaxTrials,nVisibleSamplingSites,nSignals,nAxis);
    for iSignal = 1:nSignals
        tmpB = SS(iSignal).B;
        signalStr(iSignal) = {tmpB{1,'Signal.name'}};
        clear tmpB
        for iAxis = 1:nAxis

            axes(hAxis(iAxis)); hold on;

            nTrials = max(SS.B{:,'Trial'});

            %Prepare the data
            iFamily = familiesIdx(iAxis);
            tmpE = SS(iSignal).E(:,iFamily);
            tmpE = table2cell(tmpE); %Note that table2array still yields a cell
            %array in this case, so it is clearer to do
            %it in 2 steps.
            [tmpE,~,~] = icnna.util.padVectors(tmpE');
            tmpE = cell2mat(tmpE);
            nSamples = size(tmpE,1);

            %plot
            hLines(1:nTrials,:,iSignal,iAxis) = ...
                plot(tmpE,...
                'LineStyle',signalLineStyle{mod(iSignal-1,3)+1},...
                'LineWidth',opt.lineWidth);

            xlabel('Time [samples]','FontSize',opt.fontSize);
            if iAxis == 1
                ylabel('Conc.','FontSize',opt.fontSize);
            end
            title(familyNames{iFamily},'FontSize',opt.fontSize);
            %suptitle (opt.title,'FontSize',opt.fontSize);

            clear tmpE



            %Adjust the X axes
            set(hAxis(iAxis),'XLim',[1 nSamples])
        end

    end

    set(hAxis,'Box','on');
    set(hAxis,'XGrid','on','YGrid','on');

    %Add legend on first axis
    legend(hLines(1,1,:,1),signalStr);


end


set(hfig,'Visible','on');

end




%% AUXILIARY FUNCTIONS
function [sitesLocations] = getSitesNominalLocations(sites)
%Attempts to retrieve the nominal location for the sampling sites.
%
% [sitesLocations] = getSitesNominalLocations(sites)
%
%
% sites - As in S.sites
%
% sitesLocations - Double array (nSites x 2).
%   A 2D nominal location for the sites.
%   If sites contains this information e.g. a descriptor providing
%   the location, an educated guess about the descriptor name is made
%   and that descriptor is used.
%   If the nominal locations cannot be found in the sites, then a
%   nominal "grid" location is given.
%

nSites = size(sites,1);

%Set the default "grid" location
tmp = linspace(0.05,0.9,nSites+1);
tmp(end) = [];
sitesLocations = [tmp' 0.05*ones(nSites,1)];

%Make an educated guess on the name of the descriptor; it should
%contain the substring 'loc' or 'pos'
tmp = regexp(lower(sites.Properties.VariableNames),'loc|pos');

%Loop over potential candidates
for iCol = 1:length(tmp)
    tmp2 = tmp{iCol};
    if ~isempty(tmp2)
        try
            theColumn = cell2mat(sites{:,iCol});
            if (isnumeric(theColumn) ...
                && size(theColumn,1) == nSites ...
                && size(theColumn,2) > 2)
                sitesLocations = theColumn(:,1:2);

                %Normalize
                %v1.3.1. Because of ICNNA's current deprecated function normalize
                % hiding MATLAB's function normalize, unfortunately I
                % cannot simply call normalize yet here... So I have to
                % do this "manually" column by column.
                sitesLocations(:,1) = 0.05+0.85*icnna_normalize(sitesLocations(:,1),'range',[0 1]);
                sitesLocations(:,2) = 0.05+0.85*icnna_normalize(sitesLocations(:,2),'range',[0 1]);
                break
            end
                
        catch
            %ignore and continue
        end
    end
end

end