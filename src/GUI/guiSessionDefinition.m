function element=guiSessionDefinition(element)
%guiSessionDefinition GUI for creating or updating sessionDefinitions
%
% s=guiSessionDefinition() displays a graphical user interface (GUI) for
%   creating a new SessionDefinition with the default ID. The function
%   returns the new sessionDefinition, or empty value
%   if the action is cancelled or the window close without saving.
%
% s=guiSessionDefinition(s) displays a graphical user interface (GUI) for
%   updating the SessionDefinition s. The function returns the updated
%   sessionDefinition, or the unchanged sessionDefinition
%   if the action is cancelled
%   or the window closed without saving.
%
% Copyright 2008-12
% @date: 10-Jul-2008
% @author Felipe Orihuela-Espina
% @modified: 30-Jan-2012
%
% See also guiExperiment, guiSource, sessionDefinition
%

%% Initialize the figure
%...and hide the GUI as it is being constructed
width=600;
height=420;
f=figure('Visible','off','Position',[200,200,width,height]);
set(f,'NumberTitle','off');
set(f,'MenuBar','none'); %Hide MATLAB figure menu
set(f,'CloseRequestFcn',{@OnClose_Callback});

%% Add components
%Menus
menuFile = uimenu('Label','Session Definition',...
    'Tag','menuFile');
    uimenu(menuFile,'Label','Save',...
        'Tag','OptSave',...
        'Callback',{@OnSaveElement_Callback},... 
        'Accelerator','S');
    uimenu(menuFile,'Label','Save And Close',...
        'Tag','OptSaveAndClose',...
        'Callback',{@OnSaveAndClose_Callback},... 
        'Accelerator','C');
    uimenu(menuFile,'Label','Quit',...
        'Tag','OptQuit',...
        'Callback',{@OnClose_Callback},... 
        'Accelerator','Q');
menuSource = uimenu('Label','Source Definition',...
    'Tag','menuSource');
    uimenu(menuSource,'Label','Add Source Definition',...
        'Tag','OptAddSource',...
        'Callback',{@OptAddSource_Callback});
    uimenu(menuSource,'Label','Remove Source Definition',...
        'Tag','OptRemoveSource',...
        'Callback',{@OptRemoveSource_Callback});


