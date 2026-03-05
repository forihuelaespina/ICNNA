classdef qc < icnna.data.core.identifiableObject
% icnna.data.core.qc - Collection of quality control criteria for structuredData.
%
% This class holds multiple @icnna.data.core.qcCriterion objects,
% each representing a different quality control (QC) layer over the
% 3D data tensor in @icnna.data.core.structuredData acting as liaison
% among individual QC criterion and the corresponding structuredData.
%
% Together with the classes @icnna.data.core.timeline,
% @icnna.data.core.montage and @icnna.data.core.signalDescriptors,
% this class completes all the main supporting elements for a
% @icnna.data.core.structuredData.
%
%
% This class is responsible for:
%   - Gathering and managing all @icnna.data.core.qcCriterion associated to
%   an @icnna.data.core.structuredData ensuring that;
%       * |id| and |name| are unique within an @icnna.data.core.structuredData
%       * Ensuring that all @icnna.data.core.qcCriterion have the same
%       size (but note that ensuring that this size matches the
%       data tensor in @icnna.data.core.structuredData is monitored from
%       there.)
%   - Reporting/Resolving inter-criteria QC e.g. whether a sample
%   is compliant with all quality criteria at once, etc.
%
%
% Just like @icnna.data.core.qcCriterion, this class is not aware of
% the operational aspect of how the assumed criterion is operationalized.
%
%
%% Design Philosophy
%
% This class behaves as a light-weight manager rather than a processor.
% Individual logic resides in @qcCriterion.
%
% The class may later support:
%   + Aggregated compliance masks
%   + Cross-criterion logical combination
%   + Global summary statistics
%   + Integrity validation utilities
%
%
%% QC Code Convention (followed but not interpreted)
%
% Also, @icnna.data.core.qc won't be able to understand specific
% QC codes, but will follow the convention; 
%
%   UNCHECK  (-1)
%   OK        (0)
%   FAIL      (1)
%   Specific failure codes > 1
%
% The numeric convention allows this class to reason about:
%   - "Any fail"  → value > 0
%   - "Checked"   → value >= 0
%   - "Unchecked" → value == -1
% 
%
%
%% Properties
%
%   -- Private properties
%   .classVersion - Char array. (Read only. Constant)
%       The class version of the object
%       This is separate from the superclass' own |classVersion|.
%
%   -- Inherited properties
%   .id - uint32. Default is 1.
%       A numerical identifier.
%   .name - Char array. By default is 'qc0001'.
%       A name for the object. 
%
%   -- Private properties
%   .criteria - icnna.data.core.qcCriterion[]
%       User-defined QC criteria.
%
%   -- Derived properties
%   .nCriteria - int
%       Number of icnna.data.core.qcCriterion defined.
%       This is equal to numel(obj.criteria)
%   .size - int[3]
%       The current size of the criteria layers as
%       [nSamples,nChannels,nSignals].
%   .nSamples - int
%       The current number of samples of the criteria layers.
%   .nChannels - int
%       The current number of channels of the criteria layers.
%   .nSignals - int
%       The current number of signals of the criteria layers.
%
%% Methods
%
% Type methods('icnna.data.core.qc') for a list of methods
% 
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also 
%   icnna.data.core.qcCriterion, icnna.data.core.structuredData
%


