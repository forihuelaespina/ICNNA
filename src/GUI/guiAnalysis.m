function element=guiAnalysis(element)
%guiAnalysis GUI for creating or updating analysis
%
% a=guiAnalysis() displays a graphical user interface (GUI) for
%   creating a new manifold embedding neuroimage analysis (MENA).
%
% a=guiAnalysis(a) displays a graphical user interface (GUI) for
%   updating the manifold embedding neuroimage analysis a.
%       The function returns the updated
%   analysis, or the unchanged analysis if the action is cancelled
%   or the window closed without saving. The analysis type cannot
%   be changed, but its parameters and clusters can be updated.
%
%
% Copyright 2008-18
% @date: 13-Jun-2008
% @author Felipe Orihuela-Espina
% @modified: 25-Apr-2018
%
% See also guiExperiment, guiVisualizeAnalysis, analysis, cluster,
%   experimentSpace
%


%% Log
%
% 25-Apr-2018: FOE. Window rebranded to ICNNA
%
% 26-Apr-2016: FOE.
%   + Updated deprecated calls from get(obj,'numPoints') to get(obj,'nPoints')
%   in myRedrawStatus.
%








%% Initialize the figure
%...and hide the GUI as it is being constructed
width=700;
height=620;
scSize= get( 0, 'ScreenSize' );
    %WATCH OUT!  The ScreenSize property is static. Its values
    %are read-only at MATLAB startup and not updated if system
    %display settings change.
    %
    %There seems to be a dynamic version:
    %
    %   http://www.mathworks.com/matlabcentral/fileexchange/10957-get-screen-size-dynamic
    %
    %but I haven't tested.
    %

f=figure('Visible','off',...
         'Position',[round((scSize(3)-width)/2),...
                     round((scSize(4)-height)/2),...
                     width,...
                     height]);

set(f,'NumberTitle','off');
set(f,'MenuBar','none'); %Hide MATLAB figure menu
set(f,'CloseRequestFcn',{@OnQuit_Callback});
movegui(f,'center');

%% Add components
%Menus
menuFile = uimenu('Label','File',...
    'Tag','menuFile');
    uimenu(menuFile,'Label','New',...
        'Tag','menuFile_OptNew',...
        'Callback',{@OnNew_Callback},... 
        'Accelerator','n');
    uimenu(menuFile,'Label','Open...',...
        'Tag','menuFile_OptOpen',...
        'Callback',{@OnOpen_Callback},... 
        'Accelerator','o');
    uimenu(menuFile,'Label','Close',...
        'Tag','menuFile_OptClose',...
        'Callback',{@OnClose_Callback},... 
        'Accelerator','c');
    uimenu(menuFile,'Label','Save',...
        'Tag','menuFile_OptSave',...
        'Callback',{@OnSave_Callback},... 
        'Accelerator','S');
    uimenu(menuFile,'Label','Save As...',...
        'Tag','menuFile_OptSaveAs',...
        'Callback',{@OnSaveAs_Callback},... 
        'Accelerator','S');
    uimenu(menuFile,'Label','Save And Close',...
        'Tag','menuFile_OptSaveAndClose',...
        'Callback',{@OnSaveAndClose_Callback},... 
        'Accelerator','C');
    uimenu(menuFile,'Label','Quit',...
        'Tag','menuFile_OptQuit',...
        'Separator','on',...
        'Callback',{@OnQuit_Callback},... 
        'Accelerator','Q');
menuExperimentSpace = uimenu('Label','Experiment Space',...
    'Tag','menuExperimentSpace');
    uimenu(menuExperimentSpace,'Label','Compute...',...
        'Tag','menuExperimentSpace_OptComputeExperimentSpace',...
        'Callback',{@OnComputeExperimentSpace_Callback});
    uimenu(menuExperimentSpace,'Label','Load...',...
        'Tag','menuExperimentSpace_OptLoadExperimentSpace',...
        'Callback',{@OnLoadExperimentSpace_Callback});

menuClusters = uimenu('Label','Clusters',...
    'Tag','menuClusters');
    uimenu(menuClusters,'Label','Add Cluster',...
        'Tag','menuClusters_OptAddCluster',...
        'Callback',{@OptAddCluster_Callback});
    uimenu(menuClusters,'Label','Update Cluster',...
        'Tag','menuClusters_OptUpdateCluster',...
        'Callback',{@OptUpdateCluster_Callback});
    uimenu(menuClusters,'Label','Remove Cluster',...
        'Tag','menuClusters_OptRemoveCluster',...
        'Callback',{@OptRemoveCluster_Callback});

menuTools = uimenu('Label','Tools',...
    'Tag','menuTools');
    uimenu(menuTools,'Label','Distance distortion',...
        'Tag','menuTools_OptDistanceDistortion',...
        'Callback',{@OnDistanceDistortion_Callback});
    uimenu(menuTools,'Label','EMD',...
        'Tag','menuTools_OptEMD',...
        'Callback',{@OnEMD_Callback});

menuHelp = uimenu('Label','Help',...
    'Tag','menuHelp');
    uimenu(menuHelp,'Label','About this program...',...
        'Tag','menuHelp_OnAbout',...
        'Callback',{@OnAbout_Callback});

%Toolbars
toolbar = uitoolbar(f,'Tag','toolbar');
%iconsFolder='C:\Program Files\MATLAB\R2007b\toolbox\matlab\icons\';
iconsFolder='./GUI/icons/';
tempIcon=load([iconsFolder 'newdoc.mat']);
	uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_New',...
        'TooltipString','New Analysis',...
        'ClickedCallback',{@OnNew_Callback});
tempIcon=load([iconsFolder 'opendoc.mat']);
	uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_Load',...
        'TooltipString','Open Analysis',...
        'ClickedCallback',{@OnOpen_Callback});
