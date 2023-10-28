function guiRegistration(element)
%GUIREGISTRATION A small GUI for visualizing the optode registration
%
%
% Registration - A tiny tool to visualize the NIRS optode/channel
%registration to standard positioning systems.
%
%
%% Parameters
%
% element - A channelLocationMap object
%
%
%
% Copyright 2009-23
% @author Felipe Orihuela-Espina
%
% See also channelLocationMap, import_ETG4000_3DChannelPosition,
%   mesh3D_visualize, generatePositioningSystemMesh
%
%


%% Log
%
%
% File created: 1-Apr-2009
% File last modified (before creation of this log): 25-Mar-2014
%
% 24-Mar-2014: Previous auxiliary function registrationDistances has
%       now been separated into a fully independent function.
%       Now call to registration_getDistances.
%
% 16-Sep-2013: Polish and speed up code for calculating distances.
%
% 7 till 15-Sep-2013: Update from optodeSpace struct to new 
%       channelLocationMap object. It does no longer accepts
%       an optodeSpace
%
% 24-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + I have now addressed the long standing issue with accessing
%   the icons folder when the working directory is not that of ICNNA
%   using function mfilename. 
%





%% Initialize the figure
%...and hide the GUI as it is being constructed
screenSize=get(0,'ScreenSize');
width=screenSize(3)-round(screenSize(3)/10);
height=screenSize(4)-round(screenSize(4)/5);
f=figure('Visible','off',...
         'Position',[1,1,width,height]);
%set(f,'CloseRequestFcn',{@OnQuit_Callback});
movegui(f,'center');
set(f,'NumberTitle','off');
set(f,'MenuBar','none'); %Hide MATLAB figure menu


%% Add components
fontSize=12;
bgColor=get(f,'Color');

menuFile = uimenu('Label','File',...
    'Tag','menuFile',...
    'Accelerator','F');
    uimenu(menuFile,'Label','Open...',...
        'Tag','menuFile_OptOpen',...
        'Callback',{@OnOpen_Callback},... 
        'Accelerator','o');
    uimenu(menuFile,'Label','Close',...
        'Tag','menuFile_OptClose',...
        'Callback',{@OnClose_Callback},... 
        'Accelerator','w');
    uimenu(menuFile,'Label','Save',...
        'Tag','menuFile_OptSave',...
        'Callback',{@OnSave_Callback},... 
        'Separator','on','Accelerator','s');
    uimenu(menuFile,'Label','Save As...',...
        'Tag','menuFile_OptSaveAs',...
        'Callback',{@OnSaveAs_Callback},... 
        'Accelerator','S');
menuImport = uimenu(menuFile,'Label','Import',...
    'Tag','menuImport');
    uimenu(menuImport,'Label','Patriot...',...
        'Tag','menuFile_OptImportFromPatriot',...
        'Callback',{@OnBrowse_FromPatriot_Callback});
    uimenu(menuFile,'Label','Quit',...
        'Tag','menuFile_OptQuit',...
        'Callback',{@OnQuit_Callback},... 
        'Separator','on','Accelerator','q');
    
    
menuView = uimenu('Label','View',...
    'Tag','menuView',...
    'Accelerator','V');


menuTools = uimenu('Label','Tools',...
    'Tag','menuTools',...
    'Accelerator','T');
    uimenu(menuTools,'Label','Export picture',...
        'Tag','menuTools_OptExportPicture',...
        'Callback',{@OnExportPicture_Callback});
    uimenu(menuTools,'Label','Export distances DB',...
        'Tag','menuTools_OptExportDB',...
        'Enable','off',...
        'Callback',{@OnExportDB_Callback});
    uimenu(menuTools,'Label','Options',...
        'Tag','menuTools_OptOptions',...
        'Enable','on',...
        'Callback',{@OnOptions_Callback});

    
menuHelp = uimenu('Label','Help',...
    'Tag','menuHelp',...
    'Accelerator','H');
    uimenu(menuHelp,'Label','About this program...',...
        'Tag','menuHelp_OnAbout',...
        'Callback',{@OnAbout_Callback});

    
%Context Menus
cmMainAxes = uicontextmenu;
% Define the context menu items
uimenu(cmMainAxes,'Label','Rotate',...
        'Tag','cmMainAxes_OptRotate',...
        'Enable','off',...
        'Callback',{@OnRotate_Callback});
    

