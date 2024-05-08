classdef ecg < structuredData
%Class ecg
%
%An ECG (electrocardiogram).
%
%The structuredData ECG has only a single signal, which is the raw ECG
%data.
%
%
%
%% Superclass
%
% structuredData
%
%% Properties
%
% See structuredData for inherited properties
%
% == Others
%   .samplingRate - The sampling rate in [Hz]
%   .startTime - Absolute start time. A row date vector (6D);
%       [YY, MM, DD, HH, MN, SS]
%
%   .rPeaksMode - Indicates the maintenance mode for the RR intervals
%	See also .rr property. Possible values are
%		'manual' - R peaks are maintained by the user
%		'auto' - R peaks are automatically computed by the class
%			See static method getRPeaks.
%			This is the default mode. Resetting auto mode
%			overrides previous manual manipulation.
%   .rPeaksAlgo - Algorithm used to detect R peaks. Possible values
%       are:
%       'LoG' - (Default) Laplacian of a Gaussian.
%       'Chen2017' - See qrsdetection method
%   .threshold - Threshold for R peak detection over the Laplacian
%	of a Gaussian of the raw signal. In auto mode, the threshold
%	it is automatically selected to the statistically optimal
%	using the Ridler and Calvard algorithm. In manual mode,
%	it can be manipulated at will. Manipulating the threhsold
%	in manual mode overrides previous manual manipulation.
%   .rPeaks - R Peaks. Under automatic mode it is updated
%	everytime the ECG data is set. Under manual mode it MUST
%	be maintained by the user and peaks can be added or removed
%	at will. See also .rrMode and .threshold properties.
% == Derived
%   .rr - A function of the rPeaks (but pre-store to speed up things)
%       It is automatically updated everytime RPeaks are updated
%   .timestamps - Timestamps in milliseconds; relative to the absolute
%       start time. Calculated as a function of the sampling rate.
%
%
%
%% Methods
%
% Type methods('ecg') for a list of methods
% 
% Copyright 2009-24
% Author: Felipe Orihuela-Espina
%
% See also structuredData, rawData_BioHarnessECG
%



%% Log:
%
% File created: 19-Jan-2009
% File last modified (before creation of this log): N/A. This class file
%   had not been modified since creation.
%
% 28-May-2019: FOE:
%   + Log started
%   + Added new algorithm for detecting R peaks (qrsdetection [Chen2017])
%   incorporating algorithm from literature.
%
% 28-May-2019: FOE:
%   + Added property rPeaksAlgo to keep arecord of the algorithm used
%   for detecting the rPeaks
%
% 12-Apr-2024: FOE (ICNNA v1.2.2)
%   + Got rid of old labels @date and @modified.
%   + Added property classVersion. Set to '1.0' by default.
%   + Started to update calls to get attributes using the struct like syntax
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end


    properties (SetAccess=private, GetAccess=private)
        samplingRate=250;%in [Hz]
        startTime=datevec(date);       
        rPeaksMode = 'auto';
        rPeaksAlgo = 'LoG'; %{'LoG','Chen2017'}
        threshold = 0;
        rPeaks = zeros(0,1); %See getRPeaks
        rr=zeros(0,1); %See getRR and getRPeaks
    end
    properties (SetAccess=private, Dependent = true)
        timestamps;
    end
    
    methods
        function obj=ecg(varargin)
            %ECG ECG class constructor
            %
            % obj=ecg() creates a default ECG with ID equals 1.
            %
            % obj=ecg(obj2) acts as a copy constructor of ECG
            %
            % obj=ecg(id) creates a new empty ECG with the
            %   given identifier (id).
            %
            %
            % The name of the ecg is initialised
            % to 'ECGXXXX' where is the id preceded with 0.
            %
            %
            % 
            % Copyright 2009
            % date: 19-Jan-2009
            % Author: Felipe Orihuela-Espina
            %
            
            obj = obj@structuredData(varargin{:});
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'ecg')
                obj=varargin{1};
                return;
            else
                obj.id = varargin{1};

            end
            obj.description = ['ECG' num2str(obj.id,'%04i')];
            %assertInvariants(obj);
        end





 
        %%Dependent properties
        function timestamps = get.timestamps(obj)
            nSamples = obj.nSamples;
            sr=get(obj,'SamplingRate');
            %timestamps=(0+1/sr):(1/sr):(nSamples/sr);
            %timestamps=timestamps'*1000; %to ms.
            timestamps=((0:nSamples-1)/sr)*1000; %to ms.
            if ~isempty(timestamps)
                timestamps=timestamps-timestamps(1);
            end
        end % timestamps get method
    end

    methods (Access=private)
        [rr]=getRR(obj);
    end
    
    methods (Static)
        [rPeaks,threshold]=getRPeaks(ecgData,options); %Uses the R peak detection
                    %algorithm indicated by property rPeaksAlgo
        [rPeaks,threshold]=getRPeaksByLoG(ecgData,thresh); %Threshold
                    %input is optional
        thre=optimalThreshold(I); %Code belong to Jing Tian
        [rPeaks]=qrsdetection(ecgdata,options); %Threshold
                    %input is optional
    end
end