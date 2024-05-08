function obj = set(obj,varargin)
% ECG/SET Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%Modifying the ECG data also adjusts the timeline and the
%integrity status as appropriate.
%
%% Properties
%
% == Inherited
% 'ID' - The neuroimage ID.
% 'Description' - A short description of the image
% 'NSamples' - Number of samples 
% 'NChannels' - Number of picture elements (e.g. channels)
% 'NSignals' - Number of signals
% 'Timeline' - The image timeline
% 'Integrity' - The image integrity status per picture element
% 'Data' - The image data itself. Also updates the RR intervals
%	as follows; if RRMode is set to 'auto' then automatically
%	recomputes the new RR intevrals. If RRMode is set to 'manual'
%	then clear any existing RR intervals.
%
% == Others
% 'StartTime' - Absolute start time as a date vector:
%       [YY, MM, DD, HH, MN, SS]
% 'SamplingRate' - Sampling Rate in [Hz].
%       It automatically updates the timestamps
% 'RPeaksMode' - Sets the R peaks maintenance mode to either 
%   'manual' or 'auto'. In changing to 'auto' R peaks intervals
%   are refreshed.
% 'RPeaksAlgo' - Sets the R peaks detection algorithm to either 
%   'LoG' or 'Chen2017'. If 'RPeaksMode' is set to 'auto' R peaks
%   are refreshed.
% 'Threshold' - The threshold (either manual or automatic). Changing
%    this property is only possible when in manual mode. Setting
%    a new threshold automatically recalculates the rPeaks.
% 'RPeaks' - Manually sets the R peaks. See also 'RPeaksMode' and
%	'Threshold'. Refer to private method getRR for calculating
%	 RR intervals
%
%
% Copyright 2009-24
% @date: 19-Jan-2009
% @author Felipe Orihuela-Espina
%
% See also structuredData, get
%

%% Log:
%
% 29-May-2019: FOE:
%   + Log started
%   + Added support for property rPeaksAlgo
%
% 12-Apr-2024: FOE
%   + Enabled some options for controlling Chen's algorithm
%
%

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    switch prop
        case 'StartTime'
            tmpVal=datenum(val);
            if all(tmpVal==val)
                error('Value must be a date vector; [YY, MM, DD, HH, MN, SS]');
            else
                obj.startTime = datevec(tmpVal);
            end

        case 'SamplingRate'
            if (isscalar(val) && isreal(val) && val>0)
                obj.samplingRate = val;
            else
                error('ICAF:ecg:set',...
			'Value must be a positive real');
            end

        case 'Data'
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
                                tmpOptions.maskhalfsize = 2; %Half-width of the enhancement mask in [samples]
                                tmpOptions.searchingrange = 0.3; %in [s]. For adults
                                %tmpOptions.searchingrange = 0.1; %in [s]. For children
                                tmpOptions.samplingrate = get(obj,'SamplingRate'); %[Hz]
                                tmpOptions.qrsminimumamplitude = 0.5; %in [mV]. Used for triggering the QRS search.
                                tmpOptions.thresholdcrest = 0.22;
                                %tmpOptions.thresholdcrest = 0.4;
                                tmpOptions.thresholdtrough = -0.2;
                                %tmpOptions.thresholdtrough = -0.4;
                                tmpOptions.QRSlateny=0.12; %In [s]. Latency between two QRS. For adults
                                %tmpOptions.QRSlateny=0.06; %In [s]. Latency between two QRS. For child
                                %tmpOptions.QRSlateny=0.03; %In [s]. Latency between two QRS. For child plus allow arrythmias
                                tmpOptions.nboundarysamples = 5; %Controls alleviation of boundary effects
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
            
        case 'RPeaksMode'
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

        case 'RPeaksAlgo'
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

        case 'Threshold'
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

        case 'RPeaks'
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

        otherwise
            obj=set@structuredData(obj,prop,val);
    end
end
%assertInvariants(obj);