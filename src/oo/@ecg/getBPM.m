function [bpm]=getBPM(obj)
%ECG/GETBPM Extracts beats per min from the ECG data
%
% [bpm]=getBPM(obj)
%
%
%
%% Parameter
%
% obj - The ECG (electrocardiogram) object.
%
%% Output
%
% bpm - Beats per min with 2 columns,
%
%
% Copyright 2009
% Author: Felipe Orihuela-Espina
% Date: 19-Jan-2009
%
% See also ecg, getRPeaks, getRR
%


%% Deal with some options
opt.visualize=false;
if(nargin>1)
    if(isfield(options,'visualize'))
        opt.visualize=options.visualize;
    end
end


bpm=60./get(obj,'RR');

%% Visualization =========================================
if (opt.visualize)
    lineWidth=1.5;
    fontSize=13;
    
    %R to R intervals (per sec)
    figure
    set(gcf,'Units','normalized');
    set(gcf,'Position',[0.02, 0.05, 0.92, 0.85]);
    set(gcf,'Units','pixels'); %Return to default
    
    plot(bpm,'k-','LineWidth',lineWidth);
    box on, grid on  
    ylabel('BMP','FontSize',fontSize);
    xlabel('Time (samples)','FontSize',fontSize);
    title('Beats per minute','FontSize',fontSize);
    set(gca,'FontSize',fontSize);


end
