function optodeSpace_plot3(haxes,optodeSpace,options)
%Visualize the 3D optode position as recorded by the polhemus
%
% optodeSpace_plot3(haxes,optodeSpace)
%
% optodeSpace_plot3(haxes,optodeSpace,options)
%
%
%% Parameters
%
% haxes - Axes handle
%
% optodeSpace - A struct with the following fields (see function
%                                                   import3DOptodeSpace)
%       +id
%       +version
%       +productName
%       +probe
%       +type
%       +user
%           +type
%           +id
%           +comment
%           +sex
%           +age
%       +probes - An array of struct
%           +mode
%           +optodeNum - Number of optodes
%           +left ear
%           +right ear
%           +nasion
%           +inion (back)
%           +top
%           +optodeCoords - The actual coordinates.
%           +angle
%
%
% options -  A struct of options
%   .fontSize - Font size. Defualt is 13pt.
% 
% Copyright 2009
% date: 11-Mar-2009
% Author: Felipe Orihuela-Espina
%
% See also rawData_ETG4000, optodeSpace_import
%


%% Deal with options
opt.fontSize=13;
if exist('options','var')
    if isfield(options,'fontSize')
        opt.fontSize=options.fontSize;
    end
end


axes(haxes);
nProbes=length(optodeSpace.probes);

for pp=1:nProbes
    leftear=optodeSpace.probes(pp).leftear;
    line('XData',leftear(1),'YData',leftear(2),'ZData',leftear(3),...
        'Color',[0 1 0],...
        'Marker','o','MarkerSize',10,'MarkerFaceColor',[0 1 0]);
    text(leftear(1),leftear(2),leftear(3),'LE',...
        'Color',[0 0 1],...
        'FontSize',opt.fontSize,'FontWeight','bold');
    rightear=optodeSpace.probes(pp).rightear;
    line('XData',rightear(1),'YData',rightear(2),'ZData',rightear(3),...
        'Color',[0 1 0],...
        'Marker','o','MarkerSize',10,'MarkerFaceColor',[0 1 0]);
    text(rightear(1),rightear(2),rightear(3),'RE',...
        'Color',[0 0 1],...
        'FontSize',opt.fontSize,'FontWeight','bold');
    nasion=optodeSpace.probes(pp).nasion;
    line('XData',nasion(1),'YData',nasion(2),'ZData',nasion(3),...
        'Color',[0 1 0],...
        'Marker','s','MarkerSize',10,'MarkerFaceColor',[0 1 0]);
    text(nasion(1),nasion(2),nasion(3),'Nz',...
        'Color',[0 0 1],...
        'FontSize',opt.fontSize,'FontWeight','bold');
    inion=optodeSpace.probes(pp).inion;
    line('XData',inion(1),'YData',inion(2),'ZData',inion(3),...
        'Color',[0 1 0],...
        'Marker','s','MarkerSize',10,'MarkerFaceColor',[0 1 0]);
    text(inion(1),inion(2),inion(3),'Iz',...
        'Color',[0 0 1],...
        'FontSize',opt.fontSize,'FontWeight','bold');
    top=optodeSpace.probes(pp).top;
    line('XData',top(1),'YData',top(2),'ZData',top(3),...
        'Color',[0 1 0],...
        'Marker','^','MarkerSize',10,'MarkerFaceColor',[0 1 0]);
    text(top(1),top(2),top(3),'Cz',...
        'Color',[0 0 1],...
        'FontSize',opt.fontSize,'FontWeight','bold');
    
    optodesCoords=optodeSpace.probes(pp).optodeCoords;
    line('XData',optodesCoords(:,1),'YData',optodesCoords(:,2),...
        'ZData',optodesCoords(:,3),...
        'Color',[1 0 0],...
        'LineStyle','none',...
        'Marker','o','MarkerSize',10,'MarkerFaceColor',[1 0 0]);

    %%PLaying with splines
%     Tension=0;
%     n=10;
%  Px=[leftear(1) nasion(1) rightear(1) inion(1) inion(1)];	
%  Py=[leftear(2) nasion(2) rightear(2) inion(2) inion(2)];	
%  Pz=[leftear(3) nasion(3) rightear(3) inion(3) inion(3)];	
%     for k=1:length(Px)-3
%         [MatOut3]=crdatnplusoneval([Px(k),Py(k),Pz(k)], ...
%                                    [Px(k+1),Py(k+1),Pz(k+1)],...
%                                    [Px(k+2),Py(k+2),Pz(k+2)],...
%                                    [Px(k+3),Py(k+3),Pz(k+3)],...
%                                    Tension,n);
%         % Between each pair of control points plotting n+1 values of first three rows of MatOut
%         line(MatOut3(1,:),MatOut3(2,:),MatOut3(3,:),...
%             'Color',[0 0 1],...
%             'LineStyle','-',...
%             'Marker','d','MarkerSize',5,'MarkerFaceColor',[1 0 1])
%         
%     end
    
    
end

grid on
view(3);
