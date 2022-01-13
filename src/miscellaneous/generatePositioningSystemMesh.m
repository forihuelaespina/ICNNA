function [g]=generatePositioningSystemMesh(scale)
%Generate a mesh representing a standard positioning system
%
% [g]=generatePositioningSystemMesh(scale)
%
%
% This method supersedes previous method
%       generateOptodePositioningSystemGrid
%
%% Optode Positioning systems
%
%
%
%		S | System               | Ref.
%	  ----+----------------------+--------------
%		1 | International 10/20  | [Jasper, 1958]
%		2 | UI 10/10             | [Jurcak, 2007]
%		3 | 10/5                 | [Jurcak, 2007]
%
%
% Note that they can be considered subsets (supersets) of
%each other. In this sense, this function, currently
%yields the 10/5 system grid.
%
%% Algorithm
%
% 1.- Generate a default spherical grid
% 2.- Discard negative semi-sphere
% 3.- Extract three outer rings from semi-spheric grid
% 4.- Extract main axis (NzIz and LERE) from semi-spheric grid
% 5.- Construct secondary ribs using Hermite cubic interpolation
%   For this control points from the outer rings and main axes
%   were used
% 6.- Generate grid faces using Delaunay triangulation
% 7.- If required, scale the grid
%
%% Parameters
%
% scale - Optional. An initial scale estimate.
%
%
%% Output
%
% g - A 3D mesh of the 10/5 system. This is returned as a struct
%   with the following fields:
%       .coords - The nx3 vertex coordinates
%       .faces - Triangular faces of the mesh (as computed with
%           the Delaunay triangulation)
%       .tags - A cell array (with as many positions as number of
%           vertexes) with the vertex tags. Empty tags are linked to
%           vertex with no special meaning under the optode positioning
%           system.
%
%
%
%
% Copyright 2009-13
% @date: 27-Mar-2009
% @author Felipe Orihuela-Espina
% @modified: 28-Aug-2013
%
% See also mesh3D_visualize, generateRegistrationMesh
%


nRadialPositions=20;

opt.visualize=false;


if opt.visualize
    figure
    nRows=2;
    nCols=2;
    currSubplot=1;
end

%% Main Rings and Axes    

%We start by defining a semispheric grid with 20 radial positions
[X,Y,Z]=sphere(2*nRadialPositions);
%Note that this has double the number of positions along
%the vertical arcs.
X=reshape(X,numel(X),1);
Y=reshape(Y,numel(Y),1);
Z=reshape(Z,numel(Z),1);

if opt.visualize
    subplot(nRows,nCols,currSubplot); currSubplot=currSubplot+1;
    sphere(2*nRadialPositions);
end



%Remove the negative half of the sphere
X(Z<0)=[];
Y(Z<0)=[];
Z(Z<0)=[];

z=unique(Z);

if opt.visualize
    subplot(nRows,nCols,currSubplot); currSubplot=currSubplot+1;
    faces=delaunay(X,Y);
    trisurf(faces,X,Y,Z,...
        'FaceColor',[1 1 0.7],...
        'FaceAlpha',0.6,...
        'EdgeColor','k');
end


%The lowest circle of this sphere (which accounts for the
%system most outward ring) contains the nasion,
%inion, left ear and right ear, along with the following
%positions:
% anterior left quadrant: N1h, N1, AFp9, AF9, AFF9,
%			  F9, FFT9, FT9, FTT9, T9 (a.k.a. left ear)
% posterior left quadrant: TTP9, TP9, TPP9, P9, PPO9,
%			  PO9, POO9, I1, I1h, Iz (a.k.a. inion)
% posterior right quadrant: I2h, I2, POO10, PO10, PPO10, P10,
%			  TPP10, TP10, TTP10, T10 (a.k.a. right ear)
% anterior right quadrant: FTT10, FT10, FFT10, F10, AFF10,
%			  AF10, AFp10, N2, N2h, Nz (a.k.a. Nasion)
X1=X(Z==z(1));
Y1=Y(Z==z(1));
Z1=Z(Z==z(1));
%Remove the last (which close the circle)
X1(end)=[]; Y1(end)=[]; Z1(end)=[];

