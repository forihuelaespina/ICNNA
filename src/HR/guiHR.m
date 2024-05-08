function [element]=guiHR(element)
%GUIMATRICES A small GUI to display ECG data
%
% [element]=guiHR(element) - A small GUI to display ECG data
%
%
%
%
%% Input parameters
%
% element - Either a @dataSource or an @ecg object.
%
%% Output parameters
%
% element - Either a @dataSource or an @ecg object. If no input parameter
%   was given at the beginning, then it will be returned as a @dataSource.
%
%
%
% Copyright 2009-24
% @date: 19-Jan-2009
% @author Felipe Orihuela-Espina
%
% See also rawData_BioHarnessECG, ecg, dataSource, guiSplitECG
%
%

%% LOG
%
% 8-May-2019: FOE
%   + Log started.
%   + Bug fixed. Upon loading an element, the peaks mode combo box was not
%   being updated.
%
% 16-May-2019: FOE
%   + Now permits passing and @ecg object. It automatically encapsulates
%   it into a dataSource.
%   + RPeaks are now visible by default upon loading.
%
% 28-May-2019: FOE
%   + The working element is now returned on exiting
%
% 29-May-2019: FOE
%   + Liked axes ecgAxes, rrAxes and bpmAxes for slightly better refresh speed
%   + Added controls for the r peaks detection algorithm
%
% 30-May-2019: FOE
%   + Bug fixed. When adding or removing several peaks at once, parsing
%   was not correct, and also, there was no conversion to and from the
%   chosen timescale.
%
% 14-Jun-2019: FOE
%   + Temporary disabling the adding/removing R peaks dialogs for
%   faster cleaning of the DCS-Preemies dataset.
%
% 12-Apr-2019: FOE
%   + Bug fixed. Wrapping dataSource when input is an @ecg object now
%       has the right type.
%       NOTE: When class dataSource was updated in 13-May-2024 to support
%       struct like property access and included validation rules on the
%       declaration, the @dataSource property rawData can no longer be
%       initialize to null (see notes in class @dataSource), but instead,
%       it was now mandatory in MATLAB to initilize the @dataSource.rawData
%       property to some concrete class. For no particular reason, I chose
%       that to be rawData_Snirf, which means that since then, the default
%       @dataSource.type was 'nirs_neuroimage'. Becuase of this, unlocking
%       the wrapping @dataSource here was no longer sufficient to allow
%       adding the @ecg structured data to the @dataSource as it is no
%       longer of the expected type, and hence this bug. Fortunately, the
%       fixing is easy as all it takes is to replace the
%       @dataSource.rawData with an object that will convert to an @ecg,
%       e.g. @rawData_BioHarness.
%   + Started to update calls to get attributes using the struct like syntax
%   + I have now addressed the long standing issue with accessing
%   the icons folder when the working directory is not that of ICNNA
%   using function mfilename. 
%   + guiHR can only work with 1 channel at a time at the moment. 
%   I started to work on supporting more channels but it is not yet
%   finished, so these parts are still commented until I can come back to
%   this.
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
fontSize=14;
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
    uimenu(menuImport,'Label','Zephyr BioHarness ECG...',...
        'Tag','menuImport_OptBioHarness',...
        'Callback',{@OnBrowse_FromBioHarness_Callback});
    uimenu(menuFile,'Label','Quit',...
        'Tag','menuFile_OptQuit',...
        'Callback',{@OnQuit_Callback},... 
        'Separator','on','Accelerator','q');

    
menuData = uimenu('Label','Data',...
    'Tag','menuData',...
    'Accelerator','D');
    uimenu(menuData,'Label','Basic stats',...
        'Tag','menuData_OptBasicStatsReport',...
        'Enable','off',...
        'Callback',{@OnBasicStatsReport_Callback});
    uimenu(menuData,'Label','Time domain report',...
        'Tag','menuData_OptTDReport',...
        'Enable','off',...
        'Callback',{@OnTDReport_Callback});
    uimenu(menuData,'Label','Frequency Domain Report',...
        'Tag','menuData_OptFDReport',...
        'Enable','off',...
        'Callback',{@OnFDReport_Callback});
    uimenu(menuData,'Label','Frequency Domain Plot',...
        'Tag','menuData_OptFDPlot',...
        'Enable','off',...
        'Callback',{@OnFDPlot_Callback});

menuView = uimenu('Label','View',...
    'Tag','menuView',...
    'Accelerator','V');
%    uimenu(menuView,'Label','Zoom',...
%        'Tag','menuView_OptZoom',...
%        'Enable','off',...
%        'Callback',{@OnZoom_Callback});
    uimenu(menuView,'Label','R peaks',...
        'Tag','menuView_OptRPeaks',...
        'Checked','off',...
        'Enable','off',...
        'Callback',{@OnViewRPeaks_Callback});
    uimenu(menuView,'Label','R to R intervals',...
        'Tag','menuView_OptRR',...
        'Checked','off',...
        'Enable','off',...
        'Callback',{@OnViewRR_Callback});
    uimenu(menuView,'Label','BPM',...
        'Tag','menuView_OptBPM',...
        'Checked','off',...
        'Enable','off',...
        'Callback',{@OnViewBPM_Callback});


menuTools = uimenu('Label','Tools',...
    'Tag','menuTools',...
    'Accelerator','T');
%    uimenu(menuTools,'Label','Timeline',...
%        'Tag','menuTools_OptTimeline',...
%        'Separator','on','Enable','off',...
%        'Callback',{@OnTimeline_Callback});
    uimenu(menuTools,'Label','Crop',...
        'Tag','menuTools_OnCrop',...
        'Callback',{@OnCrop_Callback});
    uimenu(menuTools,'Label','Cut',...
        'Tag','menuTools_OnCut',...
        'Callback',{@OnCut_Callback});
    uimenu(menuTools,'Label','fNIRS based split',...
        'Tag','menuTools_OnSplit',...
        'Callback',{@OnSplit_Callback});
    uimenu(menuTools,'Label','Options',...
        'Tag','menuTools_OptOptions',...
        'Separator','on',...
        'Enable','on',...
        'Callback',{@OnOptions_Callback});

menuHelp = uimenu('Label','Help',...
    'Tag','menuHelp',...
    'Accelerator','H');
    uimenu(menuHelp,'Label','About this program...',...
        'Tag','menuHelp_OnAbout',...
        'Callback',{@OnAbout_Callback});

%Toolbars
toolbar = uitoolbar(f,'Tag','toolbar');
[localDir,~,~] = fileparts(mfilename('fullpath'));
iconsFolder=[localDir filesep '..' filesep 'GUI' filesep 'icons' filesep];

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
%tempIcon=load([iconsFolder 'zoom.mat']);
%    uipushtool(toolbar,'CData',tempIcon.cdata,...
%        'Tag','toolbarButton_Zoom',...
%        'TooltipString','Zoom',...
%        'Enable','off',...
%        'Separator','on',...
%        'ClickedCallback',{@OnZoom_Callback});
%tempIcon=load([iconsFolder 'timeline.mat']);
%    uipushtool(toolbar,'CData',tempIcon.cdata,...
%        'Tag','toolbarButton_Timeline',...
%        'Enable','off',...
%        'TooltipString','View timeline',...
%        'ClickedCallback',{@OnTimeline_Callback});
    
%Main area elements

controlPanel = uipanel(f,...
        'BorderType','none',...
		'FontSize',fontSize-2,...
        'BackgroundColor',get(f,'Color'),...
        'Position',[0.01 0.1 0.18 0.88]);

uicontrol(controlPanel,'Style', 'pushbutton',...
       'String', 'Add R peak',...
       'Tag','addRPeakButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Enable','off',...
       'Position', [0.04 0.9 0.58 0.04],...
       'Callback',{@OnAddRPeak_Callback});
uicontrol(controlPanel,'Style', 'pushbutton',...
       'String', 'Remove R peak',...
       'Tag','removeRPeakButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Enable','off',...
       'Position', [0.04 0.85 0.58 0.04],...
       'Callback',{@OnRemoveRPeak_Callback});

