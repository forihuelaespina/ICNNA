function element=guiDataSource(element,id)
%guiAddDataSource GUI for adding or updating dataSources into a session
%
% s=guiDataSource() displays a graphical user interface (GUI) for
%   creating a new dataSource with the default ID. The function
%   returns the new dataSource, or empty value
%   if the action is cancelled or the window close without saving.
%
% s=guiDataSource(s) displays a graphical user interface (GUI) for
%   updating the dataSource. The function returns the updated
%   dataSource, or the unchanged dataSource if the action is cancelled
%   or the window closed without saving.
%
%The function returns the new or updated dataSource, or empty value
%if the action is cancelled or the window close without saving.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also guiExperiment, guiSubject, guiSession, dataSource,
%   guiCheckIntegrity, guiManualIntegrity
%

%% Log
%
%
% File created: 12-May-2008
% File last modified (before creation of this log): 25-Apr-2018
%
% 25-Apr-2018: FOE.
%   + Added link to NIRScout import. Rebranded window
%   from ICNA to ICNNA.
%
% 23-Jan-2014: FOE.
%   + Conversion of rawData to structuredData now proceeds
%   with overlapping behaviour.
%
% 30-Oct-2019: FOE.
%   Bug fixed. OptViewStructuredData_Callback was incorrectly checking
%   sessID.
%
% 24-May-2023: FOE
%   + I have now addressed the long standing issue with accessing
%   the icons folder when the working directory is not that of ICNNA
%   using function mfilename. 
%   + Started to update the get/set methods calls to struct like syntax
%   + Dealt with new case. In the reporting of the importing of the
%   rawData, the new rawData_Snirf does not have a property .nChannels,
%   hence, in that case the informative text cannot report on the
%   number of channels.
%




%% Initialize the figure
%...and hide the GUI as it is being constructed
width=600;
height=520;
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
set(f,'CloseRequestFcn',{@OnClose_Callback});

%% Add components
%Menus
menuFile = uimenu('Label','DataSource',...
    'Tag','menuFile');
    uimenu(menuFile,'Label','Save',...
        'Tag','menuFile_OptSave',...
        'Callback',{@OnSaveElement_Callback},... 
        'Accelerator','S');
    uimenu(menuFile,'Label','Save And Close',...
        'Tag','menuFile_OptSaveAndClose',...
        'Callback',{@OnSaveAndClose_Callback},... 
        'Accelerator','C');
    uimenu(menuFile,'Label','Quit',...
        'Tag','menuFile_OptQuit',...
        'Callback',{@OnClose_Callback},... 
        'Accelerator','Q');
menuStructuredData = uimenu('Label','StructuredData',...
    'Tag','menuStructuredData');
    uimenu(menuStructuredData,'Label','Load StructuredData',...
        'Tag','menuStructuredData_OptLoadStructuredData',...
        'Callback',{@OptLoadStructuredData_Callback});
    uimenu(menuStructuredData,'Label','View StructuredData',...
        'Tag','menuStructuredData_OptViewStructuredData',...
        'Callback',{@OptViewStructuredData_Callback});
    uimenu(menuStructuredData,'Label','Remove StructuredData',...
        'Tag','menuStructuredData_OptRemoveStructuredData',...
        'Callback',{@OptRemoveStructuredData_Callback});
    uimenu(menuStructuredData,'Label','Import fOSA file',...
        'Tag','menuStructuredData_OptImportfOSAfile',...
        'Separator','on',...
        'Callback',{@ImportfOSAfile_Callback});
menuTools = uimenu('Label','Tools',...
    'Tag','menuTools');
    uimenu(menuTools,'Label','Import Raw Data',...
        'Tag','menuTools_OptImportRawData',...
        'Callback',{@ImportRawData_Callback},... 
        'Accelerator','R');
    uimenu(menuTools,'Label','Convert to Hb',...
        'Tag','menuTools_OptConvertRawData',...
        'Callback',{@ConvertRawData_Callback},... 
        'Accelerator','R');
    uimenu(menuTools,'Label','Process data',...
        'Tag','menuTools_OptProcessData',...
        'Callback',{@ProcessData_Callback},... 
        'Accelerator','R');
