function [f]=plotStructuredData(sd,options)
%Display the data in a structuredData
%
% [f]=plotStructuredData(sd,options) Display the data in a structuredData.
%	 See options below
%
%
%% Options
%
%   .mainTitle: The main title of the figure as a string. By default
%       is set to the structuredData Description.
%
%   .scale - True if you want all channels to share the same scale
%   (default). False if each channel is to be displayed on a different
%   scale.
%
%   .scaleLimits - [min max] Determine the Y scale limits of the plots.
%   It is only taken into account if option .scale=True. Otherwise
%   they are ignored. When not provided, the function will automatically
%   look for the "best" limits.
%
%   .fontSize - The font size used in the plots. Size 13 points used by
%   default
%
%   .lineWidth - The line width used in the plots. Size 1.5 used by
%   default
%
%   .displayLegend - True (default) if you want ot display the legend.
%
%   .legendLocation - The location of the legend. Default 'NorthEast'.
%
%   .nogui - An option to use this without GUI elements e.g. just for
%       figure visualization (and perhaps saving). Default is false (i.e.
%       GUI elements will be shown).
%
%% Parameters
%
%   sd - A structuredData
%
%   options-  [Optional] A struct of options. See section options
%
%% Output
%
% A figure/axis handle.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also structuredData, plotChannel, shadeTimeline
%



%% Log
%
% File created: 13-Nov-2008
% File last modified (before creation of this log): N/A
%
% 23-Nov-2013: Added zoom capabilities (restricted to horizontal zoom
%       only).
%
% 30-Jul-2014: Bug fixed. When the structuredData has a single channel
%       calculating the height of the axis required a division by 0.
%       Bug fixed. Handles controlling visibility of signals won't work
%       if the signal name included spaces.
%
% 24-Sep-2016: MATLAB has recently changed the way to access some of the component
% of the axes. Some axes properties are now associated to a subobject
% "ruler" which has properties such as color, etc. Setting some other
% axes properties have been "renamed"; for instance, axes location
% previously accessed as set(gca,'YAxis','left') should now be
% referred to as set(gca,'YAxisLocation','left')
% Method plotStructuredData has been affected as it changes the
% axes location depending on the channel being displayed. 
%
% 25-Apr-2019: FOE
%   + Bug fixed. Display of channels with integrity problems of complex
%   numbers is now adequately handled.
%   + Figure now opens to full screen size.
%
% 3-Jul-2019: FOE
%   + Bug fixed. View of individual signals was an all or nothing. It now
%   correctly renders those selected everytime.
%
% 2-Jan-2021: FOE
%   + Improvement. I noticed that sometimes it is convenient to
%   change the working directory in ICNNA but stil be able to call
%   ICNNA functions. When this happens calling this function will
%   yield an error since the icons directory is fixed with respect
%   to ICNNA main directory being the current directory e.g.
%
%       iconsFolder='./GUI/icons/';
%
%   Obviously, making this fully flexible requires a more profound
%   redesign of ICNNA, but unfortunately I do not have the time to
%   fix this right now. So in the meantime, I'm patching this by
%   trying to guess the icons directory from the location of this
%   function (using which).
%   + I have remove the @modified tag above.
%
% 25-May-2023: FOE
%   + Got rid of old label @date.
%   + Added get/set methods support for struct like access to attributes.
%
% 29-May-2023: FOE
%   + Bug fixed. For odd number of channels, the "last" of the first
%   column was pushed to the second column, e.g. with 61 channels, channel
%   31 should be on column 1 but was being pushed to column 2. It now
%   correctly leave the channel on its corresponding column.  
%   + Added option .nogui to use this without GUI elements.
%






if ~isa(sd,'structuredData')
    error('ICNA:plotStructuredData:InvalidInput',...
        'Invalid input parameter.');
end

data=sd.data;