tags1={'T9',...
    'TTP9', 'TP9', 'TPP9', 'P9', 'PPO9',...
    'PO9', 'POO9', 'I1', 'I1h', 'Iz',...
    'I2h', 'I2', 'POO10', 'PO10', 'PPO10', 'P10',...
    'TPP10', 'TP10', 'TTP10', 'T10',...
	'FTT10', 'FT10', 'FFT10', 'F10', 'AFF10',...
    'AF10', 'AFp10', 'N2', 'N2h' ,...
    'Nz','N1h', 'N1', 'AFp9', 'AF9', 'AFF9',...
	'F9', 'FFT9', 'FT9', 'FTT9'};

%The third lowest circle (which accounts for the system 2nd
%outward ring) contains the following points:
% anterior left quadrant: NFp1h, NFp1, AFp9h, AF9h, AFF9h,
%			  F9h, FFT9h, FT9h, FTT9h, T9h
% posterior left quadrant: TTP9h, TP9h, TPP9h, P9h, PPO9h,
%			  PO9h, POO9h, OI1, OI1h, OIz
% posterior right quadrant: OI2h, OI2, POO10h, PO10h, PPO10h, P10h,
%			  TPP10h, TP10h, TTP10h, T10h
% anterior right quadrant: FTT10h, FT10h, FFT10h, F10h, AFF10h,
%			  AF10h, AFp10h, NFp2, NFp2h, NFpz
X3=X(Z==z(3));
Y3=Y(Z==z(3));
Z3=Z(Z==z(3));
%Remove the last (which close the circle)
X3(end)=[]; Y3(end)=[]; Z3(end)=[];


tags3={ 'T9h',...
	'TTP9h', 'TP9h', 'TPP9h', 'P9h', 'PPO9h',...
	'PO9h', 'POO9h', 'OI1', 'OI1h', 'OIz',...
	'OI2h', 'OI2', 'POO10h', 'PO10h', 'PPO10h', 'P10h',...
	'TPP10h', 'TP10h', 'TTP10h', 'T10h',...
	'FTT10h', 'FT10h', 'FFT10h', 'F10h', 'AFF10h',...
	'AF10h', 'AFp10h', 'NFp2', 'NFp2h',...
    'NFpz', 'NFp1h', 'NFp1', 'AFp9h', 'AF9h', 'AFF9h', ...
	'F9h', 'FFT9h', 'FT9h', 'FTT9h'};

%The fifth lowest circle (which accounts for the system 3rd
%outward ring) contains the following points:
% anterior left quadrant: Fp1h, Fp1, AFp7, AF7, AFF7,
%			  F7, FFT7, FT7, FTT7, T7
% posterior left quadrant: TTP7, TP7, TPP7, P7, PPO7,
%			  PO7, POO7, O1, O1h, Oz
% posterior right quadrant: O2h, O2, POO8, PO8, PPO8,
%			  P8, TPP8, TP8, TTP8, T8
% anterior right quadrant: FTT8, FT8, FFT8, F8, AFF8,
%			  AF8, AFp8, Fp2, Fp2h, Fpz
X5=X(Z==z(5));
Y5=Y(Z==z(5));
Z5=Z(Z==z(5));
%Remove the last (which close the circle)
X5(end)=[]; Y5(end)=[]; Z5(end)=[];