tempIcon=load([iconsFolder 'savedoc.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_Save',...
        'TooltipString','Save Analysis',...
        'ClickedCallback',{@OnSave_Callback});
tempIcon=load([iconsFolder 'addCluster.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_AddCluster',...
        'Separator','on','TooltipString','Add a new Cluster',...
        'ClickedCallback',{@OptAddCluster_Callback});
tempIcon=load([iconsFolder 'updateCluster.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_UpdateCluster',...
        'TooltipString','Updates Cluster Information',...
        'ClickedCallback',{@OptUpdateCluster_Callback});
tempIcon=load([iconsFolder 'removeCluster.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_RemoveCluster',...
        'TooltipString','Removes a Cluster',...
        'ClickedCallback',{@OptRemoveCluster_Callback});
tempIcon=load([iconsFolder 'distanceDistortion.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_DistanceDistortion',...
        'Separator','on','TooltipString','Distance distortion plot',...
        'ClickedCallback',{@OnDistanceDistortion_Callback});


fontSize=16;
bgColor=get(f,'Color');
uicontrol(f,'Style', 'text',...
       'String', 'ID:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.92 0.2 0.06]);
uicontrol(f,'Style', 'edit',...
       'Tag','idEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdateElement_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.92 0.1 0.06]);
uicontrol(f,'Style', 'text',...
       'String', 'Name:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.35 0.92 0.2 0.06]);
uicontrol(f,'Style', 'edit',...
       'Tag','nameEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdateElement_Callback},...
       'Units','normalize',...
       'Position', [0.55 0.92 0.4 0.06]);
uicontrol(f,'Style', 'text',...
       'String', 'Description:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.85 0.2 0.06]);
uicontrol(f,'Style', 'edit',...
       'Tag','descriptionEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdateElement_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.85 0.72 0.06]);
uicontrol(f,'Style', 'text',...
       'String', 'Experiment Space Status:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.78 0.38 0.06]);
uicontrol(f,'Style', 'text',...
       'Tag','experimentSpaceStatusText',...
       'String', 'NOT DEFINED',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.40 0.78 0.4 0.06]);

mainTabPanel=uitabgroup(f,...
       'Position', [0.02 0.13 0.96 0.63]);
   
   
clustersTab = uitab(mainTabPanel,...
       'Title','Cluster Explorer');
%%% For some reason, the clusterTab will not display properly
%%%if declared after the paramTab
%%%Declaration of clustersTab elements is below

paramTab = uitab(mainTabPanel,...
       'Title','MENA Parameters');

% paramPanel = uipanel(paramTab,...
%         'Title','',...
%         'BorderType','none',...
% 		'FontSize',fontSize-2,...
%         'BackgroundColor',get(f,'Color'),...
%         'Position',[0.02 0.02 0.96 0.96]);
% %        'Position',[0.02 0.33 0.96 0.43]);
tabPanel=uitabgroup(paramTab,...
        'Position',[0.02 0.02 0.96 0.96]);
%       'Position', [0.01 0.22 0.98 0.76]);

metricTab = uitab(tabPanel,...
       'Title','Metric');
baseMetricPanel = uipanel(metricTab,'Title','Base (Ambient)',...
        'BorderType','etchedin',...
		'FontSize',fontSize-2,...
        'BackgroundColor',get(f,'Color'),...
        'Position',[0.02 0.02 0.46 0.92]);
uicontrol(baseMetricPanel,'Style', 'radiobutton',...
       'Tag','euclideanRButton',...
       'Min', 0,...
       'Max', 1,...
       'Value', 1,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'Units','normalize',...
       'Position', [0.05 0.8 0.05 0.12],...
       'Callback',{@OnEuclideanMetricRButton_Callback});
uicontrol(baseMetricPanel,'Style', 'text',...
       'String', 'Euclidean',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.12 0.8 0.8 0.12]);
uicontrol(baseMetricPanel,'Style', 'radiobutton',...
       'Tag','corrRButton',...
       'Min', 0,...
       'Max', 1,...
       'Value', 0,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'Units','normalize',...
       'Position', [0.05 0.55 0.05 0.12],...
       'Callback',{@OnCorrMetricRButton_Callback});
uicontrol(baseMetricPanel,'Style', 'text',...
       'String', '1-correlation',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.12 0.55 0.8 0.12]);
uicontrol(baseMetricPanel,'Style', 'radiobutton',...
       'Tag','jsmRButton',...
       'Min', 0,...
       'Max', 1,...
       'Value', 0,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'Units','normalize',...
       'Position', [0.05 0.3 0.05 0.12],...
       'Callback',{@OnJsmMetricRButton_Callback});
uicontrol(baseMetricPanel,'Style', 'text',...
       'String', 'Root of Jensen-Shannon divergence',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.12 0.3 0.8 0.12]);
manifoldMetricPanel = uipanel(metricTab,'Title','Manifold',...
        'BorderType','etchedin',...
		'FontSize',fontSize-2,...
        'BackgroundColor',get(f,'Color'),...
        'Position',[0.52 0.02 0.46 0.92]);
uicontrol(manifoldMetricPanel,'Style', 'radiobutton',...
       'Tag','ambientRButton',...
       'Min', 0,...
       'Max', 1,...
       'Value', 0,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'Units','normalize',...
       'Position', [0.05 0.8 0.05 0.12],...
       'Callback',{@OnAmbientMetricRButton_Callback});
uicontrol(manifoldMetricPanel,'Style', 'text',...
       'String', 'Ambient only',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.12 0.8 0.8 0.12]);
uicontrol(manifoldMetricPanel,'Style', 'radiobutton',...
       'Tag','geoRButton',...
       'Min', 0,...
       'Max', 1,...
       'Value', 1,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'Units','normalize',...
       'Position', [0.05 0.55 0.05 0.12],...
       'Callback',{@OnGeoMetricRButton_Callback});
uicontrol(manifoldMetricPanel,'Style', 'text',...
       'String', 'Geodesic',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.12 0.55 0.8 0.12]);
   
embeddingTab = uitab(tabPanel,...
       'Title','Embedding');
uicontrol(embeddingTab,'Style', 'radiobutton',...
       'Tag','cmdsRButton',...
       'Min', 0,...
       'Max', 1,...
       'Value', 1,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'Units','normalize',...
       'Position', [0.05 0.5 0.05 0.4],...
       'Callback',{@OnCMDSEmbeddingRButton_Callback});
uicontrol(embeddingTab,'Style', 'text',...
       'String', 'Classical MDS',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.12 0.5 0.38 0.4]);
uicontrol(embeddingTab,'Style', 'radiobutton',...
       'Tag','ccaRButton',...
       'Min', 0,...
       'Max', 1,...
       'Value', 0,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'Units','normalize',...
       'Position', [0.05 0.05 0.05 0.4],...
       'Callback',{@OnCCAEmbeddingRButton_Callback});
uicontrol(embeddingTab,'Style', 'text',...
       'String', 'Curvilinear Component Analysis',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.12 0.05 0.38 0.4]);
% uicontrol(embeddingTab,'Style', 'radiobutton',...
%        'Tag','lleRadiobutton',...
%        'Min', 0,...
%        'Max', 1,...
%        'Value', 0,...
%        'BackgroundColor',bgColor,...
%        'FontSize',fontSize-6,...
%        'Units','normalize',...
%        'Position', [0.05 0.05 0.05 0.3],...
%        'Callback',{@OnLLEEmbeddingRButton_Callback});
% uicontrol(embeddingTab,'Style', 'text',...
%        'String', 'Locally Linear Embedding',...
%        'BackgroundColor',bgColor,...
%        'FontSize',fontSize-6,...
%        'HorizontalAlignment','left',...
%        'Units','normalize',...
%        'Position', [0.12 0.05 0.8 0.3]);
uicontrol(embeddingTab,'Style', 'text',...
       'String', 'PCA = Euclidean + cMDS',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.52 0.7 0.47 0.18]);
