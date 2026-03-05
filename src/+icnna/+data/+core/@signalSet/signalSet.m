classdef signalSet < icnna.data.core.identifiableObject
% icnna.data.core.signalSet - Collection of signal descriptors for structuredData.
%
% This class holds multiple @icnna.data.core.signalDescriptor objects,
% each representing one signal dimension in the third axis of the
% 3D data tensor in @icnna.data.core.structuredData.
%
% The class acts as a liaison between individual signalDescriptor
% objects and the corresponding structuredData object.
%
% Together with the classes:
%   @icnna.data.core.timeline,
%   @icnna.data.core.montage,
%   @icnna.data.core.qc,
% this class completes all the main supporting elements for a
% @icnna.data.core.structuredData.
%
%
% This class is responsible for:
%
%   - Gathering and managing all @icnna.data.core.signalDescriptor
%     associated to a structuredData instance ensuring that:
%
%       * |id| and |name| are unique within a signalSet
%       * The number of descriptors matches the 3rd dimension
%         of the data tensor in structuredData
%       * Order consistency between descriptor index and
%         data tensor signal index
%
%   - Acting as semantic bridge for:
%       * Signal labeling
%       * Signal typing (e.g., wavelength, chromophore, derived, etc.)
%       * Signal metadata (units, domain, processing level, etc.)
%
%
% IMPORTANT:
%
%   This class does NOT hold the actual data tensor.
%   It only describes and organizes the signal dimension.
%
%
%% Design Philosophy
%
% This class behaves as a light-weight semantic manager rather than
% a data container.
%
% Individual signal meaning resides in @icnna.data.core.signalDescriptor.
%
% The class may later support:
%
%   + Logical grouping of signals
%   + Filtering by type or domain
%   + Signal dependency graphs
%   + Validation against structuredData third dimension
%   + Automatic signal index remapping
%
%
%% Properties
%
%   -- Private properties
%   .classVersion - Char array. (Read only. Constant)
%       The class version of the object.
%
%   -- Inherited properties
%   .id - uint32. Default is 1.
%       A numerical identifier.
%
%   .name - Char array.
%       Default is 'signalSet0001'.
%
%   -- Private properties
%   .descriptors - icnna.data.core.signalDescriptor[]
%       User-defined signal descriptors.
%
%   -- Derived properties
%   .nSignals - int
%       Number of signalDescriptor objects stored.
%   .signalNames - cellstr
%       Cell array of descriptor names.
%
%
%% Methods
%
% Type methods('icnna.data.core.signalSet') for a list of methods.
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also
%   icnna.data.core.signalDescriptor,
%   icnna.data.core.structuredData
%   icnna.data.core.signalSet.addSignalDescriptors
%   icnna.data.core.signalSet.removeSignalDescriptors
%


%% Log
%
% -- ICNNA v1.4.0
%
% 4-Mar-2026: FOE
%   File and class created.
%

    properties (Constant, Access = private)
        classVersion = '1.0';
    end

    properties (Access = private)
        descriptors (:,1) icnna.data.core.signalDescriptor = ...
                icnna.data.core.signalDescriptor.empty; % Internal storage of @icnna.data.core.signalDescriptor objects
    end

    properties (Dependent)
        nSignals      % Number of stored signalDescriptor objects
        signalNames   % Cell array of descriptor names
    end


    methods
    % =====================================================================
    % Constructor
    % =====================================================================
        function obj = signalSet(varargin)
            % icnna.data.core.signalSet class constructor
            %
            % obj = icnna.data.core.signalSet()
            %   Creates a default empty signalSet object.
            %
            % obj = icnna.data.core.signalSet(obj2)
            %   Acts as a copy constructor.
            %
            %
            % Description:
            %
            %   Initializes an empty signal manager with no descriptors.
            %
            %   The object:
            %       - Inherits id from identifiableObject
            %       - Automatically assigns a default name
            %       - Initializes an empty descriptor list
            %
            %
            % Notes:
            %
            %   Signal descriptors must be added explicitly
            %   using addSignalDescriptor().
            %
            %
            %% Error handling
            %
            %   + Error if more than one input argument is provided.
            %   + Error if input is not a @signalSet object.
            %
            %% Input parameters:
            %
            %   existingObj (optional)
            %       An instance of @icnna.data.core.qc.
            %       If provided, the object is copied.
            %
            %

            obj@icnna.data.core.identifiableObject();
            tmp = split(class(obj),'.');
            obj.name = [tmp{end} num2str(obj.id,'%04d')];

            if nargin == 0
                % Keep default values

            elseif isa(varargin{1}, 'icnna.data.core.signalSet')
                obj = varargin{1};
                obj = obj.assertInvariants();
                return;

            else
                error('icnna:data:core:signalSet:signalSet:InvalidNumberOfParameters', ...
                      'Unexpected number of parameters or unsupported type.');
            end
        end


    % =====================================================================
    % Getters
    % =====================================================================

        function res = get.nSignals(obj)
            % Retrieve the number of defined signal descriptors.
            %
            %   res = obj.nSignals
            %   res = get.nSignals(obj)
            %
            %% Output:
            %   res - int
            %       Number of elements in property |descriptors|
            %

            res = numel(obj.descriptors);
        end


        function res = get.signalNames(obj)
            % Retrieve the list of signal descriptor names.
            %
            %   res = obj.signalNames
            %
            %% Output:
            %   res - cellstr
            %       Cell array containing the |name| of each
            %       stored signalDescriptor.
            %
            res = {obj.descriptors.name};
        end
    end


    % =====================================================================
    % Other methods
    % =====================================================================

    methods
        % Signal descriptor manipulation - Methods implemented in separate files
        obj = addSignalDescriptors(obj, desc);
        obj = removeSignalDescriptors(obj, tags);
        obj = setSignalDescriptors(obj, desc);
        desc = getSignalDescriptors(obj, val);
        idx = findSignalDescriptors(obj, tags);
        obj = clearSignalDescriptors(obj);
        [ids, names] = getSignalDescriptorList(obj);
        obj = assertInvariants(obj);
    end

end