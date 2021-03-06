function element=guiCheckIntegrity(element)
%guiCheckIntegrity Graphical User Interface for integrity check
%
% element=guiCheckIntegrity(element) Allow selection of integrity
%   checks and apply the selected integrity checks as appropriate
%   to the element active data.
%
%
% The element may be one of the following classes:
%   + experiment
%   + subject
%   + session
%   + dataSource
%   + structuredData
%
%
% Copyright 2008-13
% @date: 8-Jul-2008
% @author Felipe Orihuela-Espina
% @modified: 2-Jan-2013
%
% See also runIntegrity
%

%% Initialize the figure
%...and hide the GUI as it is being constructed
width=700;
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
%set(f,'CloseRequestFcn',{@OnClose_Callback});

%% Add components
fontSize=16;
bgColor=get(f,'Color');


uicontrol(f,'Style', 'text',...
       'String', 'Name:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.9 0.2 0.06]);
uicontrol(f,'Style', 'text',...
       'Tag','elementNameText',...
       'String', 'NONAME',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.25 0.9 0.5 0.06]);
uicontrol(f,'Style', 'text',...
       'String', 'Element Type:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.8 0.3 0.06]);
uicontrol(f,'Style', 'text',...
       'Tag','elementTypeText',...
       'String', 'NOCLASS',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.35 0.8 0.5 0.06]);

testsPanel=uitabgroup(f,'Position', [0.05 0.15 0.9 0.6]);
 
    
nirs_neuroimageTab = uitab(testsPanel,'Title','NIRS Neuroimage');
   
nirs_neuroimageTestsPanel = uipanel(nirs_neuroimageTab,...
       'Tag','testsPanel',...
       'Title', 'Tests',...
       'BorderType', 'etchedin',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'Units','normalize',...
       'Position', [0.02 0.3 0.96 0.66]); 
uicontrol(nirs_neuroimageTestsPanel,'Style', 'text',...
       'String', 'Complex numbers',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.05 0.68 0.5 0.18]);
uicontrol(nirs_neuroimageTestsPanel,'Style', 'checkbox',...
       'Tag','complexCheckbox',...
       'Min', 0,...
       'Max', 1,...
       'Value', 1,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'Units','normalize',...
       'Position', [0.02 0.68 0.03 0.18]);
uicontrol(nirs_neuroimageTestsPanel,'Style', 'text',...
       'String', 'Mirroring',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.05 0.46 0.5 0.18]);
uicontrol(nirs_neuroimageTestsPanel,'Style', 'checkbox',...
       'Tag','mirroringCheckbox',...
       'Min', 0,...
       'Max', 1,...
       'Value', 1,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'Units','normalize',...
       'Position', [0.02 0.46 0.03 0.18]);
uicontrol(nirs_neuroimageTestsPanel,'Style', 'text',...
       'String', 'Apparent Non-Recording',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.05 0.24 0.5 0.18]);
uicontrol(nirs_neuroimageTestsPanel,'Style', 'checkbox',...
       'Tag','apparentNonRecordingCheckbox',...
       'Min', 0,...
       'Max', 1,...
       'Value', 1,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'Units','normalize',...
       'Position', [0.02 0.24 0.03 0.18]);
uicontrol(nirs_neuroimageTestsPanel,'Style', 'text',...
       'String', 'Optode Movement',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.05 0.05 0.5 0.18]);
uicontrol(nirs_neuroimageTestsPanel,'Style', 'checkbox',...
       'Tag','optodeMovementCheckbox',...
       'Min', 0,...
       'Max', 1,...
       'Value', 0,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'Units','normalize',...
       'Position', [0.02 0.05 0.03 0.18]);
uicontrol(nirs_neuroimageTestsPanel,'Style', 'text',...
       'String', 'Using Sato''s algorithm. Requires Wavelets Toolbox.',...
       'BackgroundColor',bgColor,...
       'FontSize',8,...
       'HorizontalAlignment','left',...
       'Visible','on',...
       'Units','normalize',...
       'Position', [0.6 0.05 0.35 0.18]);

nirs_neuroimageOptionsPanel = uipanel(nirs_neuroimageTab,...
       'Tag','optionsPanel',...
       'Title', 'Options',...
       'BorderType', 'etchedin',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'Units','normalize',...
       'Position', [0.02 0.02 0.96 0.26]); 
uicontrol(nirs_neuroimageOptionsPanel,'Style', 'text',...
       'String', 'Force check',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','left',...
       'Visible','on',...
       'Units','normalize',...
       'Position', [0.05 0.05 0.25 0.88]);
uicontrol(nirs_neuroimageOptionsPanel,'Style', 'text',...
       'String', ['Perform integrity check in channels ' ...
                'even if already tested. Leave option ',...
                'unticked if you only want to carry out ' ...
                'untested checks.'],...
       'BackgroundColor',bgColor,...
       'FontSize',8,...
       'HorizontalAlignment','left',...
       'Visible','on',...
       'Units','normalize',...
       'Position', [0.35 0.05 0.62 0.88]);
