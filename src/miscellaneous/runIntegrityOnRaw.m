function [theIntegrityStatus,flagSuccess] = ...
    runIntegrityOnRaw(rawElement,theIntegrityStatus,options)
%Check the integrity for a raw element
%
% [theIntegrityStatus,flagSuccess] = ...
%    runIntegrityOnRaw(rawElement,theIntegrityStatus,options)
%           Check the integrity for a raw element
%
%
%% Integrity on Raw Objects
%
% rawData objects have no integrity status associated with them.
%However, some integrity tests are faster and/or more accurate
%when carried out on raw data, than on converted data. The drawback
%is that integrity test in raw data is often device dependent.
%
%
%
%% Remarks
%
%This function responds to the excruciating need to speed up the
%integrity check process, which currently takes a few days for
%any mid-size dataset, and becomes unberable when the dataset
%contains any "long" sessions.
%
%Basically the bottleneck is of course my algorithms for detection
%of mirroring and optode movement. Whilst the second one can be
%obviously exchange for other algorithms (e.g. Sato's), the
%option for mirroring (saturation related problem) is obviously
%to look in the raw data.
%
%% Parameters:
%
% rawElement - A rawData object. Currently only rawData_ETG4000 has
%   some test in raw implemented. Any other type on rawData, will
%   currently set the corresponding flagSuccess to false.
%
% theIntegrityStatus - An integrityStatus object with as many channels
%   as the corresponding processed/structured data would have after
%   conversion. rawData objects have no integrity status
%   associated with them, and running integrity tests in rawData is
%   only shortcut to flag channels in structuredData. The parameter
%   theIntegrityStatus may contain already pre-tested integrity
%   values. This parameter is intended to be the integrityStatus
%   of the structuredData which will end up storing the integrity
%   result.
%
% options - A struct of options.
%   .whichChannels - A row vector of channels. Restrict the integrity
%       check to the selected channels. By default, integrity is checked
%       in all channels. This is regardless of whether integrity
%       will be forced or not in channels were integrity has already
%       been previously check.
%
%       +=========================================+
%       | IMP: Please note that the channels here |
%       | refer to the resulting channels upon    |
%       | conversion!                             |
%       +=========================================+
%
% .ApparentNonRecording - For rawData_ETG4000 only.
%   Test the saturation of sensors at
%	1 wavelength leading to apparent non-recording effect.
%
% .Mirroring - For rawData_ETG4000 only. Test the saturation
%	 of sensors at 2 wavelength leading to mirroring. 
%
%
%
%% Output
%
% theIntegrityStatus - the integrityStatus after testing.
%
% flagSuccess - A struct with one flag per test carried out. The
%       flag fieldname will correspond to the test option name.
%       In addition, this struct will always contain a field
%       with the set of channels tested (.whichChannels).
%
%
%
%
% Copyright 2010-23
% @author Felipe Orihuela-Espina
%
% See also structuredData.checkIntegrity, getIntegrityReport,
%   addVisualIntegrity, runIntegrity
%



%% Log
%
% File created: 29-Oct-2010
% File last modified (before creation of this log): 18-May-2018
%
% 18-May-2018: FOE. Added support for NIRScout neuroimages.
%
% 2-Jan-2021: FOE
%   + Bug fixed. If the options does not have a field .nirs_neuroimage
%   default values are not automatically set.
%
%
% 24-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%
% 25-May-2023: FOE
%   + Added case for rawData_Snirf. Currently only 1 nirsDataset (the first
%   found) of raw CW-NIRS data (snirf dataType 1) is supported.
%
%


if ~isa(rawElement,'rawData')
    error('ICNNA:runIntegrityOnRaw:InvalidInputParameter',...
          ['Unexpected rawElement class. rawElement must be ' ...
          'an object of class rawData.'])
else
    sd = convert(rawElement);
    nChannels = sd.nChannels;
    assert(length(double(theIntegrityStatus)) == nChannels, ...
            'Unexpected size of integrityStatus parameter.');
end



%% Deal with options
opt.whichChannels = 1:nChannels;
flagSuccess.whichChannels = 1:nChannels; %This is not necessary
            %as such, but ensures that flagSuccess is always
            %an struct.
if exist('options','var')
    if isfield(options,'whichChannels')
        opt.whichChannels=options.whichChannels;
        flagSuccess.whichChannels=options.whichChannels;
    end
    
    if (isa(rawElement,'rawData_ETG4000') ...
        || isa(rawElement,'rawData_NIRScout')...
        || isa(rawElement,'rawData_Snirf'))
    
        if isfield(options,'nirs_neuroimage')
            tests=options.nirs_neuroimage;
        else
            tests.Complex = true;
            tests.ApparentNonRecording = true;
            tests.Mirroring = true;
        end

        opt.nirs_neuroimage.ApparentNonRecording = false;
        flagSuccess.nirs_neuroimage.ApparentNonRecording = false;
        opt.nirs_neuroimage.Mirroring = false;
        flagSuccess.nirs_neuroimage.Mirroring = false;
        if isfield(tests,'ApparentNonRecording')
            opt.nirs_neuroimage.ApparentNonRecording=tests.ApparentNonRecording;
        end
        if isfield(tests,'Mirroring')
            opt.nirs_neuroimage.Mirroring=tests.Mirroring;
        end
    end
    
    
end



if (isa(rawElement,'rawData_ETG4000') ...
        || isa(rawElement,'rawData_NIRScout'))
    %Intensity threshold for raw signals [mV]
    thresh=4.9998;

    theData = get(rawElement,'LightRawData'); %Cols are temporal samples
    for ch=opt.whichChannels
        if (isa(rawElement,'rawData_ETG4000'))
            wlength1_data = theData(2*ch-1,:);
            wlength2_data = theData(2*ch,:);
        elseif (isa(rawElement,'rawData_NIRScout'))
            wlength1_data = theData(:,:,1);
            wlength2_data = theData(:,:,2);
        end
        %rawData_ETG4000 tests here
        res = getStatus(theIntegrityStatus,ch);
        if (opt.nirs_neuroimage.ApparentNonRecording)
            idx = find(wlength1_data >= thresh & wlength2_data >= thresh);
            if ~isempty(idx)
                res = integrityStatus.NONRECORDINGS;
            end
            flagSuccess.nirs_neuroimage.ApparentNonRecording = true;
            clear idx
        end
        if (opt.nirs_neuroimage.Mirroring)
            idx = find(wlength1_data >= thresh | wlength2_data >= thresh);
            if ~isempty(idx)
                res = integrityStatus.MIRRORING;
            end
            flagSuccess.nirs_neuroimage.Mirroring = true;
            clear idx
        end
        if res==integrityStatus.UNCHECK
            res = integrityStatus.FINE;
        end
        theIntegrityStatus = setStatus(theIntegrityStatus,ch,res);
    end


elseif isa(rawElement,'rawData_Snirf')


    tmpSnirfImg = rawElement.snirfImg;
    

    %By now, it can only check 1 nirsDataset and CW-NIRS data
    %For no particular reason, I will use the first raw nirsDataset found
    %in the Snirf structure

    idxSet = 0;
    for iSet = 1:tmpSnirfImg.nNirsDatasets
        %Check it if is a raw dataset 
        tmpSet  = tmpSnirfImg.nirs(iSet);
        tmpDataBlock = tmpSet.data;
        tmpMeasurement = tmpDataBlock.measurementList(1);
        tmpDataType = tmpMeasurement.dataType;

        %The data Type code for raw CW-NIRS data is 1
        if tmpDataType == 1
            idxSet = iSet;
            break
        end
    end

    if idxSet ~=0

        tmpSet  = tmpSnirfImg.nirs(idxSet);
        tmpDataBlock = tmpSet.data;
        tmpMeasurementList = tmpDataBlock.measurementList;
        nMeasurements = length(tmpMeasurementList);

        %%Estimate channels
        mList = nan(0,2);
        for iMeas = 1:nMeasurements
            iSrc = tmpMeasurementList(iMeas).sourceIndex;
            iDet = tmpMeasurementList(iMeas).detectorIndex;
            mList(iMeas,:) = [iSrc iDet];
        end
        channelList = unique(mList,'rows');
        nChannels = size(channelList,1);
        
        %Reformat to the classical tensor
        nSamples=size(tmpDataBlock.dataTimeSeries,1);
        nSignals=nMeasurements/nChannels;
        nWlengths=length(tmpSet.probe.wavelengths);
        tmpLightRawData = nan(nSamples, nChannels, nWlengths);
        for iMeas = 1:nMeasurements
            tmpMeasurement = tmpMeasurementList(iMeas);
            iSrc = tmpMeasurement.sourceIndex;
            iDet = tmpMeasurement.detectorIndex;
            iCh  = find(channelList(:,1) == iSrc & channelList(:,2) == iDet);
            iWl  = tmpMeasurement.wavelengthIndex;
            tmpLightRawData(:,iCh,iWl) = tmpDataBlock.dataTimeSeries(:,iMeas);
        end


        %Intensity threshold for raw signals [mV]
        thresh=4.9998;
    
        theData = tmpLightRawData; %Cols are temporal samples

        for ch=opt.whichChannels
            wlength1_data = theData(:,:,1);
            wlength2_data = theData(:,:,2);
            %rawData_ETG4000 tests here
            res = getStatus(theIntegrityStatus,ch);
            if (opt.nirs_neuroimage.ApparentNonRecording)
                idx = find(wlength1_data >= thresh & wlength2_data >= thresh);
                if ~isempty(idx)
                    res = integrityStatus.NONRECORDINGS;
                end
                flagSuccess.nirs_neuroimage.ApparentNonRecording = true;
                clear idx
            end
            if (opt.nirs_neuroimage.Mirroring)
                idx = find(wlength1_data >= thresh | wlength2_data >= thresh);
                if ~isempty(idx)
                    res = integrityStatus.MIRRORING;
                end
                flagSuccess.nirs_neuroimage.Mirroring = true;
                clear idx
            end
            if res==integrityStatus.UNCHECK
                res = integrityStatus.FINE;
            end
            theIntegrityStatus = setStatus(theIntegrityStatus,ch,res);
        end

    end



end