tags5={'T7',...
	'TTP7', 'TP7', 'TPP7', 'P7', 'PPO7',...
	'PO7', 'POO7', 'O1', 'O1h', 'Oz',...
	'O2h', 'O2', 'POO8', 'PO8', 'PPO8',...
	'P8', 'TPP8', 'TP8', 'TTP8', 'T8',...
	'FTT8', 'FT8', 'FFT8', 'F8', 'AFF8',...
	'AF8', 'AFp8', 'Fp2', 'Fp2h',...
    'Fpz', 'Fp1h', 'Fp1', 'AFp7', 'AF7', 'AFF7',...
	'F7', 'FFT7', 'FT7', 'FTT7'};

%In addition to this three rings, the main two arcs
%on their odd positions contains the following positions
%
% Along the X axes (left ear to right ear):
%   T9(left ear), T9h, T7, T7h, C5, C5h, C3, C3h, C1, C1h,
%   Cz(Top), C2h, C2, C4h, C4, C6h, C6, T8h, T8, T10h, T10(right ear)
%
% Along the Y axes (nasion to inion):
%   Nz(nasion), NFpz, Fpz, AFpz, AFz, AFFz, Fz, FFCz, FCz, FCCz,
%   Cz(Top), CCPz, CPz, CPPz, Pz, PPOz, POz,POOz, Oz, OIz, Iz(inion)
XLERE=X(Y==0);
YLERE=Y(Y==0);
ZLERE=Z(Y==0);
%Remove repetitions of the top (Note that this is necessary
%independently of the use of unique below!!)
%Note also that I cannot use unique in order to keep the order
%of the points.
idx=find(XLERE==0 & YLERE==0 & ZLERE==1);
XLERE(idx(2:end))=[];
YLERE(idx(2:end))=[];
ZLERE(idx(2:end))=[];


%For some reason this still holds some repeated rows.
%%Manually remove them
XLERE((2*nRadialPositions+2):end)=[];
YLERE((2*nRadialPositions+2):end)=[];
ZLERE((2*nRadialPositions+2):end)=[];


%Tags declared EXACTLY in the same order as their corresponding
%locations
tagsLERE={'T9', '', 'T9h', '', 'T7', '','T7h', '', 'C5','',...
    'C5h', '','C3','', 'C3h','', 'C1', '','C1h', '', 'Cz',...
    'T10',  '', 'T10h', '', 'T8', '', 'T8h',  '', 'C6', '', 'C6h',...
    '', 'C4',  '', 'C4h', '', 'C2', '', 'C2h', ''};
    %Emtpy tags correspond to the oversampling along the Z axes
    
%XNzIz=X(X==0); %Conceptually
%YNzIz=Y(X==0);
%ZNzIz=Z(X==0);
XNzIz=X(abs(X)<eps); %Implementation to avoid rounding errors
YNzIz=Y(abs(X)<eps);
ZNzIz=Z(abs(X)<eps);
%Remove repetitions of the top (Note that this is necessary
%independently of the use of unique below!!)
%Note also that I cannot use unique in order to keep the order
%of the points.
idx=find(XNzIz==0 & YNzIz==0 & ZNzIz==1);
XNzIz(idx(2:end))=[];
YNzIz(idx(2:end))=[];
ZNzIz(idx(2:end))=[];

%Tags declared in the same order as their corresponding
%locations
tagsNzIz={'Cz', 'Iz',  '', 'OIz', '', 'Oz', '',...
        'POOz', '', 'POz', '', 'PPOz', '', 'Pz', '', 'CPPz',...
         '', 'CPz', '', 'CCPz', '', ...
        'Nz', '', 'NFpz', '', 'Fpz', '','AFpz', '','AFz','',...
        'AFFz', '','Fz', '','FFCz', '','FCz', '','FCCz',''};


%The rest of the points of the grid has no anatomical meaning
%according to the system, as the arc are not defined through
%the top Cz, but through the main axes corresponding central
%locations.
%
%Hence I can discard invalid positions (or basically greate
%the grid out of the extracted points)

