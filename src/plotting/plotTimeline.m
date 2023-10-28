function [f]=plotTimeline(t,options)
%Display a timeline object
%
% [f]=plotTimeline(sd,options) Display a timeline object.
%
% This plots the analogous figure to guiTimeline but without the GUI.
%
%
%
%
%% Options
%
%   .mainTitle: The main title of the figure as a string. By default
%       is set to 'Timeline'.
%
%   .fontSize - The font size used in the plots. Size 13 points used by
%   default
%
%   .lineWidth - The line width used in the plots. Size 1.5 used by
%   default
%
%   .visibleConditionsList - Either a vector of conditions' ID or
%       a cell array of condition tags. List the conditions to be
%       shown. By default ALL conditions are shown.
%
%   .showOnsets - Displays a text label with the value event onsets
%       besides the event squares.
%
%   .showDurations - Displays a text label with the value event durations
%       besides the event squares.
%
%
%% Output
%
% A figure/axis handle.
%
% Copyright 2023
% @author Felipe Orihuela-Espina
%
% See also structuredData, plotChannel, shadeTimeline
%



%% Log
%
% 24-May-2023: FOE
%   + File created from code in guiTimeline
%



if ~isa(t,'timeline')
    error('ICNNA:plotTimeline:InvalidInput',...
        'Invalid input parameter.');
end





%% Deal with options
opt.mainTitle='Timeline';
opt.fontSize=13;
opt.lineWidth=1.5;
opt.visibleConditionsList=1:t.nConditions;
opt.showOnsets=false;
opt.showDurations=false;

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
        opt.visibleConditionsList=options.visibleConditionsList;
        %Translate visible condition tags to ids if needed.
        opt.visibleConditionsList = findCondition(t,opt.visibleConditionsList);

    end
    if(isfield(options,'showOnsets'))
        opt.showOnsets=options.showOnsets;
    end
    if(isfield(options,'showDurations'))
        opt.showDurations=options.showDurations;
    end
end








%% Initialize the figure
f=figure('Units','normalized','Position',[0 0 1 1]);
set(f,'NumberTitle','off');
set(f,'MenuBar','none'); %Hide MATLAB figure menu
%set(f,'CloseRequestFcn',{@OnClose_Callback});
movegui('center');



%Main area elements
timecourseAxes=axes('Parent',f);
set(timecourseAxes,...
        'Tag','timecourseAxes',...
		'FontSize',opt.fontSize,...
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
		'FontSize',opt.fontSize,...
        'Color','none');
%title(exclusoryBehaviourAxes,'Exclusory Behaviour');
%xlabel(exclusoryBehaviourAxes,'Condition');
ylabel(exclusoryBehaviourAxes,'Condition');






%% Render the figure



%Find out which conditions are to be shown
conditions=opt.visibleConditionsList;

%Refresh the exclusory axes as appropriate
axes(exclusoryBehaviourAxes);
cla(exclusoryBehaviourAxes);
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
    imagesc(b);

    colormap(gray(2));
    caxis([0 1]);

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





%Refresh the timecourse axes as appropriate
colors=hsv(length(conditions));
axes(timecourseAxes);
cla(timecourseAxes);
if (t.length>0)
    set(gca,'XLim',[0 t.length]);
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
                'LineWidth',opt.lineWidth);
            
            
            if opt.showOnsets
                text(events(ee,1)+1,pos+0.04,...
                    ['o: ' num2str(events(ee,1))],...
                    'FontSize',opt.fontSize);
            end
            if opt.showDurations
                text(events(ee,1)+1,pos-0.44,...
                    ['d: ' num2str(events(ee,2))],...
                    'FontSize',opt.fontSize);
            end
        end
        pos=pos+1;
        
    end
    set(gca,'YTickLabel',conditionTags);
end
%set(gca,'OuterPosition',[0 0 1 1]);
box on
set(gca,'XGrid','on');










end