uicontrol(controlPanel,'Style', 'text',...
       'String', 'R peaks detection:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.75 0.8 0.06]);

uicontrol(controlPanel,'Style', 'text',...
       'String', 'Mode:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.7 0.4 0.04]);
validTypes={'auto',...
            'manual'};
currVal=1;
uicontrol(controlPanel,'Style', 'popupmenu',...
       'Tag','rPeaksModeComboBox',...
       'String',validTypes,...
       'Value',currVal,...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Enable','off',...
       'Callback',{@rPeaksModeComboBox_Callback},...
       'Units','normalize',...
       'Position', [0.5 0.7 0.4 0.04]);

uicontrol(controlPanel,'Style', 'text',...
       'String', 'Algorithm:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.65 0.4 0.04]);
validTypes={'LoG',...
            'Chen2017'};
currVal=2;
uicontrol(controlPanel,'Style', 'popupmenu',...
       'Tag','rPeaksAlgoComboBox',...
       'String',validTypes,...
       'Value',currVal,...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Enable','off',...
       'Callback',{@rPeaksAlgoComboBox_Callback},...
       'Units','normalize',...
       'Position', [0.5 0.65 0.4 0.04]);



uicontrol(controlPanel,'Style', 'text',...
       'String', 'Threshold (LoG):',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-3,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.4 0.59 0.6 0.04]);
uicontrol(controlPanel,'Style', 'edit',...
       'Tag','thresholdEditBox',...
       'String','',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Enable','off',...
       'Callback',{@thresholdEditBox_Callback},...
       'Units','normalize',...
       'Position', [0.45 0.55 0.38 0.04]);
uicontrol(controlPanel,'Style', 'pushbutton',...
       'String', '^',...
       'Tag','increaseRPeakThresholdButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Enable','off',...
       'Position', [0.93 0.57 0.06 0.02],...
       'Callback',{@OnIncreaseRPeakThreshold_Callback});
uicontrol(controlPanel,'Style', 'pushbutton',...
       'String', 'v',...
       'Tag','decreaseRPeakThresholdButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-2,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Enable','off',...
       'Position', [0.93 0.55 0.06 0.02],...
       'Callback',{@OnDecreaseRPeakThreshold_Callback});

%%% Support for multi-channel unfinished
% uicontrol(controlPanel,'Style', 'text',...
%        'String', 'Select ECG channel:',...
%        'BackgroundColor',bgColor,...
%        'FontSize',fontSize,...
%        'HorizontalAlignment','right',...
%        'Units','normalize',...
%        'Position', [0.01 0.65 0.4 0.04]);
% validTypes={};
% if (exist('element','var'))
%     if isa(element,'ecg')
%         tmpNChannels = element.nChannels;
%     else %dataSource
%         tmpSD = element.getActiveStructured(element.activeStructured);
%         tmpNChannels = tmpSD.nChannels;
%     end
%     for iCh=1:tmpNChannels
%         validTypes(iCh)={num2str(iCh)};
%     end
% end
% currVal=1;
% uicontrol(controlPanel,'Style', 'popupmenu',...
%        'Tag','activeChannelComboBox',...
%        'String',validTypes,...
%        'Value',currVal,...
%        'BackgroundColor','w',...
%        'FontSize',fontSize,...
%        'HorizontalAlignment','left',...
%        'Enable','off',...
%        'Callback',{@rPeaksAlgoComboBox_Callback},...
%        'Units','normalize',...
%        'Position', [0.5 0.65 0.4 0.04]);

uicontrol(controlPanel,'Style', 'text',...
       'String', 'Time Window:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.1 0.39 0.8 0.06]);
uicontrol(controlPanel,'Style', 'edit',...
       'Tag','timeWindowEditBox',...
       'String','',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@timeWindowEditBox_Callback},...
       'Units','normalize',...
       'Position', [0.1 0.33 0.8 0.06]);

% uicontrol(controlPanel,'Style', 'text',...
%        'String', 'Timescale:',...
%        'BackgroundColor',bgColor,...
%        'FontSize',fontSize,...
%        'HorizontalAlignment','right',...
%        'Units','normalize',...
%        'Position', [0.01 0.2 0.4 0.12]);
validTypes={'milliseconds',...
            'seconds',...
            'samples'};
currVal=1;
uicontrol(controlPanel,'Style', 'popupmenu',...
       'Tag','timescaleComboBox',...
       'String',validTypes,...
       'Value',currVal,...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@timescaleComboBox_Callback},...
       'Units','normalize',...
       'Position', [0.1 0.2 0.8 0.12]);
  

visualizationPanel = uipanel(f,...
        'BorderType','none',...
		'FontSize',fontSize-2,...
        'BackgroundColor',get(f,'Color'),...
        'Position',[0.21 0.01 0.78 0.98]);

ecgMasterAxes=axes('Parent',visualizationPanel); %Always show a miniature of the full ECG extent
set(ecgMasterAxes,...
        'Tag','ecgMasterAxes',...
		'FontSize',fontSize,...
        'Color','w',...
        'Units','normalize',...
        'YTick',[],...
        'YTickLabel',[],...
        'XTick',[],...
        'XTickLabel',[],...
        'Position',[0.1 0.95 0.8 0.04]);

ecgAxes=axes('Parent',visualizationPanel); %The zoomed view on the ECG
set(ecgAxes,...
        'Tag','ecgAxes',...
		'FontSize',fontSize,...
        'Color','w',...
        'Units','normalize',...
        'Position',[0.1 0.56 0.8 0.38]);
%xlabel(ecgAxes,'Time (milliseconds)'); %The default units is milliseconds
ylabel(ecgAxes,'ECG Value');
set(ecgAxes,'ButtonDownFcn',{@updateCurrentSample});
%SCROLL CONTROL NOT WORKING CORRECTLY YET (CALL IS OK, BUT FUNCTION BEHAVIOUR IS NOT)
%set(f,'windowscrollWheelFcn', {@mouseScrollZoom,gca});
   
rrAxes=axes('Parent',visualizationPanel); %For displaying RR intervals
set(rrAxes,...
        'Tag','rrAxes',...
		'FontSize',fontSize,...
        'Color','w',...
        'YColor','m',...
        'Units','normalize',...
        'Position',[0.1 0.14 0.8 0.38]);
%xlabel(rrAxes,'Time (milliseconds)');
ylabel(rrAxes,'R to R intervals (-)');
set(rrAxes,'ButtonDownFcn',{@updateCurrentSample});

bpmAxes=axes('Parent',visualizationPanel); %For displaying BPM
    %Transparent; paint on top of rrAxes
set(bpmAxes,...
        'Tag','bpmAxes',...
		'FontSize',fontSize,...
        'Color','none',...
        'YAxisLocation','right',...
        'YColor','r',...
        'Units','normalize',...
        'Position',[0.1 0.14 0.8 0.38]);
ylabel(bpmAxes,'BPM (-)');
set(bpmAxes,'ButtonDownFcn',{@updateCurrentSample});


uicontrol(visualizationPanel,'Style', 'text',...
       'Tag','timeSliderText',...
       'String', 'Time Sample',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.2 0.05 0.4 0.04]);
uicontrol(visualizationPanel,'Style', 'slider',...
       'Tag','timeSlider',...
       'Min',1,...
       'Max',10,...
       'Value',1,...
       'FontSize',fontSize,...
       'Enable','off',...
       'Callback',{@OnUpdateSlider_Callback},...
       'Units','normalize',...
       'Position', [0.1 0.02 0.8 0.02]);
  
linkaxes([ecgAxes rrAxes bpmAxes],'x')

%% On Opening
handles = guihandles(f); %NOTE that only include those whose 'Tag' are not empty

handles.appOptions=hrtool_configure;
handles.zoom='off';
guidata(f,handles);

switch(handles.appOptions.timescale)
    case 'seconds'
        currVal=2;
    case 'samples'
        currVal=3;
    otherwise %in milliseconds by default
        currVal=1;
end
set(handles.timescaleComboBox,'Value',currVal);
% set(get(ecgAxes,'XLabel'),'String',...
%     ['Time (' handles.appOptions.timescale ')']);
% set(get(rrAxes,'XLabel'),'String',...
%     ['Time (' handles.appOptions.timescale ')']);


if (exist('element','var'))
    if isa(element,'ecg')
      	% Encapsulate the ecg into a dataSource so that guiHR can handle it.
        ds = dataSource();
            %Next line is a simple trick.
            % Note that by default, ds.type will be 'nirs_neuroimage' so
            %set it to 'ecg' by setting the rawData to some ECG type
        ds.rawData = rawData_BioHarnessECG();
        ds = unlock(ds);
        ds = addStructuredData(ds,element);
    else
        ds=dataSource(element);
    end
    handles.currentElement.data=ds;
    guidata(f,handles);
    OnLoad_Callback(f,[]);
else
    handles.currentElement.data=dataSource;
    handles.currentElement.timestamps=...
        [get(handles.timeSlider,'Min'):get(handles.timeSlider,'Max')];
    guidata(f,handles);

    set(handles.menuFile_OptSave,'Enable','off');
    set(handles.menuFile_OptSaveAs,'Enable','off');
    set(handles.toolbarButton_Save,'Enable','off');
    set(handles.menuData,'Enable','off');
    set(handles.menuView,'Enable','off');
    set(handles.menuTools_OnCut,'Enable','off');
    set(handles.menuTools_OnCrop,'Enable','off');
    
end
handles.currentElement.saved=true;
handles.currentElement.rawDir=pwd; %Current raw data directory
handles.currentElement.rawFilename='';
handles.currentElement.dir=pwd; %Current dataSource directory
handles.currentElement.filename='';


guidata(f,handles);

%% Make GUI visible
set(f,'Name','Heart Rate Tool');
set(f,'Visible','on');



%% adjustWindowLimits
%Adjust the window zoomed range to both; keep the selected
%sample in view and maintain the desired timeWindow.
function adjustWindowLimits(hObject)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
handles=guidata(hObject);

val=str2num(get(handles.timeWindowEditBox,'String'));
if (isscalar(val) && ~ischar(val) && isreal(val) ...
        && floor(val)==val && val>0)

    
switch(handles.appOptions.timescale)
    case 'milliseconds'
        tW=val;
    case 'seconds'
        tW=val*1000;
    case 'samples'
        activeID=handles.currentElement.data.activeStructured;
        if (activeID==0)
            warndlg('(Structured) Data not found.','guiHRTool');
            return;
        end
        sd=getStructuredData(handles.currentElement.data,activeID);
        sr=get(sd,'SamplingRate');
        tW=(val/sr)*1000;
end

%minIdx=handles.zoomedRange.MinIdx;
%maxIdx=handles.zoomedRange.MaxIdx;
selectedSampleIdx=round(get(handles.timeSlider,'Value'));
timestamps=handles.currentElement.timestamps;
nSamples=get(handles.timeSlider,'Max');

tmpXData=getXData(hObject);

%Case 1: Time window is greater than the whole ECG length
if (tW<tmpXData(1) | tW>tmpXData(end)) %(tmpXData(end)-tmpXData(1))
minIdx=1;
maxIdx=nSamples;