uicontrol(embeddingTab,'Style', 'text',...
       'String', 'Friston''s Func. Sp. = (1-corr) + cMDS',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.52 0.5 0.47 0.18]);
uicontrol(embeddingTab,'Style', 'text',...
       'String', 'Isomap = Geodesic + cMDS',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.52 0.3 0.47 0.18]);
uicontrol(embeddingTab,'Style', 'text',...
       'String', 'CDA = Geodesic + CCA',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.52 0.1 0.47 0.18]);

dataSelectionTab = uitab(tabPanel,...
       'Title','Data selection');
uicontrol(dataSelectionTab,'Style', 'text',...
       'String', 'Subjects:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-4,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.63 0.2 0.32]);
uicontrol(dataSelectionTab,'Style', 'edit',...
       'Tag','subjectsEditBox',...
       'Max',2,...
       'Min',0,...
       'BackgroundColor','w',...
       'FontSize',fontSize-4,...
       'HorizontalAlignment','left',...
       'Callback',{@OnSubjectSelection_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.5 0.5 0.45]);
   %The max and min allow the multiline!
uicontrol(dataSelectionTab,'Style', 'text',...
       'String', 'Sessions Definitions:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-4,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.13 0.2 0.32]);
uicontrol(dataSelectionTab,'Style', 'edit',...
       'Tag','sessionDefinitionsEditBox',...
       'Max',2,...
       'Min',0,...
       'BackgroundColor','w',...
       'FontSize',fontSize-4,...
       'HorizontalAlignment','left',...
       'Callback',{@OnSessionDefinitionSelection_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.05 0.5 0.4]);
uicontrol(dataSelectionTab,'Style', 'text',...
       'String',['Select those that you want to include or ' ...
                'leave empty values to select all.'],...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.74 0.3 0.24 0.48]);

groupingTab = uitab(tabPanel,...
       'Title','Feature Vector Construction');
uicontrol(groupingTab,'Style', 'text',...
       'String', 'Channel Grouping:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-4,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.63 0.2 0.32]);
uicontrol(groupingTab,'Style', 'edit',...
       'Tag','channelGroupingEditBox',...
       'Max',2,...
       'Min',0,...
       'BackgroundColor','w',...
       'FontSize',fontSize-4,...
       'HorizontalAlignment','left',...
       'Callback',{@OnChannelGrouping_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.5 0.5 0.45]);
   %The max and min allow the multiline!
uicontrol(groupingTab,'Style', 'text',...
       'String', 'Signal Descriptors:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-4,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.13 0.2 0.32]);
uicontrol(groupingTab,'Style', 'edit',...
       'Tag','signalDescriptorsEditBox',...
       'Max',2,...
       'Min',0,...
       'BackgroundColor','w',...
       'FontSize',fontSize-4,...
       'HorizontalAlignment','left',...
       'Callback',{@OnSignalDescriptors_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.05 0.5 0.4]);
uicontrol(groupingTab,'Style', 'text',...
       'String', 'Select those that you want to include',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.74 0.5 0.24 0.38]);
uicontrol(groupingTab,'Style', 'text',...
       'String', 'Signal descriptors = [DataSource  Signal]',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.74 0.1 0.24 0.38]);


generalTab = uitab(tabPanel,...
       'Title','Projection Options');
projDimPanel= uipanel(generalTab,...
        'Title','Projection Dimensionality',...
        'BorderType','etchedin',...
		'FontSize',fontSize-4,...
        'BackgroundColor',bgColor,...
        'Position',[0.05 0.2 0.6 0.6]);
uicontrol(projDimPanel,'Style', 'radiobutton',...
       'Tag','twoDRButton',...
       'Min', 0,...
       'Max', 1,...
       'Value', 1,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'Units','normalize',...
       'Position', [0.05 0.5 0.05 0.4],...
       'Callback',{@On2DRButton_Callback});
uicontrol(projDimPanel,'Style', 'text',...
       'String', '2D (Recommended)',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.12 0.5 0.38 0.4]);
uicontrol(projDimPanel,'Style', 'radiobutton',...
       'Tag','threeDRButton',...
       'Min', 0,...
       'Max', 1,...
       'Value', 0,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'Units','normalize',...
       'Position', [0.05 0.05 0.05 0.4],...
       'Callback',{@On3DRButton_Callback});
uicontrol(projDimPanel,'Style', 'text',...
       'String', '3D',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-6,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.12 0.05 0.38 0.4]);

   
%%% For some reason, the clusterTab will not display properly
%%%if declared after the paramTab
%%%Declaration of clustersTab is above
clustersPanel = uipanel(clustersTab,...
        'Title','',...
        'BorderType','none',...
		'FontSize',fontSize,...
        'BackgroundColor',get(f,'Color'),...
        'Position',[0.02 0.02 0.96 0.96]);

colNames = {'Tag','Visible','Num. Patterns'};
uitable(clustersPanel,...
        'Tag','clustersTable',...
        'Enable','Inactive',...
        'FontSize',fontSize,...
        'ColumnName',colNames,...
        'Units','normalize',...
        'Position',[0.02 0.03 0.7 0.94]);
uicontrol(clustersPanel,'Style', 'pushbutton',...
       'String', 'Visualize',...
       'Tag','visualizeButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Position', [0.75 0.5 0.22 0.18],...
       'Callback',{@OnVisualize_Callback});
uicontrol(clustersPanel,'Style', 'pushbutton',...
       'String', 'EMD',...
       'Tag','emdButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Position', [0.75 0.31 0.22 0.18],...
       'Callback',{@OnEMD_Callback});
   
    

   
   
uicontrol(f,'Style', 'text',...
       'String', 'Run Status:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.02 0.2 0.08]);
uicontrol(f,'Style', 'text',...
       'Tag','runStatusText',...
       'String', 'NOT RUN',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.22 0.02 0.34 0.08]);
uicontrol(f,'Style', 'pushbutton',...
       'String', 'Run Analysis',...
       'Tag','runButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Position', [0.57 0.02 0.35 0.08],...
       'Callback',{@OnRun_Callback});   
   
   

%% On Opening
handles = guihandles(f); %NOTE that only include those whose 'Tag' are not empty
if (exist('element','var'))
    if isa(element,'analysis')
        handles.currentElement.data=analysis(element);
    else
        errormsg('Parameter obj not valid.');
        element=[];
        delete(get(f,'Children'));
        delete(f);
        return
    end
else %Simply create a new analysis
    handles.currentElement.data=analysis;
end

