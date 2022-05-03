%Class integrityStatus
%
%IntegrityStatus keeps track of the integrity checks
%performed on a certain data.
%
%Basically it holds a list of integrity codes to track a number of
%elements. The class is however blind to what these elements represent.
%
%An element is consider clean as long as it is UNCHECKed or it
%has been labelled as FINE.
%
%% Properties
%
%   .elements - The list of intergrity codes for the tracked elements
%
% == Integrity Codes (Constant)
%   .UNCHECK            = -1;
%   .FINE               = 0;
%   .MISSING            = 1;
%   .NOISE              = 2;
%   .OTHER              = 3;
%         
%   .MIRRORING          = 11; - Saturation of 1 wavelength
%   .NONRECORDINGS      = 12; - Saturation of 2 wavelengths
%   .NEGATIVERECORDINGS = 13; - Negative Light recordings /Complex Numbers
%   .OPTODEMOVEMENT     = 14;
%   .HEADMOTION         = 15;
%
%% References
%
% 1) Orihuela-Espina, F.; Leff, D.R.; Darzi, A.W.; Yang, G.Z.
%    (2008) Data integrity in functional near infrared
%    spectroscopy. Submitted to PHYSICS IN MEDICINE AND BIOLOGY
%
%% Methods
%
% Type methods('integrityStatus') for a list of methods
% 
% Copyright 2008
% date: 14-May-2008
% Author: Felipe Orihuela-Espina
%
% See also neuroimage, nirs_neuroimage, channel
%
% 02-May-2022 (ESR): integrityStatus class SetAccess=private, GetAccess=private) removed
%   + The access from private to public was commented because before the data 
%   did not request to enter the set method and now they are forced to be executed, 
%   therefore the private accesses were modified to public.
%
classdef integrityStatus
    properties %(SetAccess=private, GetAccess=private)
        elements=[];
    end
    properties (Constant=true, GetAccess=public)
        %Integrity Codes
        UNCHECK            = -1;
        FINE               = 0;
        MISSING            = 1;
        NOISE              = 2;
        OTHER              = 3;
        
        MIRRORING          = 11; %Saturation of 1 wavelength
        NONRECORDINGS      = 12; %Saturation of 2 wavelengths
        NEGATIVERECORDINGS = 13; %Negatiev Light recordings
        OPTODEMOVEMENT     = 14;
        HEADMOTION         = 15;
    end
    methods
        function obj=integrityStatus(varargin)
            %INTEGRITYSTATUS IntegrityStatus class constructor
            %
            % obj=integrityStatus() Creates a default integrityStatus
            %   object with no elements to track.
            %
            % obj=integrityStatus(obj2) acts as a copy constructor for
            %   integrityStatus.
            %
            % obj=integrityStatus(nelem) creates a new integrityStatus
            %   object to track nelem number of elements. The number of
            %   elements to track must be a positive integer, otherwise
            %   a warning message is delivered and nelem is simply
            %   ignored.
            %
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'integrityStatus')
                obj=varargin{1};
                return;
            else
                nelem=varargin{1};
                if ((isscalar(nelem)) && (nelem==floor(nelem)) ...
                        && (nelem>=0))
                    obj.elements=obj.UNCHECK*ones(1,nelem);
                else
                    warndlg('Invalid number of elements',...
                            'integrityStatus');
                end
            end
            %assertInvariants(obj);
        end
    end
end
            