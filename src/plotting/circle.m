function [h]=circle(centre,radius,options)
%Plots a circle
%
% [h]=circle(centre,radius,options) Plots a circle with the
%       indicatd centre and radius.
%
%% Options
%
% lineStyle - The color and style of the line ('b-' by default)
% lineWidth - The width of the line (1.2 by default)
% color - The color of the line (this will overwrite the color
%       of the line style). This is so you cn use a wider variety
%       of colours. The default is [0 0 1].
% filled - Fill the circle. Default false
% fillColor - Color of the filled area. Default to the same color of the
%   line. Only valid if filled is true.
% transparency - Transparency of the fill of the circle. Default 1 opaque
%   Only valid if filled is true.
%
%
%% Output
%
% The handle to the circle line
%
% Copyright 2008
% Date: 13-Jun-2008
% Author: Felipe Orihuela-Espina
%
%

opt.color=[0 0 1]; 
opt.lineStyle='-';
opt.lineWidth=1.2;
opt.filled=false;
opt.fillColor=opt.color; 
opt.transparency=1;
if (nargin==3)
    if(isfield(options,'lineStyle'))
        opt.lineStyle=options.lineStyle;
    end
    if(isfield(options,'lineWidth'))
        opt.lineWidth=options.lineWidth;
    end
    if(isfield(options,'color'))
        opt.color=options.color;
        %...and also remove the color from the line style
        %if present
        if (any(ismember('rgbmcyk',opt.lineStyle(1))))
            opt.lineStyle(1)=[];
        end
    else
        %Initialise the color to the ine indicated in the line
        %Style, if present and remove from there
        if (any(ismember('rgbmcyk',opt.lineStyle(1))))
            opt.color=opt.lineStyle(1);
            opt.lineStyle(1)=[];
        end        
    end
    opt.fillColor=opt.color;
    if(isfield(options,'filled'))
        opt.filled=options.filled;
    end
    if(isfield(options,'fillColor'))
        opt.fillColor=options.fillColor;
    end
    if(isfield(options,'transparency'))
        opt.transparency=options.transparency;
    end

end

t=[0:.1:2*pi]; %If use 2*pi then the circle is not closed!!
                        %...so I manually add the first and last point to
                        %close the circle.
if(opt.filled)
    patch([radius+centre(1) radius*cos(t)+centre(1) radius+centre(1)], ...
       [centre(2) radius*sin(t)+centre(2) centre(2)],...
        opt.fillColor,'FaceColor',opt.fillColor,'FaceAlpha',opt.transparency);
end

h=plot([radius+centre(1) radius*cos(t)+centre(1) radius+centre(1)], ...
       [centre(2) radius*sin(t)+centre(2) centre(2)],...
        'LineStyle',opt.lineStyle,'Color',opt.color,...
        'LineWidth',opt.lineWidth);