%% Log
%
%
% -- ICNNA v1.4.0
%
% 27-Feb-2026: FOE
%   File and class created.
%
% 3-Mar-2026: FOE
%   + Improved comments
%   + Some improvements to code
%   + Added methods to check masks; getGlobalMaskAllOK,
%       getGlobalMaskAnyFail, isAllVerified
%   + Added derived property nCriteria, size, nSamples, nChannels, nSignals
%   + Polished error handling
%   + Move the methods to manage the criteria to their own
%   files.
%



    
    properties (Constant, Access = private)
        classVersion = '1.0';
    end
    
    properties (Access = private)
        criteria (:,1) icnna.data.core.qcCriterion = ...
                    icnna.data.core.qcCriterion.empty; % List of qcCriterion
    end

    properties (Dependent)
        nCriteria % Derived property that returns the number of criteria
        size      %The current size of the criteria layers
        nSamples  %The current number of samples of the criteria layers
        nChannels %The current number of channels of the criteria layers
        nSignals  %The current number of signals of the criteria layers
    end
    
    
    methods
    % =====================================================================
    % Constructor
    % =====================================================================
        function obj = qc(varargin)
            % icnna.data.core.qc class constructor
            %
            % obj = icnna.data.core.qc() creates a default object.
            % obj = icnna.data.core.qc(obj2) - acts as a copy constructor
            %
            % Description:
            %   Initializes an empty QC manager with no criteria.
            %
            %   The object:
            %       - Inherits id from identifiableObject
            %       - Automatically assigns a default name
            %       - Initializes an empty criteria struct
            %
            % Notes:
            %   Criteria must be added explicitly using addCriterion().
            %
            %% Error handling:
            %
            %   + Error if more than one input argument is provided.
            %   + Error if input is not a @qc object.
            %
            %
            %% Input parameters:
            %
            %   existingObj (optional)
            %       An instance of @icnna.data.core.qc.
            %       If provided, the object is copied.
            %
            %
            % See also:
            %   addCriterion, listCriteria
            %
            obj@icnna.data.core.identifiableObject();
            tmp = split(class(obj),'.');
            obj.name = [tmp{end} num2str(obj.id,'%04d')];
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.qc')
                obj = varargin{1};
                obj = obj.assertInvariants();
                return;
            else
                error('icnna:data:core:qc:qc:InvalidNumberOfParameters', ...
                      'Unexpected number of parameters.');
            end
        end
        
    % =====================================================================
    % Getters & setters
    % =====================================================================


        


        function res = get.nCriteria(obj)
            % Retrieve the number of defined criteria.
            %
            % res = obj.nCriteria
            % res = get.nCriteria(obj)
            %
            %% Output
            %
            % res - int
            %   Number of elements in property |criteria|
            %
            res = numel(obj.criteria);
        end


        function res = get.size(obj)
            % Retrieve the current size of the criteria layers.
            %
            %   res = obj.size
            %   res = get.size(obj)
            %
            %   Returns the size of the 'layer' property of the
            % first QC criterion, but note that ALL QC criteria ought
            % to have the same size.
            %   The size corresponds to the dimensionality of the
            % criterion layer.
            %
            %   If no criteria are defined, the size will be returned
            % as [0 0 0].
            %
            %% Output:
            %   res - int[3] as [nSamples, nChannels, nSignals].
            %       The size of the criteria layer .
            %
            %   See also:
            %       get.nSamples, get.nChannels, get.nSignals
            %
            if isempty(obj.criteria)
                res = [0 0 0];  % Return empty size when no criteria exist
                return;
            end
            res = size(obj.criteria(1).layer);
        end
        
        function res = get.nSamples(obj)
            % Retrieve the number of samples in the criteria layers.
            %
            %   res = obj.nSamples
            %   res = get.nSamples(obj)
            %
            %   Returns the number of samples (the first dimension)
            % from the 'layer' property of the first QC criterion, but
            % note that ALL QC criteria ought to have the same size.
            %
            %   If no criteria exist, the result will be 0.
            %
            %% Output:
            %   res - int
            %       The number of samples in the criteria layers.
            %
            %   See also:
            %       get.size, get.nChannels, get.nSignals
            %
            res = size(obj.criteria(1).layer, 1);
        end
        
        function res = get.nChannels(obj)
            % Retrieve the number of channels in the criteria layers.
            %
            %   res = obj.nChannels
            %   res = get.nChannels(obj)
            %
            %   Returns the number of channels (the second dimension)
            % from the 'layer' property of the first QC criterion, but
            % note that ALL QC criteria ought to have the same size.
            %
            %
            %   If no criteria exist, the result will be 0.
            %
            %% Output:
            %   res - int
            %       The number of channels in the criteria layers.
            %
            %   See also:
            %       get.size, get.nSamples, get.nSignals
            %
            res = size(obj.criteria(1).layer, 2);
        end
        
        function res = get.nSignals(obj)
            % Retrieve the number of signals in the criteria layers.
            %
            %   res = obj.nSignals
            %   res = get.nSignals(obj)
            %
            %   Returns the number of signals (the third dimension)
            % from the 'layer' property of the first QC criterion, but
            % note that ALL QC criteria ought to have the same size.
            %
            %   If no criteria exist, the result will be 0.
            %
            %% Output:
            %   res - int
            %       The number of signals in the criteria layers.
            %
            %   See also:
            %       get.size, get.nSamples, get.nChannels
            %
            res = size(obj.criteria(1).layer, 3);
        end


    % =====================================================================
    % Other methods
    % =====================================================================


        function mask = getGlobalMaskAllOK(obj)
            % Logical mask where all criteria are OK.
            %
            % mask = getGlobalMaskAllOK(obj)
            % mask = obj.getGlobalMaskAllOK()
            %
            % Returns a logical mask indicating elements that passed
            % ALL stored QC criteria.
            %
            %   Returns a logical 3D mask indicating elements that failed at least
            %   one stored QC criterion.
            %
            %   Failure is defined according to numeric convention:
            %       layer code > 0
            %
            %% Input parameters
            %
            % N/A
            %
            %% Output:
            % mask - logical 3D array
            %   If no criteria exist, returns [].
            %
            % See also:
            %   getGlobalMaskAllOK, isAllVerified
            %

            if isempty(obj.criteria)
                mask = [];
                return;
            end

            mask = true(size(obj.criteria(1).layer));
            for iQC = 1:numel(obj.criteria)
                mask = mask & obj.criteria(iQC).getMaskOK();
            end
        end

        function mask = getGlobalMaskAnyFail(obj)
            % Logical mask where any criteria reports failure.
            %
            % mask = getGlobalMaskAnyFail(obj)
            % mask = obj.getGlobalMaskAnyFail()
            %
            % Returns a logical mask indicating elements that passed
            % ALL stored QC criteria.
            %
            %   Returns a logical 3D mask indicating elements that failed at least
            %   one stored QC criterion.
            %
            %   Failure is defined according to numeric convention:
            %       layer code > 0
            %
            %% Input parameters
            %
            % N/A
            %
            %% Output:
            % mask - logical 3D array
            %   If no criteria exist, returns [].
            %
            % See also:
            %   getGlobalMaskAllOK, isAllVerified
            %

            if isempty(obj.criteria)
                mask = [];
                return;
            end

            mask = false(size(obj.criteria(1).layer));
            for i = 1:numel(obj.criteria)
                mask = mask | obj.criteria(i).getMaskAnyFail();
            end
        end


        function res = isAllVerified(obj)
            % Check if all stored criteria are verified.
            %
            % res = isAllVerified(obj)
            % res = obj.isAllVerified()
            %
            %
            %   Returns true only if every stored
            %   @icnna.data.core.qcCriterion object
            %   has its |verified| flag set to true.
            %
            %
            % Notes:
            %
            %   If no criteria exist, returns true.
            %
            %
            %% Output:
            %
            %   res - logical scalar
            %       True if all stored criteria are verified. False
            %       otherwise.
            %
            %
            % See also:
            %   qcCriterion.isVerified
            %

            res = true;  % Default to true if no criteria exist
            if isempty(obj.criteria)
                return;
            end

            % Iterate over all criteria and check if they are verified
            for iQC = 1:numel(obj.criteria)
                if ~obj.criteria(iQC).isVerified()
                    res = false;  % Found a criterion that is not verified
                    return;
                end
            end
        end

        function res = isComplete(obj)
            % Check if there is no UNCHECK anywhere
            %
            %   res = obj.isComplete()
            %
            %   Returns true only if every stored
            %   @icnna.data.core.qcCriterion object
            %   has no remaining code UNCHECK.
            %
            %
            % Notes:
            %
            %   If no criteria exist, returns true.
            %
            %
            %% Output:
            %
            %   res - logical scalar
            %       True if there is no UNCHECK anywhere. False
            %       otherwise.
            %
            %
            % See also:
            %   qcCriterion.isVerified
            %

            res = true;  % Default to true if no criteria exist
            if isempty(obj.criteria)
                return;
            end

            % Iterate over all criteria and check for "UNCHECK" (-1)
            for i = 1:numel(obj.criteria)
                if any(obj.criteria(i).layer == obj.criteria(i).codes.UNCHECK)
                    res = false;  % Found an "UNCHECK" value
                    return;
                end
            end
        end



        % function disp(obj)
        %     % Display information about the qc object and its criteria
        %     %
        %     % disp(obj) displays the internal properties of the qc object
        %     % and its stored qcCriterion objects, including layer size,
        %     % verification status, and counts of "OK" and "FAIL" elements.
        %     %
        %     fprintf('  <a href="matlab:helpPopup(''icnna.data.core.qc'')">qc</a> with properties:\n');
        %     fprintf('    id: %d\n', obj.id);
        %     fprintf('    number of criteria: %d\n', numel(obj.criteria));
        % 
        %     % Iterate over each criterion in the array and display its details
        %     for i = 1:numel(obj.criteria)
        %         crit = obj.criteria(i);
        %         fprintf('    %s:\n', crit.name);  % Display the criterion name
        %         fprintf('        layer size: %s\n', mat2str(size(crit.layer)));
        %         fprintf('        verified: %d\n', crit.isVerified());
        %         fprintf('        OK count: %d\n', crit.getCountOK());
        %         fprintf('        Fail count: %d\n', crit.getCountAnyFail());
        %     end
        % end
    end

end