else
    %Case 2: Time window is smaller than the ECG; Select a range around
    %the selected sample
    selectedSampleValue=tmpXData(selectedSampleIdx);
    tmpInitTime=selectedSampleValue-(tW/2);
    tmpEndTime=selectedSampleValue+(tW/2);
    if timestamps(1)>tmpInitTime
        %Case 2.1: The range goes beyond the lower timestamp
        %tmpInitTime=timestamps(1);
        tmpEndTime=tmpXData(1)+tW;
        minIdx=1;
        maxIdx=find(tmpXData>=tmpEndTime,1,'first');
    elseif timestamps(end)<tmpEndTime
        %Case 2.2: The range goes beyond the upper timestamp
        %tmpEndTime=tmpXData(end);
        tmpInitTime=tmpXData(end)-tW;
        minIdx=find(tmpXData>=tmpInitTime,1,'first');
        maxIdx=nSamples;
    else
        %Case 2.3: General case;
        minIdx=find(tmpXData>=tmpInitTime,1,'first');
        maxIdx=find(tmpXData>=tmpEndTime,1,'first');
    end
end

handles.zoomedRange.MinIdx=minIdx;
handles.zoomedRange.MaxIdx=maxIdx;

guidata(hObject,handles);
end %if

end


%% getXData
%Obtains the X axis data for the zoomed axes depending
%on the selected timescale
function xData=getXData(hObject)
handles=guidata(hObject);

activeID=handles.currentElement.data.activeStructured;
if (activeID==0)
    warndlg('(Structured) Data not found.','guiHRTool');
    return;
end
sd=getStructuredData(handles.currentElement.data,activeID);

timestamps=handles.currentElement.timestamps;
switch(handles.appOptions.timescale)
    case 'milliseconds' %milliseconds
        xData=timestamps;
    case 'seconds'
        xData=timestamps/1000;
    case 'samples'
        xData=1:sd.nSamples;
end

end



%% OnAbout callback
%Opens the "About" information window
function OnAbout_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
aboutHRTool;
end


%% OnAddRPeak callback
%Add a new R Peak
function OnAddRPeak_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
activeID=handles.currentElement.data.activeStructured;
if (activeID==0)
    warndlg('(HR) Data not found.','HR Tool');
    return;
end
sd=getStructuredData(handles.currentElement.data,activeID);
selectedSampleIdx=round(get(handles.timeSlider,'Value'));
% tmpXData=getXData(hObject);
% selectedSampleValue=tmpXData(selectedSampleIdx);
% 
% timescale = handles.appOptions.timescale;
% 
% 
found=true; newRPeaksIdx = selectedSampleIdx;
% found=false;
% while ~found
%     prompt = {['New R peaks in ' timescale ' (use '','' ' ...
%         'and '':'' for multiple values):']};
%     dlg_title = 'Add new R peaks';
%     num_lines = 1;
%     def = {num2str(selectedSampleValue)};
%     answer = inputdlg(prompt,dlg_title,num_lines,def);
% 
%     if isempty(answer)
%         %Action cancelled
%         break;
%     else
%         try
%             valsStr = strrep(answer{1},' ','');
%             newRPeaksIdx = [];
%             while ~isempty(valsStr)
%                 tmpIdx = find(valsStr==',',1,'first');
%                 if ~isempty(tmpIdx)
%                     tmpStr = valsStr(1:tmpIdx-1);
%                     valsStr(1:tmpIdx)=[];
%                 else %last one
%                     tmpStr = valsStr;
%                     valsStr=[];
%                 end
%                 newRPeakValue=str2num(tmpStr);
%                 newRPeaksIdx(end+1)=find(tmpXData<=newRPeakValue,1,'last');
%             end
%             
%             if (all(floor(newRPeaksIdx)==newRPeaksIdx) ...
%                     && all(newRPeaksIdx>0) ...
%                     && all(newRPeaksIdx < sd.nSamples) ...
%                     && ~ischar(newRPeaksIdx))
%                 found=true;
%             else
%                 h=warndlg(['Invalid input. ' ...
%                     'The new R peak must be specified ' ...
%                     'in ' timescale '.'],'HR Tool','modal');
%                 waitfor(h);
%             end
%         catch ME
%             h=warndlg(['Invalid input. ' ...
%                 'The new R peak must be specified in the same units you are currently working (' ...
%                 timescale ').'],'HR Tool','modal');
%             waitfor(h);
%         end
%     end
% end

if found
    %Note that this function should only be enable when the
    %RR Mode is manual, so no need to check for that
    currRPeaks=get(sd,'RPeaks');
    sd=set(sd,'RPeaksMode','manual');
    sd=set(sd,'RPeaks',unique([currRPeaks newRPeaksIdx]));
    handles.currentElement.data=...
        setStructuredData(handles.currentElement.data,activeID,sd);
    handles.currentElement.saved=false;
	set(handles.rPeaksModeComboBox,'Value',2); %manual

    guidata(hObject,handles);
    %refreshZoomedAxisRange(hObject);
    refreshAxes(hObject);
end
end



%% OnBasicStatsReport Callback
%Present a report of some basic ECG/RR/BPM measures
function OnBasicStatsReport_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no dataSource currently opened.',...
        'HR Tool','modal');
else
    activeID=handles.currentElement.data.activeStructured;
    if (activeID==0)
        warndlg('(ECG) Data not found.','HR Tool');
        return;
    end
    sd=getStructuredData(handles.currentElement.data,activeID);

    dlg_title = 'ECG - Basic Statistics';

    msg(1)={'\bf BPM:\rm'};
    tmpBPM = getBPM(sd);
    msg(end+1)={['Mean = ' num2str(nanmean(tmpBPM),'%.2f')]};
    msg(end+1)={['SD = ' num2str(nanstd(tmpBPM),'%.2f')]};
    msg(end+1)={['Min = ' num2str(min(tmpBPM),'%.2f')]};
    msg(end+1)={['Max = ' num2str(max(tmpBPM),'%.2f')]};
    
    msg(end+1)={''};
    msg(end+1)={'\bf NN (R to R):\rm'};
    tmpNN = get(sd,'RR');
    msg(end+1)={['Mean = ' num2str(nanmean(tmpNN),'%.2f')]};
    msg(end+1)={['SD = ' num2str(nanstd(tmpNN),'%.2f')]};
    msg(end+1)={'      See also SDNN and SDANN in Time Domain Report'};
    msg(end+1)={['Min = ' num2str(min(tmpNN),'%.2f')]};
    msg(end+1)={['Max = ' num2str(max(tmpNN),'%.2f')]};
    
    
    createMode.WindowStyle = 'non-modal';
    createMode.Interpreter = 'tex';
    hBox = msgbox(msg,dlg_title,createMode);
    set(hBox,'Color','w');

end

end


%% OnBrowse_FromBioHarness callback
%Display an open file dialog and call OnLoad, if
%the action is not cancelled and the file exits.
function OnBrowse_FromBioHarness_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);

[FileName,PathName] = uigetfile('*.csv',...
                    'Select Zephyr BioHarness ECG file');
if isequal(FileName,0)
    %disp('Operation ''Open Zephyr BioHarness ECG file'' cancelled')
else
    try
        %load([PathName, FileName]);
        handles.currentElement.rawDir=PathName;
        handles.currentElement.rawFilename=FileName;
        handles.currentElement.dir='';
        handles.currentElement.filename='';
        rawData=rawData_BioHarnessECG;
        rawData=import(rawData,[PathName, FileName]);
        structuredD=convert(rawData);
        structuredD=set(structuredD,'Description','Raw');
        if (isempty(handles.currentElement.data))
            ds=dataSource;
        else
            ds=handles.currentElement.data;
        end
        ds=setRawData(ds,rawData);
        ds=addStructuredData(ds,structuredD);
        handles.currentElement.data=ds;
        set(f,'Name',[PathName, FileName]);
        guidata(hObject,handles);
        

        OnLoad_Callback(hObject,eventData);
    catch ME
        msg={ME.identifier,'', ME.message};
        warndlg(msg,'guiHRTool');
        return
    end
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
    
    axes(handles.rrAxes)
    cla;
    axes(handles.bpmAxes)
    cla;
    axes(handles.ecgMasterAxes)
    cla;
    axes(handles.ecgAxes)
    cla;
    
    handles.currentElement.data=[]; 
    handles.currentElement.saved=true;
    handles.currentElement.dir=pwd;
    handles.currentElement.filename='';
    handles.currentElement.rawDir=pwd;
    handles.currentElement.rawFilename='';
    set(f,'Name','HRTool');
    
    
    %Make options and fields inactive as appropriate
    set(handles.menuFile_OptClose,'Enable','off');
    set(handles.menuFile_OptSave,'Enable','off');
    set(handles.menuFile_OptSaveAs,'Enable','off');

    set(handles.menuData,'Enable','off');
    set(handles.menuData_OptBasicStatsReport,'Enable','off');
    set(handles.menuData_OptTDReport,'Enable','off');
    set(handles.menuData_OptFDReport,'Enable','off');
    set(handles.menuData_OptFDPlot,'Enable','off');
    set(handles.menuView,'Enable','off');
    set(handles.menuView_OptRPeaks,'Enable','off');
    set(handles.menuView_OptRPeaks,'Checked','off');
    set(handles.menuView_OptRR,'Enable','off');
    set(handles.menuView_OptRR,'Checked','off');
    set(handles.menuView_OptBPM,'Enable','off');
    set(handles.menuView_OptBPM,'Checked','off');
