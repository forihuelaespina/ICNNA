classdef metaEntry < icnna.data.core.identifiableObject
% icnna.data.core.metaEntry - Annotated metadata entry with sampling-location scope.
%
% This class represents a single metadata entry associated with an
% @icnna.data.core.signalDescriptor.
%
% Each metaEntry stores:
%   * some metadata value, and
%   * the sampling locations e.g. channels, to which the metadata applies
%
% The class is intentionally lightweight and value-based, but is made
% identifiable so that metadata entries can be uniquely referenced,
% serialized, and audited in @icnna.data.core.signalDescriptor.
%
% @icnna.data.core.metaEntry objects are typically owned and managed by a
% @icnna.data.core.signalDescriptor instance and should not normally
% be instantiated directly by users.
%
%
%% Properties
%
%   -- Private properties
%   .classVersion - Char array. (Read only. Constant)
%       The class version of the object.
%
%   -- Inherited properties
%   .id - uint32.
%       Numerical identifier (unique within the parent @icnna.data.core.signalDescriptor).
%   .name - Char array. By default is 'metaEntry0001'.
%       Name of the metadata entry. When in use as part of a
%       @icnna.data.core.signalDescriptor, it should match the field name
%       used in signalDescriptor.additional.
%
%   -- Public properties
%   .value - Dynamic type
%       Value of the metadata entry.
%   .samplingLocations - Int[]
%       Index to the sampling locations to which the metadata applies.
%       * []  : applies to all sampling locations
%       * vector of indices : applies only to those sampling locations
%
%       IMPORTANT: Note that the @icnna.data.core.signalDescriptor has no
%       direct knowledge of the sampling locations in the
%       @icnna.data.core.structuredData. This actually refers to the
%       index of the sampling location @icnna.data.core.structuredData.
%
%
%% Methods
%
% Type methods('icnna.data.core.metaEntry') for a list of methods
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also
%   icnna.data.core.signalDescriptor
%


%% Log
%%
% -- ICNNA v1.4.0
%
% 14-Jan-2026: FOE
%   File and class created.
%


    properties (Constant, Access = private)
        classVersion = '1.0'; % Read-only. Object's class version.
    end


    properties
        value
        samplingLocations = []   % [] means "all sampling locations"
    end


    methods
        function obj = metaEntry(value, samplingLocations, name, id)
            % icnna.data.core.metaEntry class constructor
            %
            % obj = icnna.data.core.metaEntry() creates a default object.
            % obj = icnna.data.core.metaEntry(obj2) acts as a copy constructor
            % obj = icnna.data.core.metaEntry(value)
            % obj = icnna.data.core.metaEntry(value, samplingLocations)
            % obj = icnna.data.core.metaEntry(value, samplingLocations, name)
            % obj = icnna.data.core.metaEntry(value, samplingLocations, name, id)
            %
            % NOTE:
            %   The name and id are normally assigned by the owning
            %   signalDescriptor to ensure consistency and uniqueness.
            %

            obj@icnna.data.core.identifiableObject();
            tmp = split(class(obj),'.');
            obj.name = [tmp{end} num2str(obj.id,'%04d')];

            if (nargin==0)
                %Keep default values
            end

            % Copy constructor
            if nargin == 1 && isa(value, 'icnna.data.core.metaEntry')
                obj = value;
                return;
             % else treat as value
            end
        
            if nargin >= 1
                obj.value = value;
            end
        
            if nargin >= 2 && ~isempty(samplingLocations)
                validateattributes(samplingLocations, ...
                    {'numeric'}, {'integer','nonnegative','vector'});
                obj.samplingLocations = samplingLocations(:).';
            end
        
            if nargin >= 3 && ~isempty(name)
                obj.name = char(name);
            end
        
            if nargin == 4 && ~isempty(id)
                obj.id = id;
            elseif nargin > 4
                error(['icnna.data.core.metaEntry:metaEntry:InvalidNumberOfParameters' ...
                       ' Unexpected number of parameters.']);
            end
        end


        function tf = appliesTo(obj, samplingLocation)
            % Check whether metadata applies to a given sampling location
            if isempty(obj.samplingLocations)
                tf = true;
            else
                tf = ismember(samplingLocation, obj.samplingLocations);
            end
        end


        function disp(obj)
            % Custom display
            fprintf('  metaEntry\n');
            fprintf('    id: %d\n', obj.id);
            fprintf('    name: %s\n', obj.name);
            if isempty(obj.samplingLocations)
                fprintf('    samplingLocations: all\n');
            else
                fprintf('    samplingLocations: %s\n', ...
                    mat2str(obj.samplingLocations));
            end
            fprintf('    value: ');
            disp(obj.value);
        end


        function val = subsref(obj, S)
            % Overload subsref for @icnna.data.core.metaEntry
            %
            % Supports:
            %   me(idx) -> returns the metaEntry value if samplingLocation
            %               applies, or empty if samplingLocation does not.
            %   me.value
            %   me.samplingLocations
            %
            % Nested indexing is supported.

            switch S(1).type
                case '()'
                    idx = S(1).subs{1};

                    if isempty(obj.samplingLocations) || ismember(idx, obj.samplingLocations)
                        val = obj.value;
                    else
                        val = [];
                    end

                    % Support chained indexing, e.g. me(1)(2)
                    if numel(S) > 1
                        val = subsref(val, S(2:end));
                    end

                case '.'
                    % Default dot access to properties/methods
                    val = builtin('subsref', obj, S);

                otherwise
                    val = builtin('subsref', obj, S);
            end
        end




    end
end
