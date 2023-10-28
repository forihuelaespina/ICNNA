function guiExperiment()
%guiExperiment Graphical User Interface for experimental data storing
%
% guiExperiment
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also icnna, guiAnalysis, guiExperimentSpace
%

%% Log
%
%
% File created: 16-Apr-2008
% File last modified (before creation of this log): 4-Jan-2013
%
% 24-May-2023: FOE
%   + Added this log.
%   + Got rid of old labels @date and @modified.
%   + I have now addressed the long standing issue with accessing
%   the icons folder when the working directory is not that of ICNNA
%   using function mfilename. 
%   + Started to update the get/set methods calls to struct like syntax
%

%% Initialize the figure
%...and hide the GUI as it is being constructed
width=600;
height=580;
f=figure('Visible','off','Position',[100,100,width,height]);
set(f,'NumberTitle','off');
set(f,'MenuBar','none'); %Hide MATLAB figure menu
set(f,'CloseRequestFcn',{@AppOnQuit_Callback});


%% Add components
%Menus
menuFile = uimenu('Label','File',...
    'Tag','menuFile');
    uimenu(menuFile,'Label','New Experiment...',...
        'Tag','OptNew',...
        'Callback',{@OptNew_Callback},... 
        'Accelerator','n');
    uimenu(menuFile,'Label','Open Experiment...',...
        'Tag','OptOpen',...
        'Callback',{@OptOpen_Callback},... 
        'Accelerator','o');
    uimenu(menuFile,'Label','Close Experiment',...
        'Tag','OptClose',...
        'Callback',{@AppCloseDocument_Callback},... 
        'Accelerator','c');
    uimenu(menuFile,'Label','Save',...
        'Tag','OptSave',...
        'Callback',{@OptSave_Callback},... 
        'Separator','on','Accelerator','s');
    uimenu(menuFile,'Label','Save As...',...
        'Tag','OptSaveAs',...
        'Callback',{@OptSaveAs_Callback},... 
        'Accelerator','S');
    uimenu(menuFile,'Label','Quit',...
        'Tag','OptQuit',...
        'Callback',{@AppOnQuit_Callback},... 
        'Separator','on','Accelerator','q');
       

menuData = uimenu('Label','Data',...
    'Tag','menuData');
    uimenu(menuData,'Label','Add Data Source Definition',...
        'Tag','OptAddDataSourceDefinition',...
        'Callback',{@OptAddDataSourceDefinition_Callback});
    uimenu(menuData,'Label','Remove Data Source Definition',...
        'Tag','OptRemoveDataSourceDefinition',...
        'Callback',{@OptRemoveDataSourceDefinition_Callback});
    uimenu(menuData,'Label','Add Session Definition',...
        'Tag','OptAddSessionDefinition',...
        'Separator','on',...
        'Callback',{@OptAddSessionDefinition_Callback});
    uimenu(menuData,'Label','Remove Session Definition',...
        'Tag','OptRemoveSessionDefinition',...
        'Callback',{@OptRemoveSessionDefinition_Callback});
    uimenu(menuData,'Label','Add Subject',...
        'Tag','OptAddSubject',...
        'Separator','on',...
        'Callback',{@OptAddSubject_Callback});
    uimenu(menuData,'Label','Update Subject',...
        'Tag','OptUpdateSubject',...
        'Callback',{@OptUpdateSubject_Callback});
    uimenu(menuData,'Label','Remove Subject',...
        'Tag','OptRemoveSubject',...
        'Callback',{@OptRemoveSubject_Callback});
    uimenu(menuData,'Label','Import Subject (fOSA)',...
        'Separator','on',...
        'Tag','OptImportfOSAfile',...
        'Callback',{@ImportfOSAfile_Callback});

menuTools = uimenu('Label','Tools',...
    'Tag','menuTools');
    uimenu(menuTools,'Label','Quick import (fOSA)',...
        'Tag','OptImportfOSAdir',...
        'Callback',{@ImportfOSAdir_Callback});
    uimenu(menuTools,'Label','Check integrity...',...
        'Tag','OptCheckIntegrity',...
        'Separator','on',...
        'Callback',{@OptCheckIntegrity_Callback});
	uimenu(menuTools,'Label','Plot generation',...
        'Tag','OptPlotGeneration',...
        'Callback',{@OnPlotGeneration_Callback});
	uimenu(menuTools,'Label','Database generation',...
        'Tag','OptDatabaseGeneration',...
        'Callback',{@OnComputeExperimentSpace_Callback});


   
menuHelp = uimenu('Label','Help',...
    'Tag','menuHelp');
    uimenu(menuHelp,'Label','About',...
            'Tag','OptAbout',...
            'Callback',{@OptAbout_Callback});

%Toolbars
toolbar = uitoolbar(f,'Tag','toolbar');
[localDir,~,~] = fileparts(mfilename('fullpath'));
iconsFolder=[localDir filesep 'icons' filesep];

