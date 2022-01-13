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
classdef subject
    properties (SetAccess=private, GetAccess=private)
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
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end
    methods (Access=private)
        idx=findSession(obj,id);
    end
end

