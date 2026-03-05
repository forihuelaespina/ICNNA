classdef qcCriterion < icnna.data.core.identifiableObject
% icnna.data.core.qcCriterion - A single quality control criterion for structuredData.
%
% Each @icnna.data.core.qcCriterion object represents a 3D layer over
% the data tensor of @icnna.data.core.structuredData, with enumerated
% codes indicating the quality of each data point according to this
% quality control criterion. 
%
% An @icnna.data.core.qcCriterion is a "bitmap" like (although
% not boolean but int)of a sample by sample compliance with the
% quality criterion at hand. There may be as many
% @icnna.data.core.qcCriterion as one need to support an
% @icnna.data.core.structuredData; these are collected in and managed
% through an @icnna.data.core.qc.
%
% The layer is designed to hold a set of user-definable enumerated codes,
% where:
%   * UNCHECK (-1)  : Mandatory. Always defined. Sample has not been checked
%   * OK      (0)   : Mandatory. Always defined. Sample passed QC
%   * FAIL     (1)  : Mandatory. Always defined. Sample did not passed
%                       QC. Generic fail.
%   * PROBLEM_X (2) : User defined. Sample did not passed
%                       QC but failed for a specific reason. Example problem
%   * ISSUE_Y   (3) : Example issue
%
% Additional user-defined codes can be added for other fail reasons, but
% UNCHECK, OK and (generic) FAIL are fixed. Note that any user defined
% constant ONLY represent different failing reasons, but there is only
% one OK value.
% User defined enumerated labels will always have an associated constant
% value that is positive.
%
% This class is responsible for:
%   - Holding the 3D layer data
%   - Storing the list of valid QC codes
%   - Indicating whether this criterion has been applied or verified
%
% Note that this class itself is not aware of the operational aspect of
%how the assumed criterion is operationalized. This is delegated to an
%external method that upon being called will yield an object of this
%class. See property |qcOperator|
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
%   .name - Char array. By default is 'qcCriterion0001'.
%       A name for the object. 
%
%   -- Private properties
%   .description - char[]
%       A short description of the criterion
%
%   .layer - int8[nSamples,nChannels,nSignals]. Default is UNCHECK for each entry.
%       The 3D data check layer storing the QC outcome codes for this
%       criterion. The only valid codes are the constants defined in
%       |codes|.
%
%       In the layer, all codes can coexist for different elements. That is,
%       there may be elements set to UNCHECK, some others set to OK, some
%       others set to generic FAIL and finally some other set to more specific
%       user defined failure reasons.
%
%       NOTE: When in used as part of an @icnna.data.core.qc for
%       an @icnna.data.core.structuredData, the size of [nSamples,
%       nChannels,nSignals] is determined by the data tensor in
%       @icnna.data.core.structuredData. But this class does not
%       check for this size.
%
%   .qcOperator - handle to method. Default is empty.
%       The handle to the method that operationalizes the quality control
%       criterion. This method shall produce as output an 
%       @icnna.data.core.qcCriterion.
%
%       The static method .execute calls this qcOperator and returns
%       an instance of this qcCriterion already |verified|.
%
%   .verified - logical. Default is false i.e. unverified.
%       Flag indicating if this QC criterion has been applied/verified
%       or it is pending execution.
%       True if this QC criterion has been applied/verified.
%       False otherwise.
%
%   .codes - struct
%       (Criterion outcomes). Enumerated codes for this QC criterion.
%       Must always include UNCHECK (-1), OK (0) and generic FAIL (1).
%       Additional codes for different fail reasons can be defined
%       by the user, e.g.
%
%           obj.codes.PROBLEM_X = 2;
%           obj.codes.ISSUE_Y   = 3;
%
%       There cannot be different labels associated to the same codes.
%       At present the maximum number of user defined criterion outcomes
%       is limited to 127 (as property layer is based on int8 and negative
%       codes as reserved.)
%
%% Methods
%
% Type methods('icnna.data.core.qcCriterion') for a list of methods
% 
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also 
%   icnna.data.core.qc, icnna.data.core.structuredData
%



