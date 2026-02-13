classdef metaDataTags
% icnna.data.snirf.metaDataTags A NIRS metadata tag as defined in the snirf file format.
%
%% The Shared Near Infrared Spectroscopy Format (SNIRF).
%
% https://github.com/fNIRS/snirf
%
% SNIRF is designed by the community in an effort to facilitate
% sharing and analysis of NIRS data.
%
%
%
%
%% Properties
%
% See snirf specifications
% 
%
%
%% Methods
%
% Type methods('icnna.data.snirf.metaDataTags') for a list of methods
% 
% Copyright 2022-23
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.snirf.snirf, icnna.data.snirf.nirsDataset, icnna.data.snirf.metaDataTagsGroup
%


%% Log
%
% 16-Jul-2022: FOE
%   File and class created.
%
% 14-May-2023: FOE
%   + Imported from my LaserLab sandbox code to ICNNA. Had to adjust the
%   the package from; data.snirf.* to icnna.data.snirf.*
%   + Added property classVersion. Set to '1.0' by default.
%
%
% 16-May-2023: FOE
%   + Added validation rules to properties and simplified the code
%   accordingly.
%   + Property .additional for holding additional metadata switch
%   from cell to dictionary
%
% 19-May-2023: FOE
%   + Added constructor polymorphism for typecasting a struct.
%   + Class renamed from icnna.data.snirf.metaDataTag to
%   icnna.data.snirf.metaDataTags for consistency with snirf denomination.
%
%
% 6-Sep-2025: FOE
%   + Added support for time zone "Z" in the measurementTime
% Some public .snirf datasets e.g. the FRESH motor dataset
% (https://openneuro.org/datasets/ds005963/versions/1.0.0/download)
% express the time in the metaDataTag for "measurementTime" in
% the time zone "Z" (code for Zulu Time or Zebra Time and is the
% military code name for UTC). Because the code "Z" is not a timezone
% recognised by matlab (see MATLAB's "timezones"), then this CANNOT be
% read by default in matlab as:
%
%   datetime(tmpTags.measurementTime)
%
% It can still be read using the corresponding options e.g.:
%
%   datetime(tmpTags.measurementTime,'InputFormat','HH:mm:ssZ','TimeZone','Z')
%
% ...but this imposes a problem for ICNNA, which do not have the
% capacity to infer these uncommon formats and hence it was yielding
% an error when attempting to read the file. Yet the file content is
% perfectly ok. I have now added a naive support for this format.
%
%   THE SOLUTION IMPLEMENTED HERE DOES NOT SEEM TO BE WORKING BECAUSE
%   MATLAB CHECKS THE STRING BEFORE CALLING THE SET METHOD AND
%   SIMPLY REFUSES THE CALL THE METHOD IF THE STRING IS NOT DIRECTLY
%   CONVERTIBLE.
%
%   While not ideal, but for the time being I'm also adding support
% in the load method.
%
% 14-Nov-2025: FOE
%   + Bug fixed. Method for setting a new user-defined metaData entry
%   was only taking the key but not the value as input parameter.
%
% 16-Nov-2025: FOE / Copilot
%   + Updated implementation of the additional user-defined metadata
%   entries. The previous one based on a dictionary;
%       * Required that all fields has the same type (or can be typecasted
%           to it).
%       * The syntax for the additional properties wasn't dot.style 
%           with the consequent break of the symmetry is assigning
%           or reading values.
%   The new implementation allow for new dynamic properties to be
%   defined seamslessly offering:
%       * dynamic type alike fields in a struct
%       * dot.style syntax.
%       * ...and more importantly, better compliance with snirf.
%
%
% -- ICNNA v1.4.0
%
% 15-Dec-2025: FOE
%   + Bug fixed: In the constructor, the setting of additional properties
%   was still "assuming" that the additional properties were stored as
%   dictionary, although this implementation was changed on 16-Nov-2025.
%


    properties (Constant, Access=private)
        classVersion = '1.1'; %Read-only. Object's class version.
    end




    properties
        subjectID(1,:) char = ''; %Subject identifier
        measurementDate(1,1) datetime; %Date of the measurement in YYYY-MM-DD format.
        measurementTime(1,1) datetime; %Time of the measurement in hh:mm:ss.sTZD format
        lengthUnit(1,:) char = ''; % Length unit (case sensitive). Sample length units include "mm", "cm", and "m". A value of "um" is the same as "μm", i.e. micrometer.                      
        timeUnit(1,:) char = '';  % Time unit (case sensitive). Sample time units include "s", and "ms". A value of "us" is the same as "μs", i.e. microsecond.                            
        frequencyUnit(1,:) char   = '';  % Frequency unit (case sensitive). Sample frequency units "Hz", "MHz" and "GHz". Please note that "mHz" is milli-Hz while "MHz" denotes "mega-Hz" according to SI unit system.
        %additional(1,1) dictionary; %Additional user-defined metadata entries

    end


    properties (Access = private)
        additional struct = struct();  % Additional user-defined metadata entries.
                                       %Value-based dynamic field container
    end




    
    methods
        function obj=metaDataTags(varargin)
            %ICNNA.DATA.SNIRF.METADATATAGS A icnna.data.snirf.metaDataTags class constructor
            %
            % obj=icnna.data.snirf.metaDataTags() creates a default object.
            %
            % obj=icnna.data.snirf.metaDataTags(obj2) acts as a copy constructor
            %
            % obj=icnna.data.snirf.metaDataTags(inStruct) attempts to typecasts the struct
            %
            % 
            % Copyright 2022-23
            % @author: Felipe Orihuela-Espina
            %
            
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.snirf.metaDataTags')
                obj=varargin{1};
                return;
            elseif isstruct(varargin{1}) %Attempt to typecast
                tmp=varargin{1};

                tmpFields = fieldnames(tmp);
                tmpAdditional = struct();
                for iField = 1:length(tmpFields)
                    tmpProp = tmpFields{iField};
                    if ismember(tmpProp,properties(obj))
                        obj.(tmpProp) = tmp.(tmpProp);
                    else
                        tmpAdditional.(tmpProp) = tmp.(tmpProp);
                    end
                    obj.additional = tmpAdditional;
                end

                return;
            else
                error(['icnna.data.snirf.metaDataTags:metaDataTags:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);

            end
        end





        %Gets/Sets

        function val = get.subjectID(obj)
        %Retrieves the subject identifier
            val = obj.subjectID;
        end
        function obj = set.subjectID(obj,val)
        %Updates the subject identifier
            obj.subjectID = val;
        end

        function val = get.measurementDate(obj)
        %Retrieves the measurement date
            val = datestr(obj.measurementDate,'yyyy-mm-dd');
        end
        function obj = set.measurementDate(obj,val)
        %Updates the measurement date
            %Note that the snirf specification indicates that this
            %attribute should be a string, but I'm keeping it as a
            %datetime.
            try
                obj.measurementDate = datetime(val);
            catch
                error(['icnna.data.snirf.metaDataTags:set.measurementDate:InvalidPropertyValue',...
                    'String cannot be converted to date.'])
            end
        end


        function val = get.measurementTime(obj)
        %Retrieves the measurement time
            val = datestr(obj.measurementTime,'HH:MM:SS.FFF');
        end
        function obj = set.measurementTime(obj,val)
        %Updates the measurement time
            %Note that by the time the argument is passed, MATLAB
            %has already enforce a typecasting. That is, if you assigned
            %a char or string with a date, MATLAB has already converted
            %this to a datetime when you enter this function.

            %Note that the snirf specification indicates that this
            %attribute should be a string, but I'm keeping it as a
            %datetime.
            try
                if isstring(val) && endsWith(val, 'Z') %Support for Zulu Timezone
                    obj.measurementTime = datetime(val,...
                        'InputFormat','HH:mm:ssZ','TimeZone','Z');
                else %General case
                    obj.measurementTime = datetime(val);
                end
            catch
                error(['icnna.data.snirf.metaDataTags:set.measurementTime:InvalidPropertyValue',...
                    'String cannot be converted to date.'])
            end
           %assertInvariants(obj);
        end


        function val = get.lengthUnit(obj)
        %Retrieves the length unit
            val = obj.lengthUnit;
        end
        function obj = set.lengthUnit(obj,val)
        %Updates the length unit
            obj.lengthUnit = val;
        end


        function val = get.timeUnit(obj)
        %Retrieves the time unit
            val = obj.timeUnit;
        end
        function obj = set.timeUnit(obj,val)
        %Updates the time unit
            obj.timeUnit = val;
        end

        function val = get.frequencyUnit(obj)
        %Retrieves the frequency unit
            val = obj.frequencyUnit;
        end
        function obj = set.frequencyUnit(obj,val)
        %Updates the time unit
            obj.frequencyUnit = val;
        end

        % function val = get.additional(obj)
        % %Retrieves the additional metadata (as a dictionary)
        %     val = obj.additional;
        % end
        % function obj = set.additional(obj,val)
        % %Updates the additional metadata (as a dictionary)
        %     obj.additional = val;
        % end
        % 
        % 
        % 
        % function val = getMetadata(obj,key)
        % %Retrieves the metadata indexed by the key
        %     val = obj.additional(key);
        % end
        % function obj = setMetadata(obj,key,val)
        % %Retrieves the metadata indexed by the key
        %     obj.additional(key) = val;
        % end
        % function obj = removeMetadata(obj,key)
        % %Retrieves the metadata indexed by the key
        %     obj.additional(key) = [];
        % end


        %% Support for dynamic fields
        function obj = setField(obj, name, value)
            % Add or update a dynamic field
            validateattributes(name, {'char', 'string'}, {'scalartext'});
            obj.additional.(char(name)) = value;
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
            if isfield(obj.additional, name)
                obj.additional = rmfield(obj.additional, name);
            else
                warning('Field "%s" does not exist.', name);
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
            % Support for fieldnames(obj)
            out = [fieldnames(obj.additional); ...
                    "subjectID"; ...
                    "measurementDate"; ...
                    "measurementTime"; ...
                    "lengthUnit"; ...
                    "timeUnit"; ...
                    "frequencyUnit"];
        end

        function out = isfield(obj, name)
            % Support for isfield(obj, 'fieldName')
            out = strcmp(name, 'subjectID') || ...
                       strcmp(name, 'measurementDate') || ...
                       strcmp(name, 'measurementTime') || ...
                       strcmp(name, 'lengthUnit') || ...
                       strcmp(name, 'timeUnit') || ...
                       strcmp(name, 'frequencyUnit') || ...
                       isfield(obj.additional, name);
        end

        function disp(obj)
            % Custom display
            fprintf('  <a href="matlab:helpPopup(''icnna.data.snirf.metaDataTags'')">metaDataTags</a> with properties:\n\n');
            fprintf('    subjectID: %s\n', obj.subjectID);
            fprintf('    measurementDate: %s\n', obj.measurementDate);
            fprintf('    measurementTime: %s\n', obj.measurementTime);
            fprintf('    lengthUnit: %s\n', obj.lengthUnit);
            fprintf('    timeUnit: %s\n', obj.timeUnit);
            fprintf('    frequencyUnit: %s\n', obj.frequencyUnit);
            f = fieldnames(obj.additional);
            for i = 1:numel(f)
                tmp = obj.additional.(f{i});
                if isscalar(tmp)
                    if isnumeric(tmp)
                        fprintf('    %s: %g\n', f{i}, obj.additional.(f{i}));
                    else %char
                        fprintf('    %s: %s\n', f{i}, obj.additional.(f{i}));
                    end
                else
                    fprintf('    %s: %s\n', f{i}, mat2str(obj.additional.(f{i})));
                end
            end
            fprintf('\n');
        end

        function val = subsref(obj, S)
            % Overload dot and parens access
            switch S(1).type
                case '.'
                    if strcmp(S(1).subs, 'subjectID') || ...
                       strcmp(S(1).subs, 'measurementDate') || ...
                       strcmp(S(1).subs, 'measurementTime') || ...
                       strcmp(S(1).subs, 'lengthUnit') || ...
                       strcmp(S(1).subs, 'timeUnit') || ...
                       strcmp(S(1).subs, 'frequencyUnit') || ...
                       ismethod(obj, S(1).subs)
                        val = builtin('subsref', obj, S);
                    elseif isfield(obj.additional, S(1).subs)
                        val = obj.additional.(S(1).subs);
                        if numel(S) > 1
                            val = subsref(val, S(2:end));
                        end
                    else
                        error('No such field or method "%s".', S(1).subs);
                    end
                otherwise
                    val = builtin('subsref', obj, S);
            end
        end

        function obj = subsasgn(obj, S, val)
            % Overload dot assignment
            switch S(1).type
                case '.'
                    if strcmp(S(1).subs, 'subjectID')
                        obj.subjectID = val;
                    elseif strcmp(S(1).subs, 'measurementDate')
                        obj.measurementDate = val;
                    elseif strcmp(S(1).subs, 'measurementTime')
                        obj.measurementTime = val;
                    elseif strcmp(S(1).subs, 'lengthUnit')
                        obj.lengthUnit = val;
                    elseif strcmp(S(1).subs, 'timeUnit')
                        obj.timeUnit = val;
                    elseif strcmp(S(1).subs, 'frequencyUnit')
                        obj.frequencyUnit = val;
                    elseif isprop(obj, S(1).subs)
                        obj = builtin('subsasgn', obj, S);
                    else
                        if numel(S) == 1
                            obj.additional.(S(1).subs) = val;
                        else
                            tmp = obj.additional.(S(1).subs);
                            tmp = subsasgn(tmp, S(2:end), val);
                            obj.additional.(S(1).subs) = tmp;
                        end
                    end
                otherwise
                    obj = builtin('subsasgn', obj, S);
            end
        end




    end


end
