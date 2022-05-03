%Class Experiment
%
%An experiment is to some extent the basic "document" of the
%data storing package. An experiment holds experimental
%data from a number of @link Subject subjects @endlink.
%The experiment represent the whole dataset, coming form all
%subjects, sessions, sources, etc...
%
%
%It also holds a record of valid session definitions. This
%permits matching of sessions across subjects.
%
%% Properties
%
%   .tag - The experiment logical name
%   .version - The data structure current version.
%   .description - A brief description of the experiment
%   .date - A date string
%   .dataSourceDefinitions - A set of recognised dataSources definitions
%       for the experiment. Formally a cell array of dataSourceDefinitions.
%       Initially no definitions are set.
%   .sessionDefinitions - A set of recognised sessions definitions
%       for the experiment. Formally a cell array of sessionDefinitions.
%       Initially no definitions are set.
%   .subjects - Experimental data from subjects that have
%       participate in the experiment.
%
%% Invariants
%
% See private/assertInvariants
%       
%% Methods
%
% Type methods('experiment') for a list of methods
% 
%
% Copyright 2008
% @date: 16-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also subject
%

%% Log
%
% 1-Sep-2016 (FOE): Class created.
%
% 20-February-2022 (ESR): Get/Set Methods created in experiment class.
%   + The methods are added with the new structure. All the properties have 
%   the new structure.
%   + The new structure enables new MATLAB functions
%   + We create a dependent property inside of the experiment class.
%   + The dataset property dependent are in the experiment class.
%
% 02-May-2022 (ESR): experiment class SetAccess=private, GetAccess=private) removed
%   + The access from private to public was commented because before the data 
%   did not request to enter the set method and now they are forced to be executed, 
%   therefore the private accesses were modified to public.
%
%

classdef experiment
    properties %(SetAccess=private, GetAccess=private)
        name='NewExperiment';
        version='1.0';
        description='';
        date=date;
        dataSourceDefinitions=cell(1,0);
        sessionDefinitions=cell(1,0);
        subjects=cell(1,0);
    end
    
    properties (Dependent)
       dataset 
    end
    
    methods
        function obj=experiment(varargin)
            %EXPERIMENT Experiment class constructor
            %
            % obj=experiment() creates a default experiment
            %
            % obj=experiment(obj2) acts as a copy constructor of experiment
            %
            % obj=experiment('Parameter',value,...) creates a new
            %    experiment with the specified parameters.
            %       * 'Name' - A string with the experiment name
            %       * 'Descrition' - A string with the experiment
            %           description
            %       * 'Date' - A date string
            %
            %
            % Copyright 2008
            % @date: 16-Apr-2008
            % @author Felipe Orihuela-Espina
            %
            % See also assertInvariants, experimentalDataset, analysis
            %
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'experiment')
                obj=varargin{1};
                return;
            else
                propertyArgIn = varargin;
                while length(propertyArgIn) >= 2,
                    prop = propertyArgIn{1};
                    val = propertyArgIn{2};
                    propertyArgIn = propertyArgIn(3:end);
                    switch prop
                        case 'Name'
                            obj=set(obj,'Name',val);
                        case 'Description'
                            obj=set(obj,'Description',val);
                        case 'Date'
                            obj=set(obj,'Date',val);
                        
                        otherwise
                            error(['Property ' prop ' not valid.'])
                    end
                end
            end
            assertInvariants(obj);
        end
        %% Get/Set methods
        %Provide struct like access to properties BUT maintaining class
        %encapsulation. 
        
        %dataset
        function val = get.dataset(obj)
            val = obj.dataset;
        end
        
        %date
        function val = get.date(obj)
            val = obj.date;
        end
        function obj = set.date(obj,val)
            obj.date=val;
        end
        
        %description 
        function val = get.description (obj)
            val = obj.description;
        end
        function obj = set.description (obj,val)
            if (ischar(val))
                obj.description = val;
            else
                error('Value must be a string');
            end
        end
        
        %name
        function val = get.name(obj)
            val = obj.name;
        end
        function obj = set.name(obj,val)
            if (ischar(val))
                obj.name = val;
            else
                error('Value must be a string');
            end
        end
        
        %version
        function val = get.version(obj)
            val = obj.version;
        end
        
        
    end
end
