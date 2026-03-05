function obj = assertInvariants(obj)
% icnna.data.core.qcCriterion:assertInvariants - Validate internal invariants.
%
%   obj = obj.assertInvariants()
%
% Ensures that the @icnna.data.core.qcCriterion object satisfies
% structural and semantic invariants.
%
% Enforced invariants:
%
%   Enumeration:
%       * values is scalar struct
%       * Mandatory fields UNCHECK, OK, FAIL exist
%       * UNCHECK == -1
%       * OK      == 0
%       * FAIL    == 1
%       * All values scalar integers within int8 range
%       * All numeric values unique
%       * User-defined values > 1
%
%   Layer:
%       * layer is int8
%       * layer is 3D
%       * All layer elements belong to values
%
%   Logical:
%       * verified is scalar logical
%       * If verified == true, layer contains no UNCHECK
%
%% Error handling
%
%   Throws error if any invariant is not complied, i.e. object is corrupt.
%
%% Input parameters
%
% obj - icnna.data.core.qcCriterion
%   This object.
%
%% Output
% obj - icnna.data.core.qcCriterion
%   This object.
%
%
% See also:
%   set.layer, set.values, set.verified
%




%% Log
%
%
% -- ICNNA v1.4.0
%
% 27-Feb-2026: FOE
%   Method created
%





    % ------------------------------------------------------------------------
    % Enumeration invariants
    % -------------------------------------------------------------------------
    
    if ~isstruct(obj.values_) || ~isscalar(obj.values_)
        error('icnna:data:core:qcCriterion:assertInvariants:InvalidValuesStruct', ...
            '|values| must be a scalar struct.');
    end
    
    mandatory = {'UNCHECK','OK','FAIL'};
    
    for i = 1:numel(mandatory)
        if ~isfield(obj.values_, mandatory{i})
            error('icnna:data:core:qcCriterion:assertInvariants:MissingMandatoryValue', ...
                'Mandatory enumeration "%s" is missing.', mandatory{i});
        end
    end
    
    % Enforce fixed numeric mapping
    if obj.values_.UNCHECK ~= -1
        error('icnna:data:core:qcCriterion:assertInvariants:InvalidUNCHECK', ...
            'UNCHECK must be equal to -1.');
    end
    
    if obj.values_.OK ~= 0
        error('icnna:data:core:qcCriterion:assertInvariants:InvalidOK', ...
            'OK must be equal to 0.');
    end
    
    if obj.values_.FAIL ~= 1
        error('icnna:data:core:qcCriterion:assertInvariants:InvalidFAIL', ...
            'FAIL must be equal to 1.');
    end
    
    % Validate all enumeration values
    fields = fieldnames(obj.values_);
    enumVals = zeros(1, numel(fields), 'int8');
    
    for i = 1:numel(fields)
        val = obj.values_.(fields{i});
        
        if ~isscalar(val) || ~isnumeric(val) || val ~= fix(val)
            error('icnna:data:core:qcCriterion:assertInvariants:InvalidEnumValue', ...
                'Enumeration "%s" must be a scalar integer.', fields{i});
        end
        
        if val < intmin('int8') || val > intmax('int8')
            error('icnna:data:core:qcCriterion:assertInvariants:EnumOutOfRange', ...
                'Enumeration "%s" exceeds int8 range.', fields{i});
        end
        
        enumVals(i) = int8(val);
        
        % User-defined values must be > 1
        if ~ismember(fields{i}, mandatory)
            if val <= 1
                error('icnna:data:core:qcCriterion:assertInvariants:InvalidUserEnum', ...
                    'User-defined enumeration "%s" must be > 1.', fields{i});
            end
        end
    end
    
    % Enforce uniqueness
    if numel(unique(enumVals)) ~= numel(enumVals)
        error('icnna:data:core:qcCriterion:assertInvariants:DuplicateEnumValues', ...
            'Enumeration numeric values must be unique.');
    end
    
    % ------------------------------------------------------------------------
    % Layer invariants
    % -------------------------------------------------------------------------
    
    if ~isa(obj.layer_, 'int8')
        error('icnna:data:core:qcCriterion:assertInvariants:LayerType', ...
            '|layer| must be of type int8.');
    end
    
    if ndims(obj.layer_) ~= 3
        error('icnna:data:core:qcCriterion:assertInvariants:LayerDimension', ...
            '|layer| must be 3D.');
    end
    
    if ~isempty(obj.layer_)
        if ~all(ismember(obj.layer_(:), enumVals))
            error('icnna:data:core:qcCriterion:assertInvariants:LayerInvalidValues', ...
                '|layer| contains values not defined in |values|.');
        end
    end
    
    % ------------------------------------------------------------------------
    % Logical invariants
    % -------------------------------------------------------------------------
    
    if ~islogical(obj.verified_) || ~isscalar(obj.verified_)
        error('icnna:data:core:qcCriterion:assertInvariants:InvalidVerified', ...
            '|verified| must be a scalar logical.');
    end
    
    if obj.verified_
        if any(obj.layer_(:) == obj.values_.UNCHECK)
            error('icnna:data:core:qcCriterion:assertInvariants:VerifiedIncomplete', ...
                'Object marked as verified but UNCHECK values remain in layer.');
        end
    end

end