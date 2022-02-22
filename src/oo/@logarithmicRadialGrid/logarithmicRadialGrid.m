%Class logarithmicRadialGrid
%
%A radial grid to impose over a 2D space. Rings radious are generated
%using a logarithmic increment. Radial rings increase
%their area exponentially to their distance to the origin, with
%external rings being bigger than internal rings.
%
%Polar cells of the grid are
%sequentially numbered. Firstly by angular rotation and then by
%radial location. Central bin, is numbered 1.
%
%
%          13   12   11
%            5  4  3
%        14  6  1  2  10  18 (and so on...)
%            7  8  9
%          15  16   17
%
%% Superclass
%
% menaGrid - An abstract grid
%
%% Properties
%
%   .minR - Radius of the central cell or minimum radius. Default value is 10
%   .maxR - Maximus radius of the grid. Default value is 1000
%   .nRings - Number of rings. Default is 5
%   .nAngles - Number of angles. Default is 12 (30 degrees)
%
% == Derived/Dependent
%   .r - Radius on the different rings
%   .th - Angles of the different branches
%       Both properties are computed with private mathod createGrid.
%
%% Methods
%
% Type methods('logarithmicRadialGrid') for a list of methods
% 
% Copyright 2008
% date: 15-Aug-2008
% Author: Felipe Orihuela-Espina
%
% See also menaGrid, createGrid
%

%% Log
%
% 20-February-2022 (ESR): Get/Set Methods created in logarithmicRadialGrid
%   + The methods are added with the new structure. All the properties have 
%   the new structure.
%   

classdef logarithmicRadialGrid < menaGrid
    properties (SetAccess=private, GetAccess=private)
        minR=10;
        maxR=1000;
        nRings=5;
        nAngles=12;
    end
    properties (Dependent = true)
        r;
        th;
    end

    
    methods
        function obj=logarithmicRadialGrid(varargin)
            %LOGARITHMICRADIALGRID LogarithmicRadialGrid class constructor
            %
            % obj=logarithmicRadialGrid() creates a default 
            %   logarithmicRadialGrid with ID equals 1.
            %
            % obj=logarithmicRadialGrid(obj2) acts as a copy constructor
            %   of logarithmicRadialGrid
            %
            % obj=logarithmicRadialGrid(id) creates a new
            %   logarithmicRadialGrid with the given identifier (id).
            %
            % obj=logarithmicRadialGrid(id,size) creates a new grid with
            %   the indicated identifier and size, where size is a vector
            %       <minR,maxR,nRings>
            %
            %
            % Copyright 2008
            % date: 15-Aug-2008
            % Author: Felipe Orihuela-Espina
            %
            % See also logarithmicRadialGrid
            %
            %
            
            %obj = obj@menaGrid(varargin{:});
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'logarithmicRadialGrid')
                obj=varargin{1};
                return;
            else
                obj=set(obj,'ID',varargin{1});
                if (nargin>1) %Image size also provided
                    try
                        obj.minR=0;
                        obj=set(obj,'MaximumRadius',varargin{2}(2));
                        obj=set(obj,'MinimumRadius',varargin{2}(1));
                        obj=set(obj,'nRings',varargin{2}(3));
                    catch ME
                        error('ICNA:logarithmicRadialGrid:Constructor:InvalidParameterValue',...
                            ['  Invalid parameter value. '...
                            'Please ensure that minR<maxR and nRings>=0.']);
                    end
                end

            end
            assertInvariants(obj);
        end

        
        %% Dependent properties
        function r = get.r(obj)
            which createGrid
            [r,tmp]=createGrid(obj,obj.minR,obj.maxR,obj.nRings,obj.nAngles);
        end % r get method
        function th = get.th(obj)
            [tmp,th]=createGrid(obj,obj.minR,obj.maxR,obj.nRings,obj.nAngles);
        end % th get method
        
        %% Get/Set methods
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.
        
        %minR
        function val = get.minR(obj)
            % The method is converted and encapsulated. 
            % obj is the logarithmicRadialGrid class
            % val is the value added in the object
            % get.minR(obj) = Get the data from the logarithmicRadialGrid class
            % and look for the minR object.
            val = obj.minR;
        end
        function obj = set.minR(obj,val)
            % The method is converted and encapsulated and can be used 
            % as the example in the constructor method.
            % This method allows the change of data values.
            %   obj is the logarithmicRadialGrid class
            %   val = is the provided value, later it is conditioned 
            %   according to the data type
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                 && (val>0))
                obj.minR = val;
            else
                error('ICNA:logarithmicRadialGrid:set:InvalidPropertyValue',...
                  'Value must be a positive integer.');
            end
        end
        
        %maxR
        function val = get.maxR(obj)
           val = obj.maxR; 
        end
        function obj = set.maxR(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val>0))
                obj.maxR = val;
            else
                error('ICNA:logarithmicRadialGrid:set:InvalidPropertyValue',...
                  'Value must be a positive integer.');
            end
        end
        
        %nAngles
        function val = get.nAngles(obj)
            val = obj.nAngles;
        end
        function obj = set.nAngles(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val==floor(val)) && (val>=0))
                obj.nAngles = val;
            else
                error('ICNA:logarithmicRadialGrid:set:InvalidPropertyValue',...
                  'Value must be a positive integer.');
            end
        end
        
        %nRings
        function val = get.nRings(obj)
           val = obj.nRings; 
        end
        function obj = set.nRings(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val==floor(val)) && (val>=0))
                obj.nRings = val;
            else
                error('ICNA:logarithmicRadialGrid:set:InvalidPropertyValue',...
                  'Value must be a positive integer.');
            end
        end
        
    end

    methods (Access=protected)
        assertInvariants(obj);
    end
    methods (Access=private)
        [r,th]=createGrid(obj,minR,maxR,nRings,nAngles);
    end
end