%% Log
%
%
% -- ICNNA v1.4.0
%
% 27-Feb-2026: FOE
%   File and class created.
%

    
    properties (Constant, Access = private)
        classVersion = '1.0';
    end
    
    properties (Access = private)
        layer_ int8                      = int8(ones(0,0,0)*-1);      % 3D data layer
        verified_ logical                = false;   % QC verification status
        codes_ struct                    = struct(); % Enumerated codes
        description_ char                = ''  % Short description
        qcOperator_ function_handle      ;  % Handle to operator function. DO NOT INITIALIZE HERE!
    end

    %And the public counterparts
    properties (Dependent)
        layer
        description
        codes
        verified
        qcOperator
    end
    
    methods
    % =====================================================================
    % Constructor
    % =====================================================================
        function obj = qcCriterion(varargin)
            % icnna.data.core.qcCriterion class constructor
            % 
            % obj = icnna.data.core.qcCriterion() - empty quality control layer
            % obj = icnna.data.core.qcCriterion(obj2) - acts as a copy constructor
            % obj = icnna.data.core.qcCriterion(sizeArray) - initializes a zero/unchecked layer
            %
            % Example:
            %   qc = icnna.data.core.qcCriterion([10,5,3]);
            %% Input Parameters:
            %
            %   sizeArray - 1x3 numeric vector [nSamples, nChannels, nSignals]
            %
            %% Output:
            %   obj - @qcCriterion object
            %
            
            obj@icnna.data.core.identifiableObject();
            tmp = split(class(obj),'.');
            obj.name = [tmp{end} num2str(obj.id,'%04d')];
            
            % Initialize default enumerated codes
            obj.codes = struct('UNCHECK', -1, 'OK', 0, 'FAIL', 1);

            obj.qcOperator_ = @()[];  % a dummy empty function handle
            
            if nargin == 0
                % Empty layer
                obj.layer = int8(obj.codes.UNCHECK * ones(0,0,0));
            elseif nargin == 1
                sz = varargin{1};
                validateattributes(sz, {'numeric'}, ...
                                    {'vector','numel',3,'positive','integer'});
                % Initialize with UNCHECK
                obj.layer = int8(obj.codes.UNCHECK * ones(sz));
            else
                error('icnna:data:core:qcCriterion:qcCriterion:InvalidNumberOfParameters', ...
                      'Unexpected number of parameters.');
            end
        end
        
    % =====================================================================
    % Getters & setters
    % =====================================================================

        %Retrieves the object |layer|
        function res = get.layer(obj)
            % Getter for |layer|:
            %   Returns the |layer| property.
            %
            % Notes:
            %   - Layer may be empty (0x0x0) if not initialized
            %   - Codes are restricted to obj.codes
            %
            % Usage:
            %   res = obj.layer;  % Retrieves the 3D data check layer
            %                     % storing the QC outcome codes for this
            %                     %criterion.
            %
            %% Output
            % res - int8[nSamples,nChannels,nSignals]
            %   The 3D data check layer storing the QC outcome codes
            % for this criterion.
            %
            res = obj.layer_;
        end
        %Sets the object |layer|
        function obj = set.layer(obj,val)
            % Setter for |layer|:
            %   Sets the |layer| property.
            %
            % The 3D data check layer storing the QC outcome codes
            % for this criterion.
            %
            % Usage:
            %   obj.layer = obj.codes.OK * ones(size(obj.layer));  % Set the |layer| to OK.
            %                                   %But see also method .setOK
            %   obj.layer(iSample,jChannel,kSignal) = obj.codes.FAIL
            %                                   %But see also method .setFAIL
            %
            %% Input parameters
            %
            % val - int8[nSamples,nChannels,nSignals]
            %   The new |layer|.
            %   Codes are restricted to obj.codes
            %
            %% Output
            %
            % obj - @icnna.data.core.qcCriterion
            %   The updated object
            %
            validateattributes(val, {'numeric'}, {'3d'});

            %Check that all codes are defined
            enumVals = int8(cell2mat(struct2cell(obj.codes)));
            if ~all(ismember(int8(val(:)), enumVals))
                error('icnna:data:core:qcCriterion:setLayer:UndefinedCodes', ...
                        'Undefined codes.');
            end            
            obj.layer_ = int8(val);
            obj = obj.assertInvariants();
        end
    
        %Retrieves the object |codes|
        function res = get.codes(obj)
            % Getter for |codes|:
            %   Returns the |codes| property.
            %
            % Usage:
            %   res = obj.codes;  % Retrieves the qc outcome codes
            %
            %% Output
            % res - struct
            %   Enumerated codes for this QC criterion.
            %
            res = obj.codes_;
        end
        %Sets the object |codes|
        function obj = set.codes(obj,val)
            % Setter for |codes|:
            %   Sets the |codes| property.
            %
            % Enumerated codes for this QC criterion.
            %
            % Usage:
            %   obj.codes = val;  % Set |codes| to val.
            %
            %% Error handling
            %
            % + If codes are changed after the QC criterion is verified
            %   a warning is issued indicating the |verified| may be
            %   obsolete.
            %
            %% Input parameters
            %
            % val - struct
            %       (Criterion outcomes). Enumerated codes for this QC criterion.
            %       Must always include UNCHECK (-1), OK (0) and generic FAIL (1).
            %       Additional codes for different fail reasons can be defined
            %       by the user, e.g.
            %
            %           obj.codes.PROBLEM_X = 2;
            %           obj.codes.ISSUE_Y   = 3;
            %
            %       There cannot be different labels associated to the same codes.
            %       At present the maximum number of user defined criterion outcomes
            %       is limited to 127 (as property layer is based on int8 and negative
            %       codes as reserved.)
            %
            %% Output
            %
            % obj - @icnna.data.core.qcCriterion
            %   The updated object
            %
            validateattributes(val, {'struct'}, {'scalar'});
            obj.codes_ =  val;
            obj = obj.assertInvariants();

            if obj.verified_
                warning('icnna:data:core:qcCriterion:setCodes:UncheckedCodes', ...
                    'If codes changes, verification status may become obsolete.');
            end
        end
    
    
        %Retrieves the object |verified|
        function res = get.verified(obj)
            % Getter for |verified|:
            %   Returns the |verified| property.
            %
            % Usage:
            %   res = obj.verified;  % Retrieves the flag indicating whether
            %                        % this QC criterion has been applied/verified
            %                        % or it is pending execution.
            %
            %% Output
            % res - logical
            %   Flag indicating whether this QC criterion has been
            %   applied/verified or it is pending execution.
            %
            % See also
            %   isVerified
            %
            res = obj.verified_;
        end
        %Sets the object |verified|
        function obj = set.verified(obj,val)
            % Setter for |verified|:
            %   Sets the |verified| property.
            %
            %   Flag indicating whether this QC criterion has been
            %   applied/verified or it is pending execution.
            %
            % Usage:
            %   obj.verified = true;  % Confirm that the QC criterion has
            %                         %been check
            %
            %% Error handling
            %
            %  + If |verified| is set to true and there remains
            %  codes in |layer| equal to UNCHECK, a warning is thrown.
            %
            %% Input parameters
            %
            % val - logical
            %   True if this QC criterion has been applied/verified.
            %   False otherwise.
            %
            %
            %% Output
            %
            % obj - @icnna.data.core.qcCriterion
            %   The updated object
            %
            validateattributes(val, {'logical'}, {'scalar'});
            if val
                if any(obj.layer(:) == obj.codes.UNCHECK)
                    warning('icnna:data:core:qcCriterion:setVerified:UncheckedCodes', ...
                        'Setting verified=true while UNCHECK codes remain in layer.');
                end
            end
            obj.verified_ = val;
        end
    
        %Retrieves the object |description|
        function res = get.description(obj)
            % Getter for |description|:
            %   Returns the |description| property.
            %
            % Usage:
            %   res = obj.description;  % Retrieves the description of the QC criterion
            %
            %% Output
            % res - char[]
            %   The description of the QC criterion
            %
            res = obj.description_;
        end
        %Sets the object |description|
        function obj = set.description(obj,val)
            % Setter for |description|:
            %   Sets the |description| property.
            %
            % Usage:
            %   obj.description = 'Detector (wavelength l=830 [nm]) saturation'
            %
            %% Input parameters
            %
            % val - char[]
            %   The new description
            %
            %% Output
            %
            % obj - @icnna.data.core.qcCriterion
            %   The updated object
            %
            validateattributes(val, {'char','string'});
            obj.description_ = char(val);
        end
    


        function res = get.qcOperator(obj)
            % Getter for |qcOperator|:
            %   Returns the |qcOperator| property.
            %
            % The qcOperator is a function handle that operationalizes this
            % quality control criterion. When executed, it must return an
            % @icnna.data.core.qcCriterion object.
            %
            % Usage:
            %   fh = obj.qcOperator;
            %
            %% Output
            % res - function_handle
            %   Handle to the QC operator function.
            %   May be empty if not yet defined.
            %
            % See also
            %   set.qcOperator, execute
            %
        
            res = obj.qcOperator_;
        end
        function obj = set.qcOperator(obj,val)
            % Setter for |qcOperator|:
            %   Sets the |qcOperator| property.
            %
            % The qcOperator must be a function handle that, when called,
            % returns an @icnna.data.core.qcCriterion object.
            %
            % The operator must return a fully constructed qcCriterion
            % with consistent size and codes.
            %
            % Usage:
            %   obj.qcOperator = @myOperator;
            %
            %% Input parameters
            %
            % val - function_handle
            %   Handle to a function implementing the QC criterion.
            %
            %% Error handling
            %
            %   + Error if val is not a function_handle.
            %
            %% Output
            %
            % obj - @icnna.data.core.qcCriterion
            %   The updated object.
            %
            % See also
            %   get.qcOperator, execute
            %
        
            validateattributes(val, {'function_handle'}, {'scalar'});
            obj.qcOperator_ = val;
        end


    % =====================================================================
    % Other methods
    % =====================================================================

        
        
        function res = isVerified(obj)
            % Checks whether the QC criterion verified flag is true.
            %   Returns (|verified|==true).
            %
            % Usage:
            %   res = obj.isVerified();
            %   res = isVerified(obj);
            %
            %% Output
            % res - logical
            %   Flag indicating whether this QC criterion has been
            %   applied/verified or it is pending execution.
            %
            % See also
            %   get.verified
            %
            res = obj.verified_;
        end

        function obj = setValue(obj,value,varargin)
            % setValue - Set all or part of the QC layer to a given value.
            %
            % This method assigns a QC outcome value to the entire layer
            % or to a selected subset of its elements.
            %
            % Usage:
            %   obj = obj.setValue(value);
            %       Sets the entire layer to |value|.
            %
            %   obj = obj.setValue(value, idx);
            %       Sets the elements specified by linear indices |idx|.
            %
            %   obj = obj.setValue(value, i, j, k);
            %       Sets elements specified by subscript indices.
            %       Supports ':' as full selection.
            %
            % Examples:
            %   obj = obj.setValue(obj.codes.FAIL);
            %   obj = obj.setValue(obj.codes.FAIL, [14 567:590 820]);
            %   obj = obj.setValue(obj.codes.FAIL, 2:3, 23, :);
            %
            %% Error handling
            %
            %  + Error if |value| is not defined in |codes|.
            %  + Error if indexing exceeds layer dimensions.
            %
            %% Input parameters
            %
            % value - int8 / numeric scalar
            %   Must correspond to one of the enumerated codes defined in
            %   property |codes|.
            %
            % varargin -
            %   Either:
            %       []                → whole layer
            %       linearIndices     → linear indexing e.g. as in sub2ind
            %       i,j,k             → subscript indexing
            %
            %% Output
            %
            % obj - @icnna.data.core.qcCriterion
            %   The updated object.
            %
            % See also:
            %   setUNCHECK, setOK, setFAIL
            %

            % --- Validate value ---
            validateattributes(value, {'numeric'}, {'scalar','integer'});
            value = int8(value);

            enumVals = cell2mat(struct2cell(obj.codes));
            if ~ismember(value, enumVals)
                error('icnna:data:core:qcCriterion:setValue:InvalidValue', ...
                    'Value is not defined in obj.codes.');
            end

            % --- If layer is empty ---
            if isempty(obj.layer)
                error('icnna:data:core:qcCriterion:setValue:EmptyLayer', ...
                    'Layer is empty. Initialize it before assigning codes.');
            end

            % --- Full layer assignment ---
            if isempty(varargin)
                obj.layer(:) = value;

            % --- Linear indexing ---
            elseif numel(varargin) == 1
                idx = varargin{1};
                validateattributes(idx, {'numeric'}, {'integer','positive'});

                if any(idx > numel(obj.layer))
                    error('icnna:data:core:qcCriterion:setValue:InvalidIndexing', ...
                    'Index out of bounds.');
                end                
                obj.layer(idx) = value;

            % --- Subscript indexing ---
            elseif numel(varargin) == 3
                obj.layer(varargin{:}) = value;

            else
                error('icnna:data:core:qcCriterion:setValue:InvalidIndexing', ...
                    'Indexing must be either linear or i,j,k.');
            end

            obj = obj.assertInvariants();
        end



        function obj = setUNCHECK(obj,varargin)
            % Set all or part of the layer to UNCHECK (-1).
            %
            % Usage:
            %   obj = obj.setUNCHECK();
            %   obj = obj.setUNCHECK(idx);
            %   obj = obj.setUNCHECK(i,j,k);
            %
            % Examples:
            %   obj = obj.setUNCHECK();
            %   obj = obj.setUNCHECK([14 567:590 820]);
            %   obj = obj.setUNCHECK(2:3, 23, :);
            %
            % See also:
            %   setValue, setOK, setFAIL
            %

            obj = obj.setValue(obj.codes.UNCHECK, varargin{:});
        end

        function obj = setOK(obj,varargin)
            % Set all or part of the layer to OK (0).
            %
            % Usage:
            %   obj = obj.setOK();
            %   obj = obj.setOK(idx);
            %   obj = obj.setOK(i,j,k);
            %
            % Examples:
            %   obj = obj.setOK();
            %   obj = obj.setOK([14 567:590 820]);
            %   obj = obj.setOK(2:3, 23, :);
            %
            % See also:
            %   setValue, setUNCHECK, setFAIL
            %

            obj = obj.setValue(obj.codes.OK, varargin{:});
        end


        function obj = setFAIL(obj,varargin)
            % Set all or part of the layer to generic FAIL (1).
            %
            % Usage:
            %   obj = obj.setFAIL();
            %   obj = obj.setFAIL(idx);
            %   obj = obj.setFAIL(i,j,k);
            %
            % Examples:
            %   obj = obj.setFAIL();
            %   obj = obj.setFAIL([14 567:590 820]);
            %   obj = obj.setFAIL(2:3, 23, :);
            %
            % Notes:
            %   FAIL represents generic failure. More specific failure
            %   reasons may be defined in |codes| with positive integers > 1.
            %
            % See also:
            %   setValue, setOK, setUNCHECK
            %

            obj = obj.setValue(obj.codes.FAIL, varargin{:});
        end





        function mask = getMaskUNCHECK(obj)
            % Logical mask of UNCHECK entries.
            %
            % Usage:
            %   mask = obj.getMaskUNCHECK();
            %
            %% Output:
            %   mask - logical[nSamples,nChannels,nSignals]
            %       True where layer == UNCHECK.
            %
            % See also:
            %   getMaskOK, getMaskAnyFail, getMaskChecked

            mask = (obj.layer == obj.codes.UNCHECK);
        end


        function mask = getMaskOK(obj)
            % Logical mask of OK entries.
            %
            % Usage:
            %   mask = obj.getMaskOK();
            %
            %% Output:
            %   mask - logical array
            %       True where layer == OK.

            mask = (obj.layer == obj.codes.OK);
        end


        function mask = getMaskFAIL(obj)
            % Logical mask of generic FAIL entries only.
            %
            % Usage:
            %   mask = obj.getMaskFAIL();
            %
            % Notes:
            %   Does NOT include specific failure reasons (>1).
            %
            %% Output:
            %   mask - logical array
            %       True where layer == FAIL (generic fail only).
            %
            %
            % See also:
            %   getMaskAnyFail

            mask = (obj.layer == obj.codes.FAIL);
        end


        function mask = getMaskAnyFail(obj)
            % Logical mask of any failure.
            %
            % Usage:
            %   mask = obj.getMaskAnyFail();
            %
            % Notes:
            %   Includes generic FAIL (1) and all specific failure
            %   reasons (>1).
            %
            %   Exploits numeric ordering of enumerated codes.
            %
            %% Output:
            %   mask - logical array
            %       True where layer > OK.
            %

            mask = (obj.layer > obj.codes.OK);
        end

        function mask = getMaskChecked(obj)
            % Logical mask of checked elements.
            %
            % Usage:
            %   mask = obj.getMaskChecked();
            %
            % Notes:
            %   Equivalent to:
            %       layer >= OK
            %   but written explicitly for clarity.
            %
            % Output:
            %   mask - logical array
            %       True where layer ~= UNCHECK.
            %

            mask = (obj.layer ~= obj.codes.UNCHECK);
        end

        function mask = getMaskValue(obj,value)
            % Logical mask for a specific enumerated value.
            %
            % Usage:
            %   mask = obj.getMaskValue(value);
            %
            % Example:
            %   mask = obj.getMaskValue(obj.codes.PROBLEM_X);
            %
            %% Error handling:
            %   + Error if value is not defined in obj.codes.
            %
            %% Input parameters:
            %   value - scalar numeric
            %       Must correspond to one of obj.codes.
            %
            %% Output:
            %   mask - logical array
            %       True where layer == value.
            %

            validateattributes(value, {'numeric'}, {'scalar','integer'});
            value = int8(value);

            enumVals = cell2mat(struct2cell(obj.codes));
            if ~ismember(value, enumVals)
                error('icnna:data:core:qcCriterion:getMaskValue:InvalidValue', ...
                    'Value is not defined in obj.codes.');
            end

            mask = (obj.layer == value);
        end

        function n = getCountOK(obj)
            % getCountOK - Count the number of OK entries in the layer.
            %
            % Returns the total number of elements in |layer| whose value
            % corresponds to the enumerated constant |OK|.
            %
            % Usage:
            %   n = obj.getCountOK();
            %   n = getCountOK(obj);
            %
            %% Output
            % n - double
            %   Number of elements in |layer| equal to obj.codes.OK.
            %
            %% Notes
            %   - Only elements exactly equal to |OK| (typically 0) are counted.
            %   - UNCHECK (-1) and any failure codes (>0) are excluded.
            %   - If |layer| is empty, n = 0.
            %
            %   This method is typically used to assess the amount of data
            %   that passed this quality control criterion.
            %
            % See also
            %   getCountAnyFail, getMaskOK, getMaskAnyFail
            n = nnz(obj.layer == obj.codes.OK);
        end

        function n = getCountAnyFail(obj)
            % getCountAnyFail - Count the number of failing entries.
            %
            % Returns the total number of elements in |layer| that represent
            % any failure condition, including generic FAIL and all specific
            % user-defined failure reasons.
            %
            % Usage:
            %   n = obj.getCountAnyFail();
            %   n = getCountAnyFail(obj);
            %
            %% Output
            % n - double
            %   Number of elements in |layer| with codes greater than |OK|.
            %
            %% Notes
            %   - Exploits the numeric convention of enumerated codes:
            %       UNCHECK = -1
            %       OK      = 0
            %       FAIL    = 1
            %       Specific failures > 1
            %
            %   - Therefore, all failures satisfy:
            %         layer > obj.codes.OK
            %
            %   - UNCHECK and OK entries are excluded.
            %   - If |layer| is empty, n = 0.
            %
            %   This method is useful for quickly assessing the total
            %   amount of data that did not pass this quality control
            %   criterion.
            %
            % See also
            %   getCountOK, getMaskAnyFail, getMaskFAIL
            n = nnz(obj.layer > obj.codes.OK);
        end

        function tf = isComplete(obj)
            % isComplete - Determine whether all entries have been checked.
            %
            % Returns true if no element in |layer| remains in the
            % UNCHECK state.
            %
            % Usage:
            %   tf = obj.isComplete();
            %   tf = isComplete(obj);
            %
            % Notes
            %   - Completeness does not imply correctness.
            %     It only guarantees that every element has been assigned
            %     either OK or a failure value.
            %
            %   - Formally:
            %         tf == ~isempty(obj.layer) && ~any(layer(:) == obj.codes.UNCHECK)
            %
            %   - If |layer| is empty (0x0x0), tf returns true.
            %
            %   This method is typically used before setting:
            %         obj.verified = true
            %   to ensure that the QC criterion has been fully applied.
            %
            %% Output
            % tf - logical scalar
            %   True if there are no elements equal to |UNCHECK|.
            %   False otherwise.
            %
            % See also
            %   getMaskUNCHECK, set.verified
            %
            tf = ~isempty(obj.layer) && ~any(obj.layer(:) == obj.codes.UNCHECK);
        end

        % function disp(obj)
        %     fprintf('  <a href="matlab:helpPopup(''icnna.data.core.qcCriterion'')">qcCriterion</a> with properties:\n');
        %     fprintf('    id: %d\n', obj.id);
        %     fprintf('    verified: %d\n', obj.verified);
        %     fprintf('    layer size: %s\n', mat2str(size(obj.layer)));
        %     fprintf('    enumerated codes: %s\n', struct2str(obj.codes));
        % end
    end






    % =====================================================================
    % Static methods
    % =====================================================================
    methods (Static)
        function qcObj = execute(varargin)
            % Call the |qcOperator| and return a verified @icnna.data.core.qcCriterion
            %
            % Usage:
            %   qcObj = icnna.data.core.qcCriterion.execute(qcOperator, varargin)
            %
            % Example:
            %   qcObj = icnna.data.core.qcCriterion.execute(@myOperator, ...);
            %
            %% Input parameters:
            %   qcOperator - function_handle that returns a @icnna.data.core.qcCriterion object
            %   varargin   - additional inputs to qcOperator.
            %       Cehck function qcOperator for details
            %
            %% Output:
            %   qcObj - @icnna.data.core.qcCriterion
            %       An @icnna.data.core.qcCriterion object with verified =
            %       true.
            %

            if nargin < 1
                error('icnna:data:core:qcCriterion:execute:MissingOperator', ...
                    'qcOperator handle is required.');
            end

            qcOperator = varargin{1};
            validateattributes(qcOperator, {'function_handle'}, {});
            args = varargin(2:end);

            qcObj = qcOperator(args{:});
            if ~isa(qcObj, 'icnna.data.core.qcCriterion')
                error('icnna:data:core:qcCriterion:execute:InvalidOutput', ...
                    'qcOperator must return a @icnna.data.core.qcCriterion object.');
            end
            qcObj.verified = true;
        end
    end



end