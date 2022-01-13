function [element,exitStatus]=guiSession(element)
%guiSession GUI for creating or updating sessions
%
% s=guiSession() displays a graphical user interface (GUI) for
%   creating a new session with the default ID. The function
%   returns the new session, or empty value
%   if the action is cancelled or the window close without saving.
%
% s=guiSession(s) displays a graphical user interface (GUI) for
%   updating the session s. The function returns the updated
%   session, or the unchanged session if the action is cancelled
%   or the window closed without saving.
%
% [s,exitStatus]=guiSession(...) exitStatus keep a record of
%   whether the session has been saved at some point. This is
%   convenient to distinguish when the action has been
%   cancelled or not, since for instance
%   s=guiSession(s) followed by cancel will return the same
%   object as s=guiSession(s) followed by saved and close if
%   no modification is made to the object. ExitStatus is 0
%   if the session has not been saved at any moment, or 1 if
%   the session has been saved at some point regardless of
%   whether it has been modified or not.
%   
%
% Copyright 2008-12
% @date: 23-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 30-Jan-2012
%
% See also guiICNA, session
%

exitStatus=0;

%% Initialize the figure
%...and hide the GUI as it is being constructed
width=600;
height=420;
f=figure('Visible','off','Position',[100,150,width,height]);
set(f,'NumberTitle','off');
set(f,'MenuBar','none'); %Hide MATLAB figure menu
set(f,'CloseRequestFcn',{@OnClose_Callback});

