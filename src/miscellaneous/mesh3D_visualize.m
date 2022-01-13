function mesh3D_visualize(g,options)
%Visualize the 3D grid/mesh
%
% mesh3D_visualize(g)
%
%% Parameters
%
% g - The grid/mesh. It can either be a nx3 matrix of
%   points coordinates, or a struct with fields for
%   coordinates (.coords) and triangular faces (.faces)
%   Importantly if g is expressed only as an nx3 matrix of
%   points coordinates, the Delaunay triangulation (over the
%   XY plane) is computed on the point set to create the faces.
%   If g also has a field .tags, The tags will be displayed
%   on top of the vertex.
%
% options - A struct with some options
%   displayControlTags - True by default. Label the Nz, Iz, RE, LE and Cz
%   displayTags - True by default. Label the vertex
%   fontSize - Size for the fonts. By default is 10
%
%
% Copyright 2009
% @author Felipe Orihuela-Espina
% @date: 19-Mar-2009
%
% See also generateOptodePositioningSystemGrid
%

%Deal with options
opt.fontSize=10;
opt.displayControlTags=true;
opt.displayTags=true;
if exist('options','var')
    if isfield(options,'fontSize')
        opt.fontSize=options.fontSize;
    end
    if isfield(options,'displayControlTags')
        opt.displayControlTags=options.displayControlTags;
    end
    if isfield(options,'displayTags')
        opt.displayTags=options.displayTags;
    end
end

tags=[];
if ~isstruct(g) %g is a nx3 matrix of points coordinates
    X=g(:,1);
    Y=g(:,2);
    Z=g(:,3);
    faces=delaunay(X,Y);
else
    X=g.coords(:,1);
    Y=g.coords(:,2);
    Z=g.coords(:,3);
    faces=g.faces;
    if isfield(g,'tags')
        tags=g.tags;
    end
end

%trimesh(faces,X,Y,Z,'FaceColor','none') %Make the mesh transparent
trisurf(faces,X,Y,Z,...
        'FaceColor',[1 1 0.7],...
        'FaceAlpha',0.6,...
        'EdgeColor','k'); %Alternatively use 'FaceColor','interp'
%trimesh(faces,X,Y,Z)

xlabel('X [mm]');
ylabel('Y [mm]');
zlabel('Z [mm]');
view(3);



if (opt.displayControlTags)
    controlMarkerColor=[1 0.3 0.3];
    controlTagColor=[1 0 0];
    controlOffset=0.05;
    if ~isempty(tags)
    coord = getCoords([X Y Z],tags,'Nz');
        line('XData',coord(1),'YData',coord(2),'ZData',coord(3),...
            'Marker','o','MarkerSize',9,...
            'MarkerFaceColor',controlMarkerColor,...
            'Color',controlMarkerColor);
        text(coord(1)+controlOffset*coord(1),...
             coord(2)+controlOffset*coord(2),...
             coord(3)+controlOffset*coord(3),...
            'Nz',...
            'FontSize',opt.fontSize+2,'FontWeight','bold',...
            'Color',controlTagColor);
    
    coord = getCoords([X Y Z],tags,'Iz');
        line('XData',coord(1),'YData',coord(2),'ZData',coord(3),...
            'Marker','o','MarkerSize',9,...
            'MarkerFaceColor',controlMarkerColor,...
            'Color',controlMarkerColor);
        text(coord(1)+controlOffset*coord(1),...
             coord(2)+controlOffset*coord(2),...
             coord(3)+controlOffset*coord(3),...
            'Iz',...
            'FontSize',opt.fontSize+2,'FontWeight','bold',...
            'Color',controlTagColor);
    
    coord = getCoords([X Y Z],tags,'T9');
        line('XData',coord(1),'YData',coord(2),'ZData',coord(3),...
            'Marker','o','MarkerSize',9,...
            'MarkerFaceColor',controlMarkerColor,...
            'Color',controlMarkerColor);
        text(coord(1)+controlOffset*coord(1),...
             coord(2)+controlOffset*coord(2),...
             coord(3)+controlOffset*coord(3),...
            'LE',...
            'FontSize',opt.fontSize+2,'FontWeight','bold',...
            'Color',controlTagColor);
    
    coord = getCoords([X Y Z],tags,'T10');
        line('XData',coord(1),'YData',coord(2),'ZData',coord(3),...
            'Marker','o','MarkerSize',9,...
            'MarkerFaceColor',controlMarkerColor,...
            'Color',controlMarkerColor);
        text(coord(1)+controlOffset*coord(1),...
             coord(2)+controlOffset*coord(2),...
             coord(3)+controlOffset*coord(3),...
            'RE',...
            'FontSize',opt.fontSize+2,'FontWeight','bold',...
            'Color',controlTagColor);
    
    coord = getCoords([X Y Z],tags,'Cz');
        line('XData',coord(1),'YData',coord(2),'ZData',coord(3),...
            'Marker','o','MarkerSize',9,...
            'MarkerFaceColor',controlMarkerColor,...
            'Color',controlMarkerColor);
        text(coord(1)+controlOffset*coord(1),...
             coord(2)+controlOffset*coord(2),...
             coord(3)+controlOffset*coord(3),...
            'Cz',...
            'FontSize',opt.fontSize+2,'FontWeight','bold',...
            'Color',controlTagColor);
    end
end

if (opt.displayTags)
if ~isempty(tags)
    %Label points
    nPoints = length(X);
    for pp=1:nPoints
        text(X(pp)+0.03*X(pp),Y(pp),Z(pp)+0.03*Z(pp),tags{pp},...
            'FontSize',opt.fontSize);
    end
end
end

end



%% AUXILIAR FUNCTION
function coords=getCoords(gcoords,gtags,tag)
%Look for a point coordinates
tmp=length(gcoords);
coords=[];
for ii=1:tmp
    if strcmp(gtags{ii},tag)
        coords=gcoords(ii,:);
        break
    end
end
end
