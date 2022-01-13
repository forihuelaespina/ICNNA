function varargout=plot(obj,varargin)
%LOGARITHMICRADIALGRID/PLOT Displays a grid in the current axis
%
%A convinient function for easy visualization of a grid
%object in a 2D space.
%
% handles=plotGrid(grid) Visualize the grid object in the current axes.
%
%
%% Parameters
%
% obj - The grid
%
%% Output
%
% handles - The grid objects handles as a structure
%
%
% Copyright 2008
% Author: Felipe Orihuela-Espina
% Date: 22-Feb-2008
%
% See also ind2gridCell, getPolygon, getCellCenter
%

grd.r=obj.r;
grd.th=obj.th;


%Deal with options
opt.nRings=get(obj,'NRings'); %Partially visualize only a few rings
% if (exist('options','var'))
%     if(isfield(options,'nRings'))
%         opt.nRings=options.nRings;
%     end    
% end
% 
% 
% %Crop the grd if not all rings are to be visualized
% if (opt.nRings<size(grd.r,1))
%     grd.r = grd.r(1:opt.nRings,:);
%     grd.th = grd.th(1:opt.nRings,:);
% end

handles.figure=gcf;
handles.axes=gca;
hold on
[XX,YY] = pol2cart(grd.th,grd.r);
if (opt.nRings==1)
    handles.frame=plot(XX,YY,'Color',get(obj,'EdgeLineColor'),...
                'LineWidth',get(obj,'EdgeLineWidth'));
else
    handles.frame= mesh(XX,YY,zeros(size(XX)),...
                'EdgeColor',get(obj,'EdgeLineColor'),...
                'LineWidth',get(obj,'EdgeLineWidth'),...
                'FaceColor','none');
end
if (get(obj,'VertexVisible'))
    handles.vertex=plot(XX,YY,'LineStyle','none',...
        'Color',get(obj,'VertexColor'),...
        'Marker',get(obj,'VertexMarker'));
end

nCells=getNCells(obj);
tempPos=1;
for ii=1:nCells
    [posAngular,posRadial]=ind2gridCell(obj,ii);
    if (ismember(ii,get(obj,'HighlightCells')))
        cartesianPol=getPolygon(obj,posAngular,posRadial);
        tmpHFC=get(obj,'HighlightFaceColor');
        if (~isempty(tmpHFC))
            temp=mod(ii,size(tmpHFC,1))+1;
            handles.highlightCellsFace(tempPos)=...
                patch(cartesianPol(:,1),cartesianPol(:,2),...
                    tmpHFC(temp,:), ...
                    'FaceAlpha',get(obj,'HighlightFaceAlpha'));
        end
        handles.highlightCellsFrame(tempPos)=...
            plot(cartesianPol(:,1),cartesianPol(:,2),...
                'Color',get(obj,'HighlightEdgeColor'));
            tempPos=tempPos+1;
        
    end
    if (get(obj,'LabelCells'))
        center=getCellCenter(obj,posAngular,posRadial);
        handles.cellLabels=text(center(1),center(2),num2str(ii));
    end
end

varargout={handles};