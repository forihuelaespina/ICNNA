classdef optode
% icnna.data.core.optode - Either a light source or a detector
%
% Available since ICNNA v1.3.1
%
% According to the fNIRS glossary, an optode is the distal end of
% an fNIRS system which interfaces with the surface of the tissue
% being measured. Optodes can contain a single source (source optode),
% a single detector (detector optode), or a source accompanied by a
% short-separation detector.
%
%
%% Remarks
%
% Somewhat loosely inspired by MCX "src" component.
%
%% Known subclasses
%
%   icnna.data.core.lightSource
%   icnna.data.core.lightDetector
%
%
%% Properties
%
%   .id - uint32. default is 1.
%       A numerical identifier.
%   .name - Char array. By default is 'Optode0001'.
%       A name for the optode. 
%   .location2D - cell. A 2x1 column vector of 2D location of the
%               optode
%   .location3D - cell. A 3x1 column vector of 3D location of the
%               optode
%
%
%% Methods
%
% Type methods('icnna.data.core.condition') for a list of methods
% 
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.timeline, icnna.data.snirf.stim
%


%% Log
%
%   + Class available since ICNNA v1.2.3
%
% 8-Jul-2025: FOE
%   + File and class created.
%


    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties
        id(1,1) uint32 = 1; %Numerical identifier to make the object identifiable.
        name(1,:) char = 'Optode0001'; %Name of the condition
        location2D(2,1) double {mustBeNumeric} = [0 0];
        location3D(3,1) double {mustBeNumeric} = [0 0 0];
    end
    

    methods
        function obj=optode(varargin)
            %ICNNA.DATA.CORE.OPTODE A icnna.data.core.optode class constructor
            %
            % obj=icnna.data.core.optode() creates a default object.
            %
            % obj=icnna.data.core.optode(obj2) acts as a copy constructor
            %
            % 
            % Copyright 2025
            % @author: Felipe Orihuela-Espina
            %
            
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.optode')
                obj=varargin{1};
                return;
            else
                error(['icnna.data.core.optode:optode:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);

            end
        end





        %Gets/Sets
        function res = get.id(obj)
        %Gets the object |id|
            res = obj.id;
        end
        function obj = set.id(obj,val)
        %Sets the object |id|
            obj.id =  val;
        end


        function val = get.name(obj)
        %Retrieves the |name| of the optode
            val = obj.name;
        end
        function obj = set.name(obj,val)
        %Sets the |name| of the optode
            obj.name = val;
        end



        function val = get.location2D(obj)
        %Retrieves the |location2D| of the optode
            val = obj.location2D;
        end
        function obj = set.location2D(obj,val)
        %Sets the |location2D| of the optode
            obj.location2D = val;
        end


        function val = get.location3D(obj)
        %Retrieves the |location3D| of the optode
            val = obj.location3D;
        end
        function obj = set.location3D(obj,val)
        %Sets the |location3D| of the optode
            obj.location3D = val;
        end








    end


end
