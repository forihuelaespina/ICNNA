function obj = set(obj,varargin)
%CHANNELLOCATIONMAP/SET Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%
%
%% Properties
%
% ID - Numerical ID
% Description - Description string
% nChannels - Number of channels
% nOptodes - Number of optodes
% surfacePositioningSystems - Surface Positioning System. Currently
%       only the international '10/20' and 'UI 10/10'
%       (default) systems [JurcakV2007] are supported.
% stereotacticPositioningSystems - Stereotactic Positioning System.
%       Currently only the 'MNI' (default) and 'Talairach'
%       systems are supported.
%
%
%% References
%
%   [JurcakV2007] Jurcak, V.; Tsuzuki, D.; Dan, I. "10/20, 10/10,
%   and 10/5 systems revisited: Their validity as relative
%   head-surface-based positioning systems" NeuroImage 34 (2007) 1600–1611
%
%
%
% Copyright 2012-13
% @date: 26-Nov-2012
% @author: Felipe Orihuela-Espina
% @modified: 10-Sep-2013
%
% See also get, display
%

%% Log
%
% 8-Sep-2013: Support for updating number of optodes. Also the pairings
%       conforming the channels now automatically updates thenselves
%       when updating the number of channels.
%
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
% 
% 29-Apr-2020: Bug fixed. Setting the number of optodes, was
%       checking on the number of channels. It now checks for the number of
%       optodes correctly.
%
% 20-February-2022 (ESR): We simplify the code
%   + All cases are in the chennelLocationMap class.
%
% 24-March-2022 (ESR): Lowercase
%   + These cases are to convert the capitalization to lower case so that 
%   they can all be called correctly.
%   

propertyArgIn = varargin;
    while (length(propertyArgIn) >= 2)
       prop = propertyArgIn{1};
       val = propertyArgIn{2};
       propertyArgIn = propertyArgIn(3:end);
       
       tmp = lower(prop);
    
        switch (tmp)

            case 'description'
                obj.description = val;
           case 'id'
                obj.id = val;  
           case 'nchannels'
                obj.nChannels = val;
           case 'noptodes'
                obj.nOptodes = val;
           case 'surfacepositioningsystem'
                obj.surfacePositioningSystem = val;
           case 'stereotacticpositioningsystem'
                obj.stereotacticPositioningSystem = val;

            otherwise
                error('ICNA:optodeArray:set:InvalidPropertyName',...
                ['Property ' prop ' not valid.'])
        end
    end
    assertInvariants(obj);
end
