function element=guiTimeline(varargin)
%guiTimeline GUI for visualization and modification of a timeline
%
% t=guiTimeline displays a graphical user interface (GUI) for
%   generating a new Timeline.
%
% t=guiExperimentSpace(t) displays a graphical user interface (GUI)
%   for modifying timeline t.
%
% t=guiExperimentSpace(...,'OptionTag',optionValue) allow control of
%   different options (see below).
%
% Returns an empty object if the Cancel button is selected
%and the object has not been saved, or the latest saved version.
%
%% Options
%
% 'setTimelineLength' - Enables/Disables the option for modifying
%   the timeline length. By default is disabled. Possible values
%   are 'on' or 'off'.
%
%
% Copyright 2008-13
% @date: 15-Oct-2008
% @author Felipe Orihuela-Espina
% @modified: 1-Jan-2013
%
% See also guiExperiment, guiExperimentSpace, timeline
%

%% Deal with options
if ~isempty(varargin) && isa(varargin{1},'timeline')
    element=varargin{1};
    varargin(1)=[];
end
tmpOpt.setTimelineLength=false; %Enable/Disable the option for setting
                        %the timeline length

optionsArgIn = varargin;
while length(optionsArgIn) >= 2,
   optTag = lower(optionsArgIn{1});
   val = optionsArgIn{2};
   optionsArgIn = optionsArgIn(3:end);
   switch optTag
    case 'settimelinelength'
        val=lower(val);
        switch (val)
            case 'on'
                tmpOpt.setTimelineLength=true;
            case 'off'
                tmpOpt.setTimelineLength=false;
            otherwise
                error('ICNA:guiTimeline:InvalidParameter',...
                  ['Value for setTimelineLength must be either '...
                  '''on'' or ''off''.']);
        end
 
    otherwise
      error('ICNA:guiTimeline:InvalidParameter',...
            ['Invalid option ' optTag '.'])
   end
end

%% Initialize the figure
%...and hide the GUI as it is being constructed
screenSize=get(0,'ScreenSize');
width=screenSize(3)-round(screenSize(3)/6);
height=screenSize(4)-round(screenSize(4)/4);
wOffset=round((screenSize(3)-width)/2);
hOffset=round((screenSize(4)-height)/2);
f=figure('Visible','off','Position',[wOffset,hOffset,width,height]);
set(f,'NumberTitle','off');
set(f,'MenuBar','none'); %Hide MATLAB figure menu
%set(f,'CloseRequestFcn',{@OnClose_Callback});
movegui('center');

%% Add components
fontSize=16;
bgColor=get(f,'Color');


menuConditions = uimenu('Label','Conditions',...
    'Tag','menuConditions',...
    'Enable','off');
    uimenu(menuConditions,'Label','Add Condition ...',...
        'Tag','menuConditions_OptAddCondition',...
        'Enable','off',...
        'Callback',{@OnAddCondition});
    uimenu(menuConditions,'Label','Remove Condition ...',...
        'Tag','menuConditions_OptRemoveCondition',...
        'Enable','off',...
        'Callback',{@OnRemoveCondition});
menuEvents = uimenu('Label','Events',...
    'Tag','menuEvents',...
    'Enable','off');
    uimenu(menuEvents,'Label','Add Event ...',...
        'Tag','menuEvents_OptAddEvent',...
        'Enable','off',...
        'Callback',{@OnAddEvent});
    uimenu(menuEvents,'Label','Remove Event ...',...
        'Tag','menuEvents_OptRemoveEvent',...
        'Enable','off',...
        'Callback',{@OnRemoveEvent});
menuView = uimenu('Label','View',...
    'Tag','menuView',...
    'Enable','on');
    uimenu(menuView,'Label','Onsets and durations',...
        'Tag','menuView_OptOnsetsAndDurations',...
        'Checked','off',...
        'Enable','on',...
        'Callback',{@OnViewOnsetsAndDurations});
menuTools = uimenu('Label','Tools',...
    'Tag','menuTools',...
    'Enable','off');
    tmpMenuTools_OptSetLength=uimenu(menuTools,'Label','Set length',...
        'Tag','menuTools_OptSetLength',...
        'Enable','off',...
        'Callback',{@OnSetLength});
    uimenu(menuTools,'Label','Zoom',...
        'Tag','menuTools_OptZoom',...
        'Enable','off',...
        'Callback',{@OnZoom_Callback});
    uimenu(menuTools,'Label','Switch exclusory behaviour',...
        'Tag','menuTools_OptSwitchExclusoryBehaviour',...
        'Enable','off',...
        'Callback',{@OnSwitchExclusoryBehaviour});
    uimenu(menuTools,'Label','Set all overlapping',...
        'Tag','menuTools_OptSetAllNonExclusoryBehaviour',...
        'Enable','off',...
        'Callback',{@OnSetAllNonExclusoryBehaviour});
    uimenu(menuTools,'Label','Set all exclusory',...
        'Tag','menuTools_OptSetAllExclusoryBehaviour',...
        'Enable','off',...
        'Callback',{@OnSetAllExclusoryBehaviour});
    uimenu(menuTools,'Label','Default exclusory',...
        'Tag','menuTools_OptDefaultExclusoryBehaviour',...
        'Checked','on',...
        'Enable','off',...
        'Callback',{@OnDefaultExclusoryBehaviour});
if ~(tmpOpt.setTimelineLength)
    set(tmpMenuTools_OptSetLength,'Visible','off');
end
clear tmpMenuTools_OptSetLength


%Toolbars
toolbar = uitoolbar(f,'Tag','toolbar');
%iconsFolder='C:\Program Files\MATLAB\R2007b\toolbox\matlab\icons\';
iconsFolder='./GUI/icons/';
% tempIcon=load([iconsFolder 'savedoc.mat']);
%     uipushtool(toolbar,'CData',tempIcon.cdata,...
%         'Tag','toolbarButton_Save',...
%         'TooltipString','Save',...
%         'ClickedCallback',{@OnSave_Callback});
tempIcon=load([iconsFolder 'addCondition.mat']);
	uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_addCondition',...
        'TooltipString','Add new condition',...
        'ClickedCallback',{@OnAddCondition});
tempIcon=load([iconsFolder 'removeCondition.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_removeCondition',...
        'TooltipString','Remove an existing condition',...
        'ClickedCallback',{@OnRemoveCondition});
tempIcon=load([iconsFolder 'addEvent.mat']);
	uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_addEvent',...
        'TooltipString','Add new event',...
        'ClickedCallback',{@OnAddEvent});
tempIcon=load([iconsFolder 'removeEvent.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_removeEvent',...
        'TooltipString','Remove an existing event',...
        'ClickedCallback',{@OnRemoveEvent});
tempIcon=load([iconsFolder 'zoom.mat']);
   uipushtool(toolbar,'CData',tempIcon.cdata,...
       'Tag','toolbarButton_Zoom',...
       'TooltipString','Zoom',...
       'Enable','off',...
       'Separator','on',...
       'ClickedCallback',{@OnZoom_Callback});


%Main area elements
timecourseAxes=axes('Parent',f);
set(timecourseAxes,...
        'Tag','timecourseAxes',...
		'FontSize',fontSize,...
        'Color','none',...
        'Units','normalize',...
        'OuterPosition',[0.02 0.02 0.73 0.96]);
xlabel(timecourseAxes,'Time (Samples)');
ylabel(timecourseAxes,'Condition');


    
exclusoryBehaviourAxes=axes('Parent',f,...
        'Units','normalize',...
        'OuterPosition',[0.75 0.75 0.25 0.25]);
set(exclusoryBehaviourAxes,...
        'Tag','exclusoryAxes',...
		'FontSize',fontSize,...
        'Color','none');
%title(exclusoryBehaviourAxes,'Exclusory Behaviour');
%xlabel(exclusoryBehaviourAxes,'Condition');
ylabel(exclusoryBehaviourAxes,'Condition');

controlPanel = uipanel(f,...
        'BorderType','none',...
		'FontSize',fontSize-2,...
        'BackgroundColor',get(f,'Color'),...
        'Position',[0.75 0.02 0.25 0.73]);

uicontrol(controlPanel,'Style', 'text',...
       'String', 'Show/Hide Conditions:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Position', [0.02 0.9 0.96 0.08]);
uicontrol(controlPanel,'Style', 'listbox',...
       'Tag','conditionsListBox',...
       'String', '0',...
       'Min',0,...
       'Max',2,...
       'BackgroundColor','w',...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','left',...
       'Callback',{@ConditionsListBox_Callback},...
       'Units','normalize',...
       'Position', [0.02 0.5 0.96 0.4]);

   
uicontrol(controlPanel,'Style', 'pushbutton',...
       'String', 'Save',...
       'Tag','saveButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.02 0.28 0.96 0.13],...
       'Callback',{@OnSaveElement_Callback});

uicontrol(controlPanel,'Style', 'pushbutton',...
       'String', 'Save and Close',...
       'Tag','saveAndCloseButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.02 0.15 0.96 0.13],...
       'Callback',{@OnSaveAndClose_Callback});

uicontrol(controlPanel,'Style', 'pushbutton',...
       'String', 'Cancel',...
       'Tag','cancelButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.02 0.02 0.96 0.13],...
       'Callback',{@OnClose_Callback});


%% On Opening
handles = guihandles(f); %NOTE that only include those whose 'Tag' are not empty
handles.zoom='off';
guidata(f,handles);

if ~exist('element','var')
    element=timeline(1,100);
end

handles.currentElement.data=timeline(element);
handles.currentElement.saved=true;
guidata(f,handles);
OnLoad_Callback(f,[]);


%% Make GUI visible
set(f,'Name','ICNA - Timeline');
set(f,'Visible','on');
waitfor(f);

%% ConditionsListBox Callback
%Show or Hide conditions
function ConditionsListBox_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
refreshTimecourse(hObject);
refreshExclusoryBehaviour(hObject);
end

%% OnViewOnsetsAndDurations Callback
%Show or Hide onsets and durations
function OnViewOnsetsAndDurations(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
if strcmp(get(handles.menuView_OptOnsetsAndDurations,'Checked'),'on')
    set(handles.menuView_OptOnsetsAndDurations,'Checked','off');
else
    set(handles.menuView_OptOnsetsAndDurations,'Checked','on');
end
refreshTimecourse(hObject);
end


%% OnAddCondition
%Add a new condition
function OnAddCondition(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);


validConditionName=false;
while ~validConditionName
    %Get new condition name/tag
    answer = inputdlg('Condition Name','Add Condition');
    if isempty(answer) %cancel button pressed
        validConditionName=true;
        %but do not add any new condition
    else
        try
            exclusoryBehaviour = 1;
            if strcmp(get(handles.menuTools_OptDefaultExclusoryBehaviour,'Checked'),'on')
                exclusoryBehaviour = 1; %exclusory
            else
                exclusoryBehaviour = 0; %overlapping
            end
            
            handles.currentElement.data=...
                addCondition(handles.currentElement.data,...
                            answer{1},[],exclusoryBehaviour);
            
            conditionTags=get(handles.conditionsListBox,'String');
            if isempty(conditionTags)
                conditionTags=answer;
            else
                conditionTags(end+1)={answer{1}};
            end
            set(handles.conditionsListBox,'String',conditionTags);
            validConditionName=true;
        catch ME
            msg={ME.identifier,'', ME.message};
            h=errordlg(msg,'guiTimeline','modal');
            uiwait(h);
        end
    end
end

guidata(hObject,handles);
refreshTimecourse(hObject);
refreshExclusoryBehaviour(hObject);
end

%% OnAddEvent
%Add a new event to a condition
function OnAddEvent(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);


validEvent=false;
while ~validEvent
    %Get new condition name/tag
    answer = inputdlg({'Condition Name','Event Onset','Event Duration'},...
                      'Add Event');
    if isempty(answer) %cancel button pressed
        validEvent=true;
        %but do not add any new condition
    else
        try
            handles.currentElement.data=...
                addConditionEvents(handles.currentElement.data,...
                        answer{1},...
                        [str2double(answer{2}) str2double(answer{3})]);
            
            validEvent=true;
        catch ME
            msg={ME.identifier,'', ME.message};
            h=errordlg(msg,'guiTimeline','modal');
            uiwait(h);
        end
    end
end

guidata(hObject,handles);
refreshTimecourse(hObject);
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


%% OnDefault Exclusory Behaviour
%Change the default exclusory behaviour for new conditions
function OnDefaultExclusoryBehaviour(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles = guidata(f);
if strcmp(get(handles.menuTools_OptDefaultExclusoryBehaviour,'Checked'),'on')
    set(handles.menuTools_OptDefaultExclusoryBehaviour,'Checked','off');
else
    set(handles.menuTools_OptDefaultExclusoryBehaviour,'Checked','on');
end
guidata(hObject,handles);
end


%% OnLoad callback
%Converts data to a structured data and plot the data afresh.
function OnLoad_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
t=handles.currentElement.data;
nConditions=get(t,'NConditions');

%Controls (By default all conditions are shown)
if (nConditions==0)
    set(handles.conditionsListBox,'String','');
    set(handles.conditionsListBox,'Value',[]);
else
    conditionTags=cell(1,nConditions);
    for cc=1:nConditions
        conditionTags(cc)={getConditionTag(t,cc)};
    end
    set(handles.conditionsListBox,'String',conditionTags);
    set(handles.conditionsListBox,'Value',1:nConditions);
end


%Timecourses
refreshTimecourse(hObject);

%Exclusory behavior
refreshExclusoryBehaviour(hObject);

%Enable controls as appropriate
set(handles.menuConditions,'Enable','on');
set(handles.menuConditions_OptAddCondition,'Enable','on');
set(handles.menuConditions_OptRemoveCondition,'Enable','on');
if (nConditions==0)
    set(handles.menuEvents,'Enable','off');
    set(handles.menuEvents_OptAddEvent,'Enable','off');
    set(handles.menuEvents_OptRemoveEvent,'Enable','off');
else
    set(handles.menuEvents,'Enable','on');
    set(handles.menuEvents_OptAddEvent,'Enable','on');
    set(handles.menuEvents_OptRemoveEvent,'Enable','on');
end
set(handles.menuTools,'Enable','on');
set(handles.menuTools_OptSetLength,'Enable','on');
set(handles.menuTools_OptZoom,'Enable','on');
set(handles.menuTools_OptSwitchExclusoryBehaviour,'Enable','on');
set(handles.menuTools_OptSetAllExclusoryBehaviour,'Enable','on');
set(handles.menuTools_OptSetAllNonExclusoryBehaviour,'Enable','on');
set(handles.menuTools_OptDefaultExclusoryBehaviour,'Enable','on');

set(handles.toolbarButton_Zoom,'Enable','on');


guidata(hObject,handles);
end


%% OnRemoveCondition
%Removes an existing condition
function OnRemoveCondition(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);

%Get new condition name/tag
validConditionName=false;
while ~validConditionName
    answer = inputdlg('Condition Name','Remove Condition');
    if isempty(answer) %cancel button pressed
        validConditionName=true;
        %but do not remove any condition
    else
        try
            handles.currentElement.data=...
                removeCondition(handles.currentElement.data,answer{1});
            %and refresh the conditionsListBox
            conditionTags=get(handles.conditionsListBox,'String');
            conditionValues=get(handles.conditionsListBox,'Value');
            nConditions=length(conditionTags);
            for cc=1:nConditions
                if strcmp(answer{1},conditionTags{cc})
                    conditionTags(cc)=[];
                    conditionValues=setdiff(conditionValues,cc);
                    break;
                end
            end
            set(handles.conditionsListBox,'String',conditionTags);
            set(handles.conditionsListBox,'Value',conditionValues);
            
            validConditionName=true;
        catch ME
            msg={ME.identifier,'', ME.message};
            h=errordlg(msg,'guiTimeline','modal');
            uiwait(h);
        end
    end
end

guidata(hObject,handles);
refreshTimecourse(hObject);
refreshExclusoryBehaviour(hObject);
end

%% OnRemoveEvent
%Removes an existing event to a condition
function OnRemoveEvent(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);


validEvent=false;
while ~validEvent
    %Get new condition name/tag
    answer = inputdlg({'Condition Name','Event Onset'},...
                      'Remove Event');
    if isempty(answer) %cancel button pressed
        validEvent=true;
        %but do not add any new condition
    else
        try
            tmpEvents=...
                getConditionEvents(handles.currentElement.data,answer{1});
            idx=find(tmpEvents(:,1)==str2double(answer{2}));
            if ~isempty(idx)
                tmpEvents(idx,:)=[];
            end
            handles.currentElement.data=...
                setConditionEvents(handles.currentElement.data,...
                        answer{1},tmpEvents);
            
            validEvent=true;
        catch ME
            msg={ME.identifier,'', ME.message};
            h=errordlg(msg,'guiTimeline','modal');
            uiwait(h);
        end
    end
end

guidata(hObject,handles);
refreshTimecourse(hObject);
end



%% OnSaveElement Callback
%Save the changes to the element
function OnSaveElement_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

%OnUpdateElement_Callback(hObject,eventData)
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

%% OnSetAllExclusoryBehaviour
%Set the exclusory behaviour of all conditions to exclusory
function OnSetAllExclusoryBehaviour(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
%try
    handles.currentElement.data=...
        setAllExclusory(handles.currentElement.data,1);
%catch ME
%    msg={ME.identifier,'', ME.message};
%    h=errordlg(msg,'guiTimeline','modal');
%    uiwait(h);
%end
guidata(hObject,handles);
refreshExclusoryBehaviour(hObject);
end

%% OnSetAllNonExclusoryBehaviour
%Set the exclusory behaviour of all conditions to non-exclusory
function OnSetAllNonExclusoryBehaviour(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
try
    handles.currentElement.data=...
        setAllExclusory(handles.currentElement.data,0);
catch ME
    msg={ME.identifier,'', ME.message};
    h=errordlg(msg,'guiTimeline','modal');
    uiwait(h);
end
guidata(hObject,handles);
refreshExclusoryBehaviour(hObject);
end

%% OnSwitchExclusoryBehaviour
%Switch the exclusory behaviour between 2 conditions
function OnSwitchExclusoryBehaviour(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
valid=false;
while ~valid
    %Get new condition name/tag
    answer = inputdlg({'Condition Name 1','Condition Name 2'},...
                    'Switch Exclusory Behaviour');
    if isempty(answer) %cancel button pressed
        valid=true;
        %but do not change the length
    else
        try
            handles.currentElement.data=...
                switchExclusory(handles.currentElement.data,...
                    answer{1},answer{2});
            valid=true;
        catch ME
            msg={ME.identifier,'', ME.message};
            h=errordlg(msg,'guiTimeline','modal');
            uiwait(h);
        end
    end
end

guidata(hObject,handles);
refreshExclusoryBehaviour(hObject);
end

%% OnSetLength
%Sets the length of the timeline
function OnSetLength(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
validLength=false;
while ~validLength
    %Get new condition name/tag
    answer = inputdlg('New Length','Set Length');
    if isempty(answer) %cancel button pressed
        validLength=true;
        %but do not change the length
    else
        try
            handles.currentElement.data=...
                set(handles.currentElement.data,...
                    'Length',str2double(answer{1}));
            validLength=true;
        catch ME
            msg={ME.identifier,'', ME.message};
            h=errordlg(msg,'guiTimeline','modal');
            uiwait(h);
        end
    end
end

guidata(hObject,handles);
refreshTimecourse(hObject);
end

%% OnZoom Callback
%Turns interactive zoom on/off
function OnZoom_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles = guidata(f);
if strcmp(handles.zoom,'on')
    handles.zoom='off';
    zoom off
    zoom out
elseif strcmp(handles.zoom,'off')
    handles.zoom='on';
    zoom xon
end
guidata(hObject,handles);
end


%% Refresh exclusory behaviour
%Refresh the exclusory behaviour axes
function refreshExclusoryBehaviour(hObject)
% hObject - Handle of the object, e.g., the GUI component
handles=guidata(hObject);
t=handles.currentElement.data;

%Find out which conditions are to be shown
conditions=get(handles.conditionsListBox,'Value');

%Refresh the axes as appropriate
axes(handles.exclusoryAxes)
cla(handles.exclusoryAxes)
title(gca,'Exclusory Behaviour');
ylabel(gca,'Exclusory Behaviour');

if (isempty(conditions))
    imagesc([])
    set(gca,'XLim',[0 1]);
    set(gca,'XTick',[]);
    set(gca,'XTickLabel',[]);
    set(gca,'YLim',[0 1]);
    set(gca,'YTick',[]);
    set(gca,'YTickLabel',[]);
else

    b=getExclusory(t);
    %Discard non selected conditions
    b=b(conditions,conditions);
    imagesc(b)

    colormap(gray(2))
    caxis([0 1])

    nConditions=length(conditions);
    conditionTags=cell(1,nConditions);
    pos=1;
    for cc=conditions
        conditionTags(pos)={getConditionTag(t,cc)};
        pos=pos+1;
    end
    set(gca,'XLim',[0.5 nConditions+0.5]);
    set(gca,'XTick',1:nConditions);
    set(gca,'XTickLabel',conditionTags);
    set(gca,'XAxisLocation','top');
    set(gca,'YLim',[0.5 nConditions+0.5]);
    set(gca,'YTick',1:nConditions);
    set(gca,'YTickLabel',conditionTags);
    
end
end

%% Refresh timecourse
%Refresh the timecourse axes
function refreshTimecourse(hObject)
% hObject - Handle of the object, e.g., the GUI component
handles=guidata(hObject);
t=handles.currentElement.data;

%Find out which conditions are to be shown
conditions=get(handles.conditionsListBox,'Value');

%Refresh the axes as appropriate
colors=hsv(length(conditions));
axes(handles.timecourseAxes)
cla(handles.timecourseAxes)
if (get(t,'Length')>0)
    set(gca,'XLim',[0 get(t,'Length')]);
else
    set(gca,'XLim',[0 0.1]);
end
if (isempty(conditions))
    set(gca,'YLim',[0 1]);
    set(gca,'YTick',[]);
    set(gca,'YTickLabel',[]);
else
    nConditions=length(conditions);
    set(gca,'YLim',[0.5 nConditions+0.5]);
    set(gca,'YTick',1:nConditions);
    conditionTags=cell(1,nConditions);
    pos=1;
    for cc=conditions
        tmpTag=getConditionTag(t,cc);
        conditionTags(pos)={tmpTag};
        
        %Draw the events
        events=getConditionEvents(t,tmpTag);
        nEvents=getNEvents(t,tmpTag);
        for ee=1:nEvents
            pX=[events(ee,1) events(ee,1) ...
                events(ee,1)+events(ee,2) events(ee,1)+events(ee,2)];
            pY=[pos-0.48 pos+0.48 ...
                pos+0.48 pos-0.48];
            %%%IMPORTANT NOTE: Do NOT use this call to patch using
            %%%property FaceAlpha! I do not understand why, but it
            %will lead to an error in the exclusory behaviour axes
            %by which the tick marks in that axes are magically
            %replicated ad infinitum!!
%             patch(pX,pY,colors(mod(pos,size(colors,1))+1,:),...
%                'EdgeColor',colors(mod(pos,size(colors,1))+1,:),...
%                'FaceAlpha',0.2,'LineWidth',1.5);
            patch(pX,pY,colors(mod(pos,size(colors,1))+1,:),...
                'EdgeColor',colors(mod(pos,size(colors,1))+1,:),...
                'LineWidth',1.5);
            
            
            if strcmp(get(handles.menuView_OptOnsetsAndDurations,...
                'Checked'),'on')
                text(events(ee,1)+1,pos+0.04,...
                    ['o: ' num2str(events(ee,1))],...
                    'FontSize',fontSize);
                text(events(ee,1)+1,pos-0.44,...
                    ['d: ' num2str(events(ee,2))],...
                    'FontSize',fontSize);
            end
        end
        pos=pos+1;
        
    end
    set(gca,'YTickLabel',conditionTags);
end
%set(gca,'OuterPosition',[0 0 1 1]);
box on
set(gca,'XGrid','on');

if (get(t,'NConditions')==0)
    set(handles.menuEvents,'Enable','off');
    set(handles.menuEvents_OptAddEvent,'Enable','off');
    set(handles.menuEvents_OptRemoveEvent,'Enable','off');
else
    set(handles.menuEvents,'Enable','on');
    set(handles.menuEvents_OptAddEvent,'Enable','on');
    set(handles.menuEvents_OptRemoveEvent,'Enable','on');
end

guidata(hObject,handles);

end


end

 