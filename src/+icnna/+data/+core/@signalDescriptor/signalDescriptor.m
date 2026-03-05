classdef signalDescriptor < icnna.data.core.identifiableObject
% icnna.data.core.signalDescriptor - Meta data associated to a signal or measurement.
%
% This class supersedes the rather naive |signalTags| property of
%the @structuredData, going from a simple name (char[]) to a complete
%record of metadata associated to the recorded signals.
%
% The class allows for flexible meta-data to be added on the fly
%depending on the type of signal. For instance, for fNIRS signals
%the meta data for intensity signals may be different than for
%reconstructed concentrations of chromophores.
%
%% Remarks
%
% The metadata of the signals descriptor are not simple values.
% Instead they are @icnna.data.core.metaEntry, that is, each metadata
% is annotated with a list of channels to which they apply. Hence,
% although there is a single unique @icnna.data.core.signalDescriptor
% accompanying each signal in a @icnna.data.core.structuredData
% the descriptor itself may take different metadata (strictly metaEntry)
% for each sampling location e.g. channel.
%
%% About the metaEntries
%
% Meta entries (@icnna.data.core.metaEntry) are metadata entries that
% themselves carry scope information e.g. which sampling location
% they apply, while preserving dot-style access and keeping the class
% flexible. In other words, metaEntries are annotated metadata.
%
% Instead of simple having a metadata value e.g.;
%
%   additional.(name)
%
% the metaEntries enrich each metaData in property |additional| with further
% information.
%
%   During use, you can still use the metadata directly as if exposed e.g.;
%
%   sd.yourMetadataA
%   sd.yourMetadataB
%
% ...but under the hood, each metaEntry knows where it applies.
%
% The class still preserves the .dot index syntax. As a user, you won't
% see the metaEntry unless explicitly asking for it.
%
%   sd.foo returns the metaEntry value
%   sd.foo.value (also) returns the metaEntry value
%   sd.foo.samplingLocations returns the metaEntry sampling locations
%   sd.foo(chIdx) returns the metaEntry value if applicable (the underpinning
%           icnna.data.core.metaEntry object handles sampling logic)
%   sd.meta('foo') returns the full icnna.data.core.metaEntry object
%
% Finally, note that metadata is value-based and assignment must go through.
% Use:
%
% sd.foo = metaEntry(...)
% sd.foo.value = 10
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
%   .name - (Since v1.3.1) Char array. By default is 'signalDescriptor0001'.
%       A name for the signalDescriptor. 
%
%   -- Private properties
%   .additional - struct
%       User-defined metadata entries where each entry (field of the struct)
%       is of type icnna.data.core.metaEntry. Newly defined dynamic properties 
%       offer:
%       * dynamic type alike fields in a struct
%       * dot.style syntax.
%       * annotated metadata e.g. with associated sampling locations
% 
%
%
%% Methods
%
% Type methods('icnna.data.core.signalDescriptor') for a list of methods
% 
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also 
%