handles.currentElement.saved=true;
handles.currentElement.dir=pwd; %Current document directory
handles.currentElement.filename=''; %Current document filename

guidata(f,handles);
OnLoad(f);

 
%% Make GUI visible
set(f,'Name','ICNNA - MENA Analysis');
set(f,'Visible','on');
waitfor(f);




%%===================================================
%%CALLBACKS
%%===================================================

%% OnClear
%Clears the gui (possibly after closing the currentElement)
%See also OnLoad
function OnClear(hObject)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
handles=guidata(hObject);

set(handles.idEditBox,'String','');
set(handles.nameEditBox,'String','');
set(handles.descriptionEditBox,'String','');
set(handles.clustersTable,'RowName',[]);
set(handles.clustersTable,'Data',[]);

set(handles.twoDRButton,'Value',0);
set(handles.threeDRButton,'Value',0);

set(handles.euclideanRButton,'Value',0);
set(handles.corrRButton,'Value',0);
set(handles.geoRButton,'Value',0);
set(handles.jsmRButton,'Value',0);

set(handles.cmdsRButton,'Value',0);
set(handles.ccaRButton,'Value',0);
%set(handles.lleRButton,'Value',0);

set(handles.channelGroupingEditBox,'String','');
set(handles.signalDescriptorsEditBox,'String','');

set(handles.subjectsEditBox,'String','');
set(handles.sessionDefinitionsEditBox,'String','');

set(handles.experimentSpaceStatusText,'String','NOT DEFINED');
set(handles.runStatusText,'String','NOT DEFINED');

guidata(f,handles);


end


%% OnClose
%On Closing the current Element. Check whether data needs saving
%It does not close the window itself (see OnQuit)
function OnClose_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
closeCurrentElement=true;
if (~handles.currentElement.saved)
    element=[];
    %Offer the possibility of saving
    button = questdlg(['Current data is not saved. ' ...
        'Would you like to save the latest changes before ' ...
        'closing?'],...
        'Close window','Save','Close','Cancel','Close');
    switch (button)
        case 'Save'
            OnSave_Callback(hObject,eventData);
            closeCurrentElement=true;
        case 'Close'
            closeCurrentElement=true;
        case 'Cancel'
            closeCurrentElement=false;
    end
end
 
if (closeCurrentElement)
    handles.currentElement.data=[]; 
    handles.currentElement.saved=true;
    handles.currentElement.dir=pwd;
    handles.currentElement.filename='';

        %Make options and fields inactive as appropriate
        set(handles.menuFile_OptClose,'Enable','off');
        set(handles.menuFile_OptSave,'Enable','off');
        set(handles.menuFile_OptSaveAs,'Enable','off');
        set(handles.menuClusters,'Enable','off');
        set(handles.menuClusters_OptAddCluster,'Enable','off');
        set(handles.menuClusters_OptUpdateCluster,'Enable','off');
        set(handles.menuClusters_OptRemoveCluster,'Enable','off');

        set(handles.menuExperimentSpace,'Enable','off');
        set(handles.menuExperimentSpace_OptComputeExperimentSpace,...
                'Enable','off');
        set(handles.menuExperimentSpace_OptLoadExperimentSpace,...
                'Enable','off');

        set(handles.menuTools,'Enable','off');
        set(handles.menuTools_OptDistanceDistortion,'Enable','off');
        set(handles.menuTools_OptEMD,'Enable','off');

        set(handles.toolbarButton_DistanceDistortion,'Enable','off');
        
        set(handles.toolbarButton_Save,'Enable','off');
        set(handles.toolbarButton_AddCluster,'Enable','off');
        set(handles.toolbarButton_UpdateCluster,'Enable','off');
        set(handles.toolbarButton_RemoveCluster,'Enable','off');
        
        
        set(handles.runButton,'Enable','off');
        
        set(handles.idEditBox,'Enable','off');
        set(handles.nameEditBox,'Enable','off');
        set(handles.descriptionEditBox,'Enable','off');
        set(handles.clustersTable,'Enable','off');
        set(handles.visualizeButton,'Enable','off');
        set(handles.emdButton,'Enable','off');
    
    guidata(hObject,handles);
    OnClear(hObject);

end
end



