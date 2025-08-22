classdef experimentBundle < icnna.data.core.identifiableObject
%Class experimentBundle
%
% Supersedes class @experimentSpace
%
% An intermedite representation of the experimental data, where the
%original data has been split into vectors for further analysis formalized
%as a bundle.
%
%
%% Remarks
%
% Although this class is intended to supersede class @experimentSpace,
%there are a few important differences;
%
%   * This class no longer keeps track or store the parameters' values
% of the "processing" steps to generate the vectors.
%   * This class has no knowledge of the computation of its content, i.e.
% no equivalent to method compute. The computation of the bundle is now
% separated.
%   * This class takes bit of a more formal approach i.e. the change
% of name from @experimentSpace to @experimentBundle. See more details
% below.
%   * In contrast to the @experimentSpace which could only store one
% vector per point in the base space, the @experimentBundle can handle
% as many vectors as needed.
%
%
%% Bundles, fiber bundles and vector bundles
%
% NOTE: I am certainly not an expert on mathematical bundles, so please
% take the following comments with a pinch of salt. Most of the notes
% below are a combination of Wikipedia, the web in general and genAI
% Copilot (when using this later I have marked explicity).
%
%
% In topology bundles are topological objects that permits associating
% full spaces (a.k.a. the total space) to points in some other spaces
% (a.k.a. the base space). A bit more formally
% [Wikipedia:Bundle_(mathematics)];
%
%   A bundle is a triple (B, E, p) where B and F are spaces and p: E -> B
% is a map. In a bundle;
%       + B is called the base space
%       + E is called the total space
%       + p is called the projection
%
% So you can think of a bundle as a function between spaces rather than
%a function between sets (without structures).
%
% Note that the bundle does not impose any restriction neither on the
% base space nor on the total space. Depending on how we choose these
% spaces and which restrictions we impose to the projection, there exist
% many types of bundles. For instance;
%
%   * Fiber bundles - A bundle where the base space is a manifold
%       and the total space is a fiber.
%   * Vector bundle - An instance of fiber bundle where the base space
%       is a manifold and the total space is specifically a finite
%       dimensional vector space.
%   * Tangent bundles - An instance of a vector bundle where the base
%       space is a differentiable manifold and the total space (the
%       tangent space) is the vector space of tangent vectors.
%
% Copilot (asked 27-Jun-2025) gave me this nice tip to understand the
% difference between a bundle and a space:
%
%   "A vector space is a single, standalone algebraic object. A vector
%   bundle is like a vector space that moves smoothly along a base space."
%
%
% Now, a very important aspect of bundles is that the projection is
%defined from the total space to the base space, that is:
%
%   p: E -> B : Associate point in the base space to the vector spaces.
%
% ...rather than the more intuitive:
%
%   p: B -> E : Associate the vector spaces in the total space
%               to the points in the base space.
%
% And further, the projection p does NOT need to be invertible.
%
% Although a bit counter-intuitive, but p: E -> B is the correct choice.
%Copilot again (asked 27-Jun-2025) gives a good hint at why this is the
%case;
%   
%   "Imagine a plane attached to each point of a surface (like a sphere).
% The projection collapses all the vectors in a plane (fiber) down to
% the point they're attached to. There's no way to “go back” from a point
% on the base space to a unique vector above it - because there's an
% entire vector space up there!"
%
% But of course the total space E ought to know its position over B. In
% this sense, p(v) = b means that the vector v is in the fiber E above b.
%
% By the way, when it exists, the opposite map s: B -> E that picks a vector
% from a given fiber is called a section.
%
% I have not been able to identify a more specific name for a bundle for
% which;
%   + the base space is a discrete space
%   + the total space is a family of vector spaces.
%
%   Note that the concept of bundle maps does not quite fit as it requires
%that the different vector spaces in the family in the total space have an
%additional structure-preserving map q: E1 -> E2, which I do not have
%right now.
%
% So, in summary, what in previous ICNNA version was naively being called
% the experiment "space" (@experimentSpace), was actually a very
% rudimentary form of a bundle, ergo the new class name.
%
%
%% The base space
%
% The base space is a N dimensional discrete space where in point in the
%space correspond to a measurement of interest or case. In the old class
%@experimentSpace, this used to be a 7D discrete space described by:
%
% <Subject,
%  Session,
%  dataSource,
%  Channel,
%  Signal,
%  Stimulus,
%  Block>
%
%  Here, this is generalized and the dimensions are no longer fixed.
% Notwithstanding, there will be a minimum core of dimensions somewhat
% analogoues to the old ones;
%
%   ExperimentalUnit - Replaces <Subject> so that now for instance it can
%       identify diads in hyperscanning experiments.
%   Group - The experimental group (proxy of the experimental treatment
%       being administered to the experimental unit.
%   Session - Replaces the old <Session> (the previously grouped Group
%       and Session under the same roof) to facilitate the modelling for
%       cross-sectional or longitudinal designs.
%   SamplingSite - Replaces <Channel>. The name is intended to convey
%       a more general concept than can expand channels but also voxels
%       but also regions of interest i.e. groups of channels. Basically
%       it represents the spatial location where the measurement is taken.
%   Condition - Replaces <Stimulus> to 1) better align with the
%       nomenclature of the timeline, and 2) better convey the idea that
%       it can also represent non-experimental circumstances i.e. events
%       not related to experimenal stimuli.
%   Trial - Analogous to <Block>, which is a term less used nowadays in
%       the community, to refer to an event of a condition. While positive
%       number still refer to individual trials within a condition, but
%       importantly, negative values e.g. -1, will now be used to indicate
%       trial aggregations e.g. block averaging.
%   Signal - Analogous to <Signal>.
%   IntegrityFlag - New. Before only integrity check (and passed) data
%       will be in the @experimentSpace. Now, uncheck or non-clean data
%       is allowed to get in, but they are accompanied by a flag. You can
%       define your own flags but the following will be fixed;
%           .MISSING  = -1;
%           .UNCHECK  = 0;
%           .FINE     = 1;
%           .NOISY    = 2; - In general. Define your own flags to more
%                               accurately differentiate different types
%                               of prominent noise affecting this case.
%
%
%  Moreover, for each of these (except Trial and IntegrityFlag) the base
% space will recognise either the |id| or the |name|.
%
% Finally, note that the <dataSource> from the @experimentSpace does
% not "disappear" but instead it is now encoded in the total space as
% different vector spaces in the family in the total space.
%
%% The total space
%
% The total space is now a family of vector spaces rather than a single
%vector space (i.e. this class is NOT a vector bundle).
%
% This for instance permits a much flexible representation of the trial
%subperiods. For instance, rather than having to have a single vector
%representing the whole trial time course, (and hence "forgetting" where
%the onset was), one can now have 4 vectors; one for baseline, one for the
%break delay, one for the main block and one for the recovery. Further,
%these can now be asymmetric across cases, e.g. not every point in the
%base space will be associated to a vector of the same characteristics.
%
% Moreover, I can now associate several data sources into one e.g. for
%data fusion purposes.
%
%
%
%       
%% Properties
%
%   -- Inherited
%   .id - Int. Default is 1.
%       A numerical descriptor
%   .name - Char array. Default is 'experimenBundle0001'
%       A name.
%
%   -- Public
%   .description - Char array. Default is '' (empty)
%       A brief description.
%
%
%   -- Private
%   .E - Table. Default is empty.
%       The total space. Each row is a family of (vector) spaces. Each
%       column will be a vector space on its own.
%       Analogous to property |Fvectors| in the experimentSpace.
%   .B - Table. Default is empty.
%       The base space. See the description of the base space above.
%       Analogous to property |Findex| in the experimentSpace.
%   .p - Table. Default is empty
%       A table with two columns;
%           + 'FamilyOfSpaces' pointing to one row of E, and
%           + 'BaseSpacePoint' pointing to one row of B
%   .sites - Table. Dictionary-like but implemented with a table as 2 keys
%       are needed for each site; the Site.id and the Site.name.
%       The listing of sampling sites. In the simplest case, there will
%       be a site per channel, but more sophisticated site such as
%       regions of interest can be defined. The keys of the dictionary
%       are used to index the SamplingSite dimensions of the base space B.
%       The (sampling) sites will be described by a set of descriptors
%       that can be tailored by the user. Some examples of descriptors
%       may be:
%           - channel numbers
%           - sources or detector indexes
%           - a (nominal) 3D location
%       At least 1 descriptor (generically called Descriptor.1) is
%       considered by default (akin to the value in a dictionary), but
%       this can be customized.
%  
%
%% Dependent properties
%
%   .nCases - Number of points in the base space (for which there is
%       an associated space in E even if an empty one -missing data-,
%       i.e. not the "whole" cartesian product of the base space
%       dimensions).
%
%% Methods
%
% Type methods('icnna.data.core.experimentBundle') for a list of methods
% 
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also
%