tmpG=[...
    X1 Y1 Z1; ...
    X3 Y3 Z3; ...
    X5 Y5 Z5; ...
    XLERE YLERE ZLERE; ...
    XNzIz YNzIz ZNzIz];

%Note that some points (e.g. Nz, Iz, Fpz, Oz, etc...)
%are repeated in this way, so it is necessary to discard
%them
[g.coords,m,n] = unique(tmpG, 'rows');

tags=[tags1 tags3 tags5 tagsLERE tagsNzIz];
%But since the unique function may have reshuffled the order
%of the points so I need to reshuffle the tags
tmp=length(m);
g.tags=cell(tmp,1);
for ii=1:tmp
    g.tags(ii)={tags{m(ii)}};
end


if opt.visualize
    subplot(nRows,nCols,currSubplot); currSubplot=currSubplot+1;
tmpG2=[...
    X1 Y1 Z1; ...
    X3 Y3 Z3; ...
    X5 Y5 Z5];
    faces=delaunay(tmpG2(:,1),tmpG2(:,2));
    %Remove the "top"
    faces(faces(:,1)==98,:)=[];
    faces(faces(:,2)==98,:)=[];
    faces(faces(:,3)==98,:)=[];
    faces=[faces; 57 58 98; 58 59 98; 98 59 99; 98 57 97];
    trimesh(faces,tmpG2(:,1),tmpG2(:,2),tmpG2(:,3),...
        'FaceColor',[1 1 0.7],...
        'FaceAlpha',0.6,...
        'EdgeColor','k');
    line('XData', X1, 'YData', Y1, 'ZData', Z1,...
        'LineWidth',1.5,...
        'Color','k');
    line('XData', X3, 'YData', Y3, 'ZData', Z3,...
        'LineWidth',1,...
        'Color','k');
    line('XData', X5, 'YData', Y5, 'ZData', Z5,...
        'LineWidth',1.5,...
        'Color','k');
    tmpNPoints=length(XLERE);
    midPoint=ceil(tmpNPoints/2);
    tmpXLERE=[XLERE(1:midPoint); XLERE(end:-1:midPoint+1)];
    tmpYLERE=[YLERE(1:midPoint); YLERE(end:-1:midPoint+1)];
    tmpZLERE=[ZLERE(1:midPoint); ZLERE(end:-1:midPoint+1)];
    line('XData', tmpXLERE, 'YData', tmpYLERE, 'ZData', tmpZLERE,...
        'LineWidth',1.5,...
        'Color','r');
    tmpXNzIz=[XNzIz(2:midPoint); XNzIz(1); XNzIz(end:-1:midPoint+1)];
    tmpYNzIz=[YNzIz(2:midPoint); YNzIz(1); YNzIz(end:-1:midPoint+1)];
    tmpZNzIz=[ZNzIz(2:midPoint); ZNzIz(1); ZNzIz(end:-1:midPoint+1)];
    line('XData', tmpXNzIz, 'YData', tmpYNzIz, 'ZData', tmpZNzIz,...
        'LineWidth',1.5,...
        'Color','b');
%    mesh3D_visualize(g.coords);
end



%% Secondary Ribs
%Now fill the yet undefined positions of the systems
%in the secondary ribs using 3D splines(??)

%Rib 1: AFp7-AFpz-AFp8    Support points: AFp9 and AFp10
controlPointTags={'AFp9','AFp7','AFpz','AFp8','AFp10'};
newTags={'AFp5','AFp3','AFp1','AFp2','AFp4','AFp6'};
g=generateRib(g,controlPointTags,newTags);

%Rib 2: AF7-AFz-AF8    Support points: AF9 and AF10
controlPointTags={'AF9','AF7','AFz','AF8','AF10'};
newTags={'AF7h','AF5','AF5h','AF3','AF3h','AF1','AF1h',...
         'AF2h','AF2','AF4h','AF4','AF6h','AF6','AF8h'};
g=generateRib(g,controlPointTags,newTags);

