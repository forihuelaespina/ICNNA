function obj = set(obj,varargin)
%NEUROIMAGE/SET Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%Modifying the image data also adjusts the timeline and the
%integrity status as appropriate.
%
%% Properties
%
% == Inherited
% 'ID' - The neuroimage ID.
% 'Description' - A short description of the image
% 'NSamples' - Number of samples 
% 'NChannels' - Number of picture elements (e.g. channels)
% 'NSignals' - Number of signals
% 'Timeline' - The image timeline
% 'Integrity' - The image integrity status per picture element
% 'Data' - The image data itself
%
%
% == Self defined
% 'ChannelLocationMap' - The channel location map
%
% Copyright 2012
% @date: 22-Dec-2012
% @author Felipe Orihuela-Espina
% @modified: 28-Dec-2012
%
% See also neuroimage, get
%

%% Log
%
% 3-Apr-2019 (FOE):
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 31-January-2022 (ESR): We simplify the code
%   + All cases are in the neuroimage class.
%   + Creation of data dependent is inside of neuroimage class.
%

propertyArgIn = varargin;
while (length(propertyArgIn) >= 2)
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
   
    tmp = lower(prop);
    
    switch (tmp)
        
        case {'channellocationmap','chlocationmap'} %agregar al log
            obj.chLocationMap = val;
        %case 'data'
         %   obj.data = val;
            %comentar.
        otherwise
            obj=set@structuredData(obj,prop,val);
    end
end
assertInvariants(obj);