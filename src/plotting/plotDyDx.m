function plotDyDx(Dy,Dx)
%Scatter plot of embedded distances vs original distances
%
% plotDyDx(Dy,Dx)
%
%Scatter plot of embedded distances vs original distances
%similar to the plot in [Demartines, 1997], to see the deformation
%suffered by the distances during the embedding.
%
%% Paramaters
%
%   Dy - A square matrix of embedded (low dimensional) pairwise distances
%
%   Dx - A square matrix of original (high dimensional) pairwise distances
%
%
%
% Copyright 2007-8
% Date: 1-Nov-2007
% Author: Felipe Orihuela-Espina
%
%

fontSize=13;

gca;
hold on,
plot(Dy(:),Dx(:),'r.');

%%plotDiagonal;
xlim=get(gca,'XLim');
plot(xlim,xlim,'k-','LineWidth',1.5);

box on, grid on
xlabel('Low-dimensional distances','FontSize',fontSize);
ylabel('High-dimensional distances','FontSize',fontSize);
title('Distance distortion','FontSize',fontSize);
set(gca,'FontSize',fontSize);