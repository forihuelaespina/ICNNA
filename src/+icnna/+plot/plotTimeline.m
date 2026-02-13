function [f]=plotTimeline(t,options)
%Display a timeline object
%
% [f]=icnna.plot.plotTimeline(sd,options) Display a timeline object.
%
% Renders a graphical depiction of a @icnna.data.core.timeline.
%
%
%
%
%% Input parameters
%
%   t - A timeline or an icnna.data.core.timeline
%
%   options - A struct of options with the following fields.
%       .mainTitle: The main title of the figure as a string. By default
%           is set to 'Timeline'.
%
%       .fontSize - The font size used in the plots. Size 13 points used by
%           default
%
%       .lineWidth - The line width used in the plots. Size 1.5 used by
%           default
%
%       .visibleConditionsList - Either a vector of conditions' ID or
%           a cell array of condition tags. List the conditions to be
%           shown. By default ALL conditions are shown.
%
%       .showOnsets - Displays a text label with the value event onsets
%           besides the event squares.
%
%       .showDurations - Displays a text label with the value event durations
%           besides the event squares.
%
%
%% Output
%
% f - A uifigure handle.
%
% Copyright 2025
% @author Felipe Orihuela-Espina
%
% See also structuredData, plotChannel, shadeTimeline
%



%% Log
%
% Since v1.3.1
%
% 12-Jul-2025: FOE
%   + File created from code in plotTimeline
%   + The exclusory behaviour is now presented as a separate tab.
%
%
% -- ICNNA v1.4.0
%
% 14-Dec-2025: FOE
%   + Adjustments to icnna.data.core.timeline class version '1.2'.
%   + Added support for option .visibleConditionsList
%


if ~(isa(t,'timeline') || isa(t,'icnna.data.core.timeline'))
    error('icnna:plot:plotTimeline:InvalidInput',...
        'Invalid input parameter.');
end

if isa(t,'timeline')
    t = icnna.data.core.timeline(t); %Typecast
end

[idList,namesList] = t.getConditionsList();


%% Deal with options
opt.mainTitle             = 'Timeline';
opt.fontSize              = 13;
opt.lineWidth             = 1.5;
opt.visibleConditionsList = idList;
opt.showOnsets            = false;
opt.showDurations         = false;

if(exist('options','var'))
    %%Options provided
    if(isfield(options,'mainTitle'))
        opt.mainTitle=options.mainTitle;
    end
    if(isfield(options,'fontSize'))
        opt.fontSize=options.fontSize;
    end
    if(isfield(options,'lineWidth'))
        opt.lineWidth=options.lineWidth;
    end
    if(isfield(options,'visibleConditionsList'))
        opt.visibleConditionsList = options.visibleConditionsList;
    end
    if(isfield(options,'showOnsets'))
        opt.showOnsets=options.showOnsets;
    end
    if(isfield(options,'showDurations'))
        opt.showDurations=options.showDurations;
    end
end








%% Initialize the figure
f=uifigure('Units','normalized','Position',[0.05 0.05 0.9 0.9]);
set(f,'NumberTitle','off');
set(f,'MenuBar','none'); %Hide MATLAB figure menu
%set(f,'CloseRequestFcn',{@OnClose_Callback});
%movegui('center');


%Main area elements
tabg = uitabgroup(f,'Units','normalized','Position',[0.02 0.02 0.96 0.96]);
tab1 = uitab(tabg,"Title","Timespan");
tab2 = uitab(tabg,"Title","Exclusory Behaviour");

timecourseAxes=axes('Parent',tab1,...
        'Units','normalize',...
        'OuterPosition',[0.02 0.02 0.96 0.96]);

exclusoryBehaviourAxes=axes('Parent',tab2,...
        'Units','normalize',...
        'OuterPosition',[0.02 0.02 0.96 0.96]);



%% Render the figure


%Find out which conditions are to be shown
condsIdx  = find(ismember(idList,opt.visibleConditionsList));
nVisibleConditions = length(condsIdx);
idList    = idList(condsIdx);
namesList = namesList(condsIdx);




%NOTE: For some reason, gca does not work properly when the axis
%are within tabs (it ws creating a separate figure!). So all
% references to gca are now replaced with currentAxes.

%% Refresh the exclusory axes as appropriate
currentAxes = exclusoryBehaviourAxes;
axes(currentAxes);
cla(currentAxes);
set(currentAxes,...
        'Tag','exclusoryAxes',...
		'FontSize',opt.fontSize,...
        'Color','none');
%title(currentAxes,'Exclusory Behaviour');
xlabel(currentAxes,'Condition');
ylabel(currentAxes,'Condition');

title(currentAxes,'Exclusory Behaviour');
%ylabel(currentAxes,'Exclusory Behaviour');