%% OnLoad 
%Refresh the whole GUI when loading a new Element.
%See also OnClear
function OnLoad(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO

handles=guidata(hObject);
if (~isempty(handles.currentElement.data))
set(handles.idEditBox,'String',...
    num2str(get(handles.currentElement.data,'ID')));
set(handles.nameEditBox,'String',...
    num2str(get(handles.currentElement.data,'Name')));
set(handles.descriptionEditBox,'String',...
    num2str(get(handles.currentElement.data,'Description')));

pD=get(handles.currentElement.data,'ProjectionDimensionality');
if (pD==2)
    set(handles.twoDRButton,'Value',1);
    set(handles.threeDRButton,'Value',0);
elseif (pD==3)
    set(handles.twoDRButton,'Value',0);
    set(handles.threeDRButton,'Value',1);
else
    warndlg('Projection dimensionality larger than 3.',...
            'guiAnalysis')
end


metric=get(handles.currentElement.data,'Metric');
switch(metric)
    case 'euc' %Use of 'euc' is now DEPRECATED
        set(handles.euclideanRButton,'Value',1);
        set(handles.corrRButton,'Value',0);
        set(handles.jsmRButton,'Value',0);
        set(handles.ambientRButton,'Value',1);
        set(handles.geoRButton,'Value',0);
    case 'euclidean'
        set(handles.euclideanRButton,'Value',1);
        set(handles.corrRButton,'Value',0);
        set(handles.jsmRButton,'Value',0);
        set(handles.ambientRButton,'Value',1);
        set(handles.geoRButton,'Value',0);
    case 'corr'
        set(handles.euclideanRButton,'Value',0);
        set(handles.corrRButton,'Value',1);
        set(handles.jsmRButton,'Value',0);
        set(handles.ambientRButton,'Value',1);
        set(handles.geoRButton,'Value',0);
    case 'jsm'
        set(handles.euclideanRButton,'Value',0);
        set(handles.corrRButton,'Value',0);
        set(handles.jsmRButton,'Value',1);
        set(handles.ambientRButton,'Value',1);
        set(handles.geoRButton,'Value',0);
    case 'geo' %Use of 'geo' is now DEPRECATED
        set(handles.euclideanRButton,'Value',1);
        set(handles.corrRButton,'Value',0);
        set(handles.jsmRButton,'Value',0);
        set(handles.ambientRButton,'Value',0);
        set(handles.geoRButton,'Value',1);
    case 'geo_euclidean'
        set(handles.euclideanRButton,'Value',1);
        set(handles.corrRButton,'Value',0);
        set(handles.jsmRButton,'Value',0);
        set(handles.ambientRButton,'Value',0);
        set(handles.geoRButton,'Value',1);
    case 'geo_corr'
        set(handles.euclideanRButton,'Value',0);
        set(handles.corrRButton,'Value',1);
        set(handles.jsmRButton,'Value',0);
        set(handles.ambientRButton,'Value',0);
        set(handles.geoRButton,'Value',1);
    case 'geo_jsm'
        set(handles.euclideanRButton,'Value',0);
        set(handles.corrRButton,'Value',0);
        set(handles.jsmRButton,'Value',1);
        set(handles.ambientRButton,'Value',0);
        set(handles.geoRButton,'Value',1);
    otherwise
        errordlg('Unexpected metric identifier.',...
            'guiAnalysis')
end

embeddingTech=get(handles.currentElement.data,'Embedding');
switch(embeddingTech)
    case 'cmds'
        set(handles.cmdsRButton,'Value',1);
        set(handles.ccaRButton,'Value',0);
        %set(handles.lleRButton,'Value',0);
    case 'cca'
        set(handles.cmdsRButton,'Value',0);
        set(handles.ccaRButton,'Value',1);
        %set(handles.lleRButton,'Value',0);
%    case 'lle'
%        set(handles.cmdsRButton,'Value',0);
%        set(handles.ccaRButton,'Value',0);
%        set(handles.lleRButton,'Value',1);
    otherwise
        errordlg('Unexpected embedding technique identifier.',...
            'guiAnalysis')
end

set(handles.subjectsEditBox,'String',...
    mat2str(get(handles.currentElement.data,'SubjectsIncluded')));
set(handles.sessionDefinitionsEditBox,'String',...
    mat2str(get(handles.currentElement.data,'SessionsIncluded')));

set(handles.channelGroupingEditBox,'String',...
    mat2str(get(handles.currentElement.data,'ChannelGroups')));
set(handles.signalDescriptorsEditBox,'String',...
    mat2str(get(handles.currentElement.data,'SignalDescriptors')));


guidata(f,handles);
myRedraw(hObject); %Updates the cluster table and run status

end
end


%% On2DRButton Callback
function On2DRButton_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
set(handles.twoDRButton,'Value',1);
set(handles.threeDRButton,'Value',0);
handles.currentElement.data=...
    set(handles.currentElement.data,'ProjectionDimensionality',2);
handles.currentElement.saved=false;
guidata(f,handles);
myRedrawStatus(f);
end

%% On3DRButton Callback
function On3DRButton_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
set(handles.twoDRButton,'Value',0);
set(handles.threeDRButton,'Value',1);
handles.currentElement.data=...
    set(handles.currentElement.data,'ProjectionDimensionality',3);
handles.currentElement.saved=false;
guidata(f,handles);
myRedrawStatus(f);
end


%% OnAmbientMetricRButton Callback
function OnAmbientMetricRButton_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
set(handles.ambientRButton,'Value',1);
set(handles.geoRButton,'Value',0);
if get(handles.euclideanRButton,'Value')==1
    handles.currentElement.data=...
        set(handles.currentElement.data,'Metric','euclidean');
elseif get(handles.corrRButton,'Value')==1
    handles.currentElement.data=...
        set(handles.currentElement.data,'Metric','corr');
elseif get(handles.jsmRButton,'Value')==1
    handles.currentElement.data=...
        set(handles.currentElement.data,'Metric','jsm');
else
    warndlg('Unexpected metric selection. No change made.',...
            'guiAnalysis');
end
handles.currentElement.saved=false;
guidata(f,handles);
myRedrawStatus(f);
end


%% OnDistanceDistortion callback
%Show the distance distortion plot of the embedding
function OnDistanceDistortion_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);

dy=squareform(pdist(get(handles.currentElement.data,'ProjectionSpace')));
    %Low dimensional (Euclidean) distances
dx=get(handles.currentElement.data,'PatternDistances');
    %High dimensional distances
figure
plotDyDx(dy,dx);

end


%% OnEuclideanMetricRButton Callback
function OnEuclideanMetricRButton_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
set(handles.euclideanRButton,'Value',1);
set(handles.corrRButton,'Value',0);
set(handles.jsmRButton,'Value',0);

if get(handles.ambientRButton,'Value')==1
    handles.currentElement.data=...
        set(handles.currentElement.data,'Metric','euc');
elseif get(handles.geoRButton,'Value')==1
    handles.currentElement.data=...
        set(handles.currentElement.data,'Metric','geo_euclidean');
else
    warndlg('Unexpected metric selection. No change made.',...
            'guiAnalysis');
end
handles.currentElement.saved=false;
guidata(f,handles);
myRedrawStatus(f);
end

%% OnCorrMetricRButton Callback
function OnCorrMetricRButton_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
set(handles.euclideanRButton,'Value',0);
set(handles.corrRButton,'Value',1);
set(handles.jsmRButton,'Value',0);
if get(handles.ambientRButton,'Value')==1
    handles.currentElement.data=...
        set(handles.currentElement.data,'Metric','corr');
elseif get(handles.geoRButton,'Value')==1
    handles.currentElement.data=...
        set(handles.currentElement.data,'Metric','geo_corr');
else
    warndlg('Unexpected metric selection. No change made.',...
            'guiAnalysis');
end
handles.currentElement.saved=false;
guidata(f,handles);
myRedrawStatus(f);
end

%% OnEMD callback
%Show the EMD of the current analysis
function OnEMD_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);

if ~isempty(handles.currentElement.data)
    guiVisualizeEMDAnalysis(handles.currentElement.data);
end

end


%% OnJsmMetricRButton Callback
function OnJsmMetricRButton_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
set(handles.euclideanRButton,'Value',0);
set(handles.corrRButton,'Value',0);
set(handles.jsmRButton,'Value',1);
if get(handles.ambientRButton,'Value')==1
    handles.currentElement.data=...
        set(handles.currentElement.data,'Metric','jsm');
elseif get(handles.geoRButton,'Value')==1
    handles.currentElement.data=...
        set(handles.currentElement.data,'Metric','geo_jsm');
else
    warndlg('Unexpected metric selection. No change made.',...
            'guiAnalysis');
end
handles.currentElement.saved=false;
guidata(f,handles);
myRedrawStatus(f);
end



%% OnGeoMetricRButton Callback
function OnGeoMetricRButton_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
set(handles.ambientRButton,'Value',0);
set(handles.geoRButton,'Value',1);
if get(handles.euclideanRButton,'Value')==1
    handles.currentElement.data=...
        set(handles.currentElement.data,'Metric','geo_euclidean');
elseif get(handles.corrRButton,'Value')==1
    handles.currentElement.data=...
        set(handles.currentElement.data,'Metric','geo_corr');