%    set(handles.menuView_OptZoom,'Enable','off');
%    set(handles.menuTools_OptTimeline,'Enable','off');
    set(handles.menuTools_OnCrop,'Enable','off');
    set(handles.menuTools_OnCut,'Enable','off');

    set(handles.toolbarButton_Save,'Enable','off');
%    set(handles.toolbarButton_Zoom,'Enable','off');
%    set(handles.toolbarButton_Timeline,'Enable','off');

    set(handles.timeSlider,'Enable','off');
    set(handles.rPeaksModeComboBox,'Enable','off');
    set(handles.addRPeakButton,'Enable','off');
    set(handles.removeRPeakButton,'Enable','off');
    %set(handles.activeChannelComboBox,'Enable','off');
    set(handles.thresholdEditBox,'Enable','off');
    set(handles.increaseRPeakThresholdButton,'Enable','off');
    set(handles.decreaseRPeakThresholdButton,'Enable','off');

    guidata(hObject,handles);

end

end



%% OnCut callback
%Cut an interval from current data.
%See help structuredData.cut for more info
function OnCut_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
activeID=handles.currentElement.data.activeStructured;
if (activeID==0)
    warndlg('(HR) Data not found.','HR Tool');
    return;
end
sd=getStructuredData(handles.currentElement.data,activeID);

found=false;
while ~found
    prompt = {'Interval init (in samples):','Interval end (in samples):'};
    dlg_title = 'Cut';
    num_lines = 1;
    def = {'1',num2str(sd.nSamples)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);

    if isempty(answer)
        %Action cancelled
        break;
    else
        try
            initIdx=str2num(answer{1});
            endIdx=str2num(answer{2});
            
            if ((isscalar(initIdx) && floor(initIdx)==initIdx ...
                    && initIdx>0 && initIdx < sd.nSamples) ...
                && (isscalar(endIdx) && floor(endIdx)==endIdx ...
                    && endIdx>0 && endIdx < sd.nSamples) ...
                && (initIdx < endIdx))
                found=true;
            else
            h=warndlg(['Invalid input. ' ...
                'Interval must be stated in samples.'],'HR Tool','modal');
            waitfor(h);
                
            end
        catch ME
            h=warndlg(['Invalid input. ' ...
                'Interval must be stated in samples.'],'HR Tool','modal');
            waitfor(h);
        end
    end
end

if found
    sd=cut(sd,initIdx,endIdx);
    handles.currentElement.data=...
        setStructuredData(handles.currentElement.data,activeID,sd);
    handles.currentElement.saved=false;
    guidata(hObject,handles);
    OnLoad_Callback(hObject,eventData)
end
end

%% OnCrop callback
%Crop an interval from current data.
%See help structuredData.crop for more info
function OnCrop_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
activeID=handles.currentElement.data.activeStructured;
if (activeID==0)
    warndlg('(HR) Data not found.','HR Tool');
    return;
end
sd=getStructuredData(handles.currentElement.data,activeID);

found=false;
while ~found
    prompt = {'Interval init (in samples):','Interval end (in samples):'};
    dlg_title = 'Cut';
    num_lines = 1;
    def = {'1',num2str(sd.nSamples)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);

    if isempty(answer)
        %Action cancelled
        break;
    else
        try
            initIdx=str2num(answer{1});
            endIdx=str2num(answer{2});
            
            if ((isscalar(initIdx) && floor(initIdx)==initIdx ...
                    && initIdx>0 && initIdx < sd.nSamples) ...
                && (isscalar(endIdx) && floor(endIdx)==endIdx ...
                    && endIdx>0 && endIdx < sd.nSamples) ...
                && (initIdx < endIdx))
                found=true;
            else
            h=warndlg(['Invalid input. ' ...
                'Interval must be stated in samples.'],'HR Tool','modal');
            waitfor(h);
                
            end
        catch ME
            h=warndlg(['Invalid input. ' ...
                'Interval must be stated in samples.'],'HR Tool','modal');
            waitfor(h);
        end
    end
end

if found
    sd=crop(sd,initIdx,endIdx);
    handles.currentElement.data=...
        setStructuredData(handles.currentElement.data,activeID,sd);
    handles.currentElement.saved=false;
    guidata(hObject,handles);
    OnLoad_Callback(hObject,eventData)
end
end


%% OnDecreaseRPeakThreshold Callback
%Decrease by 1 unit the R peak detection threshold.
function OnDecreaseRPeakThreshold_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
activeID=handles.currentElement.data.activeStructured;
if (activeID==0)
    warndlg('(Structured) Data not found.','guiHRTool');
    return;
end
sd=getStructuredData(handles.currentElement.data,activeID);
set(handles.thresholdEditBox,'String',...
    num2str(max(1,get(sd,'Threshold')-1)));
guidata(hObject,handles);
thresholdEditBox_Callback(hObject,eventData);
end



%% OnFDPlot Callback
%Present a plot of the power spectra of the frequency regions
function OnFDPlot_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no dataSource currently opened.',...
        'HR Tool','modal');
else
    activeID=handles.currentElement.data.activeStructured;
    if (activeID==0)
        warndlg('(ECG) Data not found.','HR Tool');
        return;
    end
    sd=getStructuredData(handles.currentElement.data,activeID);

    options.visualize=true;
    lfhfRatio(sd,options);
end
end



%% OnFDReport Callback
%Present a report of the frequency domain HRV measures
function OnFDReport_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no dataSource currently opened.',...
        'HR Tool','modal');
else
    activeID=handles.currentElement.data.activeStructured;
    if (activeID==0)
        warndlg('(ECG) Data not found.','HR Tool');
        return;
    end
    sd=getStructuredData(handles.currentElement.data,activeID);

    dlg_title = 'HRV - Frequency domain';

    [res,hf,lf,vlf,ulf]=lfhfRatio(sd);

    msg(1)={['HF ==> ' num2str(hf,'%.2f') ' ms^2']};
    msg(end+1)={''};
    msg(end+1)={['LF ==> ' num2str(lf,'%.2f') ' ms^2']};
    msg(end+1)={''};
    msg(end+1)={['VLF ==> ' num2str(vlf,'%.2f') ' ms^2']};
    msg(end+1)={''};
    msg(end+1)={['ULF ==> ' num2str(ulf,'%.2f') ' ms^2']};
    msg(end+1)={'  Only valid for long measurements (24h).'};
    msg(end+1)={''};
    msg(end+1)={['LF/HF ratio ==> ' num2str(res,'%.2f')]};
    msg(end+1)={''};
    msg(end+1)={''};
    msg(end+1)={['Power spectra is computed as the ' ...
                 'single sided amplitudes of the FFT.']};
    
    hBox = msgbox(msg,dlg_title);
    set(hBox,'Color','w');

end

end


%% OnIncreaseRPeakThreshold Callback
%Increase by 1 unit the R peak detection threshold.
function OnIncreaseRPeakThreshold_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
activeID=handles.currentElement.data.activeStructured;
if (activeID==0)
    warndlg('(Structured) Data not found.','guiHRTool');
    return;
end
sd=getStructuredData(handles.currentElement.data,activeID);
set(handles.thresholdEditBox,'String',num2str(get(sd,'Threshold')+1));
guidata(hObject,handles);
thresholdEditBox_Callback(hObject,eventData);
end


%% OnLoad callback
%Converts data to a structured data and plot the data afresh.
function OnLoad_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles  = guidata(hObject);
activeID = handles.currentElement.data.activeStructured;
if (activeID==0)
    warndlg('(Structured) Data not found.','guiHRTool');
    return;
end
sd = getStructuredData(handles.currentElement.data,activeID);

%%% Support for multi-channel unfinshed.
% %Refresh the available channels
% tmpNChannels = sd.nChannels;
% validTypes={};
% for iCh=1:tmpNChannels
%     validTypes(iCh)={num2str(iCh)};
% end
% currValue=1;
% set(handles.activeChannelComboBox,'String',validTypes);
% set(handles.activeChannelComboBox,'Value',currValue);
% set(handles.activeChannelComboBox,'Enable','on');
% data = sd.data(:,get(handles.activeChannelComboBox,'Value'),1);

data = sd.data;

rPeaks = get(sd,'RPeaks');
rr = get(sd,'RR');
bpm = getBPM(sd);
timestamps = get(sd,'Timestamps');

handles.currentElement.timestamps=timestamps;
guidata(hObject,handles);

%paint the stuff...
fontSize=handles.appOptions.fontSize;
lineWidth=handles.appOptions.lineWidth;

selectedSampleIdx=floor(sd.nSamples/2);
tmpXData=getXData(hObject);
selectedSampleValue=tmpXData(selectedSampleIdx);

set(handles.rPeaksModeComboBox,'Enable','on');
set(handles.rPeaksAlgoComboBox,'Enable','on');
set(handles.thresholdEditBox,'String',num2str(get(sd,'Threshold')));
switch(get(sd,'RPeaksMode'))
    case 'auto'
	set(handles.timescaleComboBox,'Value',1); %auto mode
    set(handles.rPeaksModeComboBox,'Value',1);
    case 'manual'
	set(handles.timescaleComboBox,'Value',2); %manual mode
	set(handles.rPeaksModeComboBox,'Value',2);
    set(handles.addRPeakButton,'Enable','on');
	set(handles.removeRPeakButton,'Enable','on');
    set(handles.thresholdEditBox,'Enable','on');
    set(handles.increaseRPeakThresholdButton,'Enable','on');
    set(handles.decreaseRPeakThresholdButton,'Enable','on');
end
guidata(hObject,handles);

% %%By default show only 100 secs worth of time
% tW=100*1000;
% set(handles.timescaleComboBox,'Value',1); %milliseconds
% set(handles.timeWindowEditBox,'String',num2str(tW));