%% Log
%
%
% -- ICNNA v1.4.0
%
% 10-Jan-2026: FOE
%   File and class created.
%
% 14-Jan-2026: FOE
%   Adjusted to adopt @icnna.data.core.metaEntry
%
% 27-Feb-2026: FOE
%   + Improved comments
%   + Some improvements to code
%   + Added method .meta to get access to full @icnna.data.core.metaEntry
%   + Polished error handling
%


    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end


    properties (Access = private)
        additional struct = struct();  % Additional user-defined metadata entries.
                                       %Value-based dynamic field container
    end




    
    methods
        function obj=signalDescriptor(varargin)
            %icnna.data.core.signalDescriptor class constructor
            %
            % obj=icnna.data.core.signalDescriptor() creates a default object.
            % obj=icnna.data.core.signalDescriptor(obj2) acts as a copy constructor
            %
            % 
            % Copyright 2026
            % @author: Felipe Orihuela-Espina
            %
            
            obj@icnna.data.core.identifiableObject();
            tmp = split(class(obj),'.');
            obj.name = [tmp{end} num2str(obj.id,'%04d')];
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.signalDescriptor')
                obj = varargin{1};
                obj = obj.assertInvariants();
                return;
             else
                error(['icnna.data.core.signalDescriptor:signalDescriptor:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);

            end
        end





        %Gets/Sets

 
        %% Support for dynamic fields
        function obj = setField(obj, name, value)
            % Add or update a metadata entry (metaEntry)
            %
            %   obj = obj.setField(name, value)
            %
            % Adds a new metadata field or updates an existing one.
            % The assigned value must be a @icnna.data.core.metaEntry object.
            % Invariants are automatically enforced:
            %   * metaEntry names match field names
            %   * metaEntry IDs remain unique
            %
            % Example usage:
            %
            %   m = icnna.data.core.metaEntry(42);
            %   sd = sd.setField('myMeta', m);
            %
            %% Input parameters
            %
            % name - char | string
            %   Name of the metadata field.
            %
            % value - icnna.data.core.metaEntry
            %   Metadata entry to assign.
            %
            %% Output
            %
            % obj - icnna.data.core.signalDescriptor
            %   Updated signalDescriptor object.
            %
            validateattributes(name, {'char', 'string'}, {'scalartext'});
            if ~isa(value, 'icnna.data.core.metaEntry')
                error('icnna:data:core:signalDescriptor:setField:InvalidValue', ...
                    'Value must be a @icnna.data.core.metaEntry object.');
            end
            % Assign using dot-syntax to leverage subsasgn
            obj.(name) = value;  % subsasgn automatically enforces invariants
        end

        function val = getField(obj, name)
            % Retrieve a metadata entry
            %
            %   val = obj.getField(name)
            %
            % Returns the metaEntry object associated with the given
            % metadata field name.
            %
            %
            %% Error handling
            %
            % Throws an error if the field does not exist.
            %
            %% Input parameters
            %
            % name - char | string
            %   Name of the metadata field.
            %
            %% Output
            %
            % val - icnna.data.core.metaEntry
            %   Metadata entry associated with the field.
            %
            %
            validateattributes(name, {'char', 'string'}, {'scalartext'});
            if isfield(obj.additional, name)
                val = obj.additional.(name);
            else
                error('icnna:data:core:signalDescriptor:getField:FieldDoesNotExist', ...
                      'Field "%s" does not exist.', name);
            end
        end

        function obj = removeField(obj, name)
            % Remove a metadata field
            %
            %   obj = obj.removeField(name)
            %
            % Removes the specified metadata field from the descriptor.
            %
            %% Error handling
            %
            % + Issues a warning if the field does not exist.
            % + Class invariants are revalidated after removal.
            %
            %% Input parameters
            %
            % name - char | string
            %   Name of the metadata field to remove.
            %
            %% Output
            %
            % obj - icnna.data.core.signalDescriptor
            %   Updated signalDescriptor object.
            %
            validateattributes(name, {'char', 'string'}, {'scalartext'});
            name = char(name);
            if isfield(obj.additional, name)
                obj.additional = rmfield(obj.additional, name);
                obj = obj.assertInvariants(); % Enforce invariants
            else
                warning('icnna:data:core:signalDescriptor:removeField:FieldDoesNotExist', ...
                        'Field "%s" does not exist.', name);
            end
        end

        function out = fieldnames(obj)
            % Return all accessible field names of signalDescriptor
            %
            %   fn = fieldnames(obj)
            %
            % Returns a list of accessible field names, including:
            %   * Standard properties (id, name)
            %   * User-defined metadata fields
            %
            %% Input parameters
            %
            % obj - icnna.data.core.signalDescriptor
            %   The signalDescriptor object.
            %
            %% Output
            %
            % out - cell array
            %   List of accessible field names.

            % Support for fieldnames(obj)
            out = [fieldnames(obj.additional); {'id'; 'name'}];
        end


        function tf = hasfield(obj, name)
            % Check if a metadata field exists
            %
            %   tf = obj.hasfield(name)
            %
            % Returns true if the specified metadata field exists.
            %
            %% Input parameters
            %
            % name - char | string
            %   Name of the metadata field.
            %
            %% Output
            %
            % tf - bool
            %   True if the field exists, false otherwise.
            %   Returns true only for user-defined metadata fields. This is
            %   in contrast to method isfield which returns true for
            %   both standard properties and metadata fields.
            % 
            validateattributes(name, {'char', 'string'}, {'scalartext'});
            tf = isfield(obj.additional, name);
        end

        function out = isfield(obj, name)
            % Check if a given field exists in signalDescriptor
            %
            %   tf = obj.isfield(name)
            %
            % Returns true if the specified name corresponds to:
            %   * A standard property (id, name), or
            %   * A metadata field stored in .additional
            %
            %% Input parameters
            %
            % name - char | string
            %   Field name to check.
            %
            %% Output
            %
            % out - bool
            %   True if the field exists, false otherwise.
            %   Returns true for standard properties and metadata fields. This
            %   is in contrast to method hasfield which returns true only
            %   for metadata fields.

            validateattributes(name, {'char', 'string'}, {'scalartext'});
            name = char(name);
        
            out = strcmp(name, 'id') || ...
                  strcmp(name, 'name') || ...
                  obj.hasfield(name);
        end

        function m = meta(obj, name)
            % Retrieve full metaEntry object for a metadata field
            %
            %   m = obj.meta(name)
            %
            % Provides explicit access to the underlying
            % @icnna.data.core.metaEntry object associated with a
            % metadata field.
            %
            % This method is intended for advanced usage when access to
            % metaEntry-specific properties (e.g., id, samplingLocations)
            % is required.
            %
            % Example usage:
            %
            %   m = sd.meta('myMeta');
            %   m.id
            %   m.samplingLocations
            %
            %% Error handling
            %
            % Throws an error if the specified metadata field does not exist.
            %
            %% Input parameters
            %
            % name - char | string
            %   Name of the metadata field.
            %
            %% Output
            %
            % m - icnna.data.core.metaEntry
            %   The full metaEntry object associated with the field.
            %
            validateattributes(name, {'char','string'}, {'scalartext'});
            name = char(name);
            if ~isfield(obj.additional, name)
                error('icnna:data:core:signalDescriptor:subsref:NoSuchFieldOrMethod', ...
                          'No such field or method "%s".', name);
            end
            m = obj.additional.(name);
        end


        function disp(obj)
            % Custom display
            %
            %   disp(obj)
            %
            % Displays a formatted summary of the signalDescriptor,
            % including:
            %   * id
            %   * name
            %   * All metadata fields and their associated metaEntry
            %     properties (id, samplingLocations, value)
            %
            %% Input parameters
            %
            % obj - icnna.data.core.signalDescriptor
            %   The object to be displayed.
            %
            %% Output
            %
            % None
            %   This method prints formatted information to the command window. 
            %
            fprintf('  <a href="matlab:helpPopup(''icnna.data.core.signalDescriptor'')">signalDescriptor</a> with properties:\n\n');
            fprintf('    id: %d\n', obj.id);
            fprintf('    name: %s\n', obj.name);
            f = fieldnames(obj.additional);
            for i = 1:numel(f)
                tmp = obj.additional.(f{i});
                fprintf('    %s:\n', f{i});
                fprintf('      id: %d\n', tmp.id);
                if isempty(tmp.samplingLocations)
                    fprintf('      samplingLocations: all\n');
                else
                    fprintf('      samplingLocations: %s\n', mat2str(tmp.samplingLocations));
                end
                fprintf('      value: ');
                disp(tmp.value);
            end
            fprintf('\n');
        end

        function val = subsref(obj, S)
            % Overload subsref for @signalDescriptor
            %
            %   val = obj.property
            %   val = obj.metaField
            %   val = obj.metaField(idx)
            %   val = obj.metaField.property
            %
            % Supports:
            %   * Standard property and method access
            %   * Access to metadata fields stored as metaEntry objects
            %   * Indexed access to metadata values by sampling location
            %
            % Nested indexing is supported.
            %
            %% Error handling
            %
            % Throws an error if the requested property does not exist.
            %
            %% Input parameters
            %
            % obj - icnna.data.core.signalDescriptor
            %   The object being indexed.
            %
            % S - struct
            %   Subscript structure generated by MATLAB.
            %
            %% Output
            %
            % val - dynamic type
            %   Result of the indexing operation.
            %
            switch S(1).type
                case '.'
                    % Standard properties or methods
                    if strcmp(S(1).subs, 'id') || ...
                       strcmp(S(1).subs, 'name') || ...
                       ismethod(obj, S(1).subs)
                        val = builtin('subsref', obj, S);
                        return
                    end

                    % Dynamic fields (metaEntry objects)
                    if isfield(obj.additional, S(1).subs) % Metadata fields stored as metaEntry objects
                        meta = obj.additional.(S(1).subs);
                        
                        % If only dot access: return value
                        if numel(S) == 1
                            val = meta.value;
                        else % Support nested subsref, e.g., sd.myMeta.value
                            val = subsref(meta, S(2:end));
                        end
                        return
                    end

                    %Should not reach here
                    error('icnna:data:core:signalDescriptor:subsref:NoSuchFieldOrMethod', ...
                          'No such field or method "%s".', S(1).subs);

                otherwise
                    % Fall back to default for other types of indexing (e.g., '()', '{}')
                    val = builtin('subsref', obj, S);
            end
        end

        function obj = subsasgn(obj, S, val)
            % Overload subsasgn for @signalDescriptor
            %
            %   obj.property = value
            %   obj.metaField = metaEntry(...)
            %   obj.metaField.property = value
            %
            % Supports assignment to:
            %   * Standard properties (id, name)
            %   * Metadata fields (metaEntry objects)
            %   * Nested properties of existing metaEntry fields
            %
            %% Error handling
            %
            % Invariants are automatically enforced after assignment.
            %
            %% Input parameters
            %
            % obj - icnna.data.core.signalDescriptor
            %   The object being modified.
            %
            % S - struct
            %   Subscript structure generated by MATLAB.
            %
            % val - dynamic type
            %   Value to assign.
            %
            %% Output
            %
            % obj - icnna.data.core.signalDescriptor
            %   Updated object after assignment.
            %
            switch S(1).type
                case '.'
                    % Standard properties
                    if strcmp(S(1).subs, 'id')
                        obj.id = val;
                    elseif strcmp(S(1).subs, 'name')
                        obj.name = val;
                    
                    % Existing metaEntry field or assignment of new metaEntry
                    elseif isfield(obj.additional, S(1).subs) || ...
                            isa(val, 'icnna.data.core.metaEntry')
                        if numel(S) == 1
                            % Direct assignment of a metaEntry
                            if ~isa(val, 'icnna.data.core.metaEntry')
                                error('icnna:data:core:signalDescriptor:subsasgn:InvalidValue', ...
                                      'Assigned value must be a @icnna.data.core.metaEntry object.');
                            end
                            % Ensure metaEntry name matches field
                            val.name = S(1).subs;
                            obj.additional.(S(1).subs) = val;
                            obj = obj.assertInvariants(); % Enforce invariants
                        else
                            % Nested assignment, e.g., sd.myMeta.value = 10
                            if ~isfield(obj.additional, S(1).subs)
                                error('icnna:data:core:signalDescriptor:subsasgn:NoSuchField', ...
                                      'Cannot assign to unknown field "%s".', S(1).subs);
                            end
                            tmp = obj.additional.(S(1).subs);
                            tmp = subsasgn(tmp, S(2:end), val);
                            obj.additional.(S(1).subs) = tmp;
                            obj = obj.assertInvariants(); % Enforce invariants
                        end
                    else
                        % Unknown field
                        error('icnna:data:core:signalDescriptor:subsasgn:NoSuchField', ...
                              'Cannot assign to unknown field "%s".', S(1).subs);
                    end
                otherwise
                    % Fallback for '()' or '{}' assignments, etc
                    obj = builtin('subsasgn', obj, S);
            end
        end

        % function s = toStruct(obj)
        %     % Export dynamic fields as a struct
        %     s = obj.additional;
        % end




    end


    methods (Access = private)
        obj = assertInvariants(obj);
    end

end