%Toolbars
toolbar = uitoolbar(f,'Tag','toolbar');
[localDir,~,~] = fileparts(mfilename('fullpath'));
iconsFolder=[localDir filesep 'icons' filesep];
tempIcon=load([iconsFolder 'opendoc.mat']);
	uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_Load',...
        'TooltipString','Open',...
        'ClickedCallback',{@OnOpen_Callback});
tempIcon=load([iconsFolder 'savedoc.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_Save',...
        'TooltipString','Save',...
        'ClickedCallback',{@OnSave_Callback});
tempIcon=load([iconsFolder 'rotate.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_Rotate',...
        'TooltipString','Save',...
        'Separator','on',...
        'ClickedCallback',{@OnRotate_Callback});


%Main area elements
visualizationPanel = uipanel(f,...
        'BorderType','none',...
		'FontSize',fontSize-2,...
        'BackgroundColor',get(f,'Color'),...
        'Position',[0.01 0.21 0.98 0.78]);

mainAxes=axes('Parent',visualizationPanel);
set(mainAxes,...
        'Tag','mainAxes',...
		'FontSize',fontSize,...
        'Color','none',...
        'Units','normalize',...
        'UIContextMenu',cmMainAxes,...
        'OuterPosition',[0.05 0.01 0.75 0.98]);

XYAxes=axes('Parent',visualizationPanel); %Top view
set(XYAxes,...
        'Tag','XYAxes',...
		'FontSize',fontSize-2,...
        'Color','none',...
        'Units','normalize',...
        'Position',[0.85 0.72 0.14 0.27]);
XZAxes=axes('Parent',visualizationPanel);
set(XZAxes,...
        'Tag','XZAxes',...
		'FontSize',fontSize-2,...
        'Color','none',...
        'Units','normalize',...
        'Position',[0.85 0.37 0.14 0.27]);
YZAxes=axes('Parent',visualizationPanel);
set(YZAxes,...
        'Tag','YZAxes',...
		'FontSize',fontSize-2,...
        'Color','none',...
        'Units','normalize',...
        'Position',[0.85 0.04 0.14 0.27]);


    
controlPanel = uipanel(f,...
        'BorderType','none',...
		'FontSize',fontSize-2,...
        'BackgroundColor',get(f,'Color'),...
        'Position',[0.01 0.01 0.98 0.18]);
uicontrol(controlPanel,'Style', 'text',...
       'String', 'References:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Position', [0.01 0.83 0.3 0.16]);
uicontrol(controlPanel,'Style', 'listbox',...
       'Tag','referencesListBox',...
       'String', '0',...
       'Min',0,...
       'Max',2,...
       'BackgroundColor','w',...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','left',...
       'Callback',{@ReferencesListBox_Callback},...
       'Units','normalize',...
       'Position', [0.01 0.01 0.3 0.82]);

    
uicontrol(controlPanel,'Style', 'text',...
       'String', 'Optodes:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Position', [0.33 0.83 0.3 0.16]);
uicontrol(controlPanel,'Style', 'listbox',...
       'Tag','optodesListBox',...
       'String', '0',...
       'Min',0,...
       'Max',2,...
       'BackgroundColor','w',...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','left',...
       'Callback',{@OptodesListBox_Callback},...
       'Units','normalize',...
       'Position', [0.33 0.01 0.3 0.82]);

   
uicontrol(controlPanel,'Style', 'text',...
       'String', 'Channels:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Position', [0.66 0.83 0.3 0.16]);
uicontrol(controlPanel,'Style', 'listbox',...
       'Tag','channelsListBox',...
       'String', '0',...
       'Min',0,...
       'Max',2,...
       'BackgroundColor','w',...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','left',...
       'Callback',{@ChannelsListBox_Callback},...
       'Units','normalize',...
       'Position', [0.66 0.01 0.3 0.82]);
   
   
%% On Opening
handles = guihandles(f); %NOTE that only include those whose 'Tag' are not empty

handles.appOptions=registration_loadAppOptions;

guidata(f,handles);


if (exist('element','var'))

  try %This can go wrong if reference points have not been defined.  

%DEPRECATED: Support for optodeSpace
%    probe=handles.appOptions.probe;
    handles.currentElement.data=element; %OptodeSpace

%DEPRECATED: Support for optodeSpace
%     [g,estimatedScale]=optodeSpace_getRegisteredSystemMesh(element,...
%                 handles.appOptions.probe);
%     channelCoords=optodeSpace_getChannelLocation(element,probe);

    [g,estimatedScale]=generateRegistrationMesh(element);
    channelCoords=getChannel3DLocations(element);
        handles.currentElement.mesh=g;
        handles.currentElement.scale=estimatedScale;
        handles.currentElement.channelCoords=channelCoords;
    guidata(f,handles);
    OnLoad_Callback(f,[]);
    
  catch ME
      fW=warndlg([ME.message ' Nothing will be load.'],'modal');
      waitfor(fW);
      %Act like if nothing has been passed as parameter
      handles.currentElement.data=[];
      handles.currentElement.mesh=generatePositioningSystemMesh;
      handles.currentElement.scale=1;
      handles.currentElement.channelCoords=zeros(0,3);
      guidata(f,handles);
      
      set(handles.menuFile_OptSave,'Enable','off');
      set(handles.menuFile_OptSaveAs,'Enable','off');
      set(handles.toolbarButton_Save,'Enable','off');
      set(handles.toolbarButton_Rotate,'Enable','off');
      
      set(handles.menuView,'Enable','off');
      
  end
else
    handles.currentElement.data=[];
        handles.currentElement.mesh=generatePositioningSystemMesh;
        handles.currentElement.scale=1;
        handles.currentElement.channelCoords=zeros(0,3);
    guidata(f,handles);

    set(handles.menuFile_OptSave,'Enable','off');
    set(handles.menuFile_OptSaveAs,'Enable','off');
    set(handles.toolbarButton_Save,'Enable','off');
    set(handles.toolbarButton_Rotate,'Enable','off');

    set(handles.menuView,'Enable','off');
    
end
handles.currentElement.saved=true;
handles.currentElement.rawDir=pwd; %Current raw data directory
handles.currentElement.rawFilename='';
handles.currentElement.dir=pwd; %Current dataSource directory
handles.currentElement.filename='';

guidata(f,handles);


%% Make GUI visible
set(f,'Name','Registration');
set(f,'Visible','on');



%% ChannelsListBox Callback
%Show or Hide Channels
function ChannelsListBox_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

labelledChannels_MainAxes=handles.labelledElements.mainAxes.channels;
%Find out which references are to be shown
channels=get(handles.channelsListBox,'Value');
chCoords=handles.currentElement.channelCoords;
nChannels=size(chCoords,1);
for ii=1:nChannels
    if ismember(ii,channels)
        set(labelledChannels_MainAxes(ii).tag,'Visible','on');
        set(labelledChannels_MainAxes(ii).marker,'Visible','on');
    else
        set(labelledChannels_MainAxes(ii).tag,'Visible','off');
        set(labelledChannels_MainAxes(ii).marker,'Visible','off');
    end
end

end




%% OnAbout callback
%Opens the "About" information window
function OnAbout_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
aboutRegistration;
end

%% OnBrowse_FromPatriot callback
%Display an open file dialog and call OnLoad, if
%the action is not cancelled and the file exits.
function OnBrowse_FromPatriot_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
%DEPRECATED Support for optodeSpace
%probe=handles.appOptions.probe;

[FileName,PathName] = uigetfile('*.pos','Select Positioning file');
if isequal(FileName,0)
    %disp('Operation ''Open positionnig file'' cancelled')
else
   % try
        %load([PathName, FileName]);
        handles.currentElement.rawDir=PathName;
        handles.currentElement.rawFilename=FileName;
        handles.currentElement.dir='';
        handles.currentElement.filename='';
        
        %%DEPRECATED: Support for optodeSpace
        %os=optodeSpace_import([PathName, FileName]);
        %[g,estimatedScale]=optodeSpace_getRegisteredSystemMesh(os,probe);
        %%optodeCoords=os.probes(probe).optodeCoords;
        %channelCoords=optodeSpace_getChannelLocation(os,probe);

        [clm]=import_ETG4000_3DChannelPosition([PathName, FileName]);
        [g,estimatedScale]=generateRegistrationMesh(clm);
        optodeCoords=getOptode3DLocations(clm);
        channelCoords=getChannel3DLocations(clm);
        
        
        %%DEPRECATED: Support for optodeSpace
        %handles.currentElement.data=os;
        handles.currentElement.data=clm;
        handles.currentElement.mesh=g;
        handles.currentElement.scale=estimatedScale;
        handles.currentElement.channelCoords=channelCoords;
        set(f,'Name',[PathName, FileName]);
        guidata(f,handles);
        
        OnLoad_Callback(f,[]);
%     catch ME
%         msg={ME.identifier,'', ME.message};
%         warndlg(msg,'guiRegistration');
%         return
%     end
end

end

%% OnClose callback
%On Closing currentElement. Check whether data needs saving.
%It does not close the window, but only the document.
function OnClose_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
closeCurrentElement=true;
if (~handles.currentElement.saved)
    %Offer the possibility of saving
    button = questdlg(['Current data is not saved. ' ...
        'Would you like to save the latest changes before ' ...
        'closing?'],...
        'Close Document','Save','Close','Cancel','Close');
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
    
    axes(handles.mainAxes)
    cla;
 
    handles.currentElement.data=[]; 
        handles.currentElement.mesh=generatePositioningSystemMesh;
        handles.currentElement.scale=1;
        handles.currentElement.channelCoords=zeros(0,3);
    handles.currentElement.saved=true;
    handles.currentElement.dir=pwd;
    handles.currentElement.filename='';
    handles.currentElement.rawDir=pwd;
    handles.currentElement.rawFilename='';
    set(f,'Name','Registration');
    
    
    %Make options and fields inactive as appropriate
    set(handles.menuFile_OptClose,'Enable','off');
    set(handles.menuFile_OptSave,'Enable','off');
    set(handles.menuFile_OptSaveAs,'Enable','off');

    set(handles.menuTools_OptExportDB,'Enable','off');

    
    set(handles.toolbarButton_Save,'Enable','off');
    set(handles.toolbarButton_Rotate,'Enable','off');

    set(handles.cmMainAxes_OptRotate,'Enable','off');

    guidata(hObject,handles);

end

end

%% OnExportDB callback
%Export distances database
function OnExportDB_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

[filename, pathname] = uiputfile({'*.csv',...
          '*.txt';...
          '*.*','All Files' },...
          'Save Database',...
          ['./' handles.currentElement.filename '_registrationDB.csv']);
if isequal(filename,0) || isequal(pathname,0)
   %disp('User selected Cancel')
else
    handles=guidata(hObject);
    
    g=handles.currentElement.mesh;
    %%DEPRECATED Support for optodeSpace
    %[DOptodes, DChannels]=registrationDistances(...
    %    g,handles.currentElement.data,handles.appOptions.probe);
    [DOptodes, DChannels]=registration_getDistances(g,handles.currentElement.data);
   
   
   % Open the file for writing
   fidr = fopen([pathname filename], 'w');
   if fidr == -1
       error('ICAF:guiRegistration:OnExportDB_Callback',...
           ['Unable to open ' pathname filename]);
   end
   
   nPoints=size(g.coords,1);
   nOptodes=size(DOptodes,2);
   nChannels=size(DChannels,2);
   
   %Column Headers
   fprintf(fidr,'Position, ');
   for oo=1:nOptodes
        fprintf(fidr,'Optode  %d, ',oo);
   end
   for ch=1:nChannels
        fprintf(fidr,'Channel  %d, ',ch);
   end

   %Data
   for pp=1:nPoints
       if ~isempty(g.tags{pp}) %Exclude "irrelevant" untagged vertex
            fprintf(fidr,'\n%s, ',g.tags{pp});
            fprintf(fidr,'%.2f, ',DOptodes(pp,:));
            fprintf(fidr,'%.2f, ',DChannels(pp,:));
       end
   end

   fprintf(fidr,'\n');
   fclose(fidr);

end      


end


%% OnExportPicture callback
%Export current picture
function OnExportPicture_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

[filename, pathname] = uiputfile({'*.jpg;*.tif;*.png;*.gif',...
          'All Image Files';...
          '*.*','All Files' },...
          'Save Image',...
          './newimage.tif');
if isequal(filename,0) || isequal(pathname,0)
   %disp('User selected Cancel')
else
   idx=find(filename=='.',1,'last');
   format=filename(idx+1:end);
   %saveas(gca,fullfile(pathname,filename),format)
   print(['-f' num2str(gcf)],'-dtiff','-r300',[pathname filename]);
end      

end


%% OnLoad callback
%Converts data to a structured data and plot the data afresh.
function OnLoad_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
os=handles.currentElement.data;
if (isempty(os))
    warndlg('(Optode Space) Data not found.','guiRegistration');
    return;
end
g=handles.currentElement.mesh;
scale=handles.currentElement.scale;
chCoords=handles.currentElement.channelCoords;


%paint the stuff...
fontSize=handles.appOptions.fontSize;
lineWidth=1.5;
%DEPRECATED: Support for optodeSpace
%probe=handles.appOptions.probe;

%---------------------
%3D Visualization
%---------------------
axes(handles.mainAxes);
options.displayTags=false;
mesh3D_visualize(g,options);
view(3);

axes(handles.XYAxes);
options.displayTags=false;
mesh3D_visualize(g,options);
view(0,90);

axes(handles.XZAxes);
options.displayTags=false;
mesh3D_visualize(g,options);
view(0,0);

axes(handles.YZAxes);
%options.displayControlTags=false;
options.displayTags=false;
mesh3D_visualize(g,options);
view(90,90);


%---------------------
%Labels/Tags selection lists
%---------------------
xoffset=0.12;
yoffset=0.12;
zoffset=0.15;

ff=gcf;

clear hh
hh = waitbar(0,'Labelling elements...',...
    'Name','Registration','WindowStyle','modal');

step=1/3; %References, Optodes and channels
x=0;

%Controls (By default no reference is shown)
nReferences=size(g.tags,1);
substep=step/(nReferences);
if (nReferences==0)
    set(handles.referencesListBox,'String','');
    set(handles.referencesListBox,'Value',[]);
else
    tmpTags=cell(1,nReferences);
    for ii=1:nReferences
        x=x+substep;
        set(0,'CurrentFigure',hh);
        waitbar(x,hh,['Labelling references - ' ...
            num2str(round(x*100)) '%']);
        
        tag=g.tags{ii};
        if isempty(tag)
            tag='Untagged vertex';
        end
        tmpTags(ii)={tag};
        %axes(handles.mainAxes);
        set(0,'CurrentFigure',ff);
        set(ff,'CurrentAxes',handles.mainAxes);
        labelledElements.mainAxes.references(ii).marker=...
            line('XData',g.coords(ii,1),...
                'YData',g.coords(ii,2),...
                'ZData',g.coords(ii,3),...
                'Color','m','LineWidth',lineWidth,...
                'Marker','d','MarkerSize',7,'MarkerFaceColor','m',...
                'Visible','off');
        labelledElements.mainAxes.references(ii).tag=...
            text(g.coords(ii,1)+(xoffset*g.coords(ii,1)),...
                g.coords(ii,2)+(yoffset*g.coords(ii,2)),...
                g.coords(ii,3)+(zoffset*g.coords(ii,3)),...
                tmpTags{ii},...
                'Color','k',...
                'Visible','off',...
                'HorizontalAlignment','center',...
                'FontSize',fontSize-3,'FontWeight','bold');
    end
    set(handles.referencesListBox,'String',tmpTags);
    %set(handles.referencesListBox,'Value',1:nReferences); %Select all
    set(handles.referencesListBox,'Value',[]); %Select none
end
handles.labelledElements=labelledElements;
guidata(hObject,handles);



%Controls (By default no optode is shown)
%DEPRECATED: Support for optodeSpace
% nOptodes=size(os.probes(probe).optodeCoords,1);
% optodeCoords=os.probes(probe).optodeCoords;
%optodeArrays=unique(getOptodeOptodeArrays(os))';
optodeArrays=getOptodeOptodeArrays(os);
optodeArraysInfo=getOptodeArraysInfo(os);
nOptodes = get(os,'nOptodes');
substep=step/(nOptodes);
if (nOptodes==0)
    set(handles.optodesListBox,'String','');
    set(handles.optodesListBox,'Value',[]);
else
    tmpTags=cell(1,nOptodes);
    for ii=1:nOptodes
        x=x+substep;
        set(0,'CurrentFigure',hh);
        waitbar(x,hh,['Labelling optodes - ' ...
            num2str(round(x*100)) '%']);
        
        
        oaInfo=optodeArraysInfo(optodeArrays(ii));
        %Look for optode coordinates
        %refPointsCoords = getReferencePoints(os);
        optodeCoords = getOptode3DLocations(os);
        
        
        tmpTags(ii)={num2str(ii)};
        %axes(handles.mainAxes);
        set(0,'CurrentFigure',ff);
        set(ff,'CurrentAxes',handles.mainAxes);
        labelledElements.mainAxes.optodes(ii).marker=...
            line('XData',optodeCoords(ii,1),...
                'YData',optodeCoords(ii,2),...
                'ZData',optodeCoords(ii,3),...
                'Color','b','LineWidth',lineWidth,...
                'Marker','o','MarkerSize',13,'MarkerFaceColor','b',...
                'Visible','off');
        labelledElements.mainAxes.optodes(ii).tag=...
            text(optodeCoords(ii,1),...
                optodeCoords(ii,2),...
                optodeCoords(ii,3),...
                tmpTags{ii},...
                'Color','y',...
                'Visible','off',...
                'HorizontalAlignment','center',...
                'FontSize',fontSize-3,'FontWeight','bold');
    end
    set(handles.optodesListBox,'String',tmpTags);
    %set(handles.optodesListBox,'Value',1:nOptodes);
    set(handles.optodesListBox,'Value',[]);
end
handles.labelledElements=labelledElements;
guidata(hObject,handles);


%Controls (By default no channel is shown)
nChannels=size(chCoords,1);
substep=step/(nChannels);
if (nChannels==0)
    set(handles.channelsListBox,'String','');
    set(handles.channelsListBox,'Value',[]);
else
    tmpTags=cell(1,nChannels);
    for ii=1:nChannels
        x=x+substep;
        set(0,'CurrentFigure',hh);
        waitbar(x,hh,['Labelling channels - ' ...
            num2str(round(x*100)) '%']);
        
        tmpTags(ii)={num2str(ii)};
        %axes(handles.mainAxes);
        set(0,'CurrentFigure',ff);
        set(ff,'CurrentAxes',handles.mainAxes);
        labelledElements.mainAxes.channels(ii).marker=...
            line('XData',chCoords(ii,1),...
                'YData',chCoords(ii,2),...
                'ZData',chCoords(ii,3),...
                'Color','r','LineWidth',lineWidth,...
                'Marker','s','MarkerSize',13,'MarkerFaceColor','r',...
                'Visible','off');
        labelledElements.mainAxes.channels(ii).tag=...
            text(chCoords(ii,1),...
                chCoords(ii,2),...
                chCoords(ii,3),...
                tmpTags{ii},...
                'Color','y',...
                'Visible','off',...
                'HorizontalAlignment','center',...
                'FontSize',fontSize-3,'FontWeight','bold');
    end
    set(handles.channelsListBox,'String',tmpTags);
    %set(handles.channelsListBox,'Value',1:nChannels);
    set(handles.channelsListBox,'Value',[]);
end
handles.labelledElements=labelledElements;
guidata(hObject,handles);

set(0,'CurrentFigure',hh);
waitbar(1,hh,'Done - 100%');
close(hh);
clear hh



%Make options and fields active as appropriate
set(handles.menuFile_OptClose,'Enable','on');
set(handles.menuFile_OptSave,'Enable','on');
set(handles.menuFile_OptSaveAs,'Enable','on');

set(handles.menuView,'Enable','on');

set(handles.menuTools_OptExportDB,'Enable','on');

set(handles.toolbarButton_Save,'Enable','on');
set(handles.toolbarButton_Rotate,'Enable','on');

set(handles.cmMainAxes_OptRotate,'Enable','on');

guidata(hObject,handles);

end


%% OnOpen callback
%Opens an existing optode registration data file
function OnOpen_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

%Before opening a document, close the current document if any
OnClose_Callback(hObject,eventData)

[FileName,PathName] = uigetfile('*.mat','Select data file');
if isequal(FileName,0)
    %disp('Operation ''Open'' cancelled')
else
    s=open([PathName, FileName]);
    vars = struct2cell(s);
    
    %Look for an 'channelLocationMap' variable
    for ii=1:length(vars)
        tmp=vars{ii};
        if isa(tmp,'channelLocationMap')
            break;
        end
    end
    if isa(tmp,'channelLocationMap')
        handles=guidata(hObject);
        handles.currentElement.data=tmp;
        [g,estimatedScale]=generateRegistrationMesh(...
                handles.currentElement.data);
        channelCoords=getChannel3DLocations(handles.currentElement.data);
        handles.currentElement.mesh=g;
        handles.currentElement.scale=estimatedScale;
        handles.currentElement.channelCoords=channelCoords;
        
        handles.currentElement.saved=true;
        handles.currentElement.dir=PathName;
        handles.currentElement.filename=FileName;
        handles.currentElement.rawDir='';
        handles.currentElement.rawFilename='';
        
        set(f,'Name',[PathName, FileName]);
        
        guidata(hObject,handles);
        OnLoad_Callback(hObject,eventData)
        
        
    else
        warndlg(['The selected file does not contain ' ...
            'any channelLocationMap.'],...
            'Open Failed','modal');
    end
        
    
%%DEPRECATED Support for optodeSpace
%     %Look for an 'optodeSpace' variable
%     for ii=1:length(vars)
%         tmp=vars{ii};
%         if(isstruct(tmp) ...
%               && isfield(tmp,'id') ...
%               && isfield(tmp,'version') ...
%               && isfield(tmp,'productName') ...
%               && isfield(tmp,'probe') ...
%               && isfield(tmp,'type'))
%             break;
%         end
%     end
%     if (isstruct(tmp) ...
%               && isfield(tmp,'id') ...
%               && isfield(tmp,'version') ...
%               && isfield(tmp,'productName') ...
%               && isfield(tmp,'probe') ...
%               && isfield(tmp,'type'))
%         handles=guidata(hObject);
%         handles.currentElement.data=tmp;
%         [g,estimatedScale]=optodeSpace_getRegisteredSystemMesh(...
%                 handles.currentElement.data,...
%                 handles.appOptions.probe);
%         channelCoords=optodeSpace_getChannelLocation(...
%                 handles.currentElement.data,...
%                 handles.appOptions.probe);
%         handles.currentElement.mesh=g;
%         handles.currentElement.scale=estimatedScale;
%         handles.currentElement.channelCoords=channelCoords;
%         
%         handles.currentElement.saved=true;
%         handles.currentElement.dir=PathName;
%         handles.currentElement.filename=FileName;
%         handles.currentElement.rawDir='';
%         handles.currentElement.rawFilename='';
%         
%         set(f,'Name',[PathName, FileName]);
%         
%         guidata(hObject,handles);
%         OnLoad_Callback(hObject,eventData)
%         
%         
%     else
%         warndlg(['The selected file does not contain ' ...
%             'any optode space.'],...
%             'Open Failed','modal');
%     end
end

end



%% OnOptions callback
%Allow some configuration
function OnOptions_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles = guidata(f);

tmpCurrentOptions=handles.appOptions;
% uiwait(warndlg('Not all options are yet working.','Registration','modal'));
handles.appOptions=guiRegistrationOptions(handles.appOptions);

%Apply new options
if (~isempty(handles.currentElement.data))
if tmpCurrentOptions.fontSize~=handles.appOptions.fontSize
    set(handles.mainAxes,'FontSize',handles.appOptions.fontSize);
end


% if tmpCurrentOptions.lineWidth~=handles.appOptions.lineWidth
%     nMarkers=2;
%     for ss=1:nMarkers
%         set(handles.MainAxesHandles(ss),...
%             'LineWidth',handles.appOptions.lineWidth);
%     end
% end


%Change Probe
if tmpCurrentOptions.probe~=handles.appOptions.probe
    %NOT YET DONE!
    warning('Sorry! Change of probe not yet available');
end

end
guidata(hObject,handles);

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

%% OnRotate callback
%Rotate the main axes using the mouse
function OnRotate_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles = guidata(f);
rotate3d(handles.mainAxes);

end


%% OnSave Callback
%Save the changes to the element
function OnSave_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles = guidata(f);
if (strcmp(handles.currentElement.filename,''))
    OnSaveAs_Callback(hObject,eventData);
else

    if (isempty(handles.currentElement.data))
        warndlg(['There''s no file currently opened.' ...
            'Nothing to be saved.'],...
            'Save','modal');
    else
        optodeSpc=handles.currentElement.data;
        
        save([handles.currentElement.dir, ...
              handles.currentElement.filename],'optodeSpc');
        handles.currentElement.saved=true;
        guidata(hObject,handles);
        
    end
end
end

%% OnSaveAs Callback
%Save the changes to the element
function OnSaveAs_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles = guidata(f);
if (isempty(handles.currentElement.data))
    warndlg(['There''s no file currently opened.' ...
            'Nothing to be saved.'],...
        'Save As...','modal');
else
    [FileName,PathName] = uiputfile('*.mat','WindowStyle');
    if isequal(FileName,0)
        %disp('Operation ''Save as'' cancelled')
    else
        optodeSpc=handles.currentElement.data;
        save([PathName, FileName],'optodeSpc');
        handles.currentElement.saved=true;
        handles.currentElement.dir=PathName;
        handles.currentElement.filename=FileName;
        guidata(hObject,handles);
    end
end

end


%% OptodesListBox Callback
%Show or Hide optodes
function OptodesListBox_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

labelledOpts_MainAxes=handles.labelledElements.mainAxes.optodes;
%Find out which references are to be shown
optodes=get(handles.optodesListBox,'Value');
os=handles.currentElement.data;
%DEPRECATED: Support for optodeSpace
%probe=handles.appOptions.probe;
%nOptodes=size(os.probes(probe).optodeCoords,1);
optodeCoords = getOptode3DLocations(os);
nOptodes = size(optodeCoords,1);

for ii=1:nOptodes
    if ismember(ii,optodes)
        set(labelledOpts_MainAxes(ii).tag,'Visible','on');
        set(labelledOpts_MainAxes(ii).marker,'Visible','on');
    else
        set(labelledOpts_MainAxes(ii).tag,'Visible','off');
        set(labelledOpts_MainAxes(ii).marker,'Visible','off');
    end
end

end


%% ReferencesListBox Callback
%Show or Hide reference points
function ReferencesListBox_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

labelledRefs_MainAxes=handles.labelledElements.mainAxes.references;
%Find out which references are to be shown
references=get(handles.referencesListBox,'Value');
nReferences=size(handles.currentElement.mesh.coords,1);
for ii=1:nReferences
    if ismember(ii,references)
        set(labelledRefs_MainAxes(ii).tag,'Visible','on');
        set(labelledRefs_MainAxes(ii).marker,'Visible','on');
    else
        set(labelledRefs_MainAxes(ii).tag,'Visible','off');
        set(labelledRefs_MainAxes(ii).marker,'Visible','off');
    end
end

end

end



%% AUXILIAR FUNCTIONS


% %DEPRECATED Support for optodeSpace
% function [DOptodes, DChannels]=registrationDistances(g,optodeSpace,probe)
% %Compute the distance from every point in the mesh (g) to
% %every optode and channel in the probe
% %
% %% Parameters
% %
% % g - A 3D mesh as specified in generateOptodePositioningSystemGrid
% % optodeSpace - An optode space as specified in optodeSpace_import
% % probe - Optional. Probe number. Default 1.
% %
% %% Output
% %
% % DOptodes- Matrix of distances between points in mesh and optodes.
% %   Rows represents points in the mesh, and columns represents optodes.
% %
% % DChannels- Matrix of distances between points in mesh and channels.
% %   Rows represents points in the mesh, and columns represents channels.
% %
% %
% %       +========================================+
% %       | "Irrelevant" mesh vertexes (those with |
% %       | empty tag) are also included!!, i.e.   |
% %       | they also produce an entry in the      |
% %       | distance matrices.                     |
% %       +========================================+
% %
% %
% % Copyright 2009
% % @date: 2-Apr-2009
% % @author Felipe Orihuela-Espina
% %
% % See also guiRegistration, optodeSpace_import, mesh3D_visualize,
% % generateOptodePositioningSystemGrid
% %
% 
% h = waitbar(0,'Calculating distances...',...
%     'Name','Registration DB');
% 
% optodeCoords=optodeSpace.probes(probe).optodeCoords;
% channelCoords=optodeSpace_getChannelLocation(optodeSpace,probe);
% nOptodes=size(optodeCoords,1);
% nChannels=size(channelCoords,1);
% nMeshPoints=size(g.coords,1);
% 
% step=1/nMeshPoints;
% substep=step/(nOptodes+nChannels);
% x=0;
% 
% DOptodes=zeros(nMeshPoints,nOptodes);
% DChannels=zeros(nMeshPoints,nChannels);
% for pp=1:nMeshPoints
%     pTag=g.tags{pp};
%     pCoords=g.coords(pp,:);
%     if isempty(pTag) %Untagged vertex
%         pTag='untagged vertex';
%     end
%     
%     waitbar(x,h,['Computing distances to ' pTag ' - ' ...
%                 num2str(round(x*100)) '%']);
% 
%     for oo=1:nOptodes
%         x=x+substep;
%         waitbar(x,h,['Computing distances to ' pTag ' - ' ...
%                 num2str(round(x*100)) '%']);
%         tmp=[optodeCoords(:,1)-pCoords(:,1), ...
%             optodeCoords(:,2)-pCoords(:,2), ...
%             optodeCoords(:,3)-pCoords(:,3)];
%         DOptodes(pp,:)=sqrt(sum(tmp.^2,2))';
%     end
%     
%     for oo=1:nChannels
%         x=x+substep;
%         waitbar(x,h,['Computing distances to ' pTag ' - ' ...
%                 num2str(round(x*100)) '%']);
%         tmp=[channelCoords(:,1)-pCoords(:,1), ...
%             channelCoords(:,2)-pCoords(:,2), ...
%             channelCoords(:,3)-pCoords(:,3)];
%         DChannels(pp,:)=sqrt(sum(tmp.^2,2))';    
%     end
% end
% 
% waitbar(1,h,'Done - 100%');
% close(h);
% 
% 
% 
% end