%%By default show full signal
tW=sd.nSamples;
set(handles.timescaleComboBox,'Value',1); %samples
set(handles.timeWindowEditBox,'String',num2str(timestamps(end)));

% if timestamps(selectedSampleIdx)+tW<=timestamps(end)
%     tmpEndSampleIdx=...
%         find(timestamps<=timestamps(selectedSampleIdx)+tW,1,'last');
% else
%     tmpEndSampleIdx=length(timestamps);
% end
%handles.zoomedRange.MinIdx=selectedSampleIdx;
%handles.zoomedRange.MaxIdx=tmpEndSampleIdx;
handles.zoomedRange.MinIdx=1;
handles.zoomedRange.MaxIdx=sd.nSamples;
zoomedMinValue=tmpXData(handles.zoomedRange.MinIdx);
zoomedMaxValue=tmpXData(handles.zoomedRange.MaxIdx);

guidata(hObject,handles);

nMarkers=sd.nSignals;
if nMarkers>1
    warndlg(['Unexpected number of signals. ' ...
            'Using first signal as ECG data.']);
end

%---------------------
%ECG
%---------------------

%Master
nSamples=sd.nSamples;
axes(handles.ecgMasterAxes);
cla;

h(1)=line('XData',1:nSamples,...
        'YData',data,...
        'LineStyle','-','LineWidth',lineWidth,...
        'Color','b');
    
ylim=axis;
tmp=[zoomedMinValue ylim(3);...
     zoomedMinValue ylim(4);...
     zoomedMaxValue ylim(4);...
     zoomedMaxValue ylim(3)];
h(2)=patch(tmp(:,1),tmp(:,2),[1 1 0],...
    'FaceAlpha',0.3,...
    'EdgeColor',[0 1 0],'LineWidth',lineWidth);
handles.ecgMasterAxesHandles=h;
guidata(hObject,handles);
clear h
set(handles.ecgMasterAxes,'XLim',[1 nSamples]);

%Zoomed ECG axes    
axes(handles.ecgAxes);
cla;
% h=line('XData',tmpXData(selectedSampleIdx:tmpEndSampleIdx),...
%     'YData',data(selectedSampleIdx:tmpEndSampleIdx),...
%     'LineStyle','-','LineWidth',lineWidth,...
%     'Color','b');
h=line('XData',tmpXData,...
    'YData',data,...
    'LineStyle','-','LineWidth',lineWidth,...
    'Color','b');
handles.ecgAxesHandles=h;
guidata(hObject,handles);
clear h
grid(handles.ecgAxes,'on');
% set(handles.ecgAxes,'XLim',...
%     [tmpXData(selectedSampleIdx) tmpXData(tmpEndSampleIdx)]);


%hold on
%rPeaks(rPeaks>tmpEndSampleIdx)=[];
%rPeaks(rPeaks<selectedSampleIdx)=[];
rPeaksSampleValues=tmpXData(rPeaks);
ylim=get(handles.ecgAxes,'YLim');
h=line('XData',rPeaksSampleValues,...
    'YData',(min(data(handles.zoomedRange.MinIdx:handles.zoomedRange.MaxIdx))+...
                0.95*(max(data(handles.zoomedRange.MinIdx:handles.zoomedRange.MaxIdx))...
                     -min(data(handles.zoomedRange.MinIdx:handles.zoomedRange.MaxIdx))))...
                *ones(length(rPeaksSampleValues),1),...
    'Color','r',...
    'LineStyle','none',...
    'LineWidth',lineWidth,...
    'Marker','d',...
    'MarkerSize',9,...
    'MarkerFaceColor','r',...
    'Visible','off');
handles.rPeaksECGAxesHandles=h;
guidata(hObject,handles);
clear h

%---------------------
%R to R intervals and BPM
%---------------------
%%These two axes share the timescale with the zoomed ECG axes
axes(handles.rrAxes);
cla;
% h=line('XData',tmpXData(selectedSampleIdx:tmpEndSampleIdx),...
%     'YData',rr(selectedSampleIdx:tmpEndSampleIdx),...
%     'LineStyle','-','LineWidth',lineWidth,...
%     'Color','m');
h=line('XData',tmpXData,...
    'YData',rr,...
    'LineStyle','-','LineWidth',lineWidth,...
    'Color','m');
handles.rrAxesHandles=h;
guidata(hObject,handles);
grid(handles.rrAxes,'on');
clear h
% set(handles.rrAxes,'XLim',...
%     [tmpXData(selectedSampleIdx) tmpXData(tmpEndSampleIdx)]);


axes(handles.bpmAxes);
cla;
% h=line('XData',tmpXData(selectedSampleIdx:tmpEndSampleIdx),...
%     'YData',bpm(selectedSampleIdx:tmpEndSampleIdx),...
%     'LineStyle','-','LineWidth',lineWidth,...
%     'Color','r');
h=line('XData',tmpXData,...
    'YData',bpm,...
    'LineStyle','-','LineWidth',lineWidth,...
    'Color','r');
handles.bpmAxesHandles=h;
guidata(hObject,handles);
grid(handles.bpmAxes,'on');
clear h
%set(handles.bpmAxes,'XLim',...
%    [tmpXData(selectedSampleIdx) tmpXData(tmpEndSampleIdx)]);

set(handles.ecgAxes,'XLim',...
    [tmpXData(handles.zoomedRange.MinIdx) tmpXData(handles.zoomedRange.MaxIdx)]);
    %Note that the bpmAxes an the rrAxes are linked


%---------------------
%Temporal Navigation Slider
%---------------------
%Adjust slider limits
set(handles.timeSlider,'Max',...
    max(1,sd.nSamples));
set(handles.timeSlider,'Value',selectedSampleIdx);
set(handles.timeSlider,...
    'SliderStep',[1/get(handles.timeSlider,'Max') 0.1]);
set(handles.timeSliderText,'String',...
    ['Time [' handles.appOptions.timescale '] (' ...
      num2str(selectedSampleValue,'%.2f') ')']);


%Print slider guides
axes(handles.ecgAxes);
ylim=get(handles.ecgAxes,'YLim');
h=line('XData',[selectedSampleValue selectedSampleValue],...
    'YData',[ylim(1) ylim(2)],...
    'Color','k',...
    'LineWidth',lineWidth);
handles.timeSliderGuide.ECG=h;
clear h ylim

axes(handles.rrAxes);
ylim=get(handles.rrAxes,'YLim');
h=line('XData',[selectedSampleValue selectedSampleValue],...
    'YData',[ylim(1) ylim(2)],...
    'Color','k',...
    'LineWidth',lineWidth);
handles.timeSliderGuide.RR=h;
clear h ylim

axes(handles.bpmAxes);
ylim=get(handles.bpmAxes,'YLim');
h=line('XData',[selectedSampleValue selectedSampleValue],...
    'YData',[ylim(1) ylim(2)],...
    'Color','k',...
    'LineWidth',lineWidth);
handles.timeSliderGuide.BPM=h;
clear h ylim

%Make options and fields active as appropriate
set(handles.menuFile_OptClose,'Enable','on');
set(handles.menuFile_OptSave,'Enable','on');
set(handles.menuFile_OptSaveAs,'Enable','on');

set(handles.menuData,'Enable','on');
set(handles.menuData_OptBasicStatsReport,'Enable','on');
set(handles.menuData_OptTDReport,'Enable','on');
set(handles.menuData_OptFDReport,'Enable','on');
set(handles.menuData_OptFDPlot,'Enable','on');

set(handles.menuView,'Enable','on');
set(handles.menuView_OptRPeaks,'Enable','on');
set(handles.menuView_OptRPeaks,'Checked','on');
    set(handles.rPeaksECGAxesHandles,'Visible','on');
set(handles.menuView_OptRR,'Enable','on');
set(handles.menuView_OptRR,'Checked','on');
set(handles.menuView_OptBPM,'Enable','on');
set(handles.menuView_OptBPM,'Checked','on');
%set(handles.menuView_OptZoom,'Enable','on');
%set(handles.menuTools_OptTimeline,'Enable','on');
set(handles.menuTools_OnCrop,'Enable','on');
set(handles.menuTools_OnCut,'Enable','on');

set(handles.toolbarButton_Save,'Enable','on');
%set(handles.toolbarButton_Zoom,'Enable','on');
%set(handles.toolbarButton_Timeline,'Enable','on');

set(handles.timeSlider,'Enable','on');

guidata(hObject,handles);

end


%% OnOpen callback
%Opens an existing aurora measuringTracking data file
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
    %Look for an 'dataSource' variable
    for ii=1:length(vars)
        tmp=vars{ii};
        if(isa(tmp,'dataSource'))
            break;
        end
    end
    if (isa(tmp,'dataSource'))
        handles=guidata(hObject);
        handles.currentElement.data=dataSource(tmp);
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
            'any dataSource.'],...
            'Open Failed','modal');
    end
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
handles.appOptions=guiHROptions(handles.appOptions);

%Apply new options
if (~isempty(handles.currentElement.data))
if tmpCurrentOptions.fontSize~=handles.appOptions.fontSize
    set(handles.ecgAxes,'FontSize',handles.appOptions.fontSize);
    set(handles.rrAxes,'FontSize',handles.appOptions.fontSize);
    set(handles.bpmAxes,'FontSize',handles.appOptions.fontSize);
end