elseif get(handles.jsmRButton,'Value')==1
    handles.currentElement.data=...
        set(handles.currentElement.data,'Metric','geo_jsm');
else
    warndlg('Unexpected metric selection. No change made.',...
            'guiAnalysis');
end
handles.currentElement.saved=false;
guidata(f,handles);
myRedrawStatus(f);
end


%% OnCMDSEmbeddingRButton Callback
function OnCMDSEmbeddingRButton_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
set(handles.cmdsRButton,'Value',1);
set(handles.ccaRButton,'Value',0);
handles.currentElement.data=...
    set(handles.currentElement.data,'Embedding','cmds');
handles.currentElement.saved=false;
guidata(f,handles);
myRedrawStatus(f);
end


%% OnCCAEmbeddingRButton Callback
function OnCCAEmbeddingRButton_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
set(handles.cmdsRButton,'Value',0);
set(handles.ccaRButton,'Value',1);
handles.currentElement.data=...
    set(handles.currentElement.data,'Embedding','cca');
handles.currentElement.saved=false;
guidata(f,handles);
myRedrawStatus(f);
end

%% OnChannelGrouping callback
%Updates the current analysis with new information
function OnChannelGrouping_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
try
    s=analysis(handles.currentElement.data);

    tmp=str2num(get(handles.channelGroupingEditBox,'String'));
    s=set(s,'ChannelGroups',tmp);
    
    handles.currentElement.data=s;
    handles.currentElement.saved=false;
    guidata(hObject,handles);
catch ME
    msg={ME.identifier,'', ME.message};
    warndlg(msg,'Update Analysis');
    %Refresh those wrong values
    set(handles.channelGroupingEditBox,'String',...
            get(handles.currentElement.data,'ChannelGroups'))
end

end

%% OnSessionDefinitionSelection callback
%Updates the current analysis with new information
function OnSessionDefinitionSelection_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
try
    s=analysis(handles.currentElement.data);

    tmp=str2num(get(handles.sessionDefinitionsEditBox,'String'));
    s=set(s,'SessionsIncluded',tmp);
    
    handles.currentElement.data=s;
    handles.currentElement.saved=false;
    guidata(hObject,handles);
catch ME
    msg={ME.identifier,'', ME.message};
    warndlg(msg,'Update Analysis');
    %Refresh those wrong values
    set(handles.sessionDefinitionsEditBox,'String',...
            get(handles.currentElement.data,'SessionsIncluded'))
end

end

%% OnSignalDescriptors callback
%Updates the current analysis with new information
function OnSignalDescriptors_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
try
    s=analysis(handles.currentElement.data);

    tmp=str2num(get(handles.signalDescriptorsEditBox,'String'));
    s=set(s,'SignalDescriptors',tmp);
    
    handles.currentElement.data=s;
    handles.currentElement.saved=false;
    guidata(hObject,handles);
catch ME
    msg={ME.identifier,'', ME.message};
    warndlg(msg,'Update Analysis');
    %Refresh those wrong values
    set(handles.signalDescriptorsEditBox,'String',...
            get(handles.currentElement.data,'SignalDescriptors'))
end

end

%% OnSubjectSelection callback
%Updates the current analysis with new information
function OnSubjectSelection_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
try
    s=analysis(handles.currentElement.data);

    tmp=str2num(get(handles.subjectsEditBox,'String'));
    s=set(s,'SubjectsIncluded',tmp);
    
    handles.currentElement.data=s;
    handles.currentElement.saved=false;
    guidata(hObject,handles);
catch ME
    msg={ME.identifier,'', ME.message};
    warndlg(msg,'Update Analysis');
    %Refresh those wrong values
    set(handles.subjectsEditBox,'String',...
            get(handles.currentElement.data,'SubjectsIncluded'))
end

end


%% OptAddCluster callback
%Opens the window for adding a new cluster to the analysis
function OptAddCluster_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no analysis currently opened.',...
        'guiAnalysis','modal');
else
    
    tmpExpSp=get(handles.currentElement.data,'ExperimentSpace');
    if (get(handles.currentElement.data,'RunStatus') ...
        && get(tmpExpSp,'RunStatus'))
        handles.currentElement.data=...
        guiCluster(handles.currentElement.data);
        handles.currentElement.saved=false;
        guidata(hObject,handles);
    else
        warndlg(['Analysis has not yet been run. Please ' ...
            'run the analysis before attempting to ' ...
            'insert new clusters.'],...
            'guiAnalysis','modal')
    end
end
myRedraw(hObject);
end

%% OptUpdateCluster callback
%Opens the window for update a cluster information
function OptUpdateCluster_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no analysis currently opened.',...
        'guiAnalysis','modal');
else
    options.Resize='off';
    options.WindowStyle='modal';
    while 1 %Get a valid (existing or new) id, or cancel action
        answer = inputdlg('Cluster ID:','Update which cluster?',...
                          1,{''},options);
        if (isempty(answer)) %Action cancelled
            break;
        else
            tmpID=str2double(answer{1});
            if (isscalar(tmpID) && isreal(tmpID) ...
                && (tmpID == floor(tmpID)))
                break;
            end
        end
    end
            
    if (~isempty(answer))
        elemID=str2double(answer{1});
        existingElements=getClusterList(handles.currentElement.data);
        if (ismember(elemID,existingElements))
            s=getCluster(handles.currentElement.data,elemID);
        else           
            button = questdlg(['Cluster ID not found. ' ...
                'Would you like to create a new cluster ' ...
                'with the given ID?'],'Create New Cluster',...
                'Yes','No','No');
            switch(button)
                case 'Yes'
                    tmpExpSp=get(handles.currentElement.data,'ExperimentSpace');
                    if (get(handles.currentElement.data,'RunStatus') ...
                            && get(tmpExpSp,'RunStatus'))
                        %Note that the view will be created, even
                        %if the user click the cancel button on the
                        %guiCluster!!
                        s=cluster(elemID);
                        handles.currentElement.data=...
                            addCluster(handles.currentElement.data,s);
                        handles.currentElement.saved=false;
                        guidata(hObject,handles);
                        myRedraw(hObject);
                    else
                        warndlg(['Analysis has not yet been run. Please ' ...
                            'run the analysis before attempting to ' ...
                            'insert new clusters.'],...
                            'guiAnalysis','modal')
                        return
                    end
                case 'No'
                    return
            end
        end
        
        %Now update
        handles.currentElement.data=...
            guiCluster(handles.currentElement.data,elemID);
        handles.currentElement.saved=false;
        guidata(hObject,handles);
        myRedraw(hObject);
    end
end
end

