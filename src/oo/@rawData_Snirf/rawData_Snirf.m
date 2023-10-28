classdef rawData_Snirf < rawData
%Class rawData_Snirf
%
%A rawData_Snirf represents the bridge between the .snirf data files
%and ICNNA.
%Snirf sfiles support both raw and recostructed data.
%
% ICNNA also supports reading .snirf files using the more recent
%package based API. See:
%
%   icnna.data.snirf.snirf
%
% In fact, this class is just a wrapper over the icnna.data.snirf.snirf
%to operationalize the rawData abstract class in the traditional
%ICNNA architecture. But otherwise, it is recommended to use the newer
%package oriented API.
%
%% The Shared Near Infrared Spectroscopy Format (SNIRF).
%
% SNIRF is designed by the community in an effort to facilitate
% sharing and analysis of NIRS data.
%
% https://github.com/fNIRS/snirf
%
% See snirf specifications
% 
%
%
%
%% Superclass
%
% rawData - An abstract class for holding raw data.
%
%
%% Properties
%
%  == General information
%   .snirfImg - A icnna.data.snirf.snirf object. 
%  
%% Methods
%
% Type methods('rawData_Snirf') for a list of methods
%
%
% Copyright 2023
% @author: Felipe Orihuela-Espina
%
% See also rawData, rawData_Snirf, icnna.data.snirf.snirf
%

%% Log
%
% 13-May-2023: FOE
%   + File created
%


    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end


    properties
        snirfImg(1,1) icnna.data.snirf.snirf; % An icnna.data.snirf.snirf object
    end


 
    methods    
        function obj=rawData_Snirf(varargin)
            %RAWDATA_SNIRF RawData_Snirf class constructor
            %
            % obj=rawData_Snirf() creates a default rawData_Snirf
            %   with ID equals 1.
            %
            % obj=rawData_Snirf(obj2) acts as a copy constructor of
            %   rawData_Snirf
            %
            % obj=rawData_Snirf(id) creates a new rawData_Snirf
            %   with the given identifier (id). The name of the
            %   rawData_Snirf is initialised
            %   to 'RawDataXXXX' where is the id preceded with 0.
            %
            
            if (nargin==0)
                %Keep all other default values
            elseif isa(varargin{1},'rawData_Snirf')
                obj=varargin{1};
                return;
            else
                obj.id=varargin{1};
                obj.description=['RawData' num2str(obj.id,'%04i')];
            end
            %assertInvariants(obj);

        end
  
    end

    % methods (Access=protected)
    %     assertInvariants(obj);
    % end

    %RawData abstract methods
    methods
        obj=import(obj,filename);
        nimg=convert(obj,varargin);
    end


    methods

      %Getters/Setters

          %General information


      function res = get.snirfImg(obj)
         %Gets the object's |snirfImg|
         res = obj.snirfImg;
      end
      function obj = set.snirfImg(obj,val)
         %Sets the object's |snirfImg|
        obj.snirfImg = val;
      end



    end



end