if tmpCurrentOptions.lineWidth~=handles.appOptions.lineWidth
    set(handles.ecgAxesHandles,...
        'LineWidth',handles.appOptions.lineWidth);
    set(handles.rrAxesHandles,...
        'LineWidth',handles.appOptions.lineWidth);
    set(handles.bpmAxesHandles,...
        'LineWidth',handles.appOptions.lineWidth);

    set(handles.timeSliderGuide.ECG,...
        'LineWidth',handles.appOptions.lineWidth);
    set(handles.timeSliderGuide.RR,...
        'LineWidth',handles.appOptions.lineWidth);
    set(handles.timeSliderGuide.BPM,...
        'LineWidth',handles.appOptions.lineWidth);
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

if exist('element','var') & isa(element,'ecg')
    % De-encapsulate the ecg into a dataSource so that guiHR can handle it.
    ds=handles.currentElement.data;
    element = getStructuredData(ds,get(ds,'ActiveStructured'));
else
    element = handles.currentElement.data;
end

OnClose_Callback(hObject,eventData);
delete(get(gcf,'Children'));
delete(gcf);
end



%% OnRemoveRPeak callback
%Removes an existing R Peak
function OnRemoveRPeak_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
activeID=handles.currentElement.data.activeStructured;
if (activeID==0)
    warndlg('(HR) Data not found.','HR Tool');
    return;
end
sd=getStructuredData(handles.currentElement.data,activeID);
selectedSampleIdx=round(get(handles.timeSlider,'Value'));
% tmpXData=getXData(hObject);
% selectedSampleValue=tmpXData(selectedSampleIdx);
% 
% timescale = handles.appOptions.timescale;
% 
 found=true; rPeaksIdx = selectedSampleIdx;
% found=false;
% while ~found
%     prompt = {['R peaks locations in ' timescale ' (use '','' ' ...
%         'and '':'' for multiple values):']};
%     dlg_title = 'Remove R peaks';
%     num_lines = 1;
%     def = {num2str(selectedSampleValue)};
%     answer = inputdlg(prompt,dlg_title,num_lines,def);
% 
%     if isempty(answer)
%         %Action cancelled
%         break;
%     else
%         try
%             valsStr = strrep(answer{1},' ','');
%             rPeaksIdx = [];
%             while ~isempty(valsStr)
%                 tmpIdx = find(valsStr==',',1,'first');
%                 if ~isempty(tmpIdx)
%                     tmpStr = valsStr(1:tmpIdx-1);
%                     valsStr(1:tmpIdx)=[];
%                 else %last one
%                     tmpStr = valsStr;
%                     valsStr=[];
%                 end
%                 rPeakValue=str2num(tmpStr);
%                 rPeaksIdx(end+1)=find(tmpXData<=rPeakValue,1,'last');
%             end
%             
%             if (all(floor(rPeaksIdx)==rPeaksIdx) ...
%                     && all(rPeaksIdx>0) ...
%                     && all(rPeaksIdx < sd.nSamples) ...
%                     && ~ischar(rPeaksIdx))
%                 found=true;
%             else
%             h=warndlg(['Invalid input. ' ...
%                 'The R peak location must be specified in ' timescale '.'],...
%                 'HR Tool','modal');
%                 waitfor(h);
%                 
%             end
%         catch ME
%             h=warndlg(['Invalid input. ' ...
%                 'The R peak location must be specified in ' timescale '.'],...
% 		'HR Tool','modal');
%             waitfor(h);
%         end
%     end
% end

if found
    %Note that this function should only be enable when the
    %RR Mode is manual, so no need to check for that
    currRPeaks=get(sd,'RPeaks');
    sd=set(sd,'RPeaksMode','manual');
    sd=set(sd,'RPeaks',setdiff(currRPeaks,rPeaksIdx));
    handles.currentElement.data=...
       setStructuredData(handles.currentElement.data,activeID,sd);
    handles.currentElement.saved=false;
	set(handles.rPeaksModeComboBox,'Value',2); %manual
    guidata(hObject,handles);
    %refreshZoomedAxisRange(hObject);
    refreshAxes(hObject);
end
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
        theData=dataSource(handles.currentElement.data);
        element = handles.currentElement.data;
        
        save([handles.currentElement.dir, ...
              handles.currentElement.filename],'theData');
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
        theData=dataSource(handles.currentElement.data);
        save([PathName, FileName],'theData');
        handles.currentElement.saved=true;
        handles.currentElement.dir=PathName;
        handles.currentElement.filename=FileName;
        guidata(hObject,handles);
    end
end

end



%% OnSplit callback
%Split into parts according to an fNIRS (ETG-4000) recording
function OnSplit_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
activeID=handles.currentElement.data.activeStructured;
if (activeID==0)
    warndlg('(HR) Data not found.','HR Tool');
    return;
end
sd=getStructuredData(handles.currentElement.data,activeID);

guiSplitECG(sd);

end





%% OnTDReport Callback
%Present a report of the time domain HRV measures
function OnTDReport_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no dataSource currently opened.',...
        'HR Tool','modal');
else
    activeID=handles.currentElement.data.activeStructured;
    if (activeID==0)
        warndlg('(ECG) Data not found.','HR Tool');
        return;
    end
    sd=getStructuredData(handles.currentElement.data,activeID);

    dlg_title = 'HRV - Time Domain';

    msg(1)={['SDNN ==> ' num2str(sdnn(sd),'%.2f')]};
    msg(end+1)={''};
    tmp=num2str(sdann(sd),'%.2f, ');
    tmp(end-1:end)=[]; %Remove the last comma and space
    tmp=['[' tmp ']'];
    msg(end+1)={['SDANN ==> ' tmp]};
    msg(end+1)={'   (over 5 min period)'};
    msg(end+1)={''};
    msg(end+1)={['RMSSD ==> ' num2str(rmssd(sd),'%.2f')]};
    msg(end+1)={''};
    msg(end+1)={['NN50 ==> ' num2str(nn50(sd),'%.2f')]};
    msg(end+1)={''};
    msg(end+1)={['pNN50 ==> ' num2str(pnn50(sd),'%.2f')]};
    msg(end+1)={''};
    msg(end+1)={''};
    msg(end+1)={'NN intervals are computed as R to R intervals.'};
    
    hBox = msgbox(msg,dlg_title);
    set(hBox,'Color','w');

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
        'HR Tool','modal');
else
    activeID=handles.currentElement.data.activeStructured;
    if (activeID==0)
        warndlg('(ECG) Data not found.','HR Tool');
        return;
    end
    tM=getStructuredData(handles.currentElement.data,activeID);
    t=get(tM,'Timeline');
    t=guiTimeline(t,'setTimelineLength','off');
    if ~isempty(t)
        tM=set(tM,'Timeline',t);
        handles.currentElement.data=...
            setStructuredData(handles.currentElement.data,activeID,tM);
        handles.currentElement.saved=false;
        guidata(hObject,handles);
    end
end
end



% %% mouseScrollZoom callback
% %NOT YET WORKING
% %Zoom in/out around the selected sample from mouse roll up/down on axes
% function mouseScrollZoom(hObject,eventData,gca)
% % hObject - Handle of the object, e.g., the GUI component,
% %   for which the callback was triggered.  See GCBO
% % eventdata - Reserved for later use.
% 
% handles = guidata(f);
% 
% activeID=handles.currentElement.data.activeStructured;
% if (activeID==0)
%     warndlg('(Structured) Data not found.','guiHRTool');
%     return;
% end
% sd=getStructuredData(handles.currentElement.data,activeID);
% 
% 
% selectedSampleIdx=round(get(handles.timeSlider,'Value'));
% set(handles.timeSlider,'Value',selectedSampleIdx);
% guidata(hObject,handles);
% OnUpdateSlider_Callback(hObject);
% 
% 
% 
% axes(gca)
% if (eventData.VerticalScrollCount>0),
%     % scroll down
%     %disp('Scroll Up')
%     zoom('xon')
%     zoom(1/10)
%     zoom('off')
% else
%     % scroll up
%     %disp('Scroll Down')
%     zoom('xon')
%     zoom(10)
%     zoom('off')
% end
% 
% 
% guidata(hObject,handles);
% 
% 
% xlim = get(gca,'XLim');
% set(handles.timeWindowEditBox,'String',num2str(xlim(2)-xlim(1)));
% guidata(hObject,handles);
% 
% 
% 
% end


