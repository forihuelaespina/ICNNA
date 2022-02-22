%Class nirs_neuroimage
%
%An fNIRS (functional Near InfraRed Spectrocopy) neuroimage.
%
% The total Hb and the HbDiff are not stored but calculated
%on the fly when needed.
%
% This class has a special set of integrity checks, specially
%developed for the fNIRS neuroimage data.
%
%% Superclass
%
% neuroimage
%
%% Properties
%
% .probeMode - DEPRECATED. The optode array distribution. By default is set
%   to '3x3'. See superclass neuroimage channelLocationMap
%
% ==Constants
%   .OXY - To reference the oxygenated haemoglobin (HbO2) signal.
%   .DEOXY - To reference the de-oxygenated haemoglobin (HHb) signal.
%   .TOTALHB - To reference the total haemoglobin (HbO2+HHb) signal.
%   .HBDIFF - To reference the haemoglobin oxygenation (HbO2-HHb) signal.
%
%% Methods
%
% Type methods('nirs_neuroimage') for a list of methods
% 
% Copyright 2008-12
% @date: 13-May-2008
% @author: Felipe Orihuela-Espina
% @modified: 22-Dec-2012
%
% See also neuroimage
%

%% Log
%
% 17-February-2022 (ESR): Get/Set Methods created in nirs_neuroimage
%   + The methods are added with the new structure. All the properties have 
%   the new structure.
%   + The new structure enables new MATLAB functions.
%

classdef nirs_neuroimage < neuroimage
    properties (SetAccess=private, GetAccess=private)
        probeMode='3x3'; %DEPRECATED. See superclass neuroimage channelLocationMap
    end
    properties (Constant=true, GetAccess=public)
        OXY=1;
        DEOXY=2;
        %CYTOCHROME=3;
        TOTALHB=4;
        HBDIFF=5;
    end
    
    methods
        function obj=nirs_neuroimage(varargin)
            %NIRS_NEUROIMAGE NIRS_neuroimage class constructor
            %
            % obj=nirs_neuroimage() creates a default NIRS_neuroimage
            %   with ID equals 1.
            %
            % obj=nirs_neuroimage(obj2) acts as a copy constructor
            %   of NIRS_neuroimage
            %
            % obj=nirs_neuroimage(id) creates a new NIRS_neuroimage
            %   with the given identifier (id).
            %
            % obj=nirs_neuroimage(id,size) creates a new neuroimage with
            %   the indicated identifier and size, where size is a vector
            %       <nSamples,nChannels,nSignals>
            %
            % The name of the nirs_neuroimage is initialised
            % to 'NIRSImageXXXX' where is the id preceded with 0.
            %
            %
            % 
            % Copyright 2008
            % date: 13-May-2008
            % Author: Felipe Orihuela-Espina
            %
            
            obj = obj@neuroimage(varargin{:});
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'nirs_neuroimage')
                obj=varargin{1};
                return;
            else
                obj=set(obj,'ID',varargin{1});
                if (nargin>1) %Image size also provided
                    if ((isnumeric(varargin{2})) && (length(varargin{2})==3))
                        obj=set(obj,'Data',zeros(varargin{2}));
                    else
                        error(['Not a valid size vector; ' ...
                            '[nSamples, nChannels, nSignals].']);
                    end
                end

            end
            obj=set(obj,'Description',...
                    ['NIRSImage' num2str(get(obj,'ID'),'%04i')]);
            %assertInvariants(obj);
        end
    
        %% Get/Set methods    
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.
        
        %probeMode
        function val = get.probeMode(obj)
            % The method is converted and encapsulated. 
            % obj is the nirs_neuroimage class
            % val is the value added in the object
            % get.probeMode(obj) = Get the data from the nirs_neuroimage class
            % and look for the data object.
               warning('ICNA:nirs_neuroimage:get:Deprecated',...
                ['Use of probeMode has now been deprecated. ' ...
                'Please refer to neuroimage.channelLocationMap.']);
            val = obj.probeMode; 
        end
        function obj = set.probeMode(obj,val)
            % The method is converted and encapsulated and can be used 
            % as the example in the constructor method.
            % This method allows the change of data values.
            %   obj is the probeMode class
            %   val = is the provided value, later it is conditioned 
            %   according to the data type.
            warning('ICNA:nirs_neuroimage:set:Deprecated',...
                ['Use of probeMode has now been deprecated. ' ...
                'Please refer to neuroimage.channelLocationMap.']);
            if ischar(val)
                switch(val)
                    case '3x3'
                        obj.probeMode = '3x3';
                    case '4x4'
                        obj.probeMode = '4x4';
                    case '3x5'
                        obj.probeMode = '3x5';
                    otherwise
                        error('ICNA:nirs_neuroimage:set:InvalidParameterValue',...
                              'ProbeMode must be a string ''3x3'', ''4x4'' etc.');
                end
            else
                error('ICNA:nirs_neuroimage:set:InvalidParameterValue',...
                      'ProbeMode must be a string ''3x3'', ''4x4'' etc.');
            end
        end
    end
    
    methods (Static)
        [C,episodes]=detectMirroringv3(x,y,options);
        c=mirroring(x,y,init,ws,tolerance);
        %My optode movement detection algorithm
        [idx,reconstructed,alpha,gamma,allIdx]=detectSuddenChanges(signals,thresholdPC,options);
        [alpha,gamma]=optimizeDESWeights(s);
        [F]=sos_suddenChange(x,s);
        [S,b,f]=doubleES(s,a,g,m);
        %Sato's optode movement detection algorithm
        [idx,reconstructed,idxPeaks]=Sato_detectOptodeMovement(signal,options);
        %Pegna's optode movement detection algorithm
        [idx,reconstructed,idxPeaks]=Pegna_detectOptodeMovement(signal,options);
    end

end