%Toolbars
toolbar = uitoolbar(f,'Tag','toolbar');
%iconsFolder='C:\Program Files\MATLAB\R2007b\toolbox\matlab\icons\';
iconsFolder='./GUI/icons/';
tempIcon=load([iconsFolder 'addDataSourceDefinition.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_AddSource',...
        'Separator','on',...
        'TooltipString','Add a new source definition',...
        'ClickedCallback',{@OptAddSource_Callback});
tempIcon=load([iconsFolder 'removeDataSourceDefinition.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_RemoveSource',...
        'TooltipString','Removes a source definition',...
        'ClickedCallback',{@OptRemoveSource_Callback});


fontSize=16;
bgColor=get(f,'Color');
uicontrol(f,'Style', 'text',...
       'String', 'ID:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.9 0.2 0.08]);
uicontrol(f,'Style', 'edit',...
       'Tag','idEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdateElement_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.9 0.5 0.08]);
uicontrol(f,'Style', 'text',...
       'String', 'Name:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.8 0.2 0.08]);
uicontrol(f,'Style', 'edit',...
       'Tag','nameEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdateElement_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.8 0.5 0.08]);
uicontrol(f,'Style', 'text',...
       'String', 'Description:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.7 0.2 0.08]);
uicontrol(f,'Style', 'edit',...
       'Tag','descriptionEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdateElement_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.7 0.5 0.08]);



uicontrol(f,'Style', 'text',...
       'String', 'Source definitions:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.5 0.5 0.08]);
colNames = {'Type','Device Number'};
uitable(f,...
        'Tag','sourcesTable',...
        'Enable','Inactive',...
        'FontSize',fontSize,...
        'ColumnName',colNames,... 
        'Units','normalize',...
        'Position',[0.05 0.18 0.9 0.3]);
    
uicontrol(f,'Style', 'pushbutton',...
       'String', 'Save',...
       'Tag','saveButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.3 0.05 0.18 0.08],...
       'Callback',{@OnSaveElement_Callback});

uicontrol(f,'Style', 'pushbutton',...
       'String', 'Save and Close',...
       'Tag','saveAndCloseButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.5 0.05 0.28 0.08],...
       'Callback',{@OnSaveAndClose_Callback});

uicontrol(f,'Style', 'pushbutton',...
       'String', 'Cancel',...
       'Tag','cancelButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.8 0.05 0.18 0.08],...
       'Callback',{@OnClose_Callback});
   

%% On Opening
handles = guihandles(f); %NOTE that only include those whose 'Tag' are not empty

if (exist('element','var'))
    handles.currentElement.data=element;
    handles.currentElement.saved=true;
else %Create a new one
    handles.currentElement.data=sessionDefinition;
    handles.currentElement.saved=false;
    element=[];
end
guidata(f,handles);
myRedraw(f);

 
%% Make GUI visible
if (isempty(element))
    set(f,'Name','ICNA - Session Definition.');
else
    set(f,'Name','ICNA - Update Session Definition.');
end
set(f,'Visible','on');
waitfor(f);



%% OptAddSource callback
%Opens the window for adding a new session to the sessionDefinition
function OptAddSource_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no session definition currently opened.',...
        'Session Definition','modal');
else
    
    
    s=guiDataSourceDefinition();
    if (~isempty(s))
       tmpIDs=getSourceList(handles.currentElement.data);
       if ~ismember(get(s,'ID'),tmpIDs)
            handles.currentElement.data=...
                addSource(handles.currentElement.data,s);
            handles.currentElement.saved=false;
            guidata(hObject,handles);
       else
           warndlg('Source not added: Repeated ID.');
       end
    end
end
myRedraw(hObject);
end



%% OptRemoveSource callback
%Opens the window for eliminating a session from the sessionDefinition
function OptRemoveSource_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no sessionDefinition currently opened.',...
        'Remove Source','modal');
else
    options.Resize='off';
    options.WindowStyle='modal';
    answer = inputdlg('Source ID:','Remove source?',1,{''},options);
    if (isempty(answer)) %Cancel button pressed
    else
        id=str2double(answer);
        if (~isnan(id))
            handles.currentElement.data=...
                    removeSource(handles.currentElement.data,id);
            handles.currentElement.saved=false;
            guidata(hObject,handles);
        else
            warndlg('Source ID not recognised','Remove Source','modal');
        end
    end
end
myRedraw(hObject);
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

%% OnUpdateElement callback
%Updates the current element with new information
function OnUpdateElement_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
tmpElement=handles.currentElement.data;

tmpId=str2double(get(handles.idEditBox,'String'));
if isnan(tmpId)
    warndlg('Invalid ID.','Session Definition');
    set(handles.idEditBox,'String',get(tmpElement,'ID'));
else
    if (isreal(tmpId) && ~ischar(tmpId) && isscalar(tmpId) ...
            && floor(tmpId)==tmpId && tmpId>0)
        tmpElement=set(tmpElement,'ID',tmpId);
    else
        warndlg('Invalid ID','Update Session Definition');
    end
end
tmpElement=set(tmpElement,'Name',...
                get(handles.nameEditBox,'String'));
tmpElement=set(tmpElement,'Description',...
                get(handles.descriptionEditBox,'String'));
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
    set(handles.idEditBox,'String','1');
    set(handles.nameEditBox,'String','Session0001');
    set(handles.descriptionEditBox,'String','');
    set(handles.sourcesTable,'RowName',[]);
    set(handles.sourcesTable,'Data',[]);

else %Refresh the Information
    s=sessionDefinition(handles.currentElement.data);
    set(handles.idEditBox,'String',get(s,'ID'));
    set(handles.nameEditBox,'String',get(s,'Name'));
    set(handles.descriptionEditBox,'String',get(s,'Description'));
    sources=getSourceList(s);
    data=cell(getNSources(s),1); %One column: Type
    rownames=zeros(1,getNSources(s));
    pos=1;
    for ii=sources
        rownames(pos)=ii;
        data(pos,1)={get(getSource(s,ii),'Type')};
        data(pos,2)={get(getSource(s,ii),'DeviceNumber')};
        pos=pos+1;
    end
    set(handles.sourcesTable,'RowName',rownames);
    set(handles.sourcesTable,'Data',data);
end
end




