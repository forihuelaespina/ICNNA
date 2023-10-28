function [res]=save(filename,theSnirf)
%Save an icnna.data.snirf.snirf object to an snirf file
%
% [res]=save(filename,theSnirf)
%
%
%
%% Input parameters
%
% filename - String. The filename including the path whether
%   absolute or relative to current working directory.
%
% theSnirf - The icnna.data.snirf.snirf object to be serialized.
%
%% Output parameters
%
% res - int. 1 if the writing succeeded or 0 otherwise.
%
%
%
% Copyright 2023
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.snirf.snirf
%


%% Log
%
% 18/19-Aug-2023: FOE
%   File created.
%


%Create the output file
if exist(filename,"file")
    x = 'x';
    while (x ~= 'y' && x ~= 'n')
        x = input('File already exists. Do you want to overwrite it [y/n]? ','s');
    end
    if (x == 'n')
        return
    end
end
fcpl = H5P.create('H5P_FILE_CREATE');
fapl = H5P.create('H5P_FILE_ACCESS');
fid = H5F.create(filename,'H5F_ACC_TRUNC',fcpl,fapl);



precision.int   = 'int32';
precision.float = 'single';




nNIRSDatasets = theSnirf.nNirsDatasets;
for iDataset = 1:length(nNIRSDatasets)

    tmpNirsDataset = theSnirf.nirs(iDataset);
    nirsGroup = ['/nirs' num2str(iDataset)];
    plist = "H5P_DEFAULT";
    gid(1) = H5G.create(fid,nirsGroup,plist,plist,plist);

    %Export the metadata (both snirf mandatory and user defined)
    groupName = [nirsGroup '/metaDataTags'];
    plist = "H5P_DEFAULT";
    gid(2) = H5G.create(fid,groupName,plist,plist,plist);
    tags = properties(tmpNirsDataset.metaDataTags);
    for iTag = 1:length(tags)
        iElem = tags{iTag};
        capElem = iElem;
        capElem(1) = upper(capElem(1)); %Make sure it is capitalized
        datasetName = [groupName '/' capElem];
        if strcmp(iElem,'additional')
            %User defined meta data
            tmpKeys = tmpNirsDataset.metaDataTags.additional.keys;
            for ii = 1:length(tmpKeys)
                iKey = tmpKeys{ii};
                capElem = iKey;
                capElem(1) = upper(capElem(1)); %Make sure it is capitalized
                datasetName = [groupName '/' capElem];
                theData = string(tmpNirsDataset.metaDataTags.additional(iKey));
                h5create(filename,datasetName,size(theData),'Datatype','string');
                h5write(filename,datasetName,theData);
            end
        else
            %Basic snirf standard metadata
            theData = string(tmpNirsDataset.metaDataTags.(iElem));
            h5create(filename,datasetName,size(theData),'Datatype','string');
            h5write(filename,datasetName,theData);
        end
    end
    H5G.close(gid(2));

    %Export the NIRS data blocks
    for iDataBlock = 1:length(tmpNirsDataset.data)
        dataBlock = tmpNirsDataset.data(iDataBlock);
        groupName = [nirsGroup '/data'  num2str(iDataBlock)];
        gid(2) = H5G.create(fid,groupName,plist,plist,plist);

        datasetName = [groupName '/dataTimeSeries'];
        theData = feval(precision.float,dataBlock.dataTimeSeries);
        h5create(filename,datasetName,size(theData),'Datatype',precision.float);
        h5write(filename,datasetName,theData);

        datasetName = [groupName '/time'];
        theData = feval(precision.float,dataBlock.time);
        h5create(filename,datasetName,size(theData),'Datatype',precision.float);
        h5write(filename,datasetName,theData);

        for iML = 1:length(dataBlock.measurementList)
            theML = dataBlock.measurementList(iML);
            subgroupName = [groupName '/measurementList'  num2str(iML)];
            gid(3) = H5G.create(fid,subgroupName,plist,plist,plist);

            tags = properties(theML);
            for iTag = 1:length(tags)
                iElem = tags{iTag};
                datasetName = [subgroupName '/' iElem];

                theData = theML.(iElem);
                switch(iElem)
                    case {'sourceIndex','detectorIndex','wavelengthIndex',...
                            'dataType','dataTypeIndex','moduleIndex',...
                            'sourceModuleIndex','detectorModuleIndex'}
                        theData = feval(precision.int,theData);
                        theType = precision.int;
                    case {'wavelengthActual','wavelengthEmissionActual',...
                            'sourcePower','detectorGain'}
                        theData = feval(precision.float,theData);
                        theType = precision.float;
                    otherwise
                        theData = string(theData);
                        theType = 'string';
                end

                h5create(filename,datasetName,size(theData),'Datatype',theType);
                h5write(filename,datasetName,theData);
            end
    
            H5G.close(gid(3));
        end

        %h5write(filename,groupName,dataBlock);
        H5G.close(gid(2));
    end

    %Export the Stimulus measurements
    for iStim = 1:length(tmpNirsDataset.stim)
        theStim = tmpNirsDataset.stim(iStim);
        groupName = [nirsGroup '/stim'  num2str(iStim)];
        gid(2) = H5G.create(fid,groupName,plist,plist,plist);

        tags = properties(theStim);
        for iTag = 1:length(tags)
            iElem = tags{iTag};
            datasetName = [groupName '/' iElem];

            theData = theStim.(iElem);
            switch(iElem)
                case {'dataLabels'}
                    theType = 'cell'; %Cell array of strings
                case {'data'}
                    theData = feval(precision.float,theData);
                    theType = precision.float;
                otherwise
                    theData = string(theData);
                    theType = 'string';
            end

            if ~strcmp(theType,'cell')
                h5create(filename,datasetName,size(theData),'Datatype',theType);
                h5write(filename,datasetName,theData);
            else
                for ii = 1:numel(theData)
                    datasetName = [groupName '/' capElem num2str(ii)];
                    tmp2 = theData{ii};
                    h5create(filename,datasetName,size(tmp2),'Datatype','string');
                    h5write(filename,datasetName,tmp2);
                end
            end
        end
        
        
        H5G.close(gid(2));
    end

    %Export the probe information
    groupName = [nirsGroup '/probe'];
    gid(2) = H5G.create(fid,groupName,plist,plist,plist);
    
        tags = properties(tmpNirsDataset.probe);
        for iTag = 1:length(tags)
            iElem = tags{iTag};
            datasetName = [groupName '/' iElem];

            theData = tmpNirsDataset.probe.(iElem);
            switch(iElem)
                case {'sourceLabels','detectorLabels','landmarkLabels   '}
                    theType = 'cell'; %Cell array of strings
                case {'useLocalIndex'}
                    theData = feval(precision.int,theData);
                    theType = precision.int;
                case {'wavelengths','wavelengthsEmission',...
                        'sourcePos2D','sourcePos3D',...
                        'detectorPos2D','detectorPos3D',...
                        'landmarkPos2D','landmarkPos3D',...
                        'frequencies','timeDelays','timeDelayWidths',...
                        'momentOrders','correlationTimeDelays',...
                        'correlationTimeDelayWidths'}
                    theData = feval(precision.float,theData);
                    theType = precision.float;
                otherwise
                    theData = string(theData);
                    theType = 'string';
            end

            if ~strcmp(theType,'cell')
                %Fields with missing information may fail a direct
                % attempt to write (h5create doesn't like something
                % sized [0 1] e.g. nan(0,1)). Fortunately, not all
                % fields are compulsory; so we casn skip those which
                % are empty and not compulsory. 
                if ~isempty(theData)
                    h5create(filename,datasetName,size(theData),'Datatype',theType);
                    h5write(filename,datasetName,theData);
                elseif strcmpi(iElem,{'wavelengths'}) %Check if compulsory
                    error(['icnna.data.snirf.snirf:save:InvalidParameterValue' ...
                            'Unexpected empty dataset; ' datasetName ' is mandatory.']);

                end
            else
                for ii = 1:numel(theData)
                    datasetName = [groupName '/' capElem num2str(ii)];
                    tmp2 = theData{ii};
                    h5create(filename,datasetName,size(tmp2),'Datatype','string');
                    h5write(filename,datasetName,tmp2);
                end
            end
        end

    H5G.close(gid(2));

    %Export the Auxiliary measurements
    for iAux = 1:length(tmpNirsDataset.aux)
        theAux = tmpNirsDataset.aux(iAux);
        groupName = [nirsGroup '/aux'  num2str(iAux)];
        gid(2) = H5G.create(fid,groupName,plist,plist,plist);

        tags = properties(theAux);
        for iTag = 1:length(tags)
            iElem = tags{iTag};
            datasetName = [groupName '/' iElem];

            theData = theStim.(iElem);
            switch(iElem)
                case {'dataTimeSeries','time','timeOffset'}
                    theData = feval(precision.float,theData);
                    theType = precision.float;
                otherwise
                    theData = string(theData);
                    theType = 'string';
            end

            h5create(filename,datasetName,size(theData),'Datatype',theType);
            h5write(filename,datasetName,theData);
        end


        H5G.close(gid(2));
    end

    
    %Close the nirs group
    H5G.close(gid(1));


end



%Close the file
H5F.close(fid);


end