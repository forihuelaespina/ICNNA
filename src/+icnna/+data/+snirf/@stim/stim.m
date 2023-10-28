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
% Type methods('icnna.data.snirf.probe') for a list of methods
% 
% Copyright 2022-23
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.snirf.snirf, icnna.data.snirf.nirsDataset
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
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end




    properties
        name(1,:) char = ''; %Name of the stimulus data
        data = nan(0,0); %Data stream of the stimulus channel
        dataLabels(:,1) cell = cell(0,1); %Names of additional columns of stim data
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
                     'Value must be a MxN matrix of M samples and N stimuli].']);
           end
           %assertInvariants(obj);
        end



        function val = get.dataLabels(obj)
        %Retrieves the list of names of additional columns of stim data
            val = obj.dataLabels;
        end
        function obj = set.dataLabels(obj,val)
        %Updates the list of names of additional columns of stim data
            for iLabel = 1:numel(val)
                if (~ischar(val{iLabel}))
                    error(['icnna.data.snirf.stim:set.dataLabels:InvalidPropertyValue',...
                        'Each object of cell array val must be a string.']);
                end
            end
            obj.dataLabels = reshape(val,numel(val),1);
        end



    end


end
