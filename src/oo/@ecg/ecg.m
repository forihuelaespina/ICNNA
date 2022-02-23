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
% Copyright 2009-19
% date: 19-Jan-2009
% Author: Felipe Orihuela-Espina
%
% See also structuredData, rawData_BioHarnessECG
%



%% Log:
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
% 20-February-2022 (ESR): Get/Set Methods created in ecg class
%   + The methods are added with the new structure. All the properties have 
%   the new structure.
%   + The new structure enables new MATLAB functions
%   + We create a dependent property inside of the ecg class.
%   + The RR, NN, timestamps and data properties dependents are in the
%   ecg class.



classdef ecg < structuredData
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
    
    properties (Dependent)
        RR
        NN
        data
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
                obj=set(obj,'ID',varargin{1});

            end
            obj=set(obj,'Description',...
                    ['ECG' num2str(get(obj,'ID'),'%04i')]);
            %assertInvariants(obj);
        end

        %%Dependent properties
        function timestamps = get.timestamps(obj)
            nSamples=get(obj,'NSamples');
            sr=get(obj,'SamplingRate');
            %timestamps=(0+1/sr):(1/sr):(nSamples/sr);
            %timestamps=timestamps'*1000; %to ms.
            timestamps=((0:nSamples-1)/sr)*1000; %to ms.
            if ~isempty(timestamps)
                timestamps=timestamps-timestamps(1);
            end
        end % timestamps get method
        
        
        %% Get/Set methods
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.
        
        %data
        function obj = set.data(obj,val)
            try
                obj=set@structuredData(obj,'Data',val);
                %The data must be set before calling getRR, otherwise
                %we will be operating on old data
                switch(get(obj,'RPeaksMode'))
                    case 'manual'
                        obj.rPeaks=zeros(0,1); %Clear existing ones
                    case 'auto'
                        %Automatic update
                        switch lower(obj.rPeaksAlgo)
                            case 'log'
                                tmpOptions.algo = 'LoG';
                                tmpOptions.threshold = obj.threshold;
                            case 'chen2017'
                                tmpOptions.algo = 'Chen2017';
                            otherwise
                                error('ICAF:ecg:set',...
                                    'Unexpected R Peaks detection algorithm.');
                        end
                        tmpData = getSignal(obj,1);
                        [obj.rPeaks,obj.threshold] = ...
                            ecg.getRPeaks(tmpData,tmpOptions);
                    otherwise
                        error('ICAF:ecg:set',...
                            'Unexpected R Peaks Maintenance Mode.');
                end
                obj.rr = getRR(obj);
            catch ME
                %Rethrow the error
                rethrow(ME);
            end
        end

        %RR
        function val = get.RR(obj)
           val = obj.rr; 
        end
        
        %rPeaksMode
        function val = get.rPeaksMode(obj)
            val = obj.rPeaksMode;
        end
        function obj = set.rPeaksMode(obj,val)
            if ischar(val)
              switch(val)
                  case 'manual'
                      obj.rPeaksMode=val;
                  case 'auto'
                      obj.rPeaksMode = val;
                      tmpOptions.logthreshold = obj.threshold;
                      tmpData = getSignal(obj,1);
                      [obj.rPeaks,obj.threshold] = ...
                            ecg.getRPeaks(tmpData,tmpOptions);
                      obj.rr = getRR(obj);
                  otherwise
                      error('ICAF:ecg:set',...
                          'Unexpected R Peaks Maintenance Mode.');
              end
            end
        end
        
        %rPeaksAlgo
        function val = get.rPeaksAlgo(obj)
            val = obj.rPeaksAlgo;
        end
        function obj = set.rPeaksAlgo(obj,val)
            if ischar(val)
                if ismember(lower(val),{'log','chen2017'})
                    obj.rPeaksAlgo=val;
                    if strcmp(get(obj,'RPeaksMode'),'auto')
                        switch lower(obj.rPeaksAlgo)
                            case 'log'
                                tmpOptions.algo = 'LoG';
                                tmpOptions.threshold = obj.threshold;
                            case 'chen2017'
                                tmpOptions.algo = 'Chen2017';
                            otherwise
                                error('ICAF:ecg:set',...
                                    'Unexpected R Peaks detection algorithm.');
                        end
                        tmpData = getSignal(obj,1);
                        [obj.rPeaks,obj.threshold] = ...
                            ecg.getRPeaks(tmpData,tmpOptions);
                        obj.rr = getRR(obj);
                    end
                else
                    error('ICAF:ecg:set',...
                        'Unexpected R peaks detection algorithm.');
                end
            else
                error('ICAF:ecg:set',...
                    'R peaks detection algorithm must be a string or char array.');
            end
        end
        
        %rPeaks
        function val = get.rPeaks(obj)
            val = obj.rPeaks;
        end
        function obj = set.rPeaks(obj,val)
            switch(get(obj,'RPeaksMode'))
                case 'manual'
                    if isreal(val) && all(floor(val)==val) ...
			&& all(val>0) && ~ischar(val)
                        obj.rPeaks=unique(val);
                        obj.rr = getRR(obj);
                    end
                case 'auto'
                    warning('ICAF:ecg:set',...
                        ['Unable to update RPeaks because RPeaksMode is set to auto. ' ...
                        'Set RPeaksMode to manual before updating the R Peaks intervals.']);
                otherwise
                    error('ICAF:ecg:set',...
                        'Unexpected R peaks maintenance mode.');
            end
        end
        
        %samplingRate
        function val = get.samplingRate(obj)
            val = obj.samplingRate;
        end
        function obj = set.samplingRate(obj,val)
            if (isscalar(val) && isreal(val) && val>0)
                obj.samplingRate = val;
            else
                error('ICAF:ecg:set',...
                'Value must be a positive real');
            end
        end
        
        %startTime
        function val = get.startTime(obj)
           val = obj.startTime; 
        end
        function obj = set.startTime(obj,val)
            tmpVal=datenum(val);
            if all(tmpVal==val)
                error('Value must be a date vector; [YY, MM, DD, HH, MN, SS]');
            else
                obj.startTime = datevec(tmpVal);
            end

        end
        
        %threshold
        function val = get.threshold(obj)
            val = obj.threshold;
        end
        function obj = set.threshold(obj,val)
            switch(get(obj,'RPeaksMode'))
                case 'manual'
                    if isscalar(val) && isreal(val) ...
                            && val>0 && ~ischar(val)
                        switch lower(obj.rPeaksAlgo)
                            case 'log'
                                tmpOptions.algo = 'LoG';
                                tmpOptions.threshold = obj.threshold;
                            case 'chen2017'
                                tmpOptions.algo = 'Chen2017';
                            otherwise
                                error('ICAF:ecg:set',...
                                    'Unexpected R Peaks detection algorithm.');
                        end
                        tmpData = getSignal(obj,1);
                        [obj.rPeaks,obj.threshold] = ...
                                ecg.getRPeaks(tmpData,tmpOptions);
				        obj.rr = getRR(obj);
                    end
                case 'auto'
                    warning('ICAF:ecg:set',...
                        ['Unable to update Threshold because RPeaksMode is set to auto. ' ...
                        'Set RPeaksMode to manual before updating the threhsold.']);
                otherwise
                    error('ICAF:ecg:set',...
                        'Unexpected R peaks maintenance mode.');
            end
        end
        
        %NN
        function val = get.NN(obj)
           val = obj.rr; 
        end
        
        
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