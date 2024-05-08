classdef stim
% icnna.data.snirf.stim A stimulus measurement as defined in the snirf file format.
%
%% The Shared Near Infrared Spectroscopy Format (SNIRF).
%
% https://github.com/fNIRS/snirf
%
% SNIRF is designed by the community in an effort to facilitate
% sharing and analysis of NIRS data.
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
% Type methods('icnna.data.snirf.stim') for a list of methods
% 
% Copyright 2022-23
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.snirf.snirf, icnna.data.snirf.nirsDataset
%   icnna.data.core.condition
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
%
%
% 19-May-2023: FOE
%   + Added constructor polymorphism for typecasting a struct.
%
% 3-Mar-2024: FOE
%   + Class format update:
%       * Attributes dataLabels is now string array instead of cell array
%       as specified by .snirf. Compatibility support is provided; if the user
%       passes a cell array for this attribute this is accepted, and
%       type casted to string array. However, when getting this property,
%       now only a string array is returned. Finally, cell array use for
%       these attributes is now DEPRECATED.
%   + classVersion increased to '1.0.1'
%
% 6-Apr-2024: FOE
%   + Added visibility flags for optional properties.
%       Some of the properties of the measurement are optional; they
%       may or may not be present. In its implementation thus far, ICNNA
%       had no way to distinguish the case when the attribute was simply
%       missing from the case it has some default value. Having visibility
%       or enabling flags solves the problem.
%       ICNNA also provides a couple of further methods; one to "remove" (hide)
%       existing optional attributes and one to check whether it has
%       been defined (e.g. to check its visibility status) which shall
%       prevent the need for try/catch in other functions using the class.
%       Regarding this latter, note that;
%       + Calling properties(measurement) will still list the "hidden"
%       properties, which ideally should not happen -but this relates back
%       to MATLAB's new way of the defining the get/set methods for struct
%       like access which requires the properties to be public.
%       + MATLAB has function isprop to determine whether a property is
%       defined by object, but again this will "see" the hidden properties.
%
%       NOTE: Making the class mutable so that it can grow organically 
%       on these optional attributes is not a good solution as this then
%       loses control on what other attributes could be defined beyond
%       those acceptable for snirf.
%
% 11-Apr-2024: FOE
%   + Updated error message when setting the .data
%   + Improved documentation
%

    properties (Constant, Access=private)
        %classVersion = '1.0'; %Read-only. Object's class version.
        classVersion = '1.0.1'; %Read-only. Object's class version.
    end




    properties
        name(1,:) char = ''; %Name of the stimulus data
        data = nan(0,0); %Data stream of the stimulus channel
        dataLabels(:,1) string = strings(0,1); %Names of additional columns of stim data
    end
    
    properties (Access = private)
        %Visibility/Availability flags:
        %The optional attributes are;
        %  1) dataLabels

        flagVisible struct = struct('dataLabels',false); %Not visible by default
    end

    
    
    methods
        function obj=stim(varargin)
            %ICNNA.DATA.SNIRF.STIM A icnna.data.snirf.stim class constructor
            %
            % obj=icnna.data.snirf.stim() creates a default object.
            %
            % obj=icnna.data.snirf.stim(obj2) acts as a copy constructor
            %
            % obj=icnna.data.snirf.stim(inStruct) attempts to typecasts the struct
            %
            % 
            % Copyright 2022-23
            % @author: Felipe Orihuela-Espina
            %
            
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.snirf.stim')
                obj=varargin{1};
                return;
            elseif isstruct(varargin{1}) %Attempt to typecast
                tmp=varargin{1};
                tmpFields = fieldnames(tmp);
                for iField = 1:length(tmpFields)
                    tmpProp = tmpFields{iField};
                    if ismember(tmpProp,properties(obj))
                        obj.(tmpProp) = tmp.(tmpProp);
                    end
                end

                return;
            else
                error(['icnna.data.snirf.stim:stim:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);

            end
        end





        %Gets/Sets

        function val = get.name(obj)
        %Retrieves the name of the stimulus data
            val = obj.name;
        end
        function obj = set.name(obj,val)
        %Updates the name of the stimulus data
            obj.name = val;
        end



        function val = get.data(obj)
        %Retrieves the data stream of the stimulus channel
            val = obj.data;
        end
        function obj = set.data(obj,val)
        %Updates the data stream of the stimulus channel
           if (ismatrix(val))
               obj.data = val;
           else
               error(['icnna.data.snirf.stim:set.data:InvalidPropertyValue',...
                     'Value must be a Mx3 matrix of M events and 3 columns; onset, duration and amplitude].']);
           end
           %assertInvariants(obj);
        end



        function val = get.dataLabels(obj)
        %Retrieves the list of names of additional columns of stim data
            if obj.flagVisible.dataLabels
                val = obj.dataLabels;
            else
                error('ICNNA:icnna.data.snirf.stim:get.dataLabels:Undefined', ...
                    'Undefined optional field dataLabels.');
            end
        end
        function obj = set.dataLabels(obj,val)
        %Updates the list of names of additional columns of stim data
            % for iLabel = 1:numel(val)
            %     if (~ischar(val{iLabel}))
            %         error(['icnna.data.snirf.stim:set.dataLabels:InvalidPropertyValue',...
            %             'Each object of cell array val must be a string.']);
            %     end
            % end
            obj.dataLabels = reshape(val,numel(val),1);
            obj.flagVisible.dataLabels = true;
        end





        %%Suport methods for visibility of optional attributes
        function res = isproperty(obj,propertyName)
        %Check whether existing optional attributes have been defined (i.e. checks visibility)
            propertyName = char(propertyName);
            res = isprop(obj,propertyName);
            switch(propertyName)
                case {'dataLabels'}
                    res = obj.flagVisible.(propertyName);
                otherwise
                    %Do nothing
            end
        end


        function obj = rmproperty(obj,propertyName)
        %"Removes" (hides) existing optional attributes
            propertyName = char(propertyName);
            switch(propertyName)
                case {'dataLabels'}
                    obj.flagVisible.(propertyName) = false;
                case {'name','data'}
                    error('ICNNA:icnna.data.snirf.stim:rmproperty:NonOptionalProperty', ...
                        ['Property ' propertyName ' cannot be removed. It is not optional for .snirf format.']);
                otherwise
                    error('ICNNA:icnna.data.snirf.stim:rmproperty:UnknownProperty', ...
                        ['Unknown property ' propertyName '.']);
            end
        end

    end


end
