function [h,hBGAxis,hChAxis] = plotSnirfDataOnProbe(data, probe, options)
% [h,hBG,hCh] = plotSnirfDataOnProbe(data, probe, options)
%
% Plot the data layed out over the probe.
%
% Use option .hideChannels for plotting only the probe.
%
%
%% Remark
%
% Somewhat similar to Homer 3's plotProbe.m.
%
%
%% Input Parameters
%
% data - A icnna.data.snirf.dataBlock object. This class is expected
%   to have at least the following 3 attributes;
%   .dataTimeSeries - A matrix of double sized <nSamples,2/3>
%       This is a 2D or 3D array.
%       If it's 3D then: <DATA TIME POINTS> x <DATA TYPES x CHANNELS> 
%           where data types can be wavelengths or chromophores.
%       If it's 2D then: <DATA TIME POINTS> x <Num OF MEASUREMENTS>
%   .time - A matrix of double sized <nSamples,1>
%       This is the vector of timestamps
%   .measurementList - A list of Homer3 Snirf MeasListClass objects
%       Each MeasListClass object contains information about the
%       corresponding source, detector, wavelength or chromophore, etc
%
% probe -  A icnna.data.snirf.probe object. This contains
%   information about the probe such as the source and detector positions,
%   as well as the labels.
%
% options - Optional. A struct of options for controlling the
%   visualization. Available field options include:
%   .nDims - int. 2 if the plot is to use the 2D coordinates of the probe.
%       3 (default) of the plot is to use the 3D coordinates of the probe.
%   .fontSize - double scalar. The font size in pt e.g. 12. Default value
%       is 12
%   .blockActive - Cell array of all data blocks - 
%       Each cell corresponsds to 1 stimulus condition (see option .stim)
%       Within each cell, there is an array sized <nMeasurements,4> that
%       Homer 3 refers to as a "data block".
%           1st column indicates source
%           2nd column indicates detector.
%           3rd column - Active vs Inactive? 1 - True; 0 - False.
%           4th column - Wavelength index / DataType?
% 
%       Each data block is an array of true/false for
%       all measurements (col 3) in the contanining data block (i.e. in
%       the stimuli) specifying active/inactive status.
%           (# of data blocks x # of Channels)
%       This can be obtained from some of Homer3 functions e.g.
%       hmrR_PruneChannels
%
%   .hideChannels - Boolean. True if you to hide the auxiliary data
%       subaxis. Note that the channel lines accompanying the probe
%       visualization will still be shown. False (default) if 
%       you want to show the auxiliary data subaxis.
%
%   .maskProbe - Boolean. Some functions may have cropped the channels
%       to focus on specific ROIs. But these cropped images should still
%       keep a full copy of the original probe. Hence, upon rendering
%       a cropped image, the subplots of interest may not be using the
%       whole figure. For these cases, it is possible to "ghost" or
%       mask out the part of the probe without associated measurements,
%       permiting the channels subplots to make a better use of the
%       available space. True if you want to ghost out the part of
%       the probe with no channels. False by default, that is the whole
%       probe is depicted whether with associated measurements or not.
%
%
%   .shortChannelDistance - double scalar. Maximum interoptode distance
%       for a channel to be considered a short channel in [mm].
%       Default is 10mm.
%   .stim - A icnna.data.snirf.stim object. The timeline.
%   .lengthUnit - SI length unit used in this measurement. Default is 'mm'.
%       can be found in snirf/nirs/metaDataTags/LengthUnit
%   
%
%% Output Parameters
%
% h - Figure handle.
%
% hBGAxis - Background axis handle where the probe is plotted.
%
% hChAxis - Channels sub-axis handles.
%
%
%
%
%
%
% Copyright 2024
% @author: Felipe Orihuela-Espina
%
% See also snirfUnfoldMeasurementList
%

%% Log
%
% 21-Feb-2024: FOE
%   + File created from previous code myHomer3_plotSnirfDataOnProbe
%



%% Deal with options
opt.nDims = 3;
opt.fontSize = 12;
opt.blockActive = [];
opt.hideChannels = false;
opt.maskProbe = false;
opt.shortChannelDistance = 10;
opt.stim = [];
opt.lengthUnit = 'mm';
if exist('options','var')
    if isfield(options,'nDims') && isnumeric(options.nDims)
        if ~ismember(options.nDims,[2 3])
            warning('Unexpected value for option .nDims. Try using 2 or 3 (default). Using 3 instead here.');
        else
            opt.nDims = options.nDims;
        end
    end
    if isfield(options,'fontSize') && isnumeric(options.fontSize)
        opt.fontSize = options.fontSize;
    end
    if isfield(options,'blockActive') 
        opt.blockActive = options.blockActive;
    end
    if isfield(options,'hideChannels') 
        opt.hideChannels = options.hideChannels;
    end
    if isfield(options,'maskProbe') 
        opt.maskProbe = options.maskProbe;
    end
    if isfield(options,'shortChannelDistance') && isnumeric(options.shortChannelDistance)
        opt.shortChannelDistance = options.shortChannelDistance;
    end
    if isfield(options,'stim') 
        opt.stim = options.stim;
    end
    if isfield(options,'lengthUnit') 
        opt.lengthUnit = options.lengthUnit;
    end
end


%% Some preliminaries
nMeasurements = 0;
if ~isempty(data)
    nMeasurements = length(data.measurementList);
end

%Unfold measurement list for quicker access of some operations below.
tmpMeasurementList = snirfUnfoldMeasurementList(data);

%Figure out number of data types, e.g. number of wavelengths or
%chromophores, as well as the number of channels
if nMeasurements == 0 % nMeasurements can be 0 if nothing survives
    % the quality checks or if no data is provided e.g. for
    %plotting the probe only. But we only want this bit
    %to be exeucted if data is provided yet no measurements
    %are valid.

    h = figure('Units','normalized','Position',[0.05 0.05 0.9 0.85]);
    hBGAxis = gca;
    text(0.5,0.5,'Warning! No measurements found.',...
        'Color','red','FontWeight','bold','FontSize',opt.fontSize+4,...
        'HorizontalAlignment','center');
    hChAxis = [];

    return
end


% nDataTypes = max(tmpMeasurementList.dataType)
%This above does not work. The field dataType exists but may be not used.
%Instead, "pick" a channel and check how many measurements there are
%for this channel.
iSrc = tmpMeasurementList.sourceIndex(1);
iDet = tmpMeasurementList.detectorIndex(1);
tmpMeasurementsPerChannel = find((tmpMeasurementList.sourceIndex == iSrc)  &  ...
    (tmpMeasurementList.detectorIndex == iDet));
nDataTypes = length(tmpMeasurementsPerChannel);

%Figure out the channels from the measurements
channelList = table2array(unique(tmpMeasurementList(:,{'sourceIndex','detectorIndex'})));
%nChannels = nMeasurements/nDataTypes;
nChannels = size(channelList,1);

%Determine which ones are short channels
channelDistances = sum((probe.sourcePos2D(channelList(:,1),:)-probe.detectorPos2D(channelList(:,2),:)).^2,2).^0.5;
switch (opt.lengthUnit)
    case 'mm'
        %Do nothing
    case 'cm'
        channelDistances = channelDistances * 10;
    otherwise
        error(['Unexpected option lengthUnit value [' opt.lengthUnit ']']);
end


shortChannels = (channelDistances < opt.shortChannelDistance);

%Determine active measurements
if ~isempty(opt.blockActive)
    if isempty(opt.stim)
        nStim = length(opt.blockActive);
    else
        nStim = length(opt.stim);
    end
    activeMeasurements = ones(nMeasurements,nStim); %Enlarge to accomodate one column per stimuli
    for iStim = 1:nStim
        tmp = opt.blockActive{iStim};
        %If there is not derived information e.g. no HbT, the number of
        %measurements match the size of the block information. However,
        %in the presence of derived information, the block information
        %only covers the original measurements. The validity of the
        %derived information has to be made up from the original one.
        %
        %In the case of HbT, the AND between the active HbO and HbR
        %can be taken.
        if (size(activeMeasurements,1) == size(tmp,1))
            %No derived information present.
            activeMeasurements(:,iStim) = tmp(:,3);
        else %Derived information present
            %By now, as I'm in a rush I'll solve it ad-hoc for HbT
            %but this bit needs a bit of work if one wants to make
            %it generic.

            %idxHbO = strcmp(tmpMeasurementList{:,'dataTypeLabel'},'HbO');
            %idxHbR = strcmp(tmpMeasurementList{:,'dataTypeLabel'},'HbR');
            %idxHbT = strcmp(tmpMeasurementList{:,'dataTypeLabel'},'HbT');

            %activeMeasurements(idxHbO,iStim) = tmp(idxHbO,3);
            %activeMeasurements(idxHbR,iStim) = tmp(idxHbR,3);
            %activeMeasurements(idxHbO,iStim) = and(tmp(idxHbO,3),tmp(idxHbR,3));
            for iMeas=1:nMeasurements
                iSrc = tmpMeasurementList{iMeas,'sourceIndex'};
                iDet = tmpMeasurementList{iMeas,'detectorIndex'};
                tmpDataTypeLabel = tmpMeasurementList{iMeas,'dataTypeLabel'};
                switch tmpDataTypeLabel{1}
                    case {'HbO','HRF HbO'} %The HRF is the block averaged version
                        idxMeas = find(tmp(:,1) == iSrc & tmp(:,2) == iDet ...
                            & tmp(:,4) == 1);
                        activeMeasurements(iMeas,iStim) = tmp(idxMeas,3);
                    case {'HbR','HRF HbR'} %The HRF is the block averaged version
                        idxMeas = find(tmp(:,1) == iSrc & tmp(:,2) == iDet ...
                            & tmp(:,4) == 2);
                        activeMeasurements(iMeas,iStim) = tmp(idxMeas,3);
                    case {'HbT','HRF HbT'} %The HRF is the block averaged version
                        idxMeas = find(tmp(:,1) == iSrc & tmp(:,2) == iDet);
                        activeMeasurements(iMeas,iStim) = all(tmp(idxMeas,3));
                    otherwise
                        error(['Unexpected derived data type; ' ...
                            tmpDataTypeLabel{1}])
                end
            end

        end
    end
end



%Establish nominal channel locations at the mid point between
%the source and the detector
if (opt.nDims == 2)
    channelLocations = (probe.sourcePos2D(channelList(:,1),:)+probe.detectorPos2D(channelList(:,2),:))/2;
else %3D
    channelLocations = (probe.sourcePos3D(channelList(:,1),:)+probe.detectorPos3D(channelList(:,2),:))/2;
end



%% Mask probe if needed
%Find out which elements of the probe may need masking
mask.sources   = true(1,size(probe.sourcePos2D,1)); %Elements to show
mask.detectors = true(1,size(probe.detectorPos2D,1));
mask.channels  = true(size(channelList,1),1);
if opt.maskProbe
    for iMeas = 1:nMeasurements
        tmpMeas = data.measurementList(iMeas);
        srcList(iMeas) = tmpMeas.sourceIndex;
        detList(iMeas) = tmpMeas.detectorIndex;
    end
    mask.sources   = ismember([1:size(probe.sourcePos2D,1)],unique(srcList)');
    mask.detectors = ismember([1:size(probe.detectorPos2D,1)],unique(detList)');
    mask.channels = and(ismember(channelList(:,1),unique(srcList)'), ...
        ismember(channelList(:,2),unique(detList)') );
end





%% Prepare source and detectors labels
nSources = size(probe.sourcePos3D,1);
try
    [~] = probe.sourceLabels{nSources};
catch
    tmpSrcLabels = cell(nSources,1);
    for iSrc = size(probe.sourcePos3D,1):-1:1
        tmpSrcLabels(iSrc,1) = {num2str(iSrc,'S%03d')};
    end
    probe.sourceLabels = tmpSrcLabels;
end
nDetectors = size(probe.detectorPos3D,1);
try
    [~] = probe.detectorLabels{iDet};
catch
    tmpDetLabels = cell(nDetectors,1);
    for iDet = size(probe.detectorPos3D,1):-1:1
        tmpDetLabels(iDet,1) = {num2str(iDet,'D%03d')};
    end
    probe.detectorLabels = tmpDetLabels;
end




%% Create the figure
h = figure('Units','normalized','Position',[0.05 0.05 0.9 0.85]);

%Make background axis "bigger" and remove its axis labels
hBGAxis = gca;
set(hBGAxis,'XTickLabel',[]);
set(hBGAxis,'YTickLabel',[]);
if (opt.nDims == 3)
    set(hBGAxis,'ZTickLabel',[]);
end
set(hBGAxis,'Position',[0.05 0.05 0.9 0.9]);


%% Display the probe on the background axis
axis(hBGAxis);


%Display sources and detectors
if (opt.nDims == 2)
    % line('Xdata',probe.sourcePos2D(:,1),...
    %      'Ydata',probe.sourcePos2D(:,2),...
    %      'r.');
    for iSrc = 1:size(probe.sourcePos2D,1)
      if (mask.sources(iSrc))
        text(probe.sourcePos2D(iSrc,1),...
             probe.sourcePos2D(iSrc,2),...
             probe.sourceLabels{iSrc},...
             'Color','r','FontSize',opt.fontSize+2,'FontWeight','bold', ...
             'HorizontalAlignment','center');
      end
    end

    % line('Xdata',probe.detectorPos2D(:,1),...
    %      'Ydata',probe.detectorPos2D(:,2),...
    %      'b.');
    for iDet = 1:size(probe.detectorPos2D,1)
      if (mask.detectors(iDet))
        text(probe.detectorPos2D(iDet,1),...
             probe.detectorPos2D(iDet,2),...
             probe.detectorLabels{iDet},...
             'Color','r','FontSize',opt.fontSize+2,'FontWeight','bold', ...
             'HorizontalAlignment','center');
      end
    end

else %3D
    % line('Xdata',probe.sourcePos3D(:,1),...
    %      'Ydata',probe.sourcePos3D(:,2),...
    %      'Zdata',probe.sourcePos3D(:,3),...
    %      'Color','r','Marker','.','LineStyle','none');
    for iSrc = 1:size(probe.sourcePos3D,1)
      if (mask.sources(iSrc))
        text(probe.sourcePos3D(iSrc,1),...
             probe.sourcePos3D(iSrc,2),...
             probe.sourcePos3D(iSrc,3),...
             probe.sourceLabels{iSrc},...
             'Color','r','FontSize',opt.fontSize+2,'FontWeight','bold', ...
             'HorizontalAlignment','center');
      end
    end

    % line('Xdata',probe.detectorPos3D(:,1),...
    %      'Ydata',probe.detectorPos3D(:,2),...
    %      'Zdata',probe.detectorPos3D(:,3),...
    %      'Color','b','Marker','.','LineStyle','none');
    for iDet = 1:size(probe.detectorPos3D,1)
      if (mask.detectors(iDet))
        text(probe.detectorPos3D(iDet,1),...
             probe.detectorPos3D(iDet,2),...
             probe.detectorPos3D(iDet,3),...
             probe.detectorLabels{iDet},...
             'Color','b','FontSize',opt.fontSize+2,'FontWeight','bold', ...
             'HorizontalAlignment','center');
      end
    end
end




%Display channels locations and links Src-Det
if (opt.nDims == 2)
    line('Xdata',channelLocations(shortChannels & mask.channels,1),...
         'Ydata',channelLocations(shortChannels & mask.channels,2),...
         'Color','m','Marker','o','LineStyle','none');
    line('Xdata',channelLocations(~shortChannels & mask.channels,1),...
         'Ydata',channelLocations(~shortChannels & mask.channels,2),...
         'Color','g','Marker','o','LineStyle','none');

    for iCh = 1:nChannels
        iSrc = channelList(iCh,1);
        iDet = channelList(iCh,2);

        if (mask.sources(iSrc) && mask.detectors(iDet) )
            if shortChannels(iCh)
                 line('Xdata',[probe.sourcePos3D(iSrc,1) probe.detectorPos3D(iDet,1)],...
                      'Ydata',[probe.sourcePos3D(iSrc,2) probe.detectorPos3D(iDet,2)],...
                      'Color','m','Marker','.','LineStyle','-');
            else
                 line('Xdata',[probe.sourcePos3D(iSrc,1) probe.detectorPos3D(iDet,1)],...
                      'Ydata',[probe.sourcePos3D(iSrc,2) probe.detectorPos3D(iDet,2)],...
                      'Color','g','Marker','.','LineStyle','-');
            end
    
            text(channelLocations(iCh,1),...
                 channelLocations(iCh,2),...
                 sprintf('Ch%d',iCh), ...
                 'FontSize',opt.fontSize+2,'FontWeight','bold', ...
                 'HorizontalAlignment','center');
        end
    end

else %3D


    line('Xdata',channelLocations(shortChannels & mask.channels,1),...
         'Ydata',channelLocations(shortChannels & mask.channels,2),...
         'Zdata',channelLocations(shortChannels & mask.channels,3),...
         'Color','m','Marker','o','LineStyle','none');
    line('Xdata',channelLocations(~shortChannels & mask.channels,1),...
         'Ydata',channelLocations(~shortChannels & mask.channels,2),...
         'Zdata',channelLocations(~shortChannels & mask.channels,3),...
         'Color','g','Marker','o','LineStyle','none');

    for iCh = 1:nChannels
        iSrc = channelList(iCh,1);
        iDet = channelList(iCh,2);

        if (mask.sources(iSrc) && mask.detectors(iDet) )
            if shortChannels(iCh)
                 line('Xdata',[probe.sourcePos3D(iSrc,1) probe.detectorPos3D(iDet,1)],...
                      'Ydata',[probe.sourcePos3D(iSrc,2) probe.detectorPos3D(iDet,2)],...
                      'Zdata',[probe.sourcePos3D(iSrc,3) probe.detectorPos3D(iDet,3)],...
                      'Color','m','Marker','.','LineStyle','-');
            else
                 line('Xdata',[probe.sourcePos3D(iSrc,1) probe.detectorPos3D(iDet,1)],...
                      'Ydata',[probe.sourcePos3D(iSrc,2) probe.detectorPos3D(iDet,2)],...
                      'Zdata',[probe.sourcePos3D(iSrc,3) probe.detectorPos3D(iDet,3)],...
                      'Color','g','Marker','.','LineStyle','-');
            end


            if isempty(probe.sourceLabels{iSrc}) || isempty(probe.detectorLabels{iDet})
                text(channelLocations(iCh,1),...
                     channelLocations(iCh,2),...
                     channelLocations(iCh,3),...
                     sprintf('Ch%d',iCh), ...
                     'FontSize',opt.fontSize+2,'FontWeight','bold', ...
                     'HorizontalAlignment','center');
            else
                text(channelLocations(iCh,1),...
                     channelLocations(iCh,2),...
                     channelLocations(iCh,3),...
                     sprintf('Ch%d:%s-%s',iCh,probe.sourceLabels{iSrc},...
                                probe.detectorLabels{iDet}), ...
                     'FontSize',opt.fontSize+2,'FontWeight','bold', ...
                     'HorizontalAlignment','center');
            end


        end
    end

end








%% Create foregrond sub-axes for the channels
%1 auxiliary axes per channel. All data types available for the
%channel will be plot in the same axes.


%Try to estimate a reasonable size for the sub-axes. For this,
%use the interoptode distances, scale these, and "translate"
%these into locations in the figure.
tmpIOD = mean(channelDistances(~shortChannels));
if isnan(tmpIOD) %All channels are shortChannels...
    tmpIOD = mean(channelDistances);
end
tmpShift = 0.22*tmpIOD/2;
chAxPositions = channelLocations-tmpShift;
tmpBGax=axis(gca); %Get the range of the background axis on which the
                    %coordinate of the channels are indicated.
BG_Xrange=tmpBGax(2)-tmpBGax(1);
BG_Yrange=tmpBGax(4)-tmpBGax(3); 

chAxLeftNormalized   = (chAxPositions(:,1)-tmpBGax(1))/BG_Xrange; %Prenormalized to within the BG axes
chAxBottomNormalized = (chAxPositions(:,2)-tmpBGax(3))/BG_Yrange; %Prenormalized to within the BG axes
tmpWidthNormalized   = (tmpShift*2)/BG_Xrange;
tmpHeightNormalized  = (tmpShift*2)/BG_Yrange;

tmpBGPosition = get(hBGAxis,'Position');
chAxLeftNormalized    = (chAxLeftNormalized*tmpBGPosition(3))+tmpBGPosition(1);
chAxBottomNormalized  = (chAxBottomNormalized*tmpBGPosition(4))+tmpBGPosition(2);


    % line('Xdata',chAxPositions(:,1),...
    %      'Ydata',chAxPositions(:,2),...
    %      'Zdata',chAxPositions(:,3),...
    %      'Color','k','Marker','s','LineStyle','none');
    % line('Xdata',chAxLeftNormalized,...
    %      'Ydata',chAxBottomNormalized,...
    %      'Zdata',channelLocations(:,3),...
    %      'Color','k','Marker','s','LineStyle','none');
for iCh = 1:nChannels
    tmpColor = [0.96 0.96 0.96]; %Gray-ish
    % if shortChannels(iCh)
    %     tmpColor = [0.96 0.75 0.75]; %Magenta-ish
    % end
    hChAxis(iCh) = axes('Position',[chAxLeftNormalized(iCh) chAxBottomNormalized(iCh) ...
                                    tmpWidthNormalized tmpHeightNormalized],...
                        'Color',tmpColor);
    hold on %In case there are several measurements in this channel
end


%% Plot measurements

for iMeas = 1:nMeasurements
    %Find to which channel it belongs
    iSrc = tmpMeasurementList{iMeas,'sourceIndex'};
    iDet = tmpMeasurementList{iMeas,'detectorIndex'};
    iCh = find(channelList(:,1) == iSrc & channelList(:,2) == iDet);



    %Choose the axis to plot
    axes(hChAxis(iCh));
    %Choose a color depending on the type of data being plot
    tmpColor = [1 0 0];
    strLegend = '';
    tmpDataType      = data.measurementList(iMeas).dataType;
    tmpDataTypeLabel = data.measurementList(iMeas).dataTypeLabel;
    cmap = hsv(length(probe.wavelengths));
    switch (tmpDataType)
                case 1 %Raw CW Amplitude
            tmpColor = cmap(data.measurementList(iMeas).wavelengthIndex,:);
            strLegend = [num2str(probe.wavelengths(data.measurementList(iMeas).wavelengthIndex)) 'nm'];
        case 99999 %Processed
            switch (tmpDataTypeLabel)
                case 'dOD'
                    tmpColor = cmap(data.measurementList(iMeas).wavelengthIndex,:);
                    strLegend = ['OD @ ' num2str(probe.wavelengths(data.measurementList(iMeas).wavelengthIndex)) 'nm'];
                case 'mua'
                    tmpColor = [1 1 0];
                    strLegend = ['\mu_a [cm-1]'];
                case 'mus'
                    tmpColor = [1 0 1];
                    strLegend = ['\mu_s [cm-1]'];
                case {'HbO','HRF HbO'} %The HRF is the block averaged version
                    tmpColor = [1 0 0];
                    strLegend = ['HbO_2 [\mu mol]'];
                case {'HbR','HRF HbR'} %The HRF is the block averaged version
                    tmpColor = [0 0 1];
                    strLegend = ['HbR [\mu mol]'];
                case {'HbT','HRF HbT'} %The HRF is the block averaged version
                    tmpColor = [0 1 0];
                    strLegend = ['HbT [\mu mol]'];
                otherwise
                    error(['Measurement ' iMeas ': DataTypeLabel currently unsupported by this function.']);
            end
            %strLegend = data.measurementList(iMeas).dataTypeLabel;
        otherwise
            error(['Measurement ' iMeas ': DataType currently unsupported by this function.']);
    end

    %Plot the measurement
    line(data.time,data.dataTimeSeries(:,iMeas), 'Color', tmpColor,'DisplayName',strLegend);
    if iCh == 1
        legend();
    end

end

%% Some final beautification
for iCh = 1:nChannels
    axes(hChAxis(iCh));
    tmpAxis = axis();
    % text((tmpAxis(2)-tmpAxis(1))/2, ...
    %     (tmpAxis(4)-tmpAxis(3))*0.9,...
    %     sprintf('Ch%d',iCh), ...
    %     'FontSize',opt.fontSize+2,'FontWeight','bold', ...
    %     'HorizontalAlignment','center')
    tmpColor = 'k';
    if shortChannels(iCh)
        tmpColor = 'r';
    end
    

    iSrc = channelList(iCh,1);
    iDet = channelList(iCh,2);
    if isempty(probe.sourceLabels{iSrc}) || isempty(probe.detectorLabels{iDet})
        title(sprintf('Ch%d',iCh),'Color',tmpColor);
    else
        title(sprintf('Ch%d:%s-%s',iCh,probe.sourceLabels{iSrc},...
                          probe.detectorLabels{iDet}),...
            'Color',tmpColor);
    end
    box on;

    %Plot the timeline if available
    if ~isempty(opt.stim)
        nStims = length(opt.stim);
        cmap = hsv(nStims);
        for iStim = 1:nStims

            if isempty(opt.blockActive)
                flagActive = 1;
            else
                %Find all measurements associated to this channel
                measurementsIdx = find(tmpMeasurementList{:,1} == channelList(iCh,1) ...
                                     & tmpMeasurementList{:,2} == channelList(iCh,2));

                flagActive = activeMeasurements(measurementsIdx,iStim);
            end

            if all(flagActive) %Stimuli is active for ALL measurements. Depicted as a flat pattern.
                cevents = opt.stim.data;
                nEvents = size(cevents,1);
                for iEv = 1:nEvents
                    patch('XData',[cevents(iEv,1) cevents(iEv,1) cevents(iEv,1)+cevents(iEv,2) cevents(iEv,1)+cevents(iEv,2)], ...
                          'YData',[tmpAxis(3) tmpAxis(4) tmpAxis(4) tmpAxis(3)],...
                          'FaceColor',cmap(iStim,:),'EdgeColor',cmap(iStim,:),...
                          'FaceAlpha',0.2,'EdgeAlpha',0.2);
                    if iCh == 1
                        hLeg = legend;
                        hLeg.String(end) = []; %Remove this entry from the legend.
                    end
                end
            elseif any(flagActive) %Stimuli is only active for SOME measurements. Depicted as an interpolated pattern and yellow border.
                cevents = opt.stim.data;
                nEvents = size(cevents,1);
                for iEv = 1:nEvents
                    patch('XData',[cevents(iEv,1) cevents(iEv,1) cevents(iEv,1)+cevents(iEv,2) cevents(iEv,1)+cevents(iEv,2)], ...
                          'YData',[tmpAxis(3) tmpAxis(4) tmpAxis(4) tmpAxis(3)],...
                          'FaceColor','interp','EdgeColor','k', 'LineWidth', 3, ...
                          'FaceVertexCData', [cmap(iStim,:); 0 0 0; cmap(iStim,:); 0 0 0], ...
                          'FaceAlpha',0.2,'EdgeAlpha',0.2);
                    if iCh == 1
                        hLeg = legend;
                        hLeg.String(end) = []; %Remove this entry from the legend.
                    end
                end
            else %if none(flagActive) %Stimuli is not active for any measurements. Depicted as no patch and crossed channel.
                line('XData',[tmpAxis(1) tmpAxis(2)], ...
                     'YData',[tmpAxis(3) tmpAxis(4)], ...
                     'Color', 'k', 'LineStyle','-', 'LineWidth', 3,'Marker','none');
                line('XData',[tmpAxis(1) tmpAxis(2)], ...
                     'YData',[tmpAxis(4) tmpAxis(3)], ...
                     'Color', 'k', 'LineStyle','-', 'LineWidth', 3,'Marker','none');
                if iCh == 1
                    hLeg = legend;
                    hLeg.String(end-1:end) = []; %Remove these entries from the legend.
                end
            end
        end
    end

    if opt.hideChannels
        toHide = allchild(hChAxis(iCh));
        set(toHide,'Visible','off');
        if iCh == 1, set(hLeg,'Visible','off'), end;
        set(hChAxis(iCh),'Visible','off');
    end



end

end
