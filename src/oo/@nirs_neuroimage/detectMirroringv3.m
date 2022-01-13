function [C,episodes]=detectMirroringv3(x,y,options)
%Detect mirroring episodes
%
%   [C]=detectMirroringv3(x,y)
%
% Detects mirroring episodes using a multiscale windowed cross
%correlation algorithm.
%
% This function uses the original algorithm (mirroring.m)
%as the base building block in a multi-scale approach.
%In other words, it applies the basic mirroring detection
%to all scales (i.e. window sizes) and all posible locations.
%
%
%% Parameters
%
%   x and y - The signals time courses (vectors).
%x and y are expected to have the same length. If not they will
%only be checked from t=0 untill the length of the shortest.
%
% options - An struct of options
%   .tolerance - Tolerance level [0-1]. 0 by default
%   .visualize - Plot the mirroring function. False by default.
%   .invertYinPlot - Invert Y in plot (if options.visualize=true)
%       to allow for easy identification of mirroring episode.
%       False by default.
%
%% Output
%
% A matrix C of mirroring values, where c_ij is the result
%of the mirroring detection found at location j with window
%size i.
%
% The list of episodes as a two columns matrix: first column
%holds the location, and second column holds the duration of
%the episodes
%
% Copyright 2007-2008
% @date: 19-Nov-2007
% @author Felipe Orihuela-Espina
%
% See also mirroring.m

%Deal with some options
opt.tolerance=0;
opt.visualize=false;
opt.invertYinPlot=false;
if(exist('options','var'))
    %%Options provided
    if(isfield(options,'tolerance'))
        opt.tolerance=options.tolerance;
    end
    if(isfield(options,'visualize'))
        opt.visualize=options.visualize;
    end
    if(isfield(options,'invertYinPlot'))
        opt.invertYinPlot=options.invertYinPlot;
    end
end

tolerance=opt.tolerance;

%% The real stuff ================================================
nSamples=min(length(x),length(y));
C=zeros(nSamples,nSamples-1);
minNSamples=2;  %Minimum window size (i.e. "infinitesimally small")
for ws=minNSamples:nSamples
    for initLocation=1:nSamples-1
        C(ws,initLocation)=...
            nirs_neuroimage.mirroring(x,y,initLocation,ws,tolerance);
    end
end
%%================================================================
%An extra: Exactly report the episodes
%%Since the mirroring function returns a "binary" matrix only
%%with 0s and 1s, it is very easy to detect the "peaks", i.e.
%%The location of C indeed captures the episodes location
%%and their lengths. Simply find the locations corresponding
%%to transitions from 0 to 1 in the window size minNSamples, and then gets
%%the largest possible window size for those locations.
episodes=zeros(0,2);
for initLocation=1:nSamples-1
    if initLocation==1
        previous=0;
    else
        previous=C(minNSamples,initLocation-1);
    end
    if ((previous==0) && (C(minNSamples,initLocation)==1))
        %Mirroring episode happened at initLocation
        ws=max(find(C(:,initLocation)==1));
        if (isempty(episodes))
            episodes=[initLocation ws];
        else
            episodes(end+1,:)=[initLocation ws];
        end
    end
end



%% VISUALIZATION =================================================
if (opt.visualize)
    fontSize=13;
    lineWidth=1.5;

    figure
    set(gcf,'Units','normalized');
    set(gcf,'Position',[0.02, 0.05, 0.92, 0.85]);
    set(gcf,'Units','pixels'); %Return to default
    subplot(2,1,1);
    hold on,
    plot(x,'r-','LineWidth',lineWidth)
    if (opt.invertYinPlot)
        plot(-y,'b-','LineWidth',lineWidth)
    else
        plot(y,'b-','LineWidth',lineWidth)
    end
    set(gca,'Xlim',[0 nSamples])
    grid on, box on
    xlabel('Time','FontSize',fontSize)
    ylabel('Intensity (Amplitude)','FontSize',fontSize)
    set(gca,'FontSize',fontSize);

    subplot(2,1,2);
    image(C,'CDataMapping','scale')
    box on, grid on
    %set(gca,'XLim',[0 nSamples]); %Avoid a optical "displacement" effect...
    %set(gca,'YLim',[-0.1 1.1]); %Avoid a few problems during the display...
    xlabel('Location (in samples)','FontSize',fontSize)
    ylabel('Window Size (in samples)','FontSize',fontSize)
    set(gca,'FontSize',fontSize);

    
    %Highlight "peaks"
    hold on,
    plot(episodes(:,1),episodes(:,2),'yo','LineWidth',2, ...
            'MarkerSize',8)

end
