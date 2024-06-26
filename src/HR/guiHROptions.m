function appOptions=guiHROptions(appOptions)
%A GUI for configuring the HR tool application options
%
% appOptions=guiHROptions; Updates the configuration
%   options of the application, preloading the default options
%
% appOptions=guiHROptions(appOptions); Updates the configuration
%   options of the application
%
%
% Copyright 2009
% @date: 20-Jan-2009
% @author Felipe Orihuela-Espina
%
% See also rawData_BioHarnessECG, ecg, dataSource, hrtool_configure
%

if (~exist('appOptions','var'))
    appOptions=hrtool_configure;
end


%% Initialize the figure
%...and hide the GUI as it is being constructed
screenSize=get(0,'ScreenSize');
width=400;%screenSize(3)-round(screenSize(3)/10);
height=300;%screenSize(4)-round(screenSize(4)/5);
f=figure('Visible','off',...
         'Position',[1,1,width,height]);
%set(f,'CloseRequestFcn',{@OnQuit_Callback});
movegui(f,'center');
set(f,'NumberTitle','off');
set(f,'MenuBar','none'); %Hide MATLAB figure menu

%% Add components
fontSize=14;
bgColor=get(f,'Color');


tabPanel=uitabgroup(f,...
       'Position', [0.02 0.2 0.96 0.76]);

generalTab = uitab(tabPanel,...
       'Title','General');
uicontrol(generalTab,'Style', 'text',...
       'String', 'Font Size:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.85 0.4 0.12]);
uicontrol(generalTab,'Style', 'edit',...
       'Tag','fontSizeEditBox',...
       'String',num2str(appOptions.fontSize),...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@fontSizeEditBox_Callback},...
       'Units','normalize',...
       'Position', [0.42 0.85 0.5 0.12]);

uicontrol(generalTab,'Style', 'text',...
       'String', 'Line Width:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.65 0.4 0.12]);
uicontrol(generalTab,'Style', 'edit',...
       'Tag','lineWidthEditBox',...
       'String',num2str(appOptions.lineWidth),...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@lineWidthEditBox_Callback},...
       'Units','normalize',...
       'Position', [0.42 0.65 0.5 0.12]);


uicontrol(f,'Style', 'pushbutton',...
       'String', 'Save and Exit',...
       'Tag','runButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Position', [0.5 0.02 0.4 0.1],...
       'Callback',{@OnQuit_Callback});


   
%% On Opening
handles = guihandles(f); %NOTE that only include those whose 'Tag' are not empty

guidata(f,handles);

%% Make GUI visible
set(f,'Name','HR Options');
set(f,'Visible','on');
waitfor(f);



%% fontSizeEditBox Callback
%Updates the option fontSize
function fontSizeEditBox_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
val=str2num(get(handles.fontSizeEditBox,'String'));
if (isscalar(val) && ~ischar(val) && isreal(val) ...
        && floor(val)==val && val>0)
    appOptions.fontSize=val;
else
    warndlg(['HR:guiHROptions: ' ...
        'Invalid font size.']);
end
end


%% lineWidthEditBox Callback
%Updates the option lineWidth
function lineWidthEditBox_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
val=str2num(get(handles.lineWidthEditBox,'String'));
if (isscalar(val) && ~ischar(val) && isreal(val) ...
        && val>0)
    appOptions.lineWidth=val;
else
    warndlg(['HR:guiHROptions: ' ...
        'Invalid line width.']);
end
end



%% OnQuit callback
%Close the dialog
function OnQuit_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
close(gcf);
end



end