%Rib 3: AFF7-AFFz-AFF8    Support points: AFF9 and AFF10
controlPointTags={'AFF9','AFF7','AFFz','AFF8','AFF10'};
newTags={'AFF7h','AFF5','AFF5h','AFF3','AFF3h','AFF1','AFF1h',...
         'AFF2h','AFF2','AFF4h','AFF4','AFF6h','AFF6','AFF8h'};
g=generateRib(g,controlPointTags,newTags);

%Rib 4: F7-Fz-F8    Support points: F9 and F10
controlPointTags={'F9','F7','Fz','F8','F10'};
newTags={'F7h','F5','F5h','F3','F3h','F1','F1h',...
         'F2h','F2','F4h','F4','F6h','F6','F8h'};
g=generateRib(g,controlPointTags,newTags);

%Rib 5: FFT7-FFCz-FFT8    Support points: FFT9 and FFT10
controlPointTags={'FFT9','FFT7','FFCz','FFT8','FFT10'};
newTags={'FFT7h','FFC5','FFC5h','FFC3','FFC3h','FFC1','FFC1h',...
         'FFC2h','FFC2','FFC4h','FFC4','FFC6h','FFC6','FFT8h'};
g=generateRib(g,controlPointTags,newTags);

%Rib 6: FT7-FCz-FT8    Support points: FT9 and FT10
controlPointTags={'FT9','FT7','FCz','FT8','FT10'};
newTags={'FT7h','FC5','FC5h','FC3','FC3h','FC1','FC1h',...
         'FC2h','FC2','FC4h','FC4','FC6h','FC6','FT8h'};
g=generateRib(g,controlPointTags,newTags);

%Rib 7: FTT7-FCCz-FTT8    Support points: FTT9 and FTT10
controlPointTags={'FTT9','FTT7','FCCz','FTT8','FTT10'};
newTags={'FTT7h','FCC5','FCC5h','FCC3','FCC3h','FCC1','FCC1h',...
         'FCC2h','FCC2','FCC4h','FCC4','FCC6h','FCC6','FTT8h'};
g=generateRib(g,controlPointTags,newTags);

%Next rib is actually the main axis LE-RE (T9-T10)

%Rib 8: TTP7-CCPz-TTP8    Support points: TTP9 and TTP10
controlPointTags={'TTP9','TTP7','CCPz','TTP8','TTP10'};
newTags={'TTP7h','CCP5','CCP5h','CCP3','CCP3h','CCP1','CCP1h',...
         'CCP2h','CCP2','CCP4h','CCP4','CCP6h','CCP6','TTP8h'};
g=generateRib(g,controlPointTags,newTags);

%Rib 9: TP7-CPz-TP8    Support points: TP9 and TP10
controlPointTags={'TP9','TP7','CPz','TP8','TP10'};
newTags={'TP7h','CP5','CP5h','CP3','CP3h','CP1','CP1h',...
         'CP2h','CP2','CP4h','CP4','CP6h','CP6','TP8h'};
g=generateRib(g,controlPointTags,newTags);

%Rib 10: TPP7-CPPz-TPP8    Support points: TPP9 and TPP10
controlPointTags={'TPP9','TPP7','CPPz','TPP8','TPP10'};
newTags={'TPP7h','CPP5','CPP5h','CPP3','CPP3h','CPP1','CPP1h',...
         'CPP2h','CPP2','CPP4h','CPP4','CPP6h','CPP6','TPP8h'};
g=generateRib(g,controlPointTags,newTags);

%Rib 11: P7-Pz-P8    Support points: P9 and P10
controlPointTags={'P9','P7','Pz','P8','P10'};
newTags={'P7h','P5','P5h','P3','P3h','P1','P1h',...
         'P2h','P2','P4h','P4','P6h','P6','P8h'};
g=generateRib(g,controlPointTags,newTags);