%% To do
%
% Either enforce that the base space and the total space have the
%same number of rows (cases) or properly implement projection p.
%


%% Log
%
%   + Class available since ICNNA v1.3.1
%
% 27-Apr-2025: FOE
%   + File and class created. Loosely inspired by @experimentSpace
%
% 26-Jul-2025: FOE
%   + Made subclass of @icnna.data.core.identifiableObject
%   + Improve some comments
%


    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        description(1,:) char = ''; %Description of the bundle.
        
    end

    properties (SetAccess=private)
        E table = table(); %The total space
        B table = table('Size',[0 14],...
                        'VariableTypes',{'uint32','string',...
                                         'uint32','string',...
                                         'uint32','string',...
                                         'uint32','string',...
                                         'uint32','string',...
                                         'uint32',...
                                         'uint32','string',...
                                         'double'},...
                        'VariableNames',{'ExperimentalUnit.id','ExperimentalUnit.name',...
                                         'Group.id','Group.name',...
                                         'Session.id','Session.name',...
                                         'SamplingSite.id','SamplingSite.name',...
                                         'Condition.id','Condition.name',...
                                         'Trial',...
                                         'Signal.id','Signal.name',...
                                         'IntegrityFlag'}); %The base space
        p table = table('Size',[0 2],...
                        'VariableTypes',{'uint32','uint32'},...
                        'VariableNames',{'FamilyOfSpaces','BaseSpacePoint'}); %The projection.
        sites table = table('Size',[0 3],...
                        'VariableTypes',{'uint32','string','cell'},...
                        'VariableNames',{'Site.id','Site.name','Descriptor.1'});
                            %Sampling site descriptors
    end


    properties (Dependent)
        nCases %Read only
    end



    methods
        function obj=experimentBundle(varargin)
            %A icnna.data.core.experimentBundle class constructor
            %
            % obj=icnna.data.core.experimentBundle() creates a default object.
            %
            % obj=icnna.data.core.experimentBundle(obj2) acts as a copy constructor
            %
            % 
            % Copyright 2025
            % @author: Felipe Orihuela-Espina
            %
            
            obj@icnna.data.core.identifiableObject();
            tmp = split(class(obj),'.');
            obj.name = [tmp{end} num2str(obj.id,'%04d')];
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.experimentBundle')
                obj=varargin{1};
                return;
            else
                error(['icnna.data.core.experimentBundle:experimentBundle:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);

            end
        end





        %Gets/Sets
        function val = get.description(obj)
        %Retrieves the |description| of the condition
            val = obj.description;
        end
        function obj = set.description(obj,val)
        %Sets the |description| of the condition
            obj.description = val;
        end





        function val = get.B(obj)
        %Retrieves the base space
            val = obj.B;
        end
        function obj = set.B(obj,val)
        %Sets the base space

            %Check if the number of columns is AT LEAST 14
            if size(val,2) < 14
                error('icnna:data:core:experimentBundle:set_B:InvalidValue',...
                      'Base space ought to have at least 14 columns.');
            end

            %Check the column names to ensure the mandatory ones (onset,
            %duration, amplitude and info) are present.
            tmpColNames = val.Properties.VariableNames;
            if any([~ismember('ExperimentalUnit.id',tmpColNames) , ...
                  ~ismember('ExperimentalUnit.name',tmpColNames) , ...
                  ~ismember('Group.id',tmpColNames) , ...
                  ~ismember('Group.name',tmpColNames) , ...
                  ~ismember('Session.id',tmpColNames) , ...
                  ~ismember('Session.name',tmpColNames) , ...
                  ~ismember('SamplingSite.id',tmpColNames) , ...
                  ~ismember('SamplingSite.name',tmpColNames) , ...
                  ~ismember('Condition.id',tmpColNames) , ...
                  ~ismember('Condition.name',tmpColNames) , ...
                  ~ismember('Trial',tmpColNames) , ...
                  ~ismember('Signal.id',tmpColNames) , ...
                  ~ismember('Signal.name',tmpColNames) , ...
                  ~ismember('IntegrityFlag',tmpColNames)])
                error('icnna:data:core:experimentBundle:set_B:MissingBaseSpaceDimension',...
                        ['One or more of the minimum core dimensions ' ...
                         'of the base space are missing.'])
            end

            obj.B = val;
        end

        function val = get.E(obj)
        %Retrieves the total space
            val = obj.E;
        end
        function obj = set.E(obj,val)
        %Sets the total space
            obj.E = val;
        end


        function val = get.p(obj)
        %Retrieves the projection p:E -> B
            val = obj.p;
        end
        function obj = set.p(obj,val)
        %Sets the projection p:E -> B
            tmpColNames = val.Properties.VariableNames;
            if any([~ismember('FamilyOfSpaces',tmpColNames) , ...
                    ~ismember('BaseSpacePoint',tmpColNames)])
                error('icnna:data:core:experimentBundle:set_p:InvalidValue',...
                        ['Projection p has to link ''FamilyOfSpaces'' ' ...
                         'from E to a ''BaseSpacePoint'' from B.'])
            end
            obj.p = val;
        end


        function val = get.sites(obj)
        %Retrieves the sampling site descriptors
            val = obj.sites;
        end
        function obj = set.sites(obj,val)
        %Sets the sampling site descriptors
            %Check if the number of columns is AT LEAST 14
            if size(val,2) < 3
                error('icnna:data:core:experimentBundle:set_sites:InvalidValue',...
                      'Sampling site descriptors ought to have at least 3 columns.');
            end

            %Check the column names to ensure the mandatory ones (onset,
            %duration, amplitude and info) are present.
            tmpColNames = val.Properties.VariableNames;
            if any([~ismember('Site.id',tmpColNames) , ...
                    ~ismember('Site.name',tmpColNames)])
                error('icnna:data:core:experimentBundle:set_sites:MissingBaseSpaceDimension',...
                        ['One or more of the minimum core dimensions ' ...
                         'of the sampling site descriptors are missing.'])
            end
            obj.sites = val;
        end









        %Dependent properties gets/sets
        function val = get.nCases(obj)
            %(DEPENDENT) Gets the object |nCases|
            %
            % The number of cases declared in the base space.
            val = size(obj.B,1);
        end





    end


end