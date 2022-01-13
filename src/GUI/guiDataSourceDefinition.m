function s=guiDataSourceDefinition()
%GUIDATASOURCEDEFINITION Small GUI to ask for a data source 
%definition to be defined in the sessionDefinition
%
% s=guiDataSourceDefinition() returns a valid dataSourceDefinition
%   or an empty matrix if the action is cancelled.
%
%
% Copyright 2008
% @date: 10-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also guiSessionDefinition, dataSourceDefinition, sessionDefinition,
%experiment
%

%% Initialize the figure
%...and hide the GUI as it is being constructed
width=400;
height=150;
ff=figure('Visible','off','Position',[100,100,width,height]);
set(ff,'NumberTitle','off');
set(ff,'MenuBar','none'); %Hide MATLAB figure menu

fontSize=16;
bgColor=get(ff,'Color');
uicontrol(ff,'Style', 'text',...
       'String', 'ID:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.75 0.2 0.2]);
uicontrol(ff,'Style', 'edit',...
       'Tag','idEditBox',...
       'String','1',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdate_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.75 0.75 0.2]);
uicontrol(ff,'Style', 'text',...
       'String', 'Type:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.5 0.2 0.2]);
validTypes={'nirs_neuroimage' ...
            'structuredData'};
    %Add here the new types as they become available
    %'structuredData' is the most generic... but is the least
    %recommended.
uicontrol(ff,'Style', 'popupmenu',...
       'Tag','typeComboBox',...
       'String', validTypes,...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdate_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.5 0.75 0.2]);
uicontrol(ff,'Style', 'text',...
       'String', 'Device Number:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.25 0.2 0.2]);
uicontrol(ff,'Style', 'edit',...
       'Tag','deviceNumberEditBox',...
       'String','1',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdate_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.25 0.75 0.2]);

uicontrol(ff,'Style', 'pushbutton',...
       'String', 'Save and Close',...
       'Tag','saveAndCloseButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.3 0.03 0.42 0.2],...
       'Callback',{@OnSaveAndClose_Callback});
uicontrol(ff,'Style', 'pushbutton',...
       'String', 'Cancel',...
       'Tag','cancelButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.75 0.03 0.23 0.2],...
       'Callback',{@OnCancel_Callback});

%% On Opening
handles = guihandles(ff); %NOTE that only include those whose 'Tag' are not empty
s=[];
set(ff,'Name','ICNA - Data Source Definition');
movegui(ff,'center');
set(ff,'Visible','on');
guidata(ff,handles);
waitfor(ff);

%% OnUpdate callback
%Checks the information
function OnUpdate_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);

n=str2double(get(handles.idEditBox,'String'));
if (isnan(n))
    warndlg('Invalid ID','Data Source Definition','modal');
elseif ((floor(n)~=n) || n<1)
    warndlg('Invalid ID','Data Source Definition','modal');
end

tString=get(handles.typeComboBox,'String');
tIdx=get(handles.typeComboBox,'Value');
t=tString{tIdx};
if (isempty(t) || ~ischar(t))
    warndlg('Invalid Type','Data Source Definition','modal');
end

dn=str2double(get(handles.deviceNumberEditBox,'String'));
if (isnan(dn))
    warndlg('Invalid Device Number','Data Source Definition','modal');
elseif ((floor(dn)~=dn) || dn<1)
    warndlg('Invalid Device Number','Data Source Definition','modal');
end

end

%% OnSaveAndClose callback
%On Save and Closing this window
function OnCancel_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
s=[];
close(ff)
end

%% OnSaveAndClose callback
%On Save and Closing this window
function OnSaveAndClose_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);

n=str2double(get(handles.idEditBox,'String'));
flagID=false;
if (isnan(n))
    warndlg('Invalid ID','Data Source Definition','modal');
elseif ((floor(n)~=n) || n<1)
    warndlg('Invalid ID','Data Source Definition','modal');
else
    flagID=true;
end

tString=get(handles.typeComboBox,'String');
tIdx=get(handles.typeComboBox,'Value');
t=tString{tIdx};
flagType=false;
if (isempty(t) || ~ischar(t))
    warndlg('Invalid Type','Data Source Definition','modal');
else
    flagType=true;
end

dn=str2double(get(handles.deviceNumberEditBox,'String'));
flagDeviceNumber=false;
if (isnan(dn))
    warndlg('Invalid Device Number','Data Source Definition','modal');
elseif ((floor(dn)~=dn) || dn<1)
    warndlg('Invalid Device Number','Data Source Definition','modal');
else
    flagDeviceNumber=true;
end

if (flagID && flagType && flagDeviceNumber)
    s=dataSourceDefinition(n,t,dn);
    close(ff);
end

end


end