%% Add components
%Menus
menuFile = uimenu('Label','Session',...
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
menuDataSource = uimenu('Label','Source',...
    'Tag','menuDataSource');
    uimenu(menuDataSource,'Label','Add DataSource',...
        'Tag','menuDataSource_OptAddDataSource',...
        'Callback',{@OptAddDataSource_Callback});
    uimenu(menuDataSource,'Label','Update DataSource',...
        'Tag','menuDataSource_OptUpdateDataSource',...
        'Callback',{@OptUpdateDataSource_Callback});
    uimenu(menuDataSource,'Label','Remove DataSource',...
        'Tag','menuDataSource_OptRemoveDataSource',...
        'Callback',{@OptRemoveDataSource_Callback});
    uimenu(menuDataSource,'Label','Import Data Source (fOSA)',...
        'Tag','menuDataSource_OptImportfOSAfile',...
        'Separator','on',...
        'Callback',{@ImportfOSAfile_Callback});
menuTools = uimenu('Label','Tools',...
    'Tag','menuTools');
    uimenu(menuTools,'Label','Change Definition...',...
        'Tag','OptChangeDefinition',...
        'Callback',{@OnUpdateDefinition_Callback});
    uimenu(menuTools,'Label','Check integrity...',...
        'Tag','OptCheckIntegrity',...
        'Callback',{@OptCheckIntegrity_Callback});


%Toolbars
toolbar = uitoolbar(f,'Tag','toolbar');
%iconsFolder='C:\Program Files\MATLAB\R2007b\toolbox\matlab\icons\';
iconsFolder='./GUI/icons/';
tempIcon=load([iconsFolder 'addDataSource.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_AddDataSource',...
        'Separator','on','TooltipString','Add a new DataSource',...
        'ClickedCallback',{@OptAddDataSource_Callback});
tempIcon=load([iconsFolder 'updateDataSource.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_UpdateDataSource',...
        'TooltipString','Updates DataSource Information',...
        'ClickedCallback',{@OptUpdateDataSource_Callback});
tempIcon=load([iconsFolder 'removeDataSource.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_RemoveDataSource',...
        'TooltipString','Removes a DataSource',...
        'ClickedCallback',{@OptRemoveDataSource_Callback});
tempIcon=load([iconsFolder 'importfOSAfile.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_ImportfOSAfile',...
        'TooltipString','Import data from fOSA',...
        'ClickedCallback',{@ImportfOSAfile_Callback});
tempIcon=load([iconsFolder 'checkIntegrity.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_CheckIntegrity',...
        'Separator','on',...
        'TooltipString','Check integrity of active data',...
        'ClickedCallback',{@OptCheckIntegrity_Callback});


fontSize=16;
bgColor=get(f,'Color');
uicontrol(f,'Style', 'text',...
       'String', 'ID:Name:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.9 0.2 0.08]);
uicontrol(f,'Style', 'text',...
       'Tag','nameText',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdateElement_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.9 0.5 0.08]);
uicontrol(f,'Style', 'pushbutton',...
       'String', 'Definition',...
       'Tag','definitionButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.75 0.9 0.18 0.08],...
       'Callback',{@OnUpdateDefinition_Callback});

   
uicontrol(f,'Style', 'text',...
       'String', 'Date:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.8 0.2 0.08]);
uicontrol(f,'Style', 'edit',...
       'Tag','dateEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdateElement_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.8 0.5 0.08]);


uicontrol(f,'Style', 'text',...
       'String', 'DataSources:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.67 0.2 0.08]);
colNames = {'Name','Raw Data','Is Lock?','Num. Struct. Data'};
            %The third column only
            %indicates whether the dataSource is already linked
            %to some raw data.
uitable(f,...
        'Tag','dataSourcesTable',...
        'Enable','Inactive',...
        'FontSize',fontSize,...
        'ColumnName',colNames,... 
        'Units','normalize',...
        'Position',[0.05 0.2 0.9 0.45]);
    
uicontrol(f,'Style', 'pushbutton',...
       'String', 'Save',...
       'Tag','saveButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.3 0.1 0.18 0.08],...
       'Callback',{@OnSaveElement_Callback});

uicontrol(f,'Style', 'pushbutton',...
       'String', 'Save and Close',...
       'Tag','saveAndCloseButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.5 0.1 0.28 0.08],...
       'Callback',{@OnSaveAndClose_Callback});

uicontrol(f,'Style', 'pushbutton',...
       'String', 'Cancel',...
       'Tag','cancelButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.8 0.1 0.18 0.08],...
       'Callback',{@OnClose_Callback});
   

%% On Opening
handles = guihandles(f); %NOTE that only include those whose 'Tag' are not empty

if (exist('element','var'))
    handles.currentElement.data=element;
    handles.currentElement.saved=true;
else %Create a new one
    handles.currentElement.data=session;
    handles.currentElement.saved=false;
    element=[];
end

def=get(handles.currentElement.data,'Definition');
set(handles.nameText,'String',...
    [num2str(get(def,'ID')) ':' get(def,'Name')]);
clear def

guidata(f,handles);
myRedraw(f);

 
%% Make GUI visible
if (isempty(element))
    set(f,'Name','ICNA - Add Session');
else
    set(f,'Name','ICNA - Update Session');
end
set(f,'Visible','on');
waitfor(f);



%% OptAddDataSource callback
%Opens the window for adding a new dataSource to the session
function OptAddDataSource_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no session currently opened.',...
        'guiSession','modal');
else
    
    s=guiDataSource();
    if (~isempty(s))
        existingElements=getDataSourceList(handles.currentElement.data);
%         if (isempty(existingElements))
%             newId=1;
%         else
%             newId=max(existingElements)+1;
%         end
%         s=set(s,'ID',newId);
        if ismember(get(s,'ID'),existingElements)
            warndlg(['Data source ID already being used. ' ...
                 'Nothing will be added'], ...
                'Session','modal');
        else
            %DataSources may still not be added if conflicts
            %of session definition occur

            handles.currentElement.data=...
                addDataSource(handles.currentElement.data,s);
            handles.currentElement.saved=false;
            guidata(hObject,handles);
            myRedraw(hObject);
        end
    end
end

end

%% OptUpdateDataSource callback
%Opens the window for update a dataSource information
function OptUpdateDataSource_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no session currently opened.',...
        'guiSession','modal');
else
    options.Resize='off';
    options.WindowStyle='modal';
    while 1 %Get a valid (existing or new) id, or cancel action
        answer = inputdlg('DataSource ID:','Update which data source?',...
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
        existingElements=getDataSourceList(handles.currentElement.data);
        if (ismember(elemID,existingElements))
            s=getDataSource(handles.currentElement.data,elemID);
        else           
            button = questdlg(['DataSource ID not found. ' ...
                'Would you like to create a new data source ' ...
                'with the given ID?'],'Create New Data Source',...
                'Yes','No','No');
            switch(button)
                case 'Yes'
                    %Note that the dataSource will be created, even
                    %if the user click the cancel button on the
                    %guiDataSource!!
                    s=dataSource(elemID);
                    handles.currentElement.data=...
                        addDataSource(handles.currentElement.data,s);
                    handles.currentElement.saved=false;
                    guidata(hObject,handles);
                    myRedraw(hObject);
                case 'No'
                    return
            end
        end
        
        %Now update
        s=guiDataSource(s);
        if (~isempty(s))
            handles.currentElement.data=...
                setDataSource(handles.currentElement.data,get(s,'ID'),s);
            handles.currentElement.saved=false;
            guidata(hObject,handles);
        end
        myRedraw(hObject);
    end
end
end

%% OptRemoveDataSource callback
%Opens the window for eliminating a dataSource from the session
function OptRemoveDataSource_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no session currently opened.',...
        'Remove Data Source','modal');
else
    options.Resize='off';
    options.WindowStyle='modal';
    answer = inputdlg('DataSource ID:','Remove data source?',1,{''},options);
    if (isempty(answer)) %Cancel button pressed
    else
        answer=str2double(answer);
        if (~isnan(answer))
            ss=getDataSource(handles.currentElement.data,answer);
            if (~isempty(ss))
                s=removeDataSource(handles.currentElement.data,answer);
                handles.currentElement.data=s;
                handles.currentElement.saved=false;
                guidata(hObject,handles);
            else
                warndlg('Data source not found','Remove Data Source','modal');
            end
        else
            warndlg('Data source ID not recognised','Remove Data Source','modal');
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
handles.currentElement.data=guiCheckIntegrity(handles.currentElement.data);
handles.currentElement.saved=false;
guidata(hObject,handles);
end



%% ImportfOSAfile Callback
%Import fOSA data file
function ImportfOSAfile_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);

%The session needs to permit a nirs_neuroimage dataSource
%so when the new datasource is added, then it comply with the
%session definition.
def=get(handles.currentElement.data,'Definition');
idSources=getSourceList(def);
doImport=true;
if (isempty(idSources))
    warndlg(['Session definition is not suitable for ' ...
        'a nirs_neuroimage. Please ensure that the definition '...
        'is appropriate before importing the data.'],'guiSession');
    doImport=false;
else
    found=false;
    for ss=idSources
        if (strcmp(getSourceType(def,ss),'nirs_neuroimage'))
            found=true;
            break;
        end
    end
    if (~found)
        doImport=false;
    else
        %warndlg(['Session definition contains a suitable source ' ...
        %    'for a nirs_neuroimage. Data may need to be overwritten ' ...
        %    'for this source.'],'guiSession');
    end

end

if (doImport)
    %First select the file
    [FileName,PathName] = uigetfile('*.mat','WindowStyle');
    if isequal(FileName,0)
        %disp('Operation ''Import fOSA data'' cancelled')
    else



        importData=true;
        button=questdlg(['The session name may be updated and '...
            'data may need to be overwritten. ' ...
            'Would you like to proceed?'],'Import fOSA data', ...
            'Yes','Cancel','Cancel');
        switch (button)
            case 'Yes'
                importData=true;
            case 'Cancel'
                importData=false;
        end




        if (importData)
            tmpS=warning('off','ICNA:importfOSAfile:DataOverwrite');
            s=importfOSAfile(handles.currentElement.data,[PathName FileName]);
            warning(tmpS);
            handles.currentElement.data=s;
            handles.currentElement.saved=false;
            guidata(hObject,handles);
            myRedraw(hObject);
        end
    end
end
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
    %close(gcf);
end
end

%% OnSaveElement Callback
%Save the changes to the element
function OnSaveElement_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
OnUpdateElement_Callback(hObject,eventData)
handles = guidata(f);
element=handles.currentElement.data;
exitStatus=1;
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


%% OnUpdateDefinition callback
%Updates the current element with new information
function OnUpdateDefinition_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
def=get(handles.currentElement.data,'Definition');
def=guiSessionDefinition(def);
if (~isempty(def) ...
     && ~(def==get(handles.currentElement.data,'Definition')))
 
    button='Yes';
    if getNDataSources(handles.currentElement.data)~=0
        button = questdlg(['Modifying the session definition may result ' ...
            'in data loss, if sources of data do not comply with the '...
            'new definition. Would you like to proceed?'],...
            'Session Definition','Yes','Cancel','Cancel');
    end
    
    if (strcmp(button,'Yes'))
        s = warning('off','ICNA:session:set:sessionDefinition');
        handles.currentElement.data=...
            set(handles.currentElement.data,'Definition',def);
        warning(s);
        handles.currentElement.saved=false;
        set(handles.nameText,'String',...
            [num2str(get(def,'ID')) ':' get(def,'Name')]);
        
        guidata(hObject,handles);
    end
end
myRedraw(hObject);
end


%% OnUpdateElement callback
%Updates the current element with new information
function OnUpdateElement_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
tmpElement=handles.currentElement.data;
tmpElement=set(tmpElement,'Date',get(handles.dateEditBox,'String'));
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
    set(handles.dateEditBox,'String','');
    set(handles.dataSourcesTable,'RowName',[]);
    set(handles.dataSourcesTable,'Data',[]);

else %Refresh the Information
    s=session(handles.currentElement.data);
    def=get(s,'Definition');
    set(handles.dateEditBox,'String',num2str(get(s,'Date')));

    dataSources=getDataSourceList(s);
    data=cell(getNDataSources(s),4); %Four columns are currently displayed
                            %Name,RawData,Lock,NStructured Data
    rownames=zeros(1,getNDataSources(s));
    pos=1;
    for ii=dataSources
        ds=getDataSource(s,ii);
        rownames(pos)=get(ds,'ID');
        data(pos,1)={get(ds,'Name')};
        if (isempty(get(ds,'RawData')))
            data(pos,2)={'Not defined'};
        else
            data(pos,2)={'Defined'};
        end
        data(pos,3)={isLock(ds)};
        data(pos,4)={getNStructuredData(ds)};
        pos=pos+1;
    end
    set(handles.dataSourcesTable,'RowName',rownames);
    set(handles.dataSourcesTable,'Data',data);
end
end
