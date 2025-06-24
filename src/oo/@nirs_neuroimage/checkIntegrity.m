function obj=checkIntegrity(obj,varargin)
%NIRS_NEUROIMAGE/CHECKINTEGRITY Check the integrity of the channels
%
% obj=checkIntegrity(obj,varargin) Check the integrity of the
%       channels. By default only UNCHECK elements are put
%       to test. However this can be override by setting
%       'testAllChannels' to true.
%
% obj=checkIntegrity(obj,whichChannels,...) Check the integrity
%       of the indicated channels only.
%       By default only UNCHECK elements are put
%       to test. However this can be override by setting
%       'testAllChannels' to true.
%
% obj=checkIntegrity(...,'TestName',true) Apply the selected
%       test.
% 
% obj=checkIntegrity(...,'testAllChannels',true) Force checking
%       of all channels, regardles whether they are still UNCHECK
%       or have already been checked.
%
% obj=checkIntegrity(...,'verbose',true/false)
%       Enable/Disable progression messages. Default is enabled.
%
%
% The function check only those artefacts tests set to 'true'.
%
%By default only UNCHECK elements are put to test. However
%this can be override by setting 'testAllChannels' to true.
%
%
%This methods overwrites the superclasses checkIntegrity methods.
%
%% Available Tests
%
% 'CoefficientOfVariation' - Check the coefficient of variation of
%   the signal(s) and discard those channels for which the CoV is
%   above a threshold for ALL signals. Default 'true'.
%
%   You can use option .CoVThreshold (default = 0.15 i.e. 15%) to set a
%   default threshold to check the coefficient of variation.
%       * If .CoVThreshold is a scalar, then the same threshold is
%       used for all signals.
%       * If .CoVThreshold is a (row) vector, then there will be one
%       threshold per signals.
%
%   While the specific threshold shall vary depending on the study
%   and processing pipeline, typical CV rejection criteria for
%   oxyhemoglobin (HbO) and deoxyhemoglobin (HbR) signals generally
%   fall within the following ranges:
%
%       * Oxyhemoglobin (HbO): CV values above 15-20% are unreliable channels.
%       * Deoxyhemoglobin (HbR): CV values above 10-15% are unreliable channels.
%
%
% 'Complex' - Test the existence of complex numbers indicative
%	of implausible negative light recordings, and
%	subsequent inadequate conversion with the modified
%	Beer-Lambert law. Default 'true'.
%
% 'ApparentNonRecording' - Test the saturation of sensors at
%	1 wavelength leading to apparent non-recording effect.
%	Also known as the 0-test. Default 'true'.
%
% 'Mirroring' - Test the saturation of sensors at
%	2 wavelength leading to mirroring. Uses the
%	multi-scaled cross-correlation algorithm.
%	Default 'true'.
%
%    #================================================#
%    | Testing for mirroring is highly time consuming |
%    #================================================#
%
% 'OptodeMovement' - Test for presence of sudden changes
%	related to optode movements artefacts. Default 'false'.
%
%     By default is using Sato's algo.
%
%    #===============================================#
%    | Testing for optode movement useing my         |
%    | algorithm (second exponential fitting time    |
%    | series analysis (see Ref[1])is highly time    |
%    | consuming) and no algorithm has yet shown high|
%    | reliability. Use Sato's algorithm for faster  |
%    | results at the cost of lower sensitivity.     |
%    #===============================================#
%
%Please refer to superclasses and subclasses for
% additional available integrity checks.
%
%
%
%% References
%
% 1) Orihuela-Espina, F.; Leff, D.R.; Darzi, A.W.; Yang, G.Z.
%    (2008) Data integrity in continuous-wave functional near infrared
%    spectroscopy. Unpublished
%
%
%
%
% Copyright 2008-25
% @author Felipe Orihuela-Espina
%
% See also nirs_neuroimage, structuredData.checkIntegrity,
%       integrityStatus, get, set
%


%% Log
%
% File created: 17-Jun-2008
% File last modified (before creation of this log): 29-Oct-2010
%
% 20-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%
% 19-May-2025: FOE
%   + Added test of coefficient of variation.
%



%Deal with the options
opt.testCoefficientOfVariation=true;
opt.testComplex=true;
opt.testApparentNonRec=true;
opt.testMirroring=true;
opt.testOptodeMov=false;
opt.testAllChannels=false;
opt.verbose=true;
nChannels = obj.nChannels;
opt.whichChannels=1:nChannels;
opt.CoVThreshold =0.15; % 15%
    %   threshold to check the coefficient of variation.
    %       * If .CoVThreshold is a scalar, then the same threshold is
    %       used for all signals.
    %       * If .CoVThreshold is a (row) vector, then there will be one
    %       threshold per signals.



