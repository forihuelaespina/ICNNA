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
% the metaEntries enrich each metaData in additional with further
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
%   sd.foo(chIdx) returns the metaEntry value if applicable
%   sd.meta('foo') (or similar) returns the full metadata object
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
%   .name - (Since v1.3.1) Char array. By default is 'signalDescriptor0001'.
%       A name for the signalDescriptor. 
%
%   -- Private properties
%   .additional - icnna.data.core.metaEntry[]
%       User-defined metadata entries. Newly defined dynamic properties 
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
%%
% -- ICNNA v1.4.0
%
% 10-Jan-2026: FOE
%   File and class created.
%
% 14-Jan-2026: FOE
%   Adjusted to adopt @icnna.data.core.metaEntry
%
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
                obj=varargin{1};
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
        % obj = obj.setField('fieldName', meta)
        %
        % The assigned value must be a @icnna.data.core.metaEntry object.
        % This automatically enforces internal invariants:
        %   * metaEntry IDs are unique
        %   * metaEntry names match field names
        %
        % Examples:
        %   m = icnna.data.core.metaEntry(42, [], 'myMeta');
        %   sd = sd.setField('myMeta', m);
            validateattributes(name, {'char', 'string'}, {'scalartext'});
            if ~isa(value, 'icnna.data.core.metaEntry')
                error('Value must be a @icnna.data.core.metaEntry object.');
            end
            % Assign using dot-syntax to leverage subsasgn
            obj.(name) = value;  % subsasgn automatically enforces invariants
        end

        function val = getField(obj, name)
            % Retrieve a dynamic field
            validateattributes(name, {'char', 'string'}, {'scalartext'});
            if isfield(obj.additional, name)
                val = obj.additional.(name);
            else
                error('Field "%s" does not exist.', name);
            end
        end

        function obj = removeField(obj, name)
            % Remove a dynamic field
            validateattributes(name, {'char', 'string'}, {'scalartext'});
            name = char(name);
            if isfield(obj.additional, name)
                obj.additional = rmfield(obj.additional, name);
                obj = obj.assertInvariants(); % Enforce invariants
            else
                warning('icnna.data.core.signalDescriptor:removeField:FieldDoesNotExist', ...
                        'Field "%s" does not exist.', name);
            end
        end

        function tf = hasField(obj, name)
            % Check if a dynamic field exists
            validateattributes(name, {'char', 'string'}, {'scalartext'});
            tf = isfield(obj.additional, name);
        end

        % function s = toStruct(obj)
        %     % Export dynamic fields as a struct
        %     s = obj.additional;
        % end

        function out = fieldnames(obj)
        % Return all accessible field names of signalDescriptor
        %
        % Includes standard properties and metadata fields.
        %
        % Usage:
        %   fn = fieldnames(sd);
    
            % Support for fieldnames(obj)
            out = [fieldnames(obj.additional); "id"; "name"];
        end

        function out = isfield(obj, name)
        % Check if a given field exists in signalDescriptor
        %
        % Returns true if the field is a standard property or a metaEntry field.

            validateattributes(name, {'char', 'string'}, {'scalartext'});
            name = char(name);
        
            out = strcmp(name, 'id') || ...
                  strcmp(name, 'name') || ...
                  isfield(obj.additional, name);
        end

        function disp(obj)
            % Custom display for signalDescriptor
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
        % Supports:
        %   sd.id or sd.name
        %   sd.methodName()
        %   sd.metaField         -> returns metaEntry object
        %   sd.metaField(idx)    -> returns value for given samplingLocation
        %   sd.metaField.value   -> returns full value
        %
        % Nested indexing is supported.
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
                        val = obj.additional.(S(1).subs);
                        % Support nested subsref, e.g., sd.myMeta.value
                        if numel(S) > 1
                            val = subsref(val, S(2:end));
                        end
                        return
                    end

                    %Should not reach here
                    error('icnna.data.core.signalDescriptor:subsref:NoSuchFieldOrMethod', ...
                          'No such field or method "%s".', S(1).subs);

                case '()'
                    % Support sd.foo(chIdx) returning metaEntry.value for given samplingLocation
                    % Parent is metaEntry: return value restricted by samplingLocations
                    if isa(obj, 'icnna.data.core.metaEntry')
                        idx = S(1).subs{1};
                        if isempty(obj.samplingLocations) || ismember(idx, obj.samplingLocations)
                            val = obj.value;
                        else
                            val = [];
                        end
                        
                        % Support nested indexing after ()
                        if numel(S) > 1
                            val = subsref(val, S(2:end));
                        end
                    else
                        % Otherwise fallback for parentheses on signalDescriptor itself
                        val = builtin('subsref', obj, S);
                    end
                otherwise
                    % Fall back to default for other types of indexing (e.g., '{}')
                    val = builtin('subsref', obj, S);
            end
        end

        function obj = subsasgn(obj, S, val)
        % Overload subsasgn for @signalDescriptor
        %
        % Supports:
        %   sd.id = ...
        %   sd.name = ...
        %   sd.metaField = metaEntry(...)
        %   sd.metaField.value = ...
        %   sd.metaField.samplingLocations = ...
        %
        % Nested assignments are supported, invariants are enforced automatically.
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
                                error('icnna.data.core.signalDescriptor:subsasgn:InvalidValue', ...
                                      'Assigned value must be a @icnna.data.core.metaEntry object.');
                            end
                            % Ensure metaEntry name matches field
                            val.name = S(1).subs;
                            obj.additional.(S(1).subs) = val;
                            obj = obj.assertInvariants(); % Enforce invariants
                        else
                            % Nested assignment, e.g., sd.myMeta.value = 10
                            if ~isfield(obj.additional, S(1).subs)
                                error('icnna.data.core.signalDescriptor:subsasgn:NoSuchField', ...
                                      'Cannot assign to unknown field "%s".', S(1).subs);
                            end
                            tmp = obj.additional.(S(1).subs);
                            tmp = subsasgn(tmp, S(2:end), val);
                            obj.additional.(S(1).subs) = tmp;
                            obj = obj.assertInvariants(); % Enforce invariants
                        end
                    else
                        % Unknown field
                        error('icnna.data.core.signalDescriptor:subsasgn:NoSuchField', ...
                              'Cannot assign to unknown field "%s".', S(1).subs);
                    end
                otherwise
                    % Fallback for '()' or '{}' assignments, etc
                    obj = builtin('subsasgn', obj, S);
            end
        end




    end


    methods (Access = private)
        obj = assertInvariants(obj);
    end

end