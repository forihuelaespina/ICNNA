classdef montage < icnna.data.core.identifiableObject
% icnna.data.core.montage - A montage describes the spatial arrangement of sensing points (measurements) collected by some sensing (measuring) device
%
%   This is an abstract class.
%
% This class provides a ligther alternative to class
%   @channelLocationMap and it is only intended to act as a convenient 
%   superclass to other montage classes specialised for different
%   sensing modalities e.g. @icnna.data.core.nirsMontage. This new
%   solution means that every sensing modality only has its bespoken
%   montage class rather than a monolithic @channelLocationMap.
%
% A @icnna.data.core.montage provides support to describe a spatial 
% sensing geometry; that is, the arrangement of sensing locations (pixels,
% voxels, channels, etc) over a surface or volume.
%
% Of particular interest for ICNNA; is the surface or volume is the
% human body (biomedical imaging), and even of more interest
% the human head (for fNIRS). But such specifics is left to implementing
% classes.
%
%% Montages vs sensing geometries
%
% Sensing geometry is likely a more formal mathematical
% term for what the neuroimaging community refers to as
% a montage. A sensing geometry establishes the locations
% where the observations are acquired in the sampling
% space.
%
% Strictly speaking a sensing geometry may also consider
% time, whereas this montage class only consider spatial
% arrangements.
%
% Each sensing location may receive different names
% depending on the domain of application with common ones
% being pixels, voxels, or channels.
%
% There are two major ways to refer to these sensing locations;
%  + By its coordinates (following some basis of the sampling space), or
%  + by a logical name according to some positioning system.
%
% Both ways of are modelled in ICNNA with the class
% @icnna.data.core.referenceLocation, however the way in which specific
% implementing classes make use of the reference locations is up to them,
% so do not assume that a montage is simply a collection of sampling
% locations. This has to do with the fact that the sensing locations for
% different sensing modalities emerge from different physical principles.
% For instance, in EEG/EKG the sampling location is where the electrode
% are but the montage itself may also impose some kind of differential
% behaviour (or not), whereas as in fNIRS the sampling location covers a
% whole volume often assumed to be in the mid-point between the light
% source and detector, i.e. the channel. Other sensing modalities may
% yield sampling locations by very different means.
%
% Finally, a sampling location in a montage may yield one or more than
% one measurements depending on the nature of the sensing modality as well
% as the modelling of the sampling space.
%
%
%
%% Known subclasses
%
% icnna.data.core.nirsMontage - A montage for an fNIRS neuroimaging.
%
%
%% Properties
%
%
%   -- Private properties
%   .classVersion - Char array. (Read only. Constant)
%       The class version of the object
%       This is separate from the superclass' own |classVersion|.
%
%   -- Inherited properties
%   .id - uint32. Default is 1.
%       A numerical identifier.
%   .name - Char array. Default is 'montage0001'
%       The montage name.
%
%   -- Public properties
%   .samplingLocationName - char[]. Default is 'pixel'.
%       The common name to refer to the sampling location in the sensing
%       modality at hand, e.g. 'pixel', 'voxel', 'channel', etc
%       It is recommended that the constructor of the implementing
%       classes redefine this in their constructors.
%
%
%% Dependent properties
%
%   .nSamplingLocations - (Abstract) Int. Read-only.
%       The total number of sampling locations in the montage.
%       Implementing classes may have additional properties with
%       a similar purpose and value, e.g. |nChannels|.
%
%% Methods
%
% Type methods('icnna.data.core.montage') for a list of methods
% 
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also 
%




%% Log
%
%   + Class available since ICNNA v1.4.0
%
% 23-Dec-2025: FOE
%   + File and class created
%
%


    properties (Constant, Access=private)
        classVersion = '1.2'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        samplingLocationName(1,:) char = 'pixel';
    end

    properties (Abstract = true, Dependent = true)
        nSamplingLocations; %Number of sampling locations. 
    end


    % =====================================================================
    % Constructor
    % =====================================================================
    methods
        function obj=montage(varargin)
            %Constructor for class @icnna.data.core.montage
            %
            % obj=icnna.data.core.montage() creates a default empty montage.
            % obj=icnna.data.core.montage(obj2) acts as a copy constructor
            %
            % This is an abstract class. You cannot create objects of this
            % class directly. Check any of the implementing classes.
            % 
            % Copyright 2025
            % @author: Felipe Orihuela-Espina
            %

            obj@icnna.data.core.identifiableObject();
            tmp = split(class(obj),'.');
            obj.name = [tmp{end} num2str(obj.id,'%04d')];
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.montage')
                obj = varargin{1};
                return;
            else
                error(['icnna.data.core.montage:montage:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);
            end
            %assertInvariants(obj);
        end
    end

    

    % =====================================================================
    % Getters & setters
    % =====================================================================
    methods
         %Gets the object |samplingLocationName|
      function res = get.samplingLocationName(obj)
            % Getter for |samplingLocationName|:
            %   Returns the value of the |samplingLocationName| property.
            %
            % The common name to refer to the sampling location in the
            % sensing modality at hand, e.g. 'pixel', 'voxel', 'channel',
            % etc
            %
            % Usage:
            %   res = obj.samplingLocationName;  % Retrieve sampling location name
            %
            %% Output
            % res - char[]
            %   The sampling location name.
            %
         res = obj.samplingLocationName;
      end
         %Sets the object |samplingLocationName|
      function obj = set.samplingLocationName(obj,val)
            % Setter for |samplingLocationName|:
            %   Sets the |samplingLocationName| property in Hz.
            %
            % The common name to refer to the sampling location in the
            % sensing modality at hand, e.g. 'pixel', 'voxel', 'channel',
            % etc
            %
            % Usage:
            %   obj.samplingLocationName = 'pixel';  % Set the sampling location name to 'pixel'
            %
            %% Input parameters
            %
            % val - char[]
            %   The new sampling location name.
            %
            %% Output
            %
            % obj - @icnna.data.core.montage
            %   The updated object
            %
            %
            obj.samplingLocationName = val;
      end

    end




end