if (~isempty(varargin))
    tmp=varargin{1};
    if ((~ischar(tmp) && isreal(tmp) && all(floor(tmp)==tmp)))
        opt.whichChannels=tmp;
        varargin{1}=[];
    end
end

propertyArgIn = varargin;
remainingArgs=cell(0,0); %to be passed to superclass
                         %checkIntegrity method
pos=1;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val  = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
    case 'CoefficientOfVariation'
        opt.testCoefficientOfVariation = val;
    case 'CoVThreshold'
        opt.CoVThreshold = val;
    case 'Complex'
        opt.testComplex = val;
    case 'ApparentNonRecording'
        opt.testApparentNonRec = val;
    case 'Mirroring'
        opt.testMirroring = val;
    case 'OptodeMovement'
        opt.testOptodeMov = val;
    case 'testAllChannels'
        opt.testAllChannels = val;
        remainingArgs(pos)={prop};
        remainingArgs(pos+1)={val};
        pos=pos+1;
    otherwise
        remainingArgs(pos)={prop};
        remainingArgs(pos+1)={val};
        pos=pos+1;
   end
end


%Check the integrity test specifically desgined for this class
integrity=getStatus(obj.integrity,opt.whichChannels);
pos=1;
for ch=opt.whichChannels

  if (opt.testAllChannels || ...
	(getStatus(obj.integrity,ch)==integrityStatus.UNCHECK))


    %First run superclass integrity checks...
    if ~isempty(remainingArgs)
        obj=checkIntegrity@neuroimage(obj,ch,remainingArgs);
    else
        obj=checkIntegrity@neuroimage(obj,ch);
    end
    condition=getStatus(obj.integrity,ch);
%    condition=integrityStatus.FINE; %By default, assume the data is clean
                %Do not remove this line, so condition has
                %a value to assign at the end of the ifs

    channelData=getChannel(obj,ch);
    
    if (opt.testCoefficientOfVariation)
        %Operationalized using the quartile coefficient of dispersion (QCD)
        %as this is a more robust estimator of the coefficient of variation
        %than the "default" sigma/mu.
        %
        % The quartile coefficient of dispersion (QCD) is defined as
        %        Q3-Q1
        % QCD = -------
        %        Q3+Q1

        
        Q = quantile(channelData,3,1);
            %Each column of matrix Q contains the quantiles for
            % the corresponding column in the channel data (i.e.
            % for each signal).
        QCD = (Q(3,:)-Q(1,:))./(Q(3,:)+Q(1,:));

        if (all(QCD > opt.CoVThreshold)) %Coefficient of variation is above threshold.
            condition=integrityStatus.COEFFICIENTOFVARIATION;
        end
    end

    if (opt.testComplex)
        if ((any(any(imag(channelData))))) %Data is complex
        %(Negative raw light intensity recordings values)
            condition=integrityStatus.NEGATIVERECORDINGS;
        end
    end

    if (opt.testApparentNonRec)
        if (all(all(channelData==0))) %0-test
            condition=integrityStatus.NONRECORDINGS;
         end
    end

       
    if (opt.testMirroring) %Check for mirroring
        oxy=channelData(:,obj.OXY);
        deoxy=channelData(:,obj.DEOXY);
        options.visualize=false;
        [~,episodes]=nirs_neuroimage.detectMirroringv3(oxy,deoxy,options);
        if (~isempty(episodes))
            condition=integrityStatus.MIRRORING;
        end
    end


    if (opt.testOptodeMov)
	    %warndlg('Option ''OptodeMovement'' not yet available',...
        %        'Integrity check');
        oxy=channelData(:,obj.OXY);
        deoxy=channelData(:,obj.DEOXY);
        options.visualize=false;
        %My optode movement detection algorithm
        %[idx,~,~,~,~]=nirs_neuroimage.detectSuddenChanges(channelData,10,options);
        %Sato's optode movement detection algorithm
        [idx,~,~]=...
            nirs_neuroimage.Sato_detectOptodeMovement(oxy+deoxy,options);
        %Pegna's optode movement detection algorithm
        %[idx,~]=Pegna_detectOptodeMovement(oxy+deoxy,options)
        if (~isempty(idx))
            condition=integrityStatus.OPTODEMOVEMENT;
        end
    end

    integrity(pos) = condition;
    pos=pos+1;
   end
end
tmpInt=obj.integrity;
tmpInt=setStatus(tmpInt,opt.whichChannels,integrity);
obj.integrity = tmpInt;

%assertInvariants(obj);


end