%% Deal with options
opt.mainTitle=[sd.description];
opt.scale=true;
%Calculate an appropriate Y scale (rounding to the nearest decade)
maxY = ceil(max(max(max(real(data))))/10)*10;
minY = floor(min(min(min(real(data))))/10)*10;
opt.scaleLimits=[minY maxY];
opt.fontSize=13;
opt.lineWidth=1.5;
opt.displayLegend=true;
opt.legendLocation='NorthEast';
opt.nogui=false;
if(exist('options','var'))
    %%Options provided
    if(isfield(options,'mainTitle'))
        opt.mainTitle=options.mainTitle;
    end
    if(isfield(options,'scale'))
        opt.scale=options.scale;
    end
    if(isfield(options,'scaleLimits'))
        opt.scaleLimits=options.scaleLimits;
    end
    if(isfield(options,'fontSize'))
        opt.fontSize=options.fontSize;
    end
    if(isfield(options,'lineWidth'))
        opt.lineWidth=options.lineWidth;
    end
    if(isfield(options,'displayLegend'))
        opt.displayLegend=options.displayLegend;
    end
    if(isfield(options,'legendLocation'))
        opt.legendLocation=options.legendLocation;
    end
    if(isfield(options,'nogui'))
        opt.nogui=options.nogui;
    end
end


%% Initialize the figure
%...and hide the GUI as it is being constructed
% screenSize=get(0,'ScreenSize');
% width=screenSize(3)-round(screenSize(3)/4);
% height=screenSize(4)-round(screenSize(4)/4);
% wOffset=round((screenSize(3)-width)/2);
% hOffset=round((screenSize(4)-height)/2);
% f=figure('Visible','off','Position',[wOffset,hOffset,width,height]);
f=figure('Visible','off','Units','normalized','Position',[0.05 0.05 0.9 0.9]);
set(f,'NumberTitle','off');
set(f,'MenuBar','none'); %Hide MATLAB figure menu
%set(f,'CloseRequestFcn',{@OnClose_Callback});
movegui('center');

%% Add components
bgColor=get(f,'Color');

%Menus
if ~opt.nogui
    menuView = uimenu('Label','View',...
        'Tag','menuView',...
        'Accelerator','V');
        uimenu(menuView,'Label','Shade timeline',...
            'Tag','menuView_OptShadeTimeline',...
            'Checked','on',...
            'Callback',{@OnViewShadeTimeline_Callback});
    for mm=1:sd.nSignals
        tag=getSignalTag(sd,mm);
        %Substitute spaces or the handle name will not work
        %Do not only remove them; because that may cause different tags to
        %become equal!
        tag(tag==' ')='_';
        tmpMI=uimenu(menuView,'Label',getSignalTag(sd,mm),...
            'Tag',['menuView_OptSignal' tag],...
            'Checked','on',...
            'Enable','on',...
            'Visible','on',...
            'Callback',{@OnViewSignal_Callback,mm});
        if mm==1
            set(tmpMI,'Separator','on');
        end
    end
    
    menuTools = uimenu('Label','Tools',...
        'Tag','menuTools',...
        'Enable','off');
        uimenu(menuTools,'Label','Zoom',...
            'Tag','menuTools_OptZoom',...
            'Enable','on',...
            'Callback',{@OnZoom_Callback});



    %Toolbars
    toolbar = uitoolbar(f,'Tag','toolbar');
    %iconsFolder='C:\Program Files\MATLAB\R2007b\toolbox\matlab\icons\';
    %iconsFolder='./GUI/icons/';
    %Retrieve icons folder from the location of this function
    tmpThisFunctionFile = which('plotStructuredData');
    [tmpThisFunctionFilepath,~,~] = fileparts(tmpThisFunctionFile);
    iconsFolder=[tmpThisFunctionFilepath filesep '..' filesep ...
                    'GUI' filesep 'icons' filesep];
    
    tempIcon=load([iconsFolder 'zoom.mat']);
       uipushtool(toolbar,'CData',tempIcon.cdata,...
           'Tag','toolbarButton_Zoom',...
           'TooltipString','Zoom',...
           'Enable','on',...
           'Separator','on',...
           'ClickedCallback',{@OnZoom_Callback});

    
    
    %Main area elements
    tabPanel=uitabgroup(f,'Position', [0.02 0.02 0.96 0.96]);
    
    temporalViewTab = uitab(tabPanel,...
           'Title','Temporal View');
end


