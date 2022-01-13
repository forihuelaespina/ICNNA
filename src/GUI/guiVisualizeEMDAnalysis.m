function element=guiVisualizeEMDAnalysis(element)
%guiVisualizeEMDAnalysis GUI for visualizing the analysis EMD
%
% a=guiVisualizeEMDAnalysis(a) Visualize analysis' EMD.
%
% The analysis must have been run i.e. 'RunStatus' equals true.
%
%
% Copyright 2008
% @date: 12-Aug-2008
% @author Felipe Orihuela-Espina
%
% See also guiAnalysis, analysis, cluster, guiVisualizeAnalysis
%

if ~get(element,'RunStatus')
    errordlg({'ICNA:guiVisualizationAnalysis:AnalysisNotRun',...
        'Analysis must be run before it can be visualized.'})
    return
end

%% Compute EMD
try
    emdResults=emd(element);
catch ME
    close gcf %close the progress waitbar
    warndlg([ME.identifier ...
        ' Unable to calculate EMD values. ' ME.message]);
    return
end

%% Initialize the figure
%...and hide the GUI as it is being constructed
scrsz = get(0,'ScreenSize');
bottom = 10*round(scrsz(4)/100);
left = 5*round(scrsz(3)/100);
width=90*round(scrsz(3)/100);
height=80*round(scrsz(4)/100);
f=figure('Visible','off','Position',[bottom,left,width,height]);
set(f,'NumberTitle','off');
%set(f,'MenuBar','none'); %Hide MATLAB figure menu
%set(f,'CloseRequestFcn',{@OnQuit_Callback});
movegui(f,'center');

fontSize=16;
bgColor=get(f,'Color');


%% Add components
%Menus
%Toolbars
%Components
tabPanel=uitabgroup('v0',f,...
       'Position', [0.01 0.02 0.98 0.93]);

imageTab = uitab('v0',tabPanel,...
       'Title','Image');
emdAxes=axes('Parent',imageTab);
set(emdAxes,...
        'Tag','emdAxes',...
		'FontSize',fontSize,...
        'Color','w',...
        'Units','normalize',...
        'Position',[0.1 0.1 0.85 0.85]);
title(emdAxes,'EMD results');

valuesTab = uitab('v0',tabPanel,...
       'Title','Values');
valuesTable=uitable(valuesTab,...
        'Tag','emdTable',...
        'Enable','Inactive',...
        'FontSize',fontSize,...
        'Units','normalize',...
        'Position',[0.05 0.03 0.85 0.94]);

histTab = uitab('v0',tabPanel,...
       'Title','Histogram');
emdHistAxes=axes('Parent',histTab);
set(emdHistAxes,...
        'Tag','emdHistogramAxes',...
		'FontSize',fontSize,...
        'Color','w',...
        'Units','normalize',...
        'Position',[0.1 0.2 0.8 0.75]);
statsText = uicontrol(histTab,'Style', 'text',...
       'Tag','statsText',...
        'String', 'Stats.',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.05 0.05 0.9 0.05]);

title(emdHistAxes,'Histogram of EMD distances');


%% On Opening
handles = guihandles(f); %NOTE that only include those whose 'Tag' are not empty
guidata(f,handles);

%Get visible clusters tags
tmpClusters=getClusterList(element);
clusters=zeros(1,0);
tags=cell(1,0);
for cc=tmpClusters
    if get(getCluster(element,cc),'Visible')
        tags(end+1)={get(getCluster(element,cc),'Tag')};
        clusters=[clusters cc];
    end
end

%Filter visible clusters
emdResults=emdResults(clusters,:);
emdResults=emdResults(:,clusters);

%Plot the image
axes(emdAxes);
image(emdResults);
colorbar;
nClusters=length(clusters);
set(gca,'XTick',1:nClusters);
set(gca,'XTickLabel',tags);
set(gca,'YTick',1:nClusters);
set(gca,'YTickLabel',tags);
set(gca,'OuterPosition',[0.05 0.05 0.9 0.9]);

%Fill the table of values with the results
set(valuesTable,'ColumnName',tags);
set(valuesTable,'RowName',tags);
set(valuesTable,'Data',emdResults);

%Plot the histogram
tmpEmdResults=squareform(emdResults);
axes(emdHistAxes);
hist(tmpEmdResults,20);
xlabel('EMD value');
ylabel('Number of cases');

%and set the stats text
sMin = min(tmpEmdResults);
sMax = max(tmpEmdResults);
sRange = sMax-sMin;
sMean = mean(tmpEmdResults);
sSTD = std(tmpEmdResults);
statsString=['Min = ' num2str(sMin,'%.2f') ...
    '; Max = ' num2str(sMax,'%.2f') ...
    '; Range = ' num2str(sRange,'%.2f') ...
    '; Mean = ' num2str(sMean,'%.2f') ...
    '; Std = ' num2str(sSTD,'%.2f')];
    
set(statsText,'String',statsString);

guidata(f,handles);



%% Make GUI visible
set(f,'Name','ICNA - MENA Analysis');
set(f,'Visible','on');
waitfor(f);

%%===================================================
%%CALLBACKS
%%===================================================

end