tempIcon=load([iconsFolder 'newdoc.mat']);
	uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_New',...
        'TooltipString','New Experiment',...
        'ClickedCallback',{@OptNew_Callback});
tempIcon=load([iconsFolder 'opendoc.mat']);
	uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_Load',...
        'TooltipString','Open Experiment',...
        'ClickedCallback',{@OptOpen_Callback});
tempIcon=load([iconsFolder 'savedoc.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_Save',...
        'TooltipString','Save Experiment',...
        'ClickedCallback',{@OptSave_Callback});
tempIcon=load([iconsFolder 'addDataSourceDefinition.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_AddDataSourceDefinition',...
        'Separator','on','TooltipString','Add a new Data Source Definition',...
        'ClickedCallback',{@OptAddDataSourceDefinition_Callback});
tempIcon=load([iconsFolder 'removeDataSourceDefinition.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_RemoveDataSourceDefinition',...
        'TooltipString','Removes a DataSource Definition',...
        'ClickedCallback',{@OptRemoveDataSourceDefinition_Callback});
tempIcon=load([iconsFolder 'addSessionDefinition.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_AddSessionDefinition',...
        'Separator','on','TooltipString','Add a new Session Definition',...
        'ClickedCallback',{@OptAddSessionDefinition_Callback});
tempIcon=load([iconsFolder 'removeSessionDefinition.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_RemoveSessionDefinition',...
        'TooltipString','Removes a Session Definition',...
        'ClickedCallback',{@OptRemoveSessionDefinition_Callback});
tempIcon=load([iconsFolder 'addSubject.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_AddSubject',...
        'Separator','on','TooltipString','Add a new Subject',...
        'ClickedCallback',{@OptAddSubject_Callback});
tempIcon=load([iconsFolder 'updateSubject.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_UpdateSubject',...
        'TooltipString','Updates Subject Information',...
        'ClickedCallback',{@OptUpdateSubject_Callback});
tempIcon=load([iconsFolder 'removeSubject.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_RemoveSubject',...
        'TooltipString','Removes a Subject',...
        'ClickedCallback',{@OptRemoveSubject_Callback});
tempIcon=load([iconsFolder 'importfOSAfile.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_ImportfOSAfile',...
        'TooltipString','Import file data from fOSA',...
        'ClickedCallback',{@ImportfOSAfile_Callback});
tempIcon=load([iconsFolder 'importfOSAdir.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_ImportfOSAdir',...
        'Separator','on',...
        'TooltipString','Quick directory import data from fOSA',...
        'ClickedCallback',{@ImportfOSAdir_Callback});
tempIcon=load([iconsFolder 'checkIntegrity.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_CheckIntegrity',...
        'TooltipString','Check integrity of active data',...
        'ClickedCallback',{@OptCheckIntegrity_Callback});


    
fontSize=14;
bgColor=get(f,'Color');
descriptionPanel = uipanel(f,...
        'BorderType','none',...
		'FontSize',fontSize-2,...
        'BackgroundColor',get(f,'Color'),...
        'Position',[0.01 0.78 0.96 0.2]);

uicontrol(descriptionPanel,'Style', 'text',...
       'String', 'Name:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.66 0.2 0.3]);
uicontrol(descriptionPanel,'Style', 'edit',...
       'Tag','nameEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@AppUpdateCurrentDocument_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.66 0.6 0.3]);
uicontrol(descriptionPanel,'Style', 'text',...
       'String', 'Description:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.33 0.2 0.3]);
uicontrol(descriptionPanel,'Style', 'edit',...
       'Tag','descriptionEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@AppUpdateCurrentDocument_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.33 0.6 0.3]);

uicontrol(descriptionPanel,'Style', 'text',...
       'String', 'Date:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.02 0.2 0.3]);
uicontrol(descriptionPanel,'Style', 'edit',...
       'Tag','dateEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@AppUpdateCurrentDocument_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.02 0.6 0.3]);

tabPanel=uitabgroup(f,'Position', [0.05 0.02 0.9 0.7]);

subjectsTab = uitab(tabPanel,...
       'Title','Subjects');
uicontrol(subjectsTab,'Style', 'checkbox',...
       'Tag','showSubjectsCheckbox',...
       'Min', 0,...
       'Max', 1,...
       'Value', 0,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-4,...
       'Units','normalize',...
       'Position', [0.04 0.85 0.04 0.12],...
       'Callback',{@showSubjectsCheckbox_Callback});
uicontrol(subjectsTab,'Style', 'text',...
       'Tag','showSubjectsText',...
       'String', 'Show/Hide subjects (0)',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-4,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.09 0.85 0.5 0.12]);
colNames = {'Name','Age','Sex','Num. Sessions'};
    uitable(subjectsTab,...
        'Tag','subjectsTable',...
        'Enable','Inactive',...
        'FontSize',fontSize,...
        'ColumnName',colNames,...
        'Units','normalize',...
        'Position',[0.02 0.02 0.96 0.8]);

sessionsDefsTab = uitab(tabPanel,...
       'Title','Session Definitions');
colNames = {'Name','Num. Sources'};
    uitable(sessionsDefsTab,...
        'Tag','sessionDefinitionsTable',...
        'Enable','Inactive',...
        'FontSize',fontSize,...
        'ColumnName',colNames,...
        'Units','normalize',...
        'Position',[0.02 0.02 0.96 0.96]);

dataSourceDefsTab = uitab(tabPanel,...
       'Title','Source Definitions');
colNames = {'Type','Device Number'};
    uitable(dataSourceDefsTab,...
        'Tag','dataSourceDefinitionsTable',...
        'Enable','Inactive',...
        'FontSize',fontSize,...
        'ColumnName',colNames,...
        'Units','normalize',...
        'Position',[0.02 0.02 0.96 0.96]);

    


%% On Opening
myhandles = guihandles(f); %NOTE that only include those whose 'Tag' are not empty
myhandles.currentDoc.data=experiment; %The experiment
myhandles.currentDoc.saved=true; %Save state; Has the document been saved since last change?
myhandles.currentDoc.dir=pwd; %Current document (experiment)directory
myhandles.currentDoc.filename=''; %Current document filename

%Redrawing tables containing information from objects
%rather than plain matrix is highly time consuming...
%Therefore try to control and minimise the number of redrawings
myhandles.redrawSubjectsTable=true;
if (get(myhandles.showSubjectsCheckbox,'Value'))
    set(myhandles.subjectsTable,'Visible','on');
else
    set(myhandles.subjectsTable,'Visible','off');
end
guidata(f,myhandles);
myRedraw(f);
 
%% Make GUI visible
set(f,'Name','ICNNA - Experiment');
set(f,'Visible','on');


%% Callback functions
%%===========================================================

%% AppCloseDocument callback
%Closes a document (experiment). Check whether data needs saving
function AppCloseDocument_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (~isempty(handles.currentDoc.data))
    closeDoc=true;
    if (~handles.currentDoc.saved)
        %Offer the possibility of saving
        button = questdlg(['Current document is not saved. ' ...
            'Would you like to save the latest changes before ' ...
            'closing it?'],...
            'Close Document','Save','Close','Cancel','Close');
        switch (button)
            case 'Save'
                OptSave_Callback(hObject,eventData);
                closeDoc=true;
            case 'Close'
                closeDoc=true;
            case 'Cancel'
                closeDoc=false;
        end
    end

    if (closeDoc)
        clear handles.currentDoc.data
        %Now closing
        handles.currentDoc.data=[];
        handles.currentDoc.saved=true;
        handles.currentDoc.dir=pwd;
        handles.currentDoc.filename='';
        
        %Make options and fields inactive as appropriate
        set(handles.OptClose,'Enable','off');
        set(handles.OptSave,'Enable','off');
        set(handles.OptSaveAs,'Enable','off');
        set(handles.menuData,'Enable','off');
        set(handles.OptAddDataSourceDefinition,'Enable','off');
        set(handles.OptRemoveDataSourceDefinition,'Enable','off');
        set(handles.OptAddSessionDefinition,'Enable','off');
        set(handles.OptRemoveSessionDefinition,'Enable','off');
        set(handles.OptAddSubject,'Enable','off');
        set(handles.OptUpdateSubject,'Enable','off');
        set(handles.OptRemoveSubject,'Enable','off');
        set(handles.OptImportfOSAfile,'Enable','off');
        set(handles.menuTools,'Enable','off');
        set(handles.OptImportfOSAdir,'Enable','off');
        set(handles.OptCheckIntegrity,'Enable','off');
        set(handles.OptPlotGeneration,'Enable','off');
        %set(handles.OptDatabaseGeneration,'Enable','off');
        
        set(handles.toolbarButton_Save,'Enable','off');
        set(handles.toolbarButton_AddDataSourceDefinition,'Enable','off');
        set(handles.toolbarButton_RemoveDataSourceDefinition,'Enable','off');
        set(handles.toolbarButton_AddSessionDefinition,'Enable','off');
        set(handles.toolbarButton_RemoveSessionDefinition,'Enable','off');
        set(handles.toolbarButton_AddSubject,'Enable','off');
        set(handles.toolbarButton_UpdateSubject,'Enable','off');
        set(handles.toolbarButton_RemoveSubject,'Enable','off');
        set(handles.toolbarButton_ImportfOSAfile,'Enable','off');
        set(handles.toolbarButton_ImportfOSAdir,'Enable','off');
        set(handles.toolbarButton_CheckIntegrity,'Enable','off');
        
        set(handles.nameEditBox,'Enable','off');
        set(handles.descriptionEditBox,'Enable','off');
        set(handles.dateEditBox,'Enable','off');
        set(handles.showSubjectsCheckbox,'Enable','off');
        set(handles.subjectsTable,'Enable','off');
        
        guidata(hObject,handles);
        myRedraw(hObject);
    end
end

end

%% AppOnQuit callback
%Clear memory and exit the application
function AppOnQuit_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
AppCloseDocument_Callback(hObject,eventData);
delete(get(gcf,'Children'));
delete(gcf);
end

%% AppUpdateCurrentDocument callback
%Updates the current document with new information
function AppUpdateCurrentDocument_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (~isempty(handles.currentDoc.data))
    e=experiment(handles.currentDoc.data);
    e.name = get(handles.nameEditBox,'String');
    e.description = get(handles.descriptionEditBox,'String');
    e.date = get(handles.dateEditBox,'String');
    handles.currentDoc.data=e;
    handles.currentDoc.saved=false;
    guidata(hObject,handles);
end
end



%% OnComputeExperimentSpace callback
%Opens the "guiExperimentSpace" GUI to compute the Experiment space
%and generate a database
function OnComputeExperimentSpace_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
guiExperimentSpace(experimentSpace);
end

%% OnPlotGeneration callback
%Opens the "guiBasicVisualization" GUI to plot basic visualization
function OnPlotGeneration_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (~isempty(handles.currentDoc.data))
  guiBasicVisualization(handles.currentDoc.data);
end
end

%% OptNew callback
%Creates a new experiment
function OptNew_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

%Before creating a new one, close the current document if any
AppCloseDocument_Callback(hObject,eventData)

handles=guidata(hObject);
handles.currentDoc.data=experiment;
handles.currentDoc.saved=true;
handles.currentDoc.dir=pwd; %Current document (experiment)directory
handles.currentDoc.filename=''; %Current document filename

%Make options and fields inactive as appropriate
set(handles.OptClose,'Enable','on');
set(handles.OptSave,'Enable','on');
set(handles.OptSaveAs,'Enable','on');
set(handles.menuData,'Enable','on');
set(handles.OptAddDataSourceDefinition,'Enable','on');
set(handles.OptRemoveDataSourceDefinition,'Enable','on');
set(handles.OptAddSessionDefinition,'Enable','on');
set(handles.OptRemoveSessionDefinition,'Enable','on');
set(handles.OptAddSubject,'Enable','on');
set(handles.OptUpdateSubject,'Enable','on');
set(handles.OptRemoveSubject,'Enable','on');
set(handles.OptImportfOSAfile,'Enable','on');
set(handles.menuTools,'Enable','on');
set(handles.OptImportfOSAdir,'Enable','on');
set(handles.OptCheckIntegrity,'Enable','on');

set(handles.toolbarButton_Save,'Enable','on');
set(handles.toolbarButton_AddDataSourceDefinition,'Enable','on');
set(handles.toolbarButton_RemoveDataSourceDefinition,'Enable','on');
set(handles.toolbarButton_AddSessionDefinition,'Enable','on');
set(handles.toolbarButton_RemoveSessionDefinition,'Enable','on');
set(handles.toolbarButton_AddSubject,'Enable','on');
set(handles.toolbarButton_UpdateSubject,'Enable','on');
set(handles.toolbarButton_RemoveSubject,'Enable','on');
set(handles.toolbarButton_ImportfOSAfile,'Enable','on');
set(handles.toolbarButton_ImportfOSAdir,'Enable','on');
set(handles.toolbarButton_CheckIntegrity,'Enable','on');
set(handles.OptPlotGeneration,'Enable','on');
%set(handles.OptDatabaseGeneration,'Enable','on');

set(handles.nameEditBox,'Enable','on');
set(handles.descriptionEditBox,'Enable','on');
set(handles.dateEditBox,'Enable','on');
set(handles.showSubjectsCheckbox,'Enable','on');
set(handles.subjectsTable,'Enable','on');

guidata(hObject,handles);
myRedraw(hObject);
end
       
%% OptOpen callback
%Opens an existing experiment
function OptOpen_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

%Before opening a document, close the current document if any
AppCloseDocument_Callback(hObject,eventData)

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
        if(isa(tmp,'experiment'))
            break;
        end
    end
    if (isa(tmp,'experiment'))
        handles=guidata(hObject);
        handles.currentDoc.data=tmp;
        handles.currentDoc.saved=true;
        handles.currentDoc.dir=PathName;
        handles.currentDoc.filename=FileName;
        
        %Make options and fields inactive as appropriate
        set(handles.OptClose,'Enable','on');
        set(handles.OptSave,'Enable','on');
        set(handles.OptSaveAs,'Enable','on');
        set(handles.menuData,'Enable','on');
        set(handles.OptAddDataSourceDefinition,'Enable','on');
        set(handles.OptRemoveDataSourceDefinition,'Enable','on');
        set(handles.OptAddSessionDefinition,'Enable','on');
        set(handles.OptRemoveSessionDefinition,'Enable','on');
        set(handles.OptAddSubject,'Enable','on');
        set(handles.OptUpdateSubject,'Enable','on');
        set(handles.OptRemoveSubject,'Enable','on');
        set(handles.OptImportfOSAfile,'Enable','on');
        set(handles.menuTools,'Enable','on');
        set(handles.OptImportfOSAdir,'Enable','on');
        set(handles.OptCheckIntegrity,'Enable','on');
        set(handles.OptPlotGeneration,'Enable','on');
        %set(handles.OptDatabaseGeneration,'Enable','on');

        set(handles.toolbarButton_Save,'Enable','on');
        set(handles.toolbarButton_AddDataSourceDefinition,'Enable','on');
        set(handles.toolbarButton_RemoveDataSourceDefinition,'Enable','on');
        set(handles.toolbarButton_AddSessionDefinition,'Enable','on');
        set(handles.toolbarButton_RemoveSessionDefinition,'Enable','on');
        set(handles.toolbarButton_AddSubject,'Enable','on');
        set(handles.toolbarButton_UpdateSubject,'Enable','on');
        set(handles.toolbarButton_RemoveSubject,'Enable','on');
        set(handles.toolbarButton_ImportfOSAfile,'Enable','on');
        set(handles.toolbarButton_ImportfOSAdir,'Enable','on');
        set(handles.toolbarButton_CheckIntegrity,'Enable','on');

        set(handles.nameEditBox,'Enable','on');
        set(handles.descriptionEditBox,'Enable','on');
        set(handles.dateEditBox,'Enable','on');
        set(handles.showSubjectsCheckbox,'Enable','on');
        set(handles.subjectsTable,'Enable','on');

        guidata(hObject,handles);
        
    else
        warndlg('The selected file does not contain any experiment',...
            'Open Failed: Experiment Not Found','modal');
    end
end

myRedraw(hObject);
end


%% OptSave callback
%Saves an existing experiment in its own file or triggers the Save As
%option if the experiment has been created new
function OptSave_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered. See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if isempty(handles.currentDoc.data)
    warndlg(['There''s no experiment currently opened.' ...
            'Nothing to be saved.'],...
            'Save','modal');
else
    AppUpdateCurrentDocument_Callback(hObject,eventData)
    if strcmp(handles.currentDoc.filename,'')
        OptSaveAs_Callback(hObject,eventData)
    else
        PathName=handles.currentDoc.dir;
        FileName=handles.currentDoc.filename;
        E=experiment(handles.currentDoc.data);
        save([PathName, FileName],'E');
        handles.currentDoc.saved=true;
        guidata(hObject,handles);
        %disp(['Experiment saved in ', fullfile(PathName, FileName)])
    end
end
end


%% OptSaveAs callback
%Saves an existing experiment
function OptSaveAs_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered. See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentDoc.data))
    warndlg(['There''s no experiment currently opened.' ...
            'Nothing to be saved.'],...
        'Save As...','modal');
else
    [FileName,PathName] = uiputfile('*.mat');
    if isequal(FileName,0)
        %disp('Operation ''Save as'' cancelled')
    else
        %load([PathName, FileName]);
        AppUpdateCurrentDocument_Callback(hObject,eventData);
        E=experiment(handles.currentDoc.data);
        save([PathName, FileName],'E');
        handles.currentDoc.saved=true;
        handles.currentDoc.dir=PathName;
        handles.currentDoc.filename=FileName;
        guidata(hObject,handles);
        %disp(['Experiment saved in ', fullfile(PathName, FileName)])
    end
end
end

%% OptAbout callback
%Opens the "About ICNNA" information window
function OptAbout_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
aboutICNNA;
end

%% OptAddDataSourceDefinition callback
%Opens the window for adding a new data source definition to the experiment
function OptAddDataSourceDefinition_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentDoc.data))
    warndlg('There''s no experiment currently opened.',...
        'Add Data Source Definition','modal');
else
    
    s=guiDataSourceDefinition();
    if (~isempty(s))
        existingElements=getDataSourceDefinitionList(handles.currentDoc.data);
%         if (isempty(existingElements))
%             newId=1;
%         else
%             newId=max(existingElements)+1;
%         end
%         s=set(s,'ID',newId);
        if ismember(get(s,'ID'),existingElements)
            warndlg('ID already being used. Nothing will be added', ...
                'Add Data Source Definition','modal');
        else

            handles.currentDoc.data=...
                addDataSourceDefinition(handles.currentDoc.data,s);
            handles.currentDoc.saved=false;
            handles.redrawDataSourcDefinitionsTable=true;
            guidata(hObject,handles);
            myRedraw(hObject);
        end
    end
end

end

%% OptAddSessionDefinition callback
%Opens the window for adding a new session definition to the experiment
function OptAddSessionDefinition_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentDoc.data))
    warndlg('There''s no experiment currently opened.',...
        'Add Session Definition','modal');
else
    
    s=guiSessionDefinition();
    if (~isempty(s))
        existingElements=getSessionDefinitionList(handles.currentDoc.data);
%         if (isempty(existingElements))
%             newId=1;
%         else
%             newId=max(existingElements)+1;
%         end
%         s=set(s,'ID',newId);
        if ismember(s.id,existingElements)
            warndlg('ID already being used. Nothing will be added', ...
                    'Add Session Definition','modal');
        else
            %The sessionDefintion may still not be added if 
            %conflicts occur
            handles.currentDoc.data=...
                addSessionDefinition(handles.currentDoc.data,s);
            handles.currentDoc.saved=false;
            handles.redrawSessionDefinitionsTable=true;
            guidata(hObject,handles);
            myRedraw(hObject);
        end
    end
end
end

%% OptRemoveDataSourceDefinition callback
%Opens the window for eliminating a dataSource definition from the experiment
function OptRemoveDataSourceDefinition_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentDoc.data))
    warndlg('There''s no experiment currently opened.',...
        'Remove Data Source Definition','modal');
else
    options.Resize='off';
    options.WindowStyle='modal';
    answer = inputdlg('Data Source Definition ID:',...
        'Remove Data Source definition?',1,{''},options);
    if (isempty(answer)) %Cancel button pressed
    else
      answer=str2double(answer);
      if (~isnan(answer))
        s=getDataSourceDefinition(handles.currentDoc.data,answer);
        if (~isempty(s))
            
            button = questdlg(['Removing a data source definition ' ...
                'may result in cascade removal of session definitions ' ...
                'from the experiment and existing session data from ' ...
                'subjects. Would you like to proceed?'],...
                'Remove Data Source definition','Yes','Cancel','Cancel');
            if (strcmp(button,'Yes'))
                handles.currentDoc.data=...
                    removeDataSourceDefinition(handles.currentDoc.data,answer);
                handles.currentDoc.saved=false;
                guidata(hObject,handles);
                myRedraw(hObject);
            end
        else
            warndlg('Data source definition not found',...
                'Remove Data Source Definition','modal');     
        end
      else
        warndlg('Data source definition ID not recognised',...
                'Remove Data Source Definition','modal');
      end
    end
end
    
end

%% OptRemoveSessionDefinition callback
%Opens the window for eliminating a session definition from the experiment
function OptRemoveSessionDefinition_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentDoc.data))
    warndlg('There''s no experiment currently opened.',...
        'Remove Session Definition','modal');
else
    options.Resize='off';
    options.WindowStyle='modal';
    answer = inputdlg('Session Definition ID:',...
        'Remove Session definition?',1,{''},options);
    if (isempty(answer)) %Cancel button pressed
    else
      answer=str2double(answer);
      if (~isnan(answer))
        s=getSessionDefinition(handles.currentDoc.data,answer);
        if (~isempty(s))
            button = questdlg(['Removing a session definition ' ...
                'may result in cascade removal of session data ' ...
                'from subjects. Would you like to proceed?'],...
                'Remove Session definition','Yes','Cancel','Cancel');
            if (strcmp(button,'Yes'))
                e=removeSessionDefinition(handles.currentDoc.data,answer);
                handles.currentDoc.data=e;
                handles.currentDoc.saved=false;
                guidata(hObject,handles);
                myRedraw(hObject);
            end
        else
            warndlg('Session definition not found',...
                'Remove Session Definition','modal');     
        end
      else
        warndlg('Session definition ID not recognised',...
                'Remove Session Definition','modal');
      end
    end
end
    
end


%% OptAddSubject callback
%Opens the window for adding a new subject to the experiment
function OptAddSubject_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentDoc.data))
    warndlg('There''s no experiment currently opened.',...
        'Add Subject','modal');
else
    
    s=guiSubject();
    if (~isempty(s))
        existingElements=getSubjectList(handles.currentDoc.data);
%         if (isempty(existingElements))
%             newId=1;
%         else
%             newId=max(existingElements)+1;
%         end
%         s=set(s,'ID',newId);
        if ismember(s.id,existingElements)
            warndlg('Subject ID already being used. Nothing will be added', ...
                    'Add Subject','modal');
        else
            %Subjects may still not be added if conflicts
            %of session definition occur
            handles.currentDoc.data=addSubject(handles.currentDoc.data,s);
            handles.currentDoc.saved=false;
            handles.redrawSubjectsTable=true;
            guidata(hObject,handles);
            myRedraw(hObject);
        end
    end
end

end

%% OptUpdateSubject callback
%Opens the window for update a subject information
function OptUpdateSubject_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentDoc.data))
    warndlg('There''s no experiment currently opened.',...
        'Update Subject','modal');
else
    options.Resize='off';
    options.WindowStyle='modal';
    while 1 %Get a valid (existing or new) id, or cancel action
        answer = inputdlg('Subject ID:','Update which subject?',...
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
        existingElements=getSubjectList(handles.currentDoc.data);
        if (ismember(elemID,existingElements))
            s=getSubject(handles.currentDoc.data,elemID);
        else           
            button = questdlg(['Subject ID not found. ' ...
                'Would you like to create a new subject ' ...
                'with the given ID?'],'Create New Subject',...
                'Yes','No','No');
            switch(button)
                case 'Yes'
                    %Note that the subject will be created, even
                    %if the user click the cancel button on the
                    %guiSubject!!
                    s=subject(elemID);
                    handles.currentDoc.data=...
                        addSubject(handles.currentDoc.data,s);
                    handles.currentDoc.saved=false;
                    handles.redrawSubjectsTable=true;
                    guidata(hObject,handles);
                    myRedraw(hObject);

                case 'No'
                    return
            end
        end
        
        %Now update
        s=guiSubject(s);
        if (~isempty(s))
            handles.currentDoc.data=...
                setSubject(handles.currentDoc.data,s.id,s);
            handles.currentDoc.saved=false;
            handles.redrawSubjectsTable=true;
            guidata(hObject,handles);
        end
        myRedraw(hObject);
    end
end
end

%% OptRemoveSubject callback
%Opens the window for eliminating a subject from the experiment
function OptRemoveSubject_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentDoc.data))
    warndlg('There''s no experiment currently opened.',...
        'Remove Subject','modal');
else
    options.Resize='off';
    options.WindowStyle='modal';
    answer = inputdlg('Subject ID:','Remove subject?',1,{''},options);
    if (isempty(answer)) %Cancel button pressed
    else
      answer=str2double(answer);
      if (~isnan(answer))
        s=getSubject(handles.currentDoc.data,answer);
        if (~isempty(s))
            e=removeSubject(handles.currentDoc.data,answer);
            handles.currentDoc.data=e;
            handles.currentDoc.saved=false;
            guidata(hObject,handles);
        else
            warndlg('Subject not found','Remove Subject','modal');     
        end
      else
        warndlg('Subject ID not recognised','Remove Subject','modal');
      end
    end
end
    myRedraw(hObject);
end

%% OptCheckIntegrity callback
%List the available integrity tests and checks the integrity appropriately
function OptCheckIntegrity_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
handles.currentDoc.data=guiCheckIntegrity(handles.currentDoc.data);
handles.currentDoc.saved=false;
guidata(hObject,handles);
end

%% ImportfOSAfile Callback
%Import fOSA data file
function ImportfOSAfile_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);