uicontrol(nirs_neuroimageOptionsPanel,'Style', 'checkbox',...
       'Tag','forceCheckCheckbox',...
       'Min', 0,...
       'Max', 1,...
       'Value', 0,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'Units','normalize',...
       'Visible','on',...
       'Enable','on',...
       'Position', [0.02 0.05 0.03 0.88]);

   
generalOptionsTab = uitab(testsPanel,...
       'Title','General Options');
   
uicontrol(generalOptionsTab,'Style', 'text',...
       'String', 'Test in raw data when possible',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','left',...
       'Visible','on',...
       'Units','normalize',...
       'Position', [0.04 0.52 0.3 0.2]);
uicontrol(generalOptionsTab,'Style', 'text',...
       'String', ['Strongly recommended. May substantially speed up ' ...
                  'the integrity check process.'],...
       'BackgroundColor',bgColor,...
       'FontSize',8,...
       'HorizontalAlignment','left',...
       'Visible','on',...
       'Units','normalize',...
       'Position', [0.4 0.52 0.57 0.2]);
uicontrol(generalOptionsTab,'Style', 'checkbox',...
       'Tag','testInRawCheckbox',...
       'Min', 0,...
       'Max', 1,...
       'Value', 1,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'Units','normalize',...
       'Visible','on',...
       'Enable','on',...
       'Position', [0.35 0.52 0.04 0.2]);
uicontrol(generalOptionsTab,'Style', 'text',...
       'String', 'Verbose:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.04 0.3 0.3 0.2]);
uicontrol(generalOptionsTab,'Style', 'checkbox',...
       'Tag','verboseCheckbox',...
       'Min', 0,...
       'Max', 1,...
       'Value', 1,...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'Units','normalize',...
       'Position', [0.35 0.3 0.04 0.2]);


uicontrol(f,'Style', 'pushbutton',...
       'String', 'Integrity',...
       'Tag','runButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Position', [0.6 0.02 0.2 0.1],...
       'Callback',{@OnCheckIntegrity_Callback});

uicontrol(f,'Style', 'pushbutton',...
       'String', 'Close',...
       'Tag','closeButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.81 0.02 0.18 0.1],...
       'Callback',{@OnQuit_Callback});   
   
%% On Opening
handles = guihandles(f); %NOTE that only include those whose 'Tag' are not empty

if isa(element,'structuredData')
    set(handles.elementNameText,'String',get(element,'Description'));
else
    set(handles.elementNameText,'String',get(element,'Name'));
end
set(handles.elementTypeText,'String',class(element));
guidata(f,handles);

 
%% Make GUI visible
set(f,'Name','ICNA - guiCheckIntegrity');
set(f,'Visible','on');
waitfor(f);

%% OnCheckIntegrity callback
%Apply the selected test to the object.
function OnCheckIntegrity_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
options.verbose=get(handles.verboseCheckbox,'Value');
%%% NOT YET READY
%options.whichChannels=1:24;
%%%

%Collect all the options
options.nirs_neuroimage.Complex=...
        get(handles.complexCheckbox,'Value');
options.nirs_neuroimage.ApparentNonRecording=...
        get(handles.apparentNonRecordingCheckbox,'Value');
options.nirs_neuroimage.Mirroring=...
        get(handles.mirroringCheckbox,'Value');
options.nirs_neuroimage.OptodeMovement=...
        get(handles.optodeMovementCheckbox,'Value');
options.nirs_neuroimage.testAllChannels=...
        get(handles.forceCheckCheckbox,'Value');
options.testInRawWhenPossible=...
        get(handles.testInRawCheckbox,'Value');

set(handles.runButton,'Enable','off');
set(handles.closeButton,'Enable','off');

button = questdlg(['Integrity checks takes long to run. ' ...
            'It may take hours or even a few DAYS!, depending ',...
            'on the size of your data. You can stop the run ',...
            'at any point by pressing Ctrl+c on the MATLAB ',...
            'main command window. If this does not work, then ',...
            'start the Task Manager (Ctrl+Alt+Del) and kill the ',...
            'MATLAB process. ' ...
            'It is strongly recommended that you save any previous ',...
            'work before you proceed.'],...
            'Check Integrity','Continue','Cancel','Cancel');
if strcmp(button,'Continue')
%And run the integrity
	element=runIntegrity(element,options);
end
set(handles.runButton,'Enable','on');
set(handles.closeButton,'Enable','on');
uiwait(msgbox('Done!','ICNA - guiCheckIntegrity','modal'));

end


%% OnQuit callback
%Clear memory and exit the application
function OnQuit_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
delete(get(gcf,'Children'));
delete(gcf);
end


end