%Generate 1 axes per channel on 2 columns
nChannels=sd.nChannels;
nSamples=sd.nSamples;
flagEvenNumChannels = (mod(nChannels,2)==0);
flagOddNumChannels  = (mod(nChannels,2)==1);
for ch=1:nChannels
    if ~opt.nogui
        chAxes(ch)=axes('Parent',temporalViewTab);
    else
        chAxes(ch)=axes();
    end
    set(chAxes(ch),...
        'Tag',['chAxes' num2str(ch)],...
		'FontSize',opt.fontSize,...
        'Color','w',...
        'YTick',[0],...
        'Units','normalize');

    %The attribute 'Rotation' is not working for some reason
    %set(get(chAxes(ch),'YLabel'),'String',['Ch.' num2str(ch)],...
    %                            'Rotation',90)   
    set(get(chAxes(ch),'YLabel'),'String',['Ch.' num2str(ch)])   
    %Set the Y label location
    if flagEvenNumChannels && ch<=floor(nChannels/2)
        set(chAxes(ch),'YAxisLocation','left');
    elseif flagOddNumChannels && ch<=floor((nChannels+1)/2)
        set(chAxes(ch),'YAxisLocation','left');
    else
        set(chAxes(ch),'YAxisLocation','right');
    end
    

    %Set the position (2 columns for more than 2 channels; or
    %one column if there is only 1 channel)
    offsetMargin=0.05;
    if opt.nogui
    offsetMargin=0.03;
    end
    if nChannels > 1
        if flagEvenNumChannels
            height=(1-2*offsetMargin)/(floor(nChannels/2));
        else
            height=(1-2*offsetMargin)/(floor((nChannels+1)/2));
        end
        yPos=(1-2*offsetMargin)-(mod(ch-1,(nChannels/2)))*height;
        width = 0.43;
    else
        height = (1-2*offsetMargin);
        width = (1-2*offsetMargin);
        yPos = 0.05;
    end
    xPos=0.05;
    if flagEvenNumChannels && ch>floor(nChannels/2) && nChannels > 1 %i.e. for even number of channels
        xPos=0.52;
    elseif flagOddNumChannels && ch>floor((nChannels+1)/2) && nChannels > 1 %i.e. for odd number of channels
        xPos=0.52;
    end
    set(chAxes(ch),'Position',[xPos yPos width height])
    
    if flagEvenNumChannels && ((ch==1) || (ch==floor(nChannels/2)+1))
        set(chAxes(ch),'XAxisLocation','top');
    elseif flagOddNumChannels && ((ch==1) || (ch==floor((nChannels+1)/2)+1))
        set(chAxes(ch),'XAxisLocation','top');
    elseif flagEvenNumChannels && ((ch==nChannels) || (ch==floor(nChannels/2)))
        set(get(chAxes(ch),'XLabel'),'String','Time (samples)'); 
    elseif flagOddNumChannels && ((ch==nChannels) || (ch==floor((nChannels+1)/2)))
        set(get(chAxes(ch),'XLabel'),'String','Time (samples)'); 
    else
        set(chAxes(ch),'XTick',[]);
    end
    
    set(chAxes(ch),'XLim',[1 nSamples]);
    if(opt.scale)
        if ~any(isnan(opt.scaleLimits))
            set(chAxes(ch),'YLim',opt.scaleLimits);
        end
    end
end
linkaxes(chAxes,'x');



%% On Opening
handles = guihandles(f); %NOTE that only include those whose 'Tag' are not empty
handles.currentElement.data=sd;
handles.chAxes=chAxes;
handles.zoom='off';


handles.colormap=[1 0 0; ...
    0 0 1; ...
    0 1 0; ...
    1 1 0; ...
    1 0 1; ...
    0 1 1; ...
    0 0 0];


guidata(f,handles);
set(f,'Visible','on');OnLoad_Callback(f,[]);

%% Make GUI visible
set(f,'Name','ICNNA - plotStructuredData');
set(f,'Visible','on');


%% OnLoad callback
%Converts data to a structured data and plot the data afresh.
function OnLoad_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
sd=handles.currentElement.data;
nSamples=sd.nSamples;
nChannels=sd.nChannels;
nSignals=sd.nSignals;
data=sd.data;
sd_integrityStatus = sd.integrity;

lineWidth=1.5;

