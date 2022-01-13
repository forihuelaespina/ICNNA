function plotFixationSequence(varargin)
%Visualize a fixation sequences on top of an imagePartition
%
% plotFixationSequence(roiSeq,iP) Visualize a fixation sequences on top of
%   an imagePartition
%
% plotFixationSequence(ha,...) Visualize a fixation sequences on top of
%   an imagePartition in the indicated axis
%
%
%
%% Remarks
%
%   +=========================================+
%   | NOTE: Fixation centers are assumed to   |
%   | be expresed in screen coordinates as    |    
%   | returned from ROISequence_extract.      |
%   | If, however, this is not the case, and  |
%   | fixation are expressed in image         |
%   | coordinates they need to be converted   |
%   | to screen coordinates by adding the     |
%   | offset as follows:                      |
%   |                                         |
%   | >> screenRes=get(iP,'ScreenResolution');|
%   | >> imgSize=get(iP,'Size');              |
%   | >> horzOffset=round((screenRes(1)...    |
%   |                      -imgSize(1))/2);   |
%   | >> vertOffset=round((screenRes(2)...    |
%   |                      -imgSize(2))/2);   |
%   | >> roiSeq(:,COL_FIXCENTERX)=...         |
%   |     roiSeq(:,COL_FIXCENTERX)+horzOffset;|
%   | >> roiSeq(:,COL_FIXCENTERY)=...         |
%   |     roiSeq(:,COL_FIXCENTERY)+vertOffset;|
%   +=========================================+
%   
%
%% Parameters
%
% h - (Optional) The axis in which to display the imagePartition
%
% roiSeq - A Nx7 matrix holding the ROI sequence where N is the number
%   of fixations events. the columns are:
%       <Fixation Onset, ...
%        Fixation Duration, ...
%        Fixation Initial Timestamp, ...
%        Fixation duration time in milliseconds, ...
%        Fixation Center X, ...
%        Fixation Center Y, ...
%        ROI ID>
%
%   You can get the ROI sequence from an eyeTracker object as
%       [roiSeq]=ROISequence_extract(eT,iP);
%
% iP - An image Partition
%
%
%
% Copyright 2009-2010
% @date: 11-May-2010 (Evolved from a previous script)
% @author Felipe Orihuela-Espina
% @modification: 11-May-2010
%
% See also imagePartition, eyeTracker, ROISequence_extract, ROISequence_crop
%       plotImagePartition
%



%% Deal with options
if ~ishandle(varargin{1})
    figure,
    hAxis = gca; 
else
    hAxis = varargin{1};
    varargin(1)=[];
end
assert(isa(varargin{2},'imagePartition'),...
        'Expected Image Partition.');
roiSeq=varargin{1};
iP=varargin{2};



%% Visualize
opts2.displayROINames=false;
plotImagePartition(gca,iP,opts2);
nFixations=size(roiSeq,1);
cmap=[linspace(0,1,nFixations)' ...
    0.2*ones(nFixations,1) ...
    linspace(1,0,nFixations)'];
cmap=colormap(cool(nFixations));
line('XData',roiSeq(:,5),...
    'YData',roiSeq(:,6),...
    'Color','b',...
    'Marker','none',...
    'LineStyle','-')

for ff=1:nFixations
    line('XData',roiSeq(ff,5),...
        'YData',roiSeq(ff,6),...
        'Color',cmap(ff,:),...
        'Marker','o',...
        'MarkerSize',30*(roiSeq(ff,2)/max(roiSeq(:,2))),...
        'MarkerFaceColor',cmap(ff,:),...
        'LineStyle','none')
end

%Final touches for the eye-tracking data
set(gca,'XTick',[]);
set(gca,'YTick',[]);