%% OptRemoveCluster callback
%Opens the window for eliminating a cluster from the analysis
function OptRemoveCluster_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
options.Resize='off';
options.WindowStyle='modal';
answer = inputdlg('Cluster ID:','Remove cluster?',1,{''},options);
if (isempty(answer)) %Cancel button pressed
else
    answer=str2double(answer);
    if (~isnan(answer))
        ss=getCluster(handles.currentElement.data,answer);
        if (~isempty(ss))
            handles.currentElement.data=...
                removeCluster(handles.currentElement.data,answer);
            handles.currentElement.saved=false;
            guidata(hObject,handles);
        else
            warndlg('Cluster not found','Remove Cluster','modal');
        end
    else
        warndlg('Cluster ID not recognised','Remove Cluster','modal');
    end
end
myRedraw(hObject);
end

%% OnAbout callback
%Opens the "About" information window
function OnAbout_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
aboutICNA;
end


%% OnComputeExperimentSpace callback
%Opens the "guiExperimentSpace" GUI to compute the Experiment space
function OnComputeExperimentSpace_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
expSp=get(handles.currentElement.data,'ExperimentSpace');
expSp=guiExperimentSpace(expSp);
if ~isempty(expSp) %i.e. if not the action is not cancelled
    handles.currentElement.data=...
        set(handles.currentElement.data,'ExperimentSpace',expSp);
    guidata(hObject,handles);
    myRedrawStatus(hObject);
end
end

%% OnLoadExperimentSpace callback
%Load an existing ExperimentSpace
function OnLoadExperimentSpace_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

[FileName,PathName] = uigetfile('*.mat');
if isequal(FileName,0)
    %disp('Operation ''Open experimentSpace'' cancelled')
else
    s=open([PathName, FileName]);
    vars = struct2cell(s);
    %Look for an 'experimentSpace' variable
    for ii=1:length(vars)
        tmp=vars{ii};
        if(isa(tmp,'experimentSpace'))
            break;
        end
    end
    if (isa(tmp,'experimentSpace'))
        handles=guidata(hObject);
        handles.currentElement.data=...
            set(handles.currentElement.data,...
                'ExperimentSpace',experimentSpace(tmp));
        handles.currentElement.saved=false;
        
        guidata(hObject,handles);
        myRedrawStatus(hObject);
    else
        warndlg(['The selected file does not contain ' ...
            'any experimentSpace'],...
            'ExperimentSpace Not Found','modal');
    end
end


end

%% OnNew callback
%Creates a new analysis
function OnNew_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

%Before creating a new one, close the current element if any
OnClose_Callback(hObject,eventData)

handles=guidata(hObject);
handles.currentElement.data=analysis;
handles.currentElement.saved=true;
handles.currentElement.dir=pwd; %Current document directory
handles.currentElement.filename=''; %Current document filename

%Make options and fields inactive as appropriate
set(handles.menuFile_OptClose,'Enable','on');
set(handles.menuFile_OptSave,'Enable','on');
set(handles.menuFile_OptSaveAs,'Enable','on');
set(handles.menuClusters,'Enable','on');
set(handles.menuClusters_OptAddCluster,'Enable','on');
set(handles.menuClusters_OptUpdateCluster,'Enable','on');
set(handles.menuClusters_OptRemoveCluster,'Enable','on');

set(handles.menuExperimentSpace,'Enable','on');
set(handles.menuExperimentSpace_OptComputeExperimentSpace,...
                'Enable','on');
set(handles.menuExperimentSpace_OptLoadExperimentSpace,...
                'Enable','on');

set(handles.menuTools,'Enable','off');
set(handles.menuTools_OptDistanceDistortion,'Enable','off');
set(handles.menuTools_OptEMD,'Enable','off');

set(handles.toolbarButton_DistanceDistortion,'Enable','off');

set(handles.toolbarButton_Save,'Enable','on');
set(handles.toolbarButton_AddCluster,'Enable','on');
set(handles.toolbarButton_UpdateCluster,'Enable','on');
set(handles.toolbarButton_RemoveCluster,'Enable','on');


set(handles.runButton,'Enable','on');

set(handles.idEditBox,'Enable','on');
set(handles.nameEditBox,'Enable','on');
set(handles.descriptionEditBox,'Enable','on');
set(handles.clustersTable,'Enable','on');
set(handles.visualizeButton,'Enable','on');
set(handles.emdButton,'Enable','on');

guidata(hObject,handles);
OnLoad(hObject);
end
       
%% OnOpen callback
%Opens an existing analysis
function OnOpen_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

%Before opening a document, close the current document if any
OnClose_Callback(hObject,eventData)

[FileName,PathName] = uigetfile('*.mat');
if isequal(FileName,0)
    %disp('Operation ''Open experiment'' cancelled')
else
    %load([PathName, FileName]);
    s=open([PathName, FileName]);
    vars = struct2cell(s);
    %Look for an 'experiment' variable
    for ii=1:length(vars)
        tmp=vars{ii};
        if(isa(tmp,'analysis'))
            break;
        end
    end
    if (isa(tmp,'analysis'))
        handles=guidata(hObject);
        handles.currentElement.data=analysis(tmp);
        handles.currentElement.saved=true;
        handles.currentElement.dir=PathName;
        handles.currentElement.filename=FileName;
        
        %Make options and fields inactive as appropriate
        set(handles.menuFile_OptClose,'Enable','on');
        set(handles.menuFile_OptSave,'Enable','on');
        set(handles.menuFile_OptSaveAs,'Enable','on');
        set(handles.menuClusters,'Enable','on');
        set(handles.menuClusters_OptAddCluster,'Enable','on');
        set(handles.menuClusters_OptUpdateCluster,'Enable','on');
        set(handles.menuClusters_OptRemoveCluster,'Enable','on');

        set(handles.menuExperimentSpace,'Enable','on');
        set(handles.menuExperimentSpace_OptComputeExperimentSpace,...
                'Enable','on');
        set(handles.menuExperimentSpace_OptLoadExperimentSpace,...
                'Enable','on');

        set(handles.toolbarButton_Save,'Enable','on');
        set(handles.toolbarButton_AddCluster,'Enable','on');
        set(handles.toolbarButton_UpdateCluster,'Enable','on');
        set(handles.toolbarButton_RemoveCluster,'Enable','on');
        set(handles.runButton,'Enable','on');

        set(handles.idEditBox,'Enable','on');
        set(handles.nameEditBox,'Enable','on');
        set(handles.descriptionEditBox,'Enable','on');
        set(handles.clustersTable,'Enable','on');
        set(handles.visualizeButton,'Enable','on');
        set(handles.emdButton,'Enable','on');

        guidata(hObject,handles);
        OnLoad(hObject);
        
    else
        warndlg('The selected file does not contain any analysis',...
            'Open Failed: Analysis Not Found','modal');
    end
end

end



