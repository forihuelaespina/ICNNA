classdef metaEntry < icnna.data.core.identifiableObject
% icnna.data.core.metaEntry - Annotated metadata 
% 
% This class represents a piece of metadata which in turn has its
% own metadata.
%
%   The class was originally developed to work in conjunction with
% class @icnna.data.core.signalDescriptor. Originally, @icnna.data.core.metaEntry
% represented a metadata entry annotated with sampling-location
% scope. In this context, this class represents a single metadata
% entry associated with an @icnna.data.core.signalDescriptor.
% In practice, the class can be used by other wrapping classes
% different from @icnna.data.core.signalDescriptor that also need
% to keep annotated metadata.
%
% Each metaEntry stores:
%   * some metadata value, and
%   * the sampling locations e.g. channels, to which the metadata applies
%
% @icnna.data.core.metaEntry objects are typically owned and managed by
% some instance object of a wrapping class e.g. 
% @icnna.data.core.signalDescriptor, and should not normally
% be instantiated directly by users.
%
% The class is intentionally lightweight and value-based, but is made
% identifiable so that metadata entries can be uniquely referenced,
% serialized, and audited in the wrapping class
% e.g. @icnna.data.core.signalDescriptor. The wrapping class ought to
% provide a strcut like property (here referred to as ".additional" but
% this class is oblivious to that) where the fields of this |additional|
% property are of type @icnna.data.core.metaEntry and the field name
% matches the |name| of the @icnna.data.core.metaEntry.
%
% For instance:
%
%   A = icnna.data.core.signalDescriptor;
%   ...
%   tmp = icnna.data.core.metaEntry;
%   tmp.name = 'b';
%   A.additional.b = tmp;
%
% Now the field 'b' in the property .additional of object A is a meta entry
%whose name itself is 'b'. Nota that in the particular case of 
%@icnna.data.core.signalDescriptor, one can actually directly access b
%from A, e.g.:
%
%       A.b
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
%       Numerical identifier (unique within the wrapping class).
%   .name - Char array. By default is 'metaEntry0001'.
%       Name of the metadata entry. When in use as part of a wrapping class
%       such as @icnna.data.core.signalDescriptor, it should match the field
%       name used in signalDescriptor.additional.
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
% 27-Feb-2026: FOE
%   + Improved comments.
%   + Added supporting method appliesToAll
%   + Improved consitency with MATLAB behaviour in method .subsref
%   + Refined some parameter validation rules.
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
            % NOTES:
            %   + The name and id are normally assigned by the owning
            %   signalDescriptor to ensure consistency and uniqueness.
            %
            %   + This constructor performs a shallow copy. If value is
            %   a handle object, both instances will reference the same
            %   underlying object.
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
                    {'numeric'}, {'integer','positive','vector'});
                obj.samplingLocations = samplingLocations(:).';
            end
        
            if nargin >= 3 && ~isempty(name)
                obj.name = char(name);
            end
        
            if nargin == 4 && ~isempty(id)
                validateattributes(id, {'numeric'}, {'scalar','integer','nonnegative'});
                obj.id = uint32(id);
            elseif nargin > 4
                error(['icnna.data.core.metaEntry:metaEntry:InvalidNumberOfParameters' ...
                       ' Unexpected number of parameters.']);
            end
        end


        function tf = appliesTo(obj, samplingLocationsIdx)
            % Check whether metadata applies to a given sampling location
            %
            %   tf = obj.appliesTo(samplingLocationsIdx)
            %
            % Example usage:
            %
            %   tf = obj.appliesTo([1 3 4]);
            %
            %% Input parameters
            %
            % samplingLocationsIdx - int[]
            %   List of indices to sampling locations to which this
            %   metaentry is associated to.
            %
            %% Output
            %
            % tf - bool[]
            %   Flag whether this meta data is associated to each of the input
            % indexed sampling locations. 
            %
            validateattributes(samplingLocationsIdx, ...
                {'numeric'}, {'integer','positive','vector'});
        
            samplingLocationsIdx = samplingLocationsIdx(:).';
        
            if isempty(obj.samplingLocations)
                tf = true(size(samplingLocationsIdx));
            else
                tf = ismember(samplingLocationsIdx, obj.samplingLocations);
            end


        end


        function tf = appliesToAll(obj)
            % Check whether metadata applies to all sampling locations
            %
            %   tf = obj.appliesToAll()
            %
            % A small helper method to clarify "All Sampling Locations"
            % semantics. Avoids user having to check whether the output
            % of method .appliesTo isempty(...) everywhere.
            %
            % Example usage:
            %
            %   tf = obj.appliesToAll();
            %
            %% Input parameters
            %
            % N/A
            %
            %% Output
            %
            % tf - bool
            %   True if metadata applies to all sampling locations. 
            %
            tf = isempty(obj.samplingLocations);
        end        


        function disp(obj)
            % Custom display
            %
            %   disp(obj)
            %
            % Displays a formatted summary of the metaEntry object,
            % including:
            %   * id
            %   * name
            %   * samplingLocations
            %   * value
            %
            % If samplingLocations is empty ([]), it is displayed as "all",
            % indicating that the metadata applies to all sampling locations.
            %
            %% Input parameters
            %
            % obj - icnna.data.core.metaEntry
            %   The metaEntry object to be displayed.
            %
            %% Output
            %
            % None
            %   This method prints formatted information to the command window.
            % 
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
            %   val = obj(idx)
            %   val = obj.property
            %   val = obj(idx).property
            %
            % Provides customized indexing behavior:
            %
            %   * obj(idx)
            %       Returns obj.value if the metadata applies to the
            %       specified sampling location index (idx).
            %       Returns [] if the metadata does not apply.
            %
            %   * obj.property
            %       Provides standard dot access to properties and methods.
            %
            % Nested indexing is supported.
            %
            %% Input parameters
            %
            % obj - icnna.data.core.metaEntry
            %   The metaEntry object being indexed.
            %
            % S - struct
            %   Subscript structure automatically generated by MATLAB.
            %   Defines the type of indexing operation ('.' or '()')
            %   and associated indices.
            %
            %% Output
            %
            % val - dynamic type
            %   The value resulting from the indexing operation.
            %   Typically:
            %       * obj.value
            %       * []
            %       * A property or method result
            %
            switch S(1).type
                case '()'
                    if numel(obj) > 1 %Array MATLAB-consistent behavior
                        val = builtin('subsref', obj, S);
                        return;
                    end

                    idx = S(1).subs{1};

                    validateattributes(idx, ...
                        {'numeric'}, {'integer','positive','vector'});
                
                    idx = idx(:).';

                    if isempty(obj.samplingLocations)
                        mask = true(size(idx));
                    else
                        mask = ismember(idx, obj.samplingLocations);
                    end


                    if isscalar(idx)
                        if mask
                            val = obj.value;
                        else
                            val = [];
                        end
                    else
                        % For vector indexing, return value if all apply, else []
                        if all(mask)
                            val = obj.value;
                        else
                            val = [];
                        end
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