%Rib 12: PPO7-PPOz-PPO8    Support points: PPO9 and PPO10
controlPointTags={'PPO9','PPO7','PPOz','PPO8','PPO10'};
newTags={'PPO7h','PPO5','PPO5h','PPO3','PPO3h','PPO1','PPO1h',...
         'PPO2h','PPO2','PPO4h','PPO4','PPO6h','PPO6','PPO8h'};
g=generateRib(g,controlPointTags,newTags);

%Rib 13: PO7-POz-PO8    Support points: PO9 and PO10
controlPointTags={'PO9','PO7','POz','PO8','PO10'};
newTags={'PO7h','PO5','PO5h','PO3','PO3h','PO1','PO1h',...
         'PO2h','PO2','PO4h','PO4','PO6h','PO6','PO8h'};
g=generateRib(g,controlPointTags,newTags);

%Rib 14: POO7-POOz-POO8    Support points: POO9 and POO10
controlPointTags={'POO9','POO7','POOz','POO8','POO10'};
newTags={'POO5','POO3','POO1','POO2','POO4','POO6'};
g=generateRib(g,controlPointTags,newTags);



%Finally scale the grid if necessary to an approximated scale
if exist('scale','var')
    g.coords=mesh3D_scale(g.coords,scale,scale,scale);
end
g.faces = delaunay(g.coords(:,1),g.coords(:,2));


if opt.visualize
    subplot(nRows,nCols,currSubplot); currSubplot=currSubplot+1;
%    trimesh(g.faces,g.coords(:,1),g.coords(:,2),g.coords(:,3),...
%        'EdgeColor','k');
    tmpOptions.displayTags=false;
    mesh3D_visualize(g,tmpOptions);
end

    %Internal function
    function g=generateRib(g,ControlTags,NewTags)
        %Generates a secondary rib
        %Control points MUST BE  provided in order, i.e.
        % {'SupportLeftMost','RibLeftOrigin','RibCentralPoint',...
        %  'RibRightEnd','SupportRightMost'}
        %Tags do not include control points
        nControl=length(ControlTags);
        ribPoints=zeros(nControl,3);
        for jj=1:nControl
            ribPoints(jj,:)=getCoords(g,ControlTags{jj});
        end
        ribNPoints=(nControl-(2))+length(NewTags);
            %Number of points in the rib including
            %control points (but not including support points)
        ribStep=(ribPoints(end-1,1)-ribPoints(2,1))/(ribNPoints-1);
        Xrib = (ribPoints(2,1):ribStep:ribPoints(end-1,1))';
        %Generate the rib with splines or Hermite cubic interpolation
        Yrib = pchip(ribPoints(:,1),ribPoints(:,2),Xrib);
        Zrib = pchip(ribPoints(:,1),ribPoints(:,3),Xrib);
        %%The overshoot with splines is massive; Hermite works better
        %Yrib = spline(ribPoints(:,1),ribPoints(:,2),Xrib);
        %Zrib = spline(ribPoints(:,1),ribPoints(:,3),Xrib);
        
        %Remove control points from rib to avoid repetitions
        Xrib([1,ceil(length(Xrib)/2),end])=[];
        Yrib([1,ceil(length(Yrib)/2),end])=[];
        Zrib([1,ceil(length(Zrib)/2),end])=[];
        
        %Rib tags (without control points)
        %Tags declared in the correct order
        ribTags=newTags';
        %Finally add the rib to the grid
        g.coords=[g.coords; [Xrib Yrib Zrib]];
        g.tags=[g.tags; ribTags];
    end

end


%% AUXILIAR FUNCTION
function coords=getCoords(g,tag)
%Look for a point coordinates
tmp=length(g.coords);
coords=[];
for ii=1:tmp
    if strcmp(g.tags{ii},tag)
        coords=g.coords(ii,:);
        break
    end
end
if isempty(coords)
    warning(['Point ' tag ' not found.']);
end
end
