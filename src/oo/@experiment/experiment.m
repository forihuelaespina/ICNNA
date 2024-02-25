classdef experiment
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
%   .classVersion - (Read only) The class version of the object
%   .tag - The experiment logical name
%   .version - DEPRECATED. The data structure current version. See
%       property .classVersion instead.
%   .description - A brief description of the experiment
%   .studyDate - Datetime. A convenience date (can be used to indicate
%        file creation, experiment start, etc.
%   .date - DEPRECATED. String. A convenience date.
%       See property studyDate instead. Property date is now only
%       wrapper of studyDate for backward compatibility.
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
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also subject
%



%% Log
%
% File created: 16-Apr-2008
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 21-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Added property classVersion. Set to '1.0' by default.
%   + Added get/set methods support for struct like access to attributes.
%   + For those attributes above also started to simplify the set
%   code replacing it with validation rules on the declaration.
%   + Improved some comments.
%   + Added property studyDate and deprecated property date.
%   + Deprecated property version.
%   + Added dependent properties for;
%       nDataSourceDefinitions
%       nSessionDefinitions
%       nSubjects
%   + Deprecated methods
%       getNDataSourceDefinitions
%       getNSessionDefinitions
%       getNSubjects
%





    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        name(1,:) char ='NewExperiment'; % The experiment logical name
        version(1,:) char ='1.0'; % DEPRECATED. The data structure current version.
        description(1,:) char =''; % A brief description of the experiment
        studyDate(1,1) datetime; % A date string
    end

    properties (SetAccess=private, GetAccess=private)
        dataSourceDefinitions= cell(1,0); % A set of recognised dataSources definitions for the experiment.
        sessionDefinitions=cell(1,0); % A set of recognised sessions definitions for the experiment. 
        subjects=cell(1,0); % List of participants.
    end

    properties (Dependent)
      date % DEPRECATED. A date string. See property studyDate
      nDataSourceDefinitions % Number of defined data sources.
      nSessionDefinitions    % Number of defined sessions.
      nSubjects              % Number of defined subjects.
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
            %       * 'name' - A string with the experiment name
            %       * 'descrition' - A string with the experiment
            %           description
            %       * 'date' - DEPRECATED. A date string
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
                obj.studyDate = datetime('now');

                propertyArgIn = varargin;
                while length(propertyArgIn) >= 2,
                    prop = propertyArgIn{1};
                    val = propertyArgIn{2};
                    propertyArgIn = propertyArgIn(3:end);
                    switch lower(prop)
                        case 'name'
                            obj.name = val;
                        case 'description'
                            obj.description = val;
                        case 'date'
                            obj.date = val;
                        
                        otherwise
                            error('ICNNA:experiment:experiment:InvalidParameter', ...
                                 ['Property ' prop ' not valid.'])
                    end
                end
            end
            assertInvariants(obj);
        end

    
    
    
    
    

      %Getters/Setters

      function res = get.name(obj)
         %Gets the object |name|
         res = obj.name;
      end
      function obj = set.name(obj,val)
         %Sets the object |name|
         obj.name = val;
      end


      function res = get.version(obj)
         %Gets the object |version|
         res = obj.version;
      end
      function obj = set.version(obj,val)
         %Sets the object |version|
         obj.version = val;
      end


      function res = get.description(obj)
         %Gets the object |description|
         res = obj.description;
      end
      function obj = set.description(obj,val)
         %Sets the object |description|
         obj.description = val;
      end


      function res = get.studyDate(obj)
         %Gets the object |studyDate|
         res = obj.studyDate;
      end
      function obj = set.studyDate(obj,val)
         %Sets the object |studyDate|
         obj.studyDate = val;
      end

      function res = get.date(obj)
         %Gets the object |date|
         res = datestr(obj.studyDate);
      end
      function obj = set.date(obj,val)
         %Sets the object |date|
         warning('ICNNA:experiment:set.date:Deprecated', ...
                 'Property date has been deprecated. Use property studyDate instead.');
         obj.studyDate = datetime(val);
      end


      function res = get.nDataSourceDefinitions(obj)
         %Gets the object |nDataSourceDefinitions|
         res = length(obj.dataSourceDefinitions);
      end

      function res = get.nSessionDefinitions(obj)
         %Gets the object |nSessionDefinitions|
         res = length(obj.sessionDefinitions);
      end
      
      function res = get.nSubjects(obj)
         %Gets the object |nSubjects|
         res = length(obj.subjects);
      end
    
    
    
    end
end
