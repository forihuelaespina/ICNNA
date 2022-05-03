%Class Subject
%
%A subject represent an person or animal that has taken part
%in a experiment.
%
%A subject can hold any number of experimental measurements
%or sessions.
%
%% Properties
%
%   .id - A numerical identifier.
%   .name - The subject's name
%   .age - The subject age. Empty if unknown
%   .sex - The subject sex; 'M'ale/'F'emale/'U'nknown
%   .hand - Handedness 'L'eft/'R'ight/'A'mbidextrous/'U'nknown
%   .sessions - Set of measurement sessions.
%
%% Methods
%
% Type methods('subject') for a list of methods
%
%
% Copyright 2008
% date: 17-Apr-2008
% Author: Felipe Orihuela-Espina
%
% See also experiment, session
%

%% Log
%
% 29-January-2022 (ESR): Get/Set Methods created in subject
%   + The methods are added with the new structure. All the properties 
%   have the new structure (id,name,age,sex and hand)
%   + The new structure enables new MATLAB functions
% 
% 02-May-2022 (ESR): subject class SetAccess=private, GetAccess=private) removed
%   + The access from private to public was commented because before the data 
%   did not request to enter the set method and now they are forced to be executed, 
%   therefore the private accesses were modified to public.
%

classdef subject
    properties %(SetAccess=private, GetAccess=private)
        id=1;
        name='Subj0001';
        age=[];
        sex='U';
        hand='U';
        sessions=cell(1,0);
    end

    methods
        function obj=subject(varargin)
            %SUBJECT Subject class constructor
            %
            % obj=subject() creates a default subject with ID equals 1.
            %
            % obj=subject(obj2) acts as a copy constructor of subject
            %
            % obj=subject(id) creates a new subject with the given
            %   identifier (id). The name of the subject is initialised
            %   to 'SubjXXXX' where is the id preceded with 0.
            %
            % obj=subject(id,name) creates a new subject with the given
            %   identifier (id) and name.
            %
            % @Copyright 2008
            % date: 17-Apr-2008
            % Author: Felipe Orihuela-Espina
            %
            % See also assertInvariants, experiment, session
            %

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'subject')
                obj=varargin{1};
                return;
            else
                obj=set(obj,'ID',varargin{1});
                obj=set(obj,'Name',['Subj' num2str(obj.id,'%04i')]);
                if (nargin>1)
                    if (ischar(varargin{2}))
                        obj=set(obj,'Name',varargin{2});
                    else
                        error('Name is not a string.');
                    end
                end
            end
            assertInvariants(obj);
        end
        
        %% Get/Set methods
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.
        
        
        %Age
        function val = get.age(obj)
            % The method is converted and encapsulated. 
            % obj is the subject class
            % val is the value added in the object
            % get.age(obj) = Get the data from the subject class
            % and look for the age object.
            val = obj.age;
        end
        function obj = set.age(obj,val)
            % The method is converted and encapsulated and can be used 
            % as the example in the constructor method.
            % This method allows the change of data values.
            %   obj is the subject class
            %   val = is the provided value, later it is conditioned 
            %   according to the data type
            if (isscalar(val) && (val==floor(val)) && (val>=0))
                obj.age = val;
            else
                error('ICNA:subject:set:InvalidPropertyValue',...
                  'Value must be a positive integer (or 0).');
            end
        end
        
        %Hand
        function val = get.hand(obj)
            val = obj.hand;
        end
        function obj = set.hand(obj,val)
            val=upper(val);
            switch (val)
                case 'L'
                    obj.hand = val;
                case 'R'
                    obj.hand = val;
                case 'A'
                    obj.hand = val;
                case 'U'
                    obj.hand = val;
                case ''
                    obj.hand = 'U';
            otherwise
               error('ICNA:subject:set:InvalidPropertyValue',...
                    ['Value must be a single char. ' ...
                     '''L''eft/''R''ight/''A''mbidextrous/''U''nknown.']);
            end
        end
        
        %ID
        function val = get.id(obj)
            val = obj.id;
        end
        function obj = set.id(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val==floor(val)) && (val>0))
                %Note that a char which can be converted to scalar
                %e.g. will pass all of the above (except the ~ischar)
                obj.id = val;
            else
                error('ICNA:subject:set:InvalidPropertyValue',...
                      'Value must be a positive integer.');
            end
        end
        
        %Name
        function val = get.name(obj)
            val = obj.name;
        end
        function obj = set.name(obj,val)
            if (ischar(val))
                obj.name = val;
            else
                error('ICNA:subject:set:InvalidPropertyValue',...
                  'Value must be a string.');
            end
        end
        
        %Sex
        function val = get.sex(obj)
            val = obj.sex;
        end
        function obj = set.sex(obj,val)
            val=upper(val);
            switch (val)
                case 'M'
                    obj.sex = val;
                case 'F'
                    obj.sex = val;
                case 'U'
                    obj.sex = val;
                case ''
                    obj.sex = 'U';
                otherwise
                    error('ICNA:subject:set:InvalidPropertyValue',...
                          ['Value must be a single char. ' ...
                            '''M''ale/''F''emale/''U''nknown.']);
            end
        end
        
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end
    methods (Access=private)
        idx=findSession(obj,id);
    end
end