menuIntegrity = uimenu(menuTools,'Label','Integrity...',...
        'Separator','on');
    uimenu(menuIntegrity,'Label','Automatic checking...',...
        'Tag','menuTools_OptCheckIntegrity',...
        'Callback',{@OptCheckIntegrity_Callback});
    uimenu(menuIntegrity,'Label','Manual setting...',...
        'Tag','menuTools_OptSetIntegrity',...
        'Callback',{@OnSetIntegrity_Callback});
    uimenu(menuTools,'Label','Plot data',...
        'Tag','menuTools_OptPlotData',...
        'Enable','off',...
        'Callback',{@OnPlotData_Callback});
    uimenu(menuTools,'Label','Timeline',...
        'Tag','menuTools_OptTimeline',...
        'Enable','off',...
        'Callback',{@OnTimeline_Callback});


%Toolbars
toolbar = uitoolbar(f,'Tag','toolbar');
[localDir,~,~] = fileparts(mfilename('fullpath'));
iconsFolder=[localDir filesep 'icons' filesep];
tempIcon=load([iconsFolder 'delete.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_RemoveStructuredData',...
        'TooltipString','Removes a StructuredData',...
        'ClickedCallback',{@OptRemoveStructuredData_Callback});
tempIcon=load([iconsFolder 'importfOSAfile.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_ImportfOSAfile',...
        'TooltipString','Import data from fOSA',...
        'Separator','on',...
        'ClickedCallback',{@ImportfOSAfile_Callback});
tempIcon=load([iconsFolder 'checkIntegrity.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_checkIntegrity',...
        'TooltipString','Check integrity of active structured data',...
        'Separator','on',...
        'ClickedCallback',{@OptCheckIntegrity_Callback});
tempIcon=load([iconsFolder 'viewTimecourse.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_PlotData',...
        'Enable','off',...
        'TooltipString','Visualize active data',...
        'ClickedCallback',{@OnPlotData_Callback});
tempIcon=load([iconsFolder 'timeline.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_Timeline',...
        'Enable','off',...
        'TooltipString','View timeline',...
        'ClickedCallback',{@OnTimeline_Callback});


fontSize=16;
bgColor=get(f,'Color');
uicontrol(f,'Style', 'text',...
       'String', 'ID:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.92 0.2 0.07]);
uicontrol(f,'Style', 'edit',...
       'Tag','idEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdateElement_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.92 0.1 0.07]);
uicontrol(f,'Style', 'text',...
       'String', 'Name:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.32 0.92 0.15 0.07]);
uicontrol(f,'Style', 'edit',...
       'Tag','nameEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdateElement_Callback},...
       'Units','normalize',...
       'Position', [0.47 0.92 0.4 0.07]);

uicontrol(f,'Style', 'text',...
       'String', 'Device Num:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.84 0.2 0.07]);
uicontrol(f,'Style', 'edit',...
       'Tag','deviceNumberEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdateElement_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.84 0.1 0.07]);
uicontrol(f,'Style', 'text',...
       'String', 'Raw Data:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.76 0.2 0.07]);
uicontrol(f,'Style', 'text',...
       'Tag','rawDataStatusText',...
       'String', '',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.22 0.76 0.45 0.07]);
uicontrol(f,'Style', 'text',...
       'String', 'Lock:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.7 0.76 0.15 0.07]);
uicontrol(f,'Style', 'checkbox',...
       'Tag','lockStatusCheckbox',...
       'Min', 0,...
       'Max', 1,...
       'Value', 0,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'Units','normalize',...
       'Position', [0.86 0.76 0.04 0.07],...
       'Callback',{@SwitchLock_Callback});
    %Note however that the default value for lock is true!!
    %So in redrawing the first time for a new dataSource it will
    %be set to true.


uicontrol(f,'Style', 'text',...
       'String', 'Structured data:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.68 0.3 0.07]);
colNames = {'Description','NSamples','NChannels','NSignals'};
uitable(f,...
        'Tag','structuredDataTable',...
        'Enable','Inactive',...
        'FontSize',fontSize,...
        'ColumnName',colNames,... 
        'Units','normalize',...
        'Position',[0.05 0.42 0.7 0.25]);
uicontrol(f,'Style', 'text',...
       'String', 'Active Structured Data:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.78 0.55 0.2 0.18]);
uicontrol(f,'Style', 'popupmenu',...
       'Tag','activeStructuredDataCombo',...
       'String', {''},...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.78 0.45 0.2 0.07],...
       'Callback',{@OnUpdateElement_Callback});
    
importPanel = uipanel(f,'Title','Import',...
        'BorderType','etchedin',...
		'FontSize',fontSize,...
        'BackgroundColor',get(f,'Color'),...
        'Position',[0.05 0.12 0.9 0.3],...
		'Parent',f);
uicontrol(importPanel,'Style', 'popupmenu',...
       'Tag','rawDataFormatCombo',...
       'String', {'ETG-4000','NIRScout'},...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.05 0.9 0.6 0.08]);
   %Up to version 1.1.2 only HITACHI ETG-4000 is available
   %v1.1.3: Included NIRScout
uicontrol(importPanel,'Style', 'pushbutton',...
       'String', '1) Import...',...
       'Tag','importRawDataButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.7 0.72 0.25 0.27],...
       'Callback',{@ImportRawData_Callback});
uicontrol(importPanel,'Style', 'pushbutton',...
       'String', '2) Convert',...
       'Tag','convertRawDataButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.7 0.38 0.25 0.27],...
       'Callback',{@ConvertRawData_Callback});
uicontrol(importPanel,'Style', 'pushbutton',...
       'String', '3) Process',...
       'Tag','processDataButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.7 0.05 0.25 0.27],...
       'Callback',{@ProcessData_Callback});
uicontrol(importPanel,'Style', 'text',...
       'String', {['* Import raw light data from all ' ...
                    'probe sets before converting to Hb.'],...
                  ['* DPF correction not yet available during ' ...
                    'conversion to Hb.'],...
                   '* Process apply decimation and detrending',...
                   '* Experimental conditions accept overlapping events.'},...
       'BackgroundColor',bgColor,...
       'FontSize',8,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.02 0.05 0.6 0.48]);



uicontrol(f,'Style', 'pushbutton',...
       'String', 'Integrity',...
       'Tag','checkIntegrityButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.1 0.02 0.18 0.08],...
       'Callback',{@OptCheckIntegrity_Callback});

uicontrol(f,'Style', 'pushbutton',...
       'String', 'Save',...
       'Tag','saveButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.3 0.02 0.18 0.08],...
       'Callback',{@OnSaveElement_Callback});

uicontrol(f,'Style', 'pushbutton',...
       'String', 'Save and Close',...
       'Tag','saveAndCloseButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.5 0.02 0.28 0.08],...
       'Callback',{@OnSaveAndClose_Callback});

uicontrol(f,'Style', 'pushbutton',...
       'String', 'Cancel',...
       'Tag','cancelButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.8 0.02 0.18 0.08],...
       'Callback',{@OnClose_Callback});
   

%% On Opening
handles = guihandles(f); %NOTE that only include those whose 'Tag' are not empty
if (exist('element','var'))
    handles.currentElement.data=element;
    handles.currentElement.saved=true;
else %Create a new one
    handles.currentElement.data=dataSource;
    handles.currentElement.saved=false;
    element=[];
end
guidata(f,handles);
myRedraw(f);

 
%% Make GUI visible
if (isempty(element))
    set(f,'Name','ICNNA - Add Data Source');
else
    set(f,'Name','ICNNA - Update Data Source');
end
set(f,'Visible','on');
waitfor(f);


%% ConvertRawData Callback
%Convert Raw Data to structured data
function ConvertRawData_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
s=dataSource(handles.currentElement.data);
r=getRawData(s);
if isempty(r)
    errordlg(['Unable to convert to structured data. Raw data ', ...
              'has not yet been imported.'],...
              'Convert Raw to Structured Data');
else
    s=addStructuredData(s,convert(r,'AllowOverlappingConditions',0));
    handles.currentElement.data=s;
    handles.currentElement.saved=false;
    guidata(hObject,handles);
    myRedraw(hObject);
end

end

%% ProcessData Callback
%Process structured data
function ProcessData_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
s=dataSource(handles.currentElement.data);

imgID=get(s,'ActiveStructured');
if imgID == 0
    errordlg(['Unable to process structured data. Structured ', ...
              'data not found.'],...
              'Process structured Data');
else
    img=decimate(getStructuredData(s,imgID));
    img=detrend(img);
    s=setStructuredData(s,imgID,img);
    clear img
    handles.currentElement.data=s;
    handles.currentElement.saved=false;
    guidata(hObject,handles);
    myRedraw(hObject);
end

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
    button=questdlg(['All existing structuredData in this dataSource ' ...
        'will be cleared.' ...
        'Would you like to proceed?'],'Import fOSA data', ...
        'Yes','Cancel','Cancel');
    switch (button)
        case 'Yes'
            importData=true;
        case 'Cancel'
            importData=false;
    end

    if (importData)
        s=importfOSAfile(dataSource,[PathName FileName]);
        tmpElement = handles.currentElement.data;
        s.id = tmpElement.id;
        handles.currentElement.data=s;
        handles.currentElement.saved=false;
        guidata(hObject,handles);
        myRedraw(hObject);
    end
end

end



%% ImportRawData Callback
%Import Raw Data file
function ImportRawData_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
s=dataSource(handles.currentElement.data);

importData=true;
if (isLock(s) && getNStructuredData(s)>0)
    button=questdlg(['All existing structured data will be cleared.' ...
        'Would you like to proceed?'],'Import Raw Data', ...
        'Yes','Cancel','Cancel');
    switch (button)
        case 'Yes'
            importData=true;
        case 'Cancel'
            importData=false;
    end
end

if (importData)
    
    tmpDevice=get(handles.rawDataFormatCombo,'Value');
    
    switch(tmpDevice)
        case 1 %ETG-4000
    
            %First select the file
            [FileName,PathName] = uigetfile('*.csv','WindowStyle');
            if isequal(FileName,0)
                %disp('Operation ''Import Raw Data'' cancelled')
            else
        
                %It may be the first probe set to be imported, or posteriors
                r=getRawData(s);
                if isempty(r)
                    %Import first probe set
                    r=rawData_ETG4000;
                else %check the type
                    if ~isa(r,'rawData_ETG4000')
                        button=questdlg(['Selected device is ' ...
                            'not compatible with existing raw data type.' ...
                            'You may choose a compatible device, or '...
                            'proceed replacing existing data. ' ...
                            'Would you like to proceed?'],'Import Raw Data', ...
                            'Yes','Cancel','Cancel');
                        switch (button)
                            case 'Yes'
                                r=rawData_ETG4000;
                            case 'Cancel'
                                return
                        end
                    end
                end
            end
        
        
        case 2 %NIRScout
            %First select the file
            [FileName,PathName] = uigetfile('*.hdr','WindowStyle');
            if isequal(FileName,0)
                %disp('Operation ''Import Raw Data'' cancelled')
            else
                r=rawData_NIRScout;
            end
        
        otherwise
        	errordlg(['Unknown device or device currently ' ...
                    'unavailable'],'Import Raw Data');
            return
    end
       
        
        
    r=import(r,[PathName FileName]);
    s=setRawData(s,r);
    %         %Check whether to convert on import
    %         if (get(handles.convertOnImportCheckbox,'Value'))
    %             s=setRawData(s,r,true);
    %         else
    %             s=setRawData(s,r);
    %         end
    %         %Check whether to process on import
    %         if (get(handles.processOnImportCheckbox,'Value'))
    %             %The converted structuredData is the only existing structuredData...
    %             imgID=get(s,'ActiveStructured');
    %             img=decimate(getStructuredData(s,imgID));
    %             img=detrend(img);
    %             s=setStructuredData(s,imgID,img);
    %             clear img
    %         end
    
    handles.currentElement.data=s;
    handles.currentElement.saved=false;
    guidata(hObject,handles);
    myRedraw(hObject);
end

end


%% OptLoadStructuredData callback
%Opens the window for loading a structuredData to the dataSource
function OptLoadStructuredData_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
[FileName,PathName] = uigetfile('*.mat');
if isequal(FileName,0)
    %disp('Operation ''Open experiment'' cancelled')
else
    %load([PathName, FileName]);
    s=open([PathName, FileName]);
    vars = struct2cell(s);
    found=false;
    %Look for all 'structuredData' variables
    for ii=1:length(vars)
        tmp=vars{ii};
        if(isa(tmp,'structureData'))
            found=true;
            %import this one
            handles.currentElement.data=addStructuredData(...
                            handles.currentElement.data,tmp);
        end
    end
    guidata(hObject,handles);
    
    if found
        handles.currentElement.saved=false;
    else
        warndlg('The selected file does not contain any structuredData',...
            'Load Failed: StructuredData Not Found','modal');
    end
end

myRedraw(hObject);
end


%% OptViewStructuredData callback
%Opens the window for visualizing structuredData information
function OptViewStructuredData_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
options.Resize='off';
options.WindowStyle='modal';
answer = inputdlg('Structured Data ID:',...
                  'View which structured data?',1,{''},options);
if (isempty(answer)) %Action cancelled
else
    elementID=str2double(answer{1});
    if (elementID == floor(elementID))
        sd=getStructured(handles.currentElement.data,elementID);
        sd=guiStructuredData(sd);
    else
        warndlg('Not a valid StructuredData ID');
    end
end
myRedraw(hObject);
end

%% OptRemoveStructuredData callback
%Opens the window for eliminating an structuredData from the dataSource
function OptRemoveStructuredData_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
options.Resize='off';
options.WindowStyle='modal';
answer = inputdlg('Structured Data ID:',...
                  'Remove structured data?',1,{''},options);
if (isempty(answer)) %Cancel button pressed
else
    answer=str2double(answer);
    if (~isnan(answer))
        ss=getStructuredData(handles.currentElement.data,answer);
        if (~isempty(ss))
            s=removeStructuredData(handles.currentElement.data,answer);
            handles.currentElement.data=s;
            handles.currentElement.saved=false;
            guidata(hObject,handles);
        else
            warndlg('Structured Data not found',...
                    'Remove Structured Data','modal');
        end
    else
        warndlg('Structured Data ID not recognised',...
                'Remove Structured Data','modal');
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
handles.currentElement.data=guiCheckIntegrity(handles.currentElement.data);
handles.currentElement.saved=false;
guidata(hObject,handles);
end



%% SwitchLock Callback
%Switch lock status
function SwitchLock_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (get(handles.lockStatusCheckbox,'Value'))
    s=lock(handles.currentElement.data);
else
    s=unlock(handles.currentElement.data);
end
handles.currentElement.data=s;
handles.currentElement.saved=false;
guidata(hObject,handles);
end

%% OnClose callback
%On Closing this window. Check whether data needs saving
function OnClose_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
closeWindow=true;
if (~handles.currentElement.saved)
    element=[];
    %Offer the possibility of saving
    button = questdlg(['Current data is not saved. ' ...
        'Would you like to save the latest changes before ' ...
        'closing it?'],...
        'Close window','Save','Close','Cancel','Close');
    switch (button)
        case 'Save'
            OnSaveElement_Callback(hObject,eventData);
            closeWindow=true;
        case 'Close'
            closeWindow=true;
        case 'Cancel'
            closeWindow=false;
    end
end
if (closeWindow)
    clear handles.currentElement.data
    delete(get(gcf,'Children'));
    delete(gcf);
end
end

%% OnPlotData Callback
%Visualize the active structuredData
function OnPlotData_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no dataSource currently opened.',...
        'ICNNA','modal');
else
    tmpElement = handles.currentElement.data;
    activeID=tmpElement.activeStructured;
    if (activeID==0)
        warndlg('Data not found.','ICNNA');
        return;
    end
    sd=getStructuredData(handles.currentElement.data,activeID);
    plotStructuredData(sd);
end
end




%% OnSaveElement Callback
%Save the dataSource changes to the session
function OnSaveElement_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
OnUpdateElement_Callback(hObject,eventData)
handles = guidata(f);
element=handles.currentElement.data;
handles.currentElement.saved=true;
guidata(f,handles);
end


%% OnSaveAndClose callback
%On Save and Closing this window
function OnSaveAndClose_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
OnSaveElement_Callback(hObject,eventData);
OnClose_Callback(hObject,eventData);
end

%% OnSetIntegrity callback
%Manual integrity setting
function OnSetIntegrity_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no dataSource currently opened.',...
        'ICNNA','modal');
else
    handles.currentElement.data=...
            guiManualIntegrity(handles.currentElement.data);
    handles.currentElement.saved=false;
    guidata(f,handles);
end
end


%% OnTimeline Callback
%Open the Timeline explorer
function OnTimeline_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no dataSource currently opened.',...
        'ICNNA','modal');
else
    activeID=get(handles.currentElement.data,'ActiveStructured');
    if (activeID==0)
        warndlg('Data not found.','ICNNA');
        return;
    end
    tM=getStructuredData(handles.currentElement.data,activeID);
    t=tM.timeline;
    t=guiTimeline(t,'setTimelineLength','off');
    if ~isempty(t)
        tM.timeline = t;
        handles.currentElement.data=...
            setStructuredData(handles.currentElement.data,activeID,tM);
        handles.currentElement.saved=false;
        guidata(hObject,handles);
    end
end
end


%% OnUpdateElement callback
%Updates the current dataSource with new information
function OnUpdateElement_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
tmpElement=dataSource(handles.currentElement.data);

tmpId=str2double(get(handles.idEditBox,'String'));
if isnan(tmpId)
    warndlg('Invalid ID.','Update Data Source');
    set(handles.idEditBox,'String', tmpElement.id);
else
    if (isreal(tmpId) && ~ischar(tmpId) && isscalar(tmpId) ...
            && floor(tmpId)==tmpId && tmpId>0)
        tmpElement=set(tmpElement,'ID',tmpId);
    else
        warndlg('Invalid ID','Update Data Source');
    end
end

tmpElement.name = get(handles.nameEditBox,'String');

devNum=str2double(get(handles.idEditBox,'String'));
if isnan(devNum)
    warndlg('Invalid Device Number.','Update Data Source');
    set(handles.idEditBox,'String',tmpElement.id);
else
    if (isreal(devNum) && ~ischar(devNum) && isscalar(devNum) ...
            && floor(devNum)==devNum && devNum>0)
        tmpElement=set(tmpElement,'DeviceNumber',devNum);
    else
        warndlg('Invalid Device Number','Update Data Source');
    end
end

tmpString=get(handles.activeStructuredDataCombo,'String');
%MATLAB only return a cell array into tmpString if there
%is more than one element in the list. Ohterwise, the single
%element string is returned.
if (size(tmpString,1)==1)
    %Only update if necessary.
    if (~strcmp(tmpString,'0'))
        tmpElement=set(tmpElement,'ActiveStructured',str2double(tmpString));
    end
else
    strIdx=get(handles.activeStructuredDataCombo,'Value');
    tmpElement=set(tmpElement,'ActiveStructured',...
                   str2double(tmpString{strIdx}));
end
handles.currentElement.data=tmpElement;
handles.currentElement.saved=false;
guidata(hObject,handles);
end



end

%% AUXILIAR FUNCTIONS
function myRedraw(hObject)
%So that the GUI keeps it information up to date, easily
% hObject - Handle of the object, e.g., the GUI component,
handles=guidata(hObject);

if (isempty(handles.currentElement.data)) %Clear
    set(handles.idEditBox,'String','');
    set(handles.nameEditBox,'String','');
    set(handles.deviceNumberEditBox,'String','');
    set(handles.lockStatusCheckbox,'Value',false);
    set(handles.rawDataStatusText,'String','');
    set(handles.structuredDataTable,'RowName',[]);
    set(handles.structuredDataTable,'Data',[]);
    set(handles.activeStructuredDataCombo,'String','');
    
else %Refresh the Information
    s=dataSource(handles.currentElement.data);
    set(handles.idEditBox,'String',num2str(s.id));
    set(handles.nameEditBox,'String',s.name);
    set(handles.deviceNumberEditBox,'String',num2str(s.deviceNumber));
    r=getRawData(s);
    if (isempty(r))
        set(handles.rawDataStatusText,'String','Not imported');
        set(handles.menuTools_OptConvertRawData,'Enable','off');
        set(handles.convertRawDataButton,'Enable','off');
    else
        %Not all raw data will have a property called .nChannels e.g. @rawData_Snirf
        try
            set(handles.rawDataStatusText,'String',...
              ['Imported (' num2str(r.nChannels) ' channels)']);
        catch
            set(handles.rawDataStatusText,'String','Imported.');
        end
        set(handles.menuTools_OptConvertRawData,'Enable','on');
        set(handles.convertRawDataButton,'Enable','on');
    end
    set(handles.lockStatusCheckbox,'Value',isLock(s));
    
    structuredData=getStructuredDataList(s);
    data=cell(s.nStructuredData,4); %Four columns are currently displayed
                            %Description, NSamples,
                            %NChannels, NSignals
    rownames=zeros(1,s.nStructuredData);
    pos=1;
    imTags=cell(1,0);
    for ii=structuredData
        elem=getStructuredData(s,ii);
        rownames(pos)=elem.id;
        data(pos,1)={elem.description};
        data(pos,2)={elem.nSamples};
        data(pos,3)={elem.nChannels};
        data(pos,4)={elem.nSignals};
        imTags(pos)={num2str(elem.id)};
        if (s.activeStructured==ii), posFound=ii; end;
        pos=pos+1;
    end
    set(handles.structuredDataTable,'RowName',rownames);
    set(handles.structuredDataTable,'Data',data);
    
    if s.nStructuredData>0
        set(handles.menuStructuredData_OptViewStructuredData,'Enable','on');
        set(handles.menuStructuredData_OptRemoveStructuredData,'Enable','on');
    else
        set(handles.menuStructuredData_OptViewStructuredData,'Enable','off');
        set(handles.menuStructuredData_OptRemoveStructuredData,'Enable','off');
    end
    
    if (isempty(imTags))
        set(handles.activeStructuredDataCombo,'String','0');
        set(handles.checkIntegrityButton,'Enable','off');
        set(handles.checkIntegrityButton,'Enable','off');
        set(handles.menuTools_OptCheckIntegrity,'Enable','off');
        set(handles.toolbarButton_checkIntegrity,'Enable','off');
        set(handles.menuTools_OptPlotData,'Enable','off');
        set(handles.toolbarButton_PlotData,'Enable','off');
        set(handles.menuTools_OptTimeline,'Enable','off');
        set(handles.toolbarButton_Timeline,'Enable','off');
        set(handles.menuTools_OptProcessData,'Enable','off');
        set(handles.processDataButton,'Enable','off');
    else
        set(handles.activeStructuredDataCombo,'String',imTags);
        set(handles.activeStructuredDataCombo,'Value',posFound);
        set(handles.checkIntegrityButton,'Enable','on');
        set(handles.menuTools_OptCheckIntegrity,'Enable','on');
        set(handles.toolbarButton_checkIntegrity,'Enable','on');
        set(handles.menuTools_OptPlotData,'Enable','on');
        set(handles.toolbarButton_PlotData,'Enable','on');
        set(handles.menuTools_OptTimeline,'Enable','on');
        set(handles.toolbarButton_Timeline,'Enable','on');
        set(handles.menuTools_OptProcessData,'Enable','on');
        set(handles.processDataButton,'Enable','on');
    end
end
end