%% updateCurrentSample callback
%Update current sample from mouse click on axes
function updateCurrentSample(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles = guidata(f);

activeID=handles.currentElement.data.activeStructured;
if (activeID==0)
    warndlg('(Structured) Data not found.','guiHRTool');
    return;
end
sd=getStructuredData(handles.currentElement.data,activeID);

coord = get(hObject, 'CurrentPoint');
pts = coord(1,1:2);
% disp(['Mouse clicked at ' num2str(pts(1))])
% disp(num2str(get(handles.timeSlider,'Value')))

samplingRate = get(sd,'SamplingRate');

%Translate value to sample
switch(handles.appOptions.timescale)
    case 'milliseconds' %milliseconds
       val=pts(1)*samplingRate/1000;
    case 'seconds'
       val=pts(1)*samplingRate;
    case 'samples'
       val=pts(1); %No need to convert
end
%val=handles.zoomedRange.MinIdx+round(val);
val=round(val);
%and ensure it stays within limits
val = min(max(1,val),length(handles.currentElement.timestamps));

set(handles.timeSlider,'Value',val);
% disp(handles.timeSlider)
% disp(num2str(get(handles.timeSlider,'Value')))
guidata(hObject,handles);
OnUpdateSlider_Callback(hObject);
end

%% OnUpdateSlider callback
%Select a different sample.
function OnUpdateSlider_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles = guidata(f);
selectedSampleIdx=round(get(handles.timeSlider,'Value'));

timescale=handles.appOptions.timescale;
tmpXData=getXData(hObject);
selectedSampleValue=tmpXData(selectedSampleIdx);

set(handles.timeSliderText,'String',...
        ['Time [' timescale '] (' ...
        num2str(selectedSampleValue,'%.2f') ')']);

%Refresh data if necessary
minIdx=handles.zoomedRange.MinIdx;
maxIdx=handles.zoomedRange.MaxIdx;
if selectedSampleIdx<minIdx
    tmpDiff=maxIdx-minIdx;
    handles.zoomedRange.MinIdx=selectedSampleIdx;
    handles.zoomedRange.MaxIdx=selectedSampleIdx+tmpDiff;
elseif selectedSampleIdx>maxIdx
    tmpDiff=maxIdx-minIdx;
    handles.zoomedRange.MaxIdx=selectedSampleIdx;
    handles.zoomedRange.MinIdx=selectedSampleIdx-tmpDiff;
end
zoomedMinValue=tmpXData(handles.zoomedRange.MinIdx);
zoomedMaxValue=tmpXData(handles.zoomedRange.MaxIdx);

guidata(hObject,handles);
refreshZoomedAxisRange(hObject);


%Update slider guides
ylim=get(handles.ecgMasterAxes,'YLim');
tmp=[zoomedMinValue ylim(1);...
     zoomedMinValue ylim(2);...
     zoomedMaxValue ylim(2);...
     zoomedMaxValue ylim(1)];
set(handles.ecgMasterAxesHandles(2),...
    'XData',tmp(:,1),...
    'YData',tmp(:,2));

ylim=get(handles.ecgAxes,'YLim');
set(handles.timeSliderGuide.ECG,...
    'XData',[selectedSampleValue selectedSampleValue],...
    'YData',[ylim(1) ylim(2)]);

ylim=get(handles.rrAxes,'YLim');
set(handles.timeSliderGuide.RR,...
    'XData',[selectedSampleValue selectedSampleValue],...
    'YData',[ylim(1) ylim(2)]);

ylim=get(handles.bpmAxes,'YLim');
set(handles.timeSliderGuide.BPM,...
    'XData',[selectedSampleValue selectedSampleValue],...
    'YData',[ylim(1) ylim(2)]);

guidata(hObject,handles);
drawnow
end


%% OnView RR Callback
%Hide/Unhide R to R intervals
function OnViewRR_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles = guidata(f);
if strcmp(get(handles.menuView_OptRR,'Checked'),'on')
    set(handles.menuView_OptRR,'Checked','off');
    set(handles.rrAxesHandles,'Visible','off');
else
    set(handles.menuView_OptRR,'Checked','on');
    set(handles.rrAxesHandles,'Visible','on');
end
guidata(hObject,handles);
end

%% OnView RPeaks Callback
%Hide/Unhide R peak detection
function OnViewRPeaks_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles = guidata(f);
if strcmp(get(handles.menuView_OptRPeaks,'Checked'),'on')
    set(handles.menuView_OptRPeaks,'Checked','off');
    set(handles.rPeaksECGAxesHandles,'Visible','off');
else
    set(handles.menuView_OptRPeaks,'Checked','on');
    set(handles.rPeaksECGAxesHandles,'Visible','on');
end
guidata(hObject,handles);
end

%% OnView BPM Callback
%Hide/Unhide Marker 2
function OnViewBPM_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles = guidata(f);
if strcmp(get(handles.menuView_OptBPM,'Checked'),'on')

    set(handles.menuView_OptBPM,'Checked','off');
    set(handles.bpmAxesHandles,'Visible','off');
else
    set(handles.menuView_OptBPM,'Checked','on');
    set(handles.bpmAxesHandles,'Visible','on');
end
guidata(hObject,handles);
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
    zoom on
end
guidata(hObject,handles);
end


%% rPeaksModeComboBox Callback
%Updates the option R peaks maintenance mode
function rPeaksModeComboBox_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
val=get(handles.rPeaksModeComboBox,'Value');

activeID=handles.currentElement.data.activeStructured;
if (activeID==0)
    warndlg('(Structured) Data not found.','guiHRTool');
    return;
end
sd=getStructuredData(handles.currentElement.data,activeID);

switch(val)
    case 1 %'auto'
        sd=set(sd,'RPeaksMode','auto');
        handles.currentElement.data=...
            setStructuredData(handles.currentElement.data,activeID,sd);
        handles.currentElement.saved=false;
        set(handles.addRPeakButton,'Enable','off');
        set(handles.removeRPeakButton,'Enable','off');
        set(handles.thresholdEditBox,'Enable','off');
        set(handles.increaseRPeakThresholdButton,'Enable','off');
        set(handles.decreaseRPeakThresholdButton,'Enable','off');
        guidata(hObject,handles);
        refreshZoomedAxisRange(hObject);
    case 2 %'manual'
        sd=set(sd,'RPeaksMode','manual');
        handles.currentElement.data=...
            setStructuredData(handles.currentElement.data,activeID,sd);
        %No need to repaint, just enable buttons to add/remove peaks
        set(handles.addRPeakButton,'Enable','on');
        set(handles.removeRPeakButton,'Enable','on');
        set(handles.thresholdEditBox,'Enable','on');
        set(handles.increaseRPeakThresholdButton,'Enable','on');
        set(handles.decreaseRPeakThresholdButton,'Enable','on');
        guidata(hObject,handles);
    otherwise
        warndlg('Unexpected R peaks maintenance mode.');
end
set(handles.thresholdEditBox,'String',num2str(get(sd,'Threshold')));
guidata(hObject,handles);
end


%% rPeaksAlgoComboBox Callback
%Updates the option R peaks detection algorithm
function rPeaksAlgoComboBox_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
val=get(handles.rPeaksAlgoComboBox,'Value');

activeID=handles.currentElement.data.activeStructured;
if (activeID==0)
    warndlg('(Structured) Data not found.','guiHRTool');
    return;
end
sd=getStructuredData(handles.currentElement.data,activeID);

handles.currentElement.saved=false;
switch(val)
    case 1 %'LoG'
        sd=set(sd,'RPeaksAlgo','LoG');
        handles.currentElement.data=...
            setStructuredData(handles.currentElement.data,activeID,sd);
        set(handles.thresholdEditBox,'Enable','on');
        set(handles.increaseRPeakThresholdButton,'Enable','on');
        set(handles.decreaseRPeakThresholdButton,'Enable','on');
        guidata(hObject,handles);
        refreshZoomedAxisRange(hObject);
    case 2 %'Chen2017'
        sd=set(sd,'RPeaksAlgo','Chen2017');
        handles.currentElement.data=...
            setStructuredData(handles.currentElement.data,activeID,sd);
        %No need to repaint, just disable buttons to control threshold
        set(handles.thresholdEditBox,'Enable','off');
        set(handles.increaseRPeakThresholdButton,'Enable','off');
        set(handles.decreaseRPeakThresholdButton,'Enable','off');
        guidata(hObject,handles);
    otherwise
        warndlg('Unexpected R peaks detection algorithm.');
end
set(handles.thresholdEditBox,'String',num2str(get(sd,'Threshold')));
guidata(hObject,handles);
end




%% timescaleComboBox Callback
%Updates the option timescale
function timescaleComboBox_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);

activeID=handles.currentElement.data.activeStructured;
if (activeID==0)
    warndlg('(Structured) Data not found.','guiHRTool');
    return;
end
sd=getStructuredData(handles.currentElement.data,activeID);
sr=get(sd,'SamplingRate');


val=get(handles.timescaleComboBox,'Value');
tW=str2num(get(handles.timeWindowEditBox,'String'));
tmpPreviousTimescale=handles.appOptions.timescale;
%minIdx=handles.zoomedRange.MinIdx;
%maxIdx=handles.zoomedRange.MaxIdx;
%timestamps=handles.currentElement.timestamps;
%tmpXData=getXData(hObject);

switch(val)
    case 1
        handles.appOptions.timescale='milliseconds';
        switch (tmpPreviousTimescale)
            case 'seconds' %Convert from seconds to milliseconds
                tW=tW*1000;
            case 'samples' %Convert from samples to milliseconds
                tW=(tW/sr)*1000;%tmpXData(maxIdx)-tmpXData(minIdx);
        end
    case 2
        handles.appOptions.timescale='seconds';
        switch (tmpPreviousTimescale)
            case 'milliseconds' %Convert from milliseconds to seconds
                tW=tW/1000;
            case 'samples' %Convert from samples to seconds
                tW=tW/sr;%(tmpXData(maxIdx)-tmpXData(minIdx))/1000;
        end
    case 3
        handles.appOptions.timescale='samples';
        
        switch (tmpPreviousTimescale)
            case 'seconds'  %Convert from seconds to samples
                tW=tW*sr;
            case 'milliseconds'  %Convert from milliseconds to samples
                tW=(tW/1000)*sr;
        end
        
    otherwise
        warndlg('Unexpected timescale.');
        set(handles.timescaleComboBox,'Value',1);
end
%tW=floor(tW);
set(handles.timeWindowEditBox,'String',num2str(tW));
guidata(hObject,handles);
refreshAxes(hObject,eventData)

end

%% thresholdEditBox Callback
%Updates the R peak detection threshold
function thresholdEditBox_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);

%Temporally disable these
%tmpactivechannel=get(handles.activeChannelComboBox,'Enable');
tmpadd=get(handles.addRPeakButton,'Enable');
tmpremove=get(handles.removeRPeakButton,'Enable');
tmpthreshold=get(handles.thresholdEditBox,'Enable');
tmpincrease=get(handles.increaseRPeakThresholdButton,'Enable');
tmpdecrease=get(handles.decreaseRPeakThresholdButton,'Enable');