%% OnQuit callback
%Clear memory and exit the application
function OnQuit_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
OnClose_Callback(hObject,eventData);
delete(get(gcf,'Children'));
delete(gcf);
end


%% OnRun callback
%On Run Analysis. Ask for an experiment and run the analysis
function OnRun_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);

%Ensure fields are updated...
OnUpdateElement_Callback(hObject,eventData)
OnChannelGrouping_Callback(hObject,eventData)
OnSessionDefinitionSelection_Callback(hObject,eventData)
OnSignalDescriptors_Callback(hObject,eventData)
OnSubjectSelection_Callback(hObject,eventData)


dlg_title='Run Analysis';
try
%     msgbox(['This may take a while, depending on the analysis '...
%             'configuration. Please be patient...'],dlg_title);
    handles.currentElement.data=...
            run(handles.currentElement.data);
    handles.currentElement.saved=false;
    guidata(hObject,handles);
    msgbox('Done!',dlg_title)
catch ME
    msg={ME.identifier,'', ME.message};
    errordlg(msg,dlg_title);
end
myRedraw(hObject); %Update status and cluster table
end

%% OnSaveAs Callback
%Save the changes to the element
function OnSaveAs_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles = guidata(f);
if (isempty(handles.currentElement.data))
    warndlg(['There''s no analysis currently opened.' ...
            'Nothing to be saved.'],...
        'Save As...','modal');
else
    [FileName,PathName] = uiputfile('*.mat');
    if isequal(FileName,0)
        %disp('Operation ''Save as'' cancelled')
    else
        mena=analysis(handles.currentElement.data);
        save([PathName, FileName],'mena');
        handles.currentElement.saved=true;
        handles.currentElement.dir=PathName;
        handles.currentElement.filename=FileName;
        guidata(hObject,handles);
    end
end

end

%% OnSave Callback
%Save the changes to the element
function OnSave_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
OnUpdateElement_Callback(hObject,eventData)
handles = guidata(f);
if (strcmp(handles.currentElement.filename,''))
    OnSaveAs_Callback(hObject,eventData);
else

    if (isempty(handles.currentElement.data))
        warndlg(['There''s no analysis currently opened.' ...
            'Nothing to be saved.'],...
            'Save As...','modal');
    else
        mena=analysis(handles.currentElement.data);
        save([handles.currentElement.dir, ...
              handles.currentElement.filename],'mena');
        handles.currentElement.saved=true;
        guidata(hObject,handles);
        
    end
end
end



%% OnSaveAndClose callback
%On Save and Closing this window
function OnSaveAndClose_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
OnSave_Callback(hObject,eventData);
OnQuit_Callback(hObject,eventData);
end


%% OnVisualize callback
%Visualizes the current analysis
function OnVisualize_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);

if ~isempty(handles.currentElement.data)
    guiVisualizeAnalysis(handles.currentElement.data);
end

end


%% OnUpdateElement callback
%Updates the current analysis with new information
function OnUpdateElement_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
try
    s=analysis(handles.currentElement.data);
    tmpId=str2double(get(handles.idEditBox,'String'));
    s=set(s,'ID',tmpId);
    s=set(s,'Name',get(handles.nameEditBox,'String'));
    s=set(s,'Description',get(handles.descriptionEditBox,'String'));
    handles.currentElement.data=s;
    handles.currentElement.saved=false;
catch ME
    msg={ME.identifier,'', ME.message};
    warndlg(msg,'Update Analysis');
    %Refresh those wrong values with the correct ones
    set(handles.idEditBox,'String',...
            num2str(get(handles.currentElement.data,'ID')));
    set(handles.nameEditBox,'String',...
            get(handles.currentElement.data,'Name'));
    set(handles.nameEditBox,'String',...
            get(handles.currentElement.data,'Description'));
end
guidata(hObject,handles);

end





end

%% AUXILIAR FUNCTIONS
function myRedraw(hObject)
%So that the GUI keeps it information up to date, easily
% hObject - Handle of the object, e.g., the GUI component,
handles=guidata(hObject);

if (isempty(handles.currentElement.data)) %Clear
    clear(hObject);
else %Refresh the Information
    s=handles.currentElement.data;
    set(handles.idEditBox,'String',get(s,'ID'));
    set(handles.nameEditBox,'String',get(s,'Name'));
    set(handles.descriptionEditBox,'String',get(s,'Description'));
    
    clusters=getClusterList(s);
    data=cell(getNClusters(s),3); %Four columns are currently displayed
                            %Tag,Visible,Num. Patterns
    rownames=zeros(1,getNClusters(s));
    pos=1;
    for ii=clusters
        element=getCluster(s,ii);
        rownames(pos)=get(element,'ID');
        data(pos,1)={get(element,'Tag')};
        data(pos,2)={get(element,'Visible')};
        data(pos,3)={num2str(get(element,'NPatterns'))};
        pos=pos+1;
    end
    set(handles.clustersTable,'RowName',rownames);
    set(handles.clustersTable,'Data',data);
    
    myRedrawStatus(hObject)
end
end


function myRedrawStatus(hObject)
%So that the GUI keeps it information up to date, easily
% hObject - Handle of the object, e.g., the GUI component,
handles=guidata(hObject);

tmpES=get(handles.currentElement.data,'ExperimentSpace');
tmpRunStatus=get(tmpES,'RunStatus');
if tmpRunStatus
    set(handles.experimentSpaceStatusText,...
        'String',['COMPUTED (' num2str(get(tmpES,'nPoints')) ')']);
    set(handles.runButton,'Enable','on');
else
    set(handles.experimentSpaceStatusText,'String','NOT COMPUTED');
    set(handles.runButton,'Enable','off');
    set(handles.visualizeButton,'Enable','off');
    set(handles.emdButton,'Enable','off');

end

if get(handles.currentElement.data,'RunStatus')
    set(handles.runStatusText,'String',['RUN (' ...
         num2str(get(handles.currentElement.data,'NPatterns')) ')']);
    set(handles.visualizeButton,'Enable','on');
    set(handles.emdButton,'Enable','on');
    set(handles.toolbarButton_DistanceDistortion,'Enable','on');

    set(handles.menuTools,'Enable','on');
    set(handles.menuTools_OptDistanceDistortion,'Enable','on');
    set(handles.menuTools_OptEMD,'Enable','on');
else
    set(handles.runStatusText,'String','NOT RUN');
    set(handles.visualizeButton,'Enable','off');
    set(handles.emdButton,'Enable','off');
    set(handles.toolbarButton_DistanceDistortion,'Enable','off');
        
    set(handles.menuTools,'Enable','off');
    set(handles.menuTools_OptDistanceDistortion,'Enable','off');
    set(handles.menuTools_OptEMD,'Enable','off');
end

guidata(hObject,handles);

end