classdef nirs_neuroimage < neuroimage
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
% Copyright 2008-23
% @author: Felipe Orihuela-Espina
%
% See also neuroimage
%




%% Log
%
% File created: 13-May-2008
% File last modified (before creation of this log): 22-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Added property classVersion. Set to '1.0' by default.
%   + Added get/set methods support for struct like access to attributes.
%
% 30-Aug-2023: FOE
%   + Activated the constant for CYTOCHROME (Kept classVersion to '1.0'
%       because ICNNA version has not yet been released).
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end



    properties %(SetAccess=private, GetAccess=private)
        %probeMode(:,1) char {mustBeMember(probeMode,{'3x3','4x4','3x5'})} = '3x3'; %DEPRECATED. See superclass neuroimage channelLocationMap
                    %Constraint mustBeMember does NOT work when the string
                    %contains a mixture of letters and numbers. So I can't
                    %use it here, and I need to check this "manually" in
                    % the set method.
        probeMode(:,1) char  = '3x'; %DEPRECATED. See superclass neuroimage channelLocationMap
    end
    properties (Constant=true, GetAccess=public)
        OXY=1;
        DEOXY=2;
        CYTOCHROME=3;
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

            %obj.probeMode = '3x3';
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'nirs_neuroimage')
                obj=varargin{1};
                return;
            else
                obj.id = varargin{1};
                if (nargin>1) %Image size also provided
                    if ((isnumeric(varargin{2})) && (length(varargin{2})==3))
                        obj.data = zeros(varargin{2});
                    else
                        error(['Not a valid size vector; ' ...
                            '[nSamples, nChannels, nSignals].']);
                    end
                end

            end
            obj.description = ['NIRSImage' num2str(obj.id,'%04i')];
            %assertInvariants(obj);
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


    methods


      %Getters/Setters

      function res = get.probeMode(obj)
         %Gets the object |probeMode|
         warning('ICNNA:nirs_neuroimage:probeMode:Deprecated',...
             ['Use of probeMode has now been deprecated. ' ...
             'Please refer to neuroimage.channelLocationMap.']);
         res = obj.probeMode;
      end
      function obj = set.probeMode(obj,val)
         %Sets the object |probeMode|
         warning('ICNNA:nirs_neuroimage:probeMode:Deprecated',...
             ['Use of probeMode has now been deprecated. ' ...
             'Please refer to neuroimage.channelLocationMap.']);
         if ismember(val,{'3x3','4x4','3x5'})
            obj.probeMode = val;
         else
             error('ICNA:nirs_neuroimage:probeMode:InvalidParameterValue',...
                'ProbeMode must be a string ''3x3'', ''4x4'' etc.');
         end
         assertInvariants(obj);
      end

    end


end