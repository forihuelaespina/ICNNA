function [valid]=isValidSurfacePosition(positions,positioningSystem)
%CHANNELLOCATIONMAP/ISVALIDSURFACEPOSITION Tests the validity of positions against a surface positioning system
%
% [valid]=isValidSurfacePosition(positions,positioningSystem) Tests
%       the validity of positions against a surface positioning system.
%       Currently, only the '10/20' and the 'UI 10/10' systems are
%       supported.
%
%% Remarks
%
% This is a static method.
%
%
%
%% Parameters
%
% positions - A cell array of strings with positions names to be checked
%
% positioningSystem - A string identifying the positioning system under
%       which the positions should be valid. Current available systems
%       are [JurcakV2007]:
%           * '10/20'
%           * 'UI 10/10'
%
%% References
%
%   [JurcakV2007] Jurcak, V.; Tsuzuki, D.; Dan, I. "10/20, 10/10,
%   and 10/5 systems revisited: Their validity as relative
%   head-surface-based positioning systems" NeuroImage 34 (2007) 1600–1611
%  
%
% Copyright 2012-13
% @date: 22-Dec-2012
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also setChannelSurfacePositions, setOptodeSurfacePositions, 
%


%% Log
%
% 8-Sep-2013: Added comments regarding the parameters.
%

validPositions={};
switch lower(positioningSystem)
    case '10/20'
        validPositions={'Fz','Cz','Pz',...
                        'Fp1','F3','C3','P3','O1',...
                        'F7','T7','P7',...
                        'Fp2','F4','C4','P4','O2',...
                        'F8','T8','P8',''};
                        %The last empty string accounts for unassociated
                        %positions
    case 'ui 10/10'
        validPositions={'Nz','N1','AF9','F9','FT9',...
                            'T9','TP9','P9','PO9','I1',...
                            'Iz','I2','PO10','P10','TP10',...
                            'T10','FT10','F10','AF10','N2',...
                        'Fpz','Fp1','AF7','F7','FT7',...
                            'T7','TP7','P7','PO7','O1',...
                            'Oz','O2','PO8','P8','TP8',...
                            'T8','FT8','F8','AF8','Fp2',...
                        'AFz','AF3','F5','FC5',...
                            'C5','CP5','P5','PO3',...
                            'POz','PO4','P6','CP6',...
                            'C6','FC6','F6','AF4',...
                        'Fz','F1','F3','FC3',...
                            'C3','CP3','P3','P1',...
                            'Pz','P2','P4','CP4',...
                            'C4','FC4','F4','F2',...
                        'FCz','FC1',...
                            'C1','CP1',...
                            'CPz','CP2',...
                            'C2','FC2',...
                        'Cz',''};
                        %The last empty string accounts for unassociated
                        %positions
    otherwise
    	error('ICNA:channelLocationMap:isValidSurfacePosition:InvalidPositioningSystem',...
                    'Unsupported surface positioning system.');
end

valid=ismember(positions,validPositions);