%set(handles.activeChannelComboBox,'Enable','off');
set(handles.addRPeakButton,'Enable','off');
set(handles.removeRPeakButton,'Enable','off');
set(handles.thresholdEditBox,'Enable','off');
set(handles.increaseRPeakThresholdButton,'Enable','off');
set(handles.decreaseRPeakThresholdButton,'Enable','off');
guidata(hObject,handles);
    

activeID=handles.currentElement.data.activeStructured;
if (activeID==0)
    warndlg('(HR) Data not found.','HR Tool');
    return;
end
sd=getStructuredData(handles.currentElement.data,activeID);

val=str2num(get(handles.thresholdEditBox,'String'));
if (isscalar(val) && ~ischar(val) && isreal(val) ...
        && val>0)
    sd=set(sd,'Threshold',val);
    handles.currentElement.data=...
        setStructuredData(handles.currentElement.data,activeID,sd);
    handles.currentElement.saved=false;
    guidata(hObject,handles);
    refreshZoomedAxisRange(hObject);
else
    warndlg(['ICNA:guiHR:thresholdEditBox_Callback ' ...
        'Invalid threshold. Threshold must be a positive scalar.']);
end

%and back to its previuos state
%set(handles.activeChannelComboBox,'Enable',tmpactivechannel);
set(handles.addRPeakButton,'Enable',tmpadd);
set(handles.removeRPeakButton,'Enable',tmpremove);
set(handles.thresholdEditBox,'Enable',tmpthreshold);
set(handles.increaseRPeakThresholdButton,'Enable',tmpincrease);
set(handles.decreaseRPeakThresholdButton,'Enable',tmpdecrease);
guidata(hObject,handles);

end


%% timeWindowEditBox Callback
%Updates the option timeWindow
function timeWindowEditBox_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
val=str2num(get(handles.timeWindowEditBox,'String'));
if (isscalar(val) && ~ischar(val) && isreal(val) ...
        && floor(val)==val && val>0)
    adjustWindowLimits(hObject);
    refreshZoomedAxisRange(hObject);
    OnUpdateSlider_Callback(hObject,eventData)

else
    warndlg(['ICNA:guiHR:timeWindowEditBox_Callback' ...
        'Invalid time window.']);
end

end




%% refreshAxes
%Redraw the axes.
function refreshAxes(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles = guidata(f);

activeID=handles.currentElement.data.activeStructured;
if (activeID==0)
    warndlg('(Structured) Data not found.','guiHRTool');
    return;
end
sd=getStructuredData(handles.currentElement.data,activeID);
data=get(sd,'Data');
rPeaks=get(sd,'RPeaks');
rr=get(sd,'RR');
bpm=getBPM(sd);

tmpXData=getXData(hObject);
rPeaksSampleValues=tmpXData(rPeaks);

selectedSampleIdx=round(get(handles.timeSlider,'Value'));
selectedSampleValue=tmpXData(selectedSampleIdx);


fontSize=handles.appOptions.fontSize;
lineWidth=handles.appOptions.lineWidth;

set(handles.ecgAxesHandles,...
    'XData',tmpXData,...
	'YData',data)
guidata(hObject,handles);

set(handles.rPeaksECGAxesHandles,...
    'XData',rPeaksSampleValues,...
	'YData',(min(data(handles.zoomedRange.MinIdx:handles.zoomedRange.MaxIdx))+...
                0.95*(max(data(handles.zoomedRange.MinIdx:handles.zoomedRange.MaxIdx))...
                     -min(data(handles.zoomedRange.MinIdx:handles.zoomedRange.MaxIdx))))...
                *ones(length(rPeaksSampleValues),1))
guidata(hObject,handles);

ylim=get(handles.ecgAxes,'YLim');
set(handles.timeSliderGuide.ECG,...
    'XData',[selectedSampleValue selectedSampleValue],...
	'YData',[ylim(1) ylim(2)])
guidata(hObject,handles);


set(handles.rrAxesHandles,...
    'XData',tmpXData,...
	'YData',rr)
guidata(hObject,handles);
ylim=get(handles.rrAxes,'YLim');
set(handles.timeSliderGuide.RR,...
    'XData',[selectedSampleValue selectedSampleValue],...
	'YData',[ylim(1) ylim(2)])
guidata(hObject,handles);

set(handles.bpmAxesHandles,...
    'XData',tmpXData,...
	'YData',bpm)
guidata(hObject,handles);

ylim=get(handles.bpmAxes,'YLim');
set(handles.timeSliderGuide.BPM,...
    'XData',[selectedSampleValue selectedSampleValue],...
	'YData',[ylim(1) ylim(2)])
guidata(hObject,handles);


minVal=tmpXData(handles.zoomedRange.MinIdx);
maxVal=tmpXData(handles.zoomedRange.MaxIdx);
set(handles.ecgAxes,'XLim',[minVal maxVal])
guidata(hObject,handles);

%Keep the link
%linkaxes([handles.ecgAxes handles.rrAxes handles.bpmAxes],'x')

%Adjust slider text
set(handles.timeSliderText,'String',...
    ['Time [' handles.appOptions.timescale '] (' ...
      num2str(selectedSampleValue,'%.2f') ')']);

%Master
nSamples=sd.nSamples;
set(handles.ecgMasterAxesHandles(1),...
    'XData',1:nSamples,...
	'YData',data)
    
ylim=axis(handles.ecgMasterAxes);
tmp=[handles.zoomedRange.MinIdx ylim(3);...
     handles.zoomedRange.MinIdx ylim(4);...
     handles.zoomedRange.MaxIdx ylim(4);...
     handles.zoomedRange.MaxIdx ylim(3)];
set(handles.ecgMasterAxesHandles(2),...
    'XData',tmp(:,1),...
	'YData',tmp(:,2))
guidata(hObject,handles);
set(handles.ecgMasterAxes,'XLim',[1 nSamples]);



guidata(hObject,handles);

end

%% Refresh Zoomed Axis Range
%Refresh the range of the zoomed axes
function refreshZoomedAxisRange(hObject)
% hObject - Handle of the object, e.g., the GUI component
handles=guidata(hObject);

% activeID=handles.currentElement.data.activeStructured;
% if (activeID==0)
%     warndlg('(Structured) Data not found.','guiHRTool');
%     return;
% end
% sd=getStructuredData(handles.currentElement.data,activeID);
% data=get(sd,'Data');
% rPeaks=get(sd,'RPeaks');
% rr=get(sd,'RR');
% bpm=getBPM(sd);
% 
tmpXData=getXData(hObject);
% minIdx=tmpXData(handles.zoomedRange.MinIdx);
% maxIdx=tmpXData(handles.zoomedRange.MaxIdx);
% minIdx=handles.zoomedRange.MinIdx;
% maxIdx=handles.zoomedRange.MaxIdx;
% 
% set(handles.ecgAxes,'XLim',[minIdx maxIdx])
% 
minVal=tmpXData(handles.zoomedRange.MinIdx);
maxVal=tmpXData(handles.zoomedRange.MaxIdx);
set(handles.ecgAxes,'XLim',[minVal maxVal])

    %Note that rrAxesHandles and bpmAxesHandles are linked

% %Refresh data
% set(handles.ecgAxesHandles,...
%     'XData',tmpXData(minIdx:maxIdx),...
%     'YData',data(minIdx:maxIdx));
% rPeaks(rPeaks>maxIdx)=[];
% rPeaks(rPeaks<minIdx)=[];
% rPeaksSampleValues=tmpXData(rPeaks);
% ylim=get(handles.ecgAxes,'YLim');
% set(handles.rPeaksECGAxesHandles,...
%     'XData',rPeaksSampleValues,...
%     'YData',(min(data(minIdx:maxIdx))+...
%                 0.95*(max(data(minIdx:maxIdx))-min(data(minIdx:maxIdx))))...
%                 *ones(length(rPeaksSampleValues),1));
% set(handles.ecgAxes,'Xlim',...
%     [tmpXData(minIdx) tmpXData(maxIdx)]);
% 
% set(handles.rrAxesHandles,...
%     'XData',tmpXData(minIdx:maxIdx),...
%     'YData',rr(minIdx:maxIdx));
% set(handles.rrAxes,'Xlim',...
%     [tmpXData(minIdx) tmpXData(maxIdx)]);
% 
% set(handles.bpmAxesHandles,...
%     'XData',tmpXData(minIdx:maxIdx),...
%     'YData',bpm(minIdx:maxIdx));
% set(handles.bpmAxes,'Xlim',...
%     [tmpXData(minIdx) tmpXData(maxIdx)]);

end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% AUXILIAR FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function p = nextpow10(n)
%NEXTPOW10 Next higher power of 10.
%   NEXTPOW10(N) returns the first P such that 10^P >= abs(N).  It is
%   often useful for finding the nearest power of ten sequence
%   length for FFT operations.
%   NEXTPOW10(X), if X is a vector, is the same as NEXTPOW10(LENGTH(X)).
%
%   Class support for input N or X:
%      float: double, single
%
%   See also LOG10.

%   Copyright 1984-2007 The MathWorks, Inc. 
%   $Revision: 5.11.4.2 $  $Date: 2007/11/01 12:38:51 $

if length(n) > 1
    n = cast(length(n),class(n));
end

[f,p] = log2(abs(n));

% Check if n is an exact power of 2.
if ~isempty(f) && f == 0.5
    p = p-1;
end

% Check for infinities and NaNs
k = ~isfinite(f);
p(k) = f(k);
end