if (isempty(condsIdx))
    imagesc(currentAxes,[])
    set(currentAxes,'XLim',[0 1]);
    set(currentAxes,'XTick',[]);
    set(currentAxes,'XTickLabel',[]);
    set(currentAxes,'YLim',[0 1]);
    set(currentAxes,'YTick',[]);
    set(currentAxes,'YTickLabel',[]);
else

    b = t.exclusory;
    %Discard non selected conditions
    b = b(condsIdx,condsIdx);
    imagesc(currentAxes,b);

    colormap(currentAxes,gray(2));
    clim(currentAxes,[0 1]);

    set(currentAxes,'XLim',[0.5 nVisibleConditions+0.5]);
    set(currentAxes,'XTick',1:nVisibleConditions);
    set(currentAxes,'XTickLabel',namesList);
    set(currentAxes,'XAxisLocation','top');
    set(currentAxes,'YLim',[0.5 nVisibleConditions+0.5]);
    set(currentAxes,'YTick',1:nVisibleConditions);
    set(currentAxes,'YTickLabel',namesList);
    
end

clear currentAxes %Unlink the handle


%% Refresh the timecourse axes as appropriate
currentAxes = timecourseAxes;
axes(currentAxes);
cla(currentAxes);
set(currentAxes,...
        'Tag','timecourseAxes',...
		'FontSize',opt.fontSize,...
        'Color','none');


if strcmp(t.unit,'samples')
    xLabel = ['Time [' t.unit ']'];
else %'seconds'
    xLabel = ['Time [10^' num2str(t.timeUnitMultiplier) ' secs]'];
end

xlabel(currentAxes,xLabel);
ylabel(currentAxes,'Condition');

colors=hsv(nVisibleConditions);
if (t.length>0)
    if strcmp(t.unit,'samples')
        set(currentAxes,'XLim',[0 t.length]);
    else %'seconds'
        set(currentAxes,'XLim',[0 t.timestamps(end)]);
    end
else
    set(currentAxes,'XLim',[0 0.1]);
end

if (isempty(condsIdx))
    set(currentAxes,'YLim',[0 1]);
    set(currentAxes,'YTick',[]);
    set(currentAxes,'YTickLabel',[]);
else
    set(currentAxes,'YLim',[0.5 nVisibleConditions+0.5]);
    set(currentAxes,'YTick',1:nVisibleConditions);
    set(currentAxes,'YTickLabel',namesList);
    
    if icnna.util.compareVersions(classVersion(t),'1.1','<=')
        cevents = t.getEvents();
    elseif icnna.util.compareVersions(classVersion(t),'1.1','==')
        cevents = table2struct(t.getEvents());
    elseif icnna.util.compareVersions(classVersion(t),'1.2','>=')
        cevents = t.condEvents;
    end


    %Filter the visible conditions
    cevents(~ismember([cevents.id],idList)) = [];

    %Draw the events
    nVisibleEvents = numel(cevents);
    for ee=1:nVisibleEvents
        pos = double(cevents(ee).id);
        tmpColor = colors(mod(pos,size(colors,1))+1,:); %For picking the color

        pX=[cevents(ee).onsets ...
            cevents(ee).onsets ...
            cevents(ee).onsets+cevents(ee).durations ...
            cevents(ee).onsets+cevents(ee).durations];
        pY=[pos-0.48 ...
            pos+0.48 ...
            pos+0.48 ...
            pos-0.48];
        %%%IMPORTANT NOTE: Do NOT use this call to patch using
        %%%property FaceAlpha! I do not understand why, but it
        %will lead to an error in the exclusory behaviour axes
        %by which the tick marks in that axes are magically
        %replicated ad infinitum!!
        %             patch(pX,pY,colors(mod(pos,size(colors,1))+1,:),...
        %                'EdgeColor',colors(mod(pos,size(colors,1))+1,:),...
        %                'FaceAlpha',0.2,'LineWidth',1.5);
        patch(pX,pY,tmpColor,...
            'Parent', currentAxes, ...
            'EdgeColor',tmpColor,...
            'LineWidth',opt.lineWidth);


        if opt.showOnsets
            text(cevents(ee).onsets+1,pos+0.04,...
                ['o: ' num2str(events(ee).onsets)],...
                'Parent', currentAxes, ...
                'FontSize',opt.fontSize);
        end
        if opt.showDurations
            text(cevents(ee).onsets+1,pos-0.44,...
                ['d: ' num2str(events(ee).durations)],...
                'Parent', currentAxes, ...
                'FontSize',opt.fontSize);
        end

    end
end
%set(currentAxes,'OuterPosition',[0 0 1 1]);
box(currentAxes,'on');
set(currentAxes,'XGrid','on');



clear currentAxes %Unlink the handle




end