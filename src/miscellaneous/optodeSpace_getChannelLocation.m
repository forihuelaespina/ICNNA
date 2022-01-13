function channelCoordinates=optodeSpace_getChannelLocation(...
                                    optodeSpace,probe)
%DEPRECATED Calculate the position of channels from the optode space
%
% channelCoordinates=optodeSpace_getChannelLocation(optodeSpace)
%
%
%Currently locations of channels are calculate by linear
%interpolation from the positions of the corresponding
%source-detector pair.
%
%% Deprecated
%
% This function has now been deprecated. Use new class channelLocationMap
%instead.
%
%
%% Source-detector pairs and corresponding channels
%
% Mode 1 => 2 array in a '3x3' configuration
%
% Optode pair | Channel No.
%-------------+--------------
%     1-2     |     1
%     2-3     |     2
%     1-4     |     3               1--(1)--2--(2)--3
%     2-5     |     4               |       |       |
%     3-6     |     5              (3)     (4)     (5)
%     4-5     |     6               |       |       |
%     5-6     |     7               4--(6)--5--(7)--6
%     4-7     |     8               |       |       |
%     5-8     |     9              (8)     (9)    (10)
%     6-9     |    10               |       |       |
%     7-8     |    11               7--(11)-8--(12)-9
%     8-9     |    12
%                           Channel number in brackets
%
%
%
%% Parameters
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
%   probe - Probe set
%
%
%% Output
%
% channelCoordinates - An nx3 matrix with the 3D coordinates for the
%   channels
%
%
% 
% Copyright 2009-13
% @date: 27-Mar-2009
% @author: Felipe Orihuela-Espina
% @modified: 27-Aug-2013
%
% See also rawData_ETG4000, optodeSpace_import, optodeSpace_plot3
%

mode=optodeSpace.probes(probe).mode;
optodeCoors=optodeSpace.probes(probe).optodeCoords;


channelCoordinates=[];
switch (mode)
    case 1 %3x3
        channelCoordinates=zeros(24,3);
        optodePairs=[...
            1 2; ...
            2 3; ...
            1 4; ...
            2 5; ...
            3 6; ...
            4 5; ...
            5 6; ...
            4 7; ...
            5 8; ...
            6 9; ...
            7 8; ...
            8 9];
%         figure, hold on
%         for oo=1:18
%             text(optodeCoors(oo,1),optodeCoors(oo,2),optodeCoors(oo,3),...
%                 num2str(oo),'Color','k',...
%                 'FontSize',12,'FontWeight','bold',...
%                 'HorizontalAlignment','center');
%         end
        for ch=1:12
            o1=optodeCoors(optodePairs(ch,1),:);
            o2=optodeCoors(optodePairs(ch,2),:);
            channelCoordinates(ch,:)=(o1+o2)/2;
%             line('XData',[o1(1) o2(1)],...
%                  'YData',[o1(2) o2(2)],...
%                  'ZData',[o1(3) o2(3)],...
%                  'Color','b',...
%                  'Marker','o','MarkerSize',12,...
%                  'LineStyle','-')
%             text(channelCoordinates(ch,1),...
%                 channelCoordinates(ch,2),...
%                 channelCoordinates(ch,3),...
%                 num2str(ch),'Color','r',...
%                 'FontSize',12,'FontWeight','bold',...
%                 'HorizontalAlignment','center');
        end
        optodePairs=optodePairs+9;
        for ch=13:24
            o1=optodeCoors(optodePairs(ch-12,1),:);
            o2=optodeCoors(optodePairs(ch-12,2),:);
            channelCoordinates(ch,:)=(o1+o2)/2;
%             line('XData',[o1(1) o2(1)],...
%                  'YData',[o1(2) o2(2)],...
%                  'ZData',[o1(3) o2(3)],...
%                  'Color','b',...
%                  'Marker','o','MarkerSize',12,...
%                  'LineStyle','-')
%             text(channelCoordinates(ch,1),...
%                 channelCoordinates(ch,2),...
%                 channelCoordinates(ch,3),...
%                 num2str(ch),'Color','r',...
%                 'FontSize',12,'FontWeight','bold',...
%                 'HorizontalAlignment','center');
        end
%         view(0,0);
%         grid on;
%         xlabel('X');
%         ylabel('Y');
%         zlabel('Z');
        
    otherwise
        warning('ICAF:optodeSpace_getChannelLocation',...
            ['Optode array mode not recognised. ' ...
            'Channel locations will not be calculated.']);
end
