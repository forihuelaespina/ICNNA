function [hAxis]=plotImagePartition(varargin)
%Visualize and image partition
%
% plotImagePartition(ip) Visualize the image partition
%
% plotImagePartition(ip,options) Visualize the image partition with the
%   indicated options
%
% plotImagePartition(h,...) Visualize the image partition within the
%   selected axis
%
% h=plotImagePartition(...) Return the axis in which the image
%   partition is displayed.
%
%% Parameters
%
% h - (Optional) The axis in which to display the imagePartition
%
% ip - An imagePartition
%
% options - A struct of options
%   .displayROINames - Display the names of the Regions of Interest
%
%
%
%
% Copyright 2009-10
% @date: ??-??-2009
% @author: Felipe Orihuela-Espina
% @modified: 6-Jun-2010
%
% See also performDisorientationAnalysis
%

%% Deal with options
if isa(varargin{1},'imagePartition')
    figure,
    hAxis = gca; 
else
    hAxis = varargin{1};
    varargin(1)=[];
end
iP=varargin{1};
varargin(1)=[];

if ~isempty(varargin)
    options=varargin{1};
    varargin(1)=[];
end

opt.fontSize=13;
opt.lineWidth=1.5;
opt.displayROINames=true;
if exist('options','var')
    if isfield(options,'fontSize')
        opt.fontSize=options.fontSize;
    end
    if isfield(options,'lineWidth')
        opt.lineWidth=options.lineWidth;
    end
    if isfield(options,'displayROINames')
        opt.displayROINames=options.displayROINames;
    end
end

%Some preliminaries
screenRes=get(iP,'ScreenResolution');
imgSize=get(iP,'Size');
horzOffset=round((screenRes(1)-imgSize(1))/2);
vertOffset=round((screenRes(2)-imgSize(2))/2); 



%% Plot the background image
hold on
colors=colormap(jet(getNROIs(iP)));
A=imread(get(iP,'AssociatedFile'));
image(horzOffset,vertOffset,A);
title(['Stimulus ' get(iP,'Name')],...
        'FontSize',opt.fontSize);

%% Plot the partition
roiList=getROIList(iP);
pos=1;
for rrId=roiList
    rr=getROI(iP,rrId);
    for kk=1:getNSubregions(rr)
        polygon=getSubregion(rr,kk);
        fill(polygon(:,1)+horzOffset,polygon(:,2)+vertOffset,...
            colors(pos,:),...
            'FaceAlpha',0.2);
        if opt.displayROINames
            %Compute mean center of the ROI subregion
            cogx = mean(polygon(1:end-1,1));
            cogy = mean(polygon(1:end-1,2));
            cog=[cogx cogy];%Mean center
            %Region titles
            text(cog(1)+horzOffset,cog(2)+vertOffset,...
                get(rr,'Name'),...
                'Color',colors(pos,:),...
                'FontSize',opt.fontSize-2);
        end
    end
    pos=pos+1;
end

set(gca,'XLim',[0+horzOffset imgSize(1)+horzOffset]);
set(gca,'YLim',[0+vertOffset imgSize(2)+vertOffset]);
%set(gca,'XTick',[]);
%set(gca,'YTick',[]);
set(gca,'YDir','reverse');
set(gca,'FontSize',opt.fontSize);


