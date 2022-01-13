function [Z,H,T]=hierarchicalClustering(obj,options)
%HIERARCHICALCLUSTERING Cluster groups of an analysis based on the EMD distance
%
% [Z,H,T]=hierarchicalClustering(obj) Cluster groups of an analysis based
% on the EMD distance
%
%% PARAMETERS
%
% obj - A MENA analysis object
%
% options - A struct of options
%   .fontSize - Font size for the figure. Default value is 13pt.
%   .tresh - Colour threshold. Select a value or the string 'default'
%
%
%% Output
%
% Z - The output from the linkage function from MATLAB
%
% H, T - The output from the dendrogram function from MATLAB
%
%
%
%
% Copyright 2009
% date: 13-Jun-2009
% Author: Felipe Orihuela-Espina
%
% See also analysis, subject, session, dataSource, setRawData,
%   linkage, dendrogram
%

opt.fontSize=13;
opt.thresh='default';
if exist('options','var')
    if isfield(options,'fontSize')
        opt.fontSize = options.fontSize;
    end
    if isfield(options,'thresh')
        opt.thresh = options.thresh;
    end
end


%% Compute EMD
try
    emdResults=emd(obj);
    emdResults=squareform(emdResults);
        %Actually undo the squareform to convert to a vector
        
    Z = linkage(emdResults,'single');
%    [H,T] = dendrogram(Z,0,'colorthreshold','default',...
%                'orientation','right');
    [H,T] = dendrogram(Z,0,'colorthreshold',opt.thresh,...
                'orientation','right');
    set(H,'LineWidth',2)
    set(gca,'FontSize',opt.fontSize);
    title('Hierarchical clustering based on EMD','FontSize',opt.fontSize);
    %ylabel('Cluster ID','FontSize',opt.fontSize);
    ylabel('Channel','FontSize',opt.fontSize);

    %T = cluster(Z,'cutoff',c)
    
    box on
    
catch ME
    close gcf %close the progress waitbar
    warndlg([ME.identifier ...
        ' Unable to calculate EMD values. ' ME.message]);
    return
end