%First select the file
[FileName,PathName] = uigetfile('*.mat','WindowStyle');
if isequal(FileName,0)
    %disp('Operation ''Import fOSA data'' cancelled')
else

    importData=true;
    button=questdlg(['A new subject will be created for this experiment. ' ...
        'Would you like to proceed?'],'Import fOSA data', ...
        'Yes','Cancel','Cancel');
    switch (button)
        case 'Yes'
            importData=true;
        case 'Cancel'
            importData=false;
    end

    if (importData)
        handles.currentDoc.data=...
            importfOSAfile(handles.currentDoc.data,[PathName FileName]);
        handles.currentDoc.saved=false;
        guidata(hObject,handles);
        myRedraw(hObject);
    end
end

end

%% ImportfOSAdir Callback
%Import all fOSA data files within a directory
%Each fOSA (*.mat) file will produce a new subject
function ImportfOSAdir_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);

%First select the file
DirName = uigetdir('');
if isequal(DirName,0)
    %disp('Operation ''Import fOSA data'' cancelled')
else

    files=dir([DirName '\*.mat']);
    
    barProgress=0;
    h = waitbar(barProgress,'Importing directory - 0%');
    p=get(h,'Position');
    p(2)=p(2)+p(4)+30;
    set(h,'Position',p);
    set(h,'DefaulttextInterpreter','none');
    step=1/(length(files)+2);

    tmpNewSubjects=cell(1,length(files));
   
    maxId=max(getSubjectList(handles.currentDoc.data));
    if (isempty(maxId)), maxId=0; end;
    
    for i=1:length(files)
        waitbar(barProgress,h,['Importing ' files(i).name...
            ' - ' num2str(round(barProgress*100)) '%']);
        barProgress=barProgress+step;
        filename=[DirName '\' files(i).name];
        tmpSubj=subject(maxId+i);
        tmpSubj=importfOSAfile(tmpSubj,filename);
        tmpNewSubjects(i)={tmpSubj};
    end
    waitbar(barProgress,h,['Adding subjects to experiment' ...
            ' - ' num2str(round(barProgress*100)) '%']);
    handles.currentDoc.data=...
            addSubject(handles.currentDoc.data,tmpNewSubjects);
    handles.currentDoc.saved=false;
    waitbar(1,h);
    close(h);
end
guidata(hObject,handles);
myRedraw(hObject);

end

%% showSubjectsCheckbox Callback
%Show or hide the subjects panel
function showSubjectsCheckbox_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (get(handles.showSubjectsCheckbox,'Value'))
    set(handles.subjectsTable,'Visible','on');
else
    set(handles.subjectsTable,'Visible','off');
end
guidata(hObject,handles);
myRedraw(hObject);
end


end %guiICNNA %Necessary because nested functions are being used.

%% AUXILIAR FUNCTIONS
function myRedraw(hObject)
%So that the GUI keeps it information up to date, easily
% hObject - Handle of the object, e.g., the GUI component,
handles=guidata(hObject);
if (isempty(handles.currentDoc.data)) %Clear
    set(handles.nameEditBox,'String','');
    set(handles.descriptionEditBox,'String','');
    set(handles.dateEditBox,'String','');
    set(handles.showSubjectsCheckbox,'Value',0);
    set(handles.showSubjectsText,'String','Show/hide subjects (0)');
    set(handles.dataSourceDefinitionsTable,'RowName',[]);
    set(handles.dataSourceDefinitionsTable,'Data',[]);
    set(handles.sessionDefinitionsTable,'RowName',[]);
    set(handles.sessionDefinitionsTable,'Data',[]);
    set(handles.subjectsTable,'Visible','off');
    set(handles.subjectsTable,'RowName',[]);
    set(handles.subjectsTable,'Data',[]);
else %Refresh the Information
    e=experiment(handles.currentDoc.data);
    set(handles.nameEditBox,'String',e.name);
    set(handles.descriptionEditBox,'String',e.description);
    set(handles.dateEditBox,'String',e.date);

    %%%%Refresh Data Source Definitions
    data=cell(e.nDataSourceDefinitions,2); %Two columns
    %Type and Device number
    dataSourceDefinitions=getDataSourceDefinitionList(e);
    rownames=zeros(1,e.nDataSourceDefinitions);
    pos=1;
    for ii=dataSourceDefinitions
        s=getDataSourceDefinition(e,ii);
        rownames(pos)=s.id;
        data(pos,1)={s.type};
        data(pos,2)={s.deviceNumber};
        pos=pos+1;
    end
    set(handles.dataSourceDefinitionsTable,'RowName',rownames);
    set(handles.dataSourceDefinitionsTable,'Data',data);

    
    
    %%%%Refresh Session Definitions
    data=cell(e.nSessionDefinitions,2); %Two columns
    %Name and Number of Sources
    sessionDefinitions=getSessionDefinitionList(e);
    rownames=zeros(1,e.nSessionDefinitions);
    pos=1;
    for ii=sessionDefinitions
        s=getSessionDefinition(e,ii);
        rownames(pos)=s.id;
        data(pos,1)={s.name};
        data(pos,2)={s.nDataSources};
        pos=pos+1;
    end
    set(handles.sessionDefinitionsTable,'RowName',rownames);
    set(handles.sessionDefinitionsTable,'Data',data);

    
    

    
    %%%%Refresh Subjects
    set(handles.showSubjectsText,'String',...
        ['Show/hide subjects (' num2str(e.nSubjects) ')']);

    %Only repaint if neccessary
    if (handles.redrawSubjectsTable ...
            && get(handles.showSubjectsCheckbox,'Value'))
        subjects=getSubjectList(e);
        plotWaitBar=true;
        if (length(subjects)<10)
            plotWaitBar=false;
        end
        
        if (plotWaitBar)
            barProgress=0;
            h = waitbar(barProgress,'Refreshing subjects - 0%');
            step=1/(length(subjects));
        end
        
        data=cell(getNSubjects(e),4); %Three columns are currently displayed
        %Name, Age, Sex, and Number of Sessions
        rownames=zeros(1,getNSubjects(e));
        pos=1;
        
        for ii=subjects
            if (plotWaitBar)
                waitbar(barProgress,h,['Refreshing subjects - ' ...
                    num2str(round(barProgress*100)) '%' ...
                    'Subject ' num2str(pos) '/' num2str(length(subjects))]);
                barProgress=barProgress+step;
            end
            s=getSubject(e,ii);
            rownames(pos)=s.id;
            data(pos,1)={s.name};
            data(pos,2)={s.age};
            data(pos,3)={s.sex};
            data(pos,4)={s.nSessions};
            pos=pos+1;
        end
        if (plotWaitBar)
            waitbar(1,h);
            close(h);
        end
        set(handles.subjectsTable,'RowName',rownames);
        set(handles.subjectsTable,'Data',data);
        myhandles.redrawSubjectsTable=true;
        
        guidata(hObject,handles);
    end
    
end
end