%Plot the signals
for ch=1:nChannels
    axes(handles.chAxes(ch));
    cla(handles.chAxes(ch));
    if (sd_integrityStatus.isCheck(ch) && sd_integrityStatus.isClean(ch))
        for ss=1:nSignals
            HH(ch,ss)=line('XData',1:nSamples,...
                'YData',data(:,ch,ss),...
                'LineStyle','-',...
                'LineWidth',lineWidth,...
                'Color',handles.colormap(ss,:));
        end
    else
        try
            for ss=1:nSignals
                HH(ch,ss)=line('XData',1:nSamples,...
                    'YData',real(data(:,ch,ss)),...
                    'LineStyle','-',...
                    'LineWidth',lineWidth,...
                    'Color',handles.colormap(ss,:));
                ylim=get(gca,'YLim');
                text(5,0.9*ylim(2),['Channel with integrity status ' ...
                    num2str(sd_integrityStatus.getStatus(ch)) ...
                    '. Rendering real part only.'],...
                    'Color','k','FontWeight','bold',...
                    'FontSize',opt.fontSize);
            end
        catch
            %Can't plot. Do nothing.
            ylim=get(gca,'YLim');
            text(5,0.9*ylim(2),['Channel with integrity status ' ...
                    num2str(sd_integrityStatus.getStatus(ch)) ...
                    '. Unable to render.'],...
                    'Color','k','FontWeight','bold',...
                    'FontSize',opt.fontSize);
            for ss=1:nSignals
                HH(ch,ss)=gobjects(1);
            end
        end
    end
    %%Shade the regions of stimulus
    %%%IMPORTANT NOTE: If I try to first paint stimulus regions and
    %%%later the signal, at the moment will not work...
    hTimelineEvents(ch)={shadeTimeline(gca,sd.timeline)};
end
handles.signalHandles=HH;
handles.timelineEventsHandles=hTimelineEvents;
%if opt.displayLegend
%    legend(legendTags,'Location',opt.legendLocation);
%end

guidata(hObject,handles);
end


%% OnViewShadeTimeline Callback
%Hide/Unhide timeline
function OnViewShadeTimeline_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles = guidata(f);
sd=handles.currentElement.data;
if strcmp(get(handles.menuView_OptShadeTimeline,'Checked'),'on')
    set(handles.menuView_OptShadeTimeline,'Checked','off');
else
    set(handles.menuView_OptShadeTimeline,'Checked','on');
end
guidata(hObject,handles);
refreshTemporalView(hObject);
end

%% OnView Signal Callback
%Hide/Unhide Signal
function OnViewSignal_Callback(hObject,eventData,ss)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles = guidata(f);
sd=handles.currentElement.data;
tag=getSignalTag(sd,ss);
tag(tag==' ')='_'; %Substitute spaces
if strcmp(get(handles.(['menuView_OptSignal' tag]),...
                'Checked'),'on')
    set(handles.(['menuView_OptSignal' tag]),'Checked','off');
else
    set(handles.(['menuView_OptSignal' tag]),'Checked','on');
end
guidata(hObject,handles);
refreshTemporalView(hObject);
end


%% Refresh temporal view
%Refresh the temporal view
function refreshTemporalView(hObject)
% hObject - Handle of the object, e.g., the GUI component
handles=guidata(hObject);
sd=handles.currentElement.data;

nSignals=sd.nSignals;
%%Show or hide the signals
for ch=1:nChannels
    for ss=1:nSignals
        tag=getSignalTag(sd,ss);
        tag(tag==' ')='_';%Substitute spaces
        if strcmp(get(handles.(['menuView_OptSignal' tag]),...
                'Checked'),'on')
            set(handles.signalHandles(ch,ss),'Visible','on');
        else
            set(handles.signalHandles(ch,ss),'Visible','off');
        end
    end
    tmpEventsHandles = handles.timelineEventsHandles{ch};
    nConditions=length(tmpEventsHandles);
    for cc=1:nConditions
        if strcmp(get(handles.menuView_OptShadeTimeline,'Checked'),'on')
            set(tmpEventsHandles{cc},'Visible','on');
        else
            set(tmpEventsHandles{cc},'Visible','off');
        end
    end
end

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




end %function
