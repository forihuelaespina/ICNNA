function [res]=save(filename,theSnirf,varargin)
%Save an icnna.data.snirf.snirf object to an snirf file
%
% [res]=save(filename,theSnirf)
%
% [res]=save(...,'y') - Overwrite file if exist (if not indicated, you
%       will be prompted.
%
%
%
%% Remarks
%
% There is what appears to be a bug in MATLAB HDF5 read/write utility by
% which data are read/written as the transpose of their actual shape.
%
% Now, this is not a bug but intended behaviour and it is related to how C
% and FORTRAN behave. See:
%
% https://uk.mathworks.com/matlabcentral/answers/308303-why-does-matlab-transpose-hdf5-data
%
% Anyhow, this has to be considered when reading and writing using MATLAB's
%HDF5 read/write utility. From the above URL:
%
% "The HDF Group intended the various applications (Fortran, MATLAB, C,
% C++, Python, etc) to be able to write to the file in a native storage
% order and simply list the dimensions of the data in the file in a
% specified order (slowest changing first ... fastest changing last). It
% is then incumbent on the user to know what storage order his/her
% applications use if they are to share data through this file format ...
% and permute the data accordingly if necessary."
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
% 3-Mar-2023: FOE
%   + Several bugs fixed related to the writing of string arrays.
%
% 4-Mar-2024: FOE
%   + Bug fixed. Writing the transposed matrix (See remark above).
%   + Bug fixed. Array of strings are now correctly written instead of
%       cell arrays.
%   + Bug fixed. /aux/name was being written as a char array instead of
%       string
%
% 18-Apr-2024: FOE
%   + Bug fixed. Access to metaDataTags.additional isn now checked
%       for empty dictionaries.
%   + Bug fixed. Optional fields were requested as if compulsory. Now they
%       are simply ignored if not present.
%
% 25-Apr-2024: FOE
%   + Bug fixed. Writing of stim array of strings dataLabels was not
%       calculating the data size correctly.
%

%% Deal with options
opt.overwriteFile = false;
if abs(nargin) > 2
    tmpOverwriteFile = varargin{end};
    if ischar(tmpOverwriteFile) && tmpOverwriteFile == 'y'
        opt.overwriteFile = true;
    end
end



%% Preliminary
res=0;

%Create the output file
if exist(filename,"file") && ~opt.overwriteFile
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

%% Main loop

%Save format version
formatVersion=string(theSnirf.formatVersion);
h5create(filename,'/formatVersion',size(formatVersion),'Datatype','string');
h5write(filename,'/formatVersion',formatVersion);


nNIRSDatasets = theSnirf.nNirsDatasets;
for iDataset = 1:length(nNIRSDatasets)

    tmpNirsDataset = theSnirf.nirs(iDataset);
    nirsGroup = ['/nirs' num2str(iDataset)];
    if length(nNIRSDatasets) == 1 %If there is only one neuroimage, there's no need for numbering.
        nirsGroup = '/nirs';
    end
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
            if (tmpNirsDataset.metaDataTags.additional.numEntries > 0)
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
        theData = theData'; %Addresses MATLAB's transposing issue (See above)
        h5create(filename,datasetName,size(theData),'Datatype',precision.float);
        h5write(filename,datasetName,theData);

        datasetName = [groupName '/time'];
        theData = feval(precision.float,dataBlock.time);
        theData = theData'; %Addresses MATLAB's transposing issue (See above)
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

                if theML.isproperty(iElem) %Some fields are optional
                    theData = theML.(iElem);
                    switch(iElem)
                        case {'sourceIndex','detectorIndex','wavelengthIndex',...
                                'dataType','dataTypeIndex','moduleIndex',...
                                'sourceModuleIndex','detectorModuleIndex'}
                            theData = feval(precision.int,theData);
                            theData = theData'; %Addresses MATLAB's transposing issue (See above)
                            theType = precision.int;
                        case {'wavelengthActual','wavelengthEmissionActual',...
                                'sourcePower','detectorGain'}
                            theData = feval(precision.float,theData);
                            theData = theData'; %Addresses MATLAB's transposing issue (See above)
                            theType = precision.float;
                        otherwise
                            theData = string(theData);
                            theType = 'string';
                    end
    
                    h5create(filename,datasetName,size(theData),'Datatype',theType);
                    h5write(filename,datasetName,theData);
                end
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

            if theStim.isproperty(iElem) %Some fields are optional
                theData = theStim.(iElem);
                switch(iElem)
                    case {'dataLabels'}
                        theType = 'strings'; %Array of strings
                    case {'data'}
                        theData = feval(precision.float,theData);
                        theData = theData'; %Addresses MATLAB's transposing issue (See above)
                        theType = precision.float;
                    otherwise
                        theData = string(theData);
                        theType = 'string';
                end

                switch (theType)
                    case precision.float
                        h5create(filename,datasetName,size(theData),'Datatype',theType);
                        h5write(filename,datasetName,theData);
                    case 'string'
                        h5create(filename,datasetName,size(theData),'Datatype','string');
                        h5write(filename,datasetName,theData);
                    case 'strings'
                        h5create(filename,datasetName,size(theData'),'Datatype','string');
                        h5write(filename,datasetName,theData');
                    otherwise
                        error(['icnna.data.snirf.snirf:save:InvalidParameterType' ...
                            'Unexpected type "' theType '" for dataset "' datasetName '".']);
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

            if tmpNirsDataset.probe.isproperty(iElem) %Some fields are optional

                theData = tmpNirsDataset.probe.(iElem);
                switch(iElem)
                    case {'sourceLabels','detectorLabels','landmarkLabels   '}
                        theType = 'strings'; %Array of strings
                    case {'useLocalIndex'}
                        theData = feval(precision.int,theData);
                        theData = theData'; %Addresses MATLAB's transposing issue (See above)
                        theType = precision.int;
                    case {'wavelengths','wavelengthsEmission',...
                            'sourcePos2D','sourcePos3D',...
                            'detectorPos2D','detectorPos3D',...
                            'landmarkPos2D','landmarkPos3D',...
                            'frequencies','timeDelays','timeDelayWidths',...
                            'momentOrders','correlationTimeDelays',...
                            'correlationTimeDelayWidths'}
                        theData = feval(precision.float,theData);
                        theData = theData'; %Addresses MATLAB's transposing issue (See above)
                        theType = precision.float;
                    otherwise
                        theData = string(theData);
                        theType = 'string';
                end

                if ~strcmp(theType,'strings')
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
                    h5create(filename,datasetName,size(theData),'Datatype','string');
                    h5write(filename,datasetName,theData);
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

            if theAux.isproperty(iElem) %Some fields are optional

                theData = theAux.(iElem);
                switch(iElem)
                    case {'dataTimeSeries','time','timeOffset'}
                        theData = feval(precision.float,theData);
                        theData = theData'; %Addresses MATLAB's transposing issue (See above)
                        theType = precision.float;
                    case {'name'} %This may be a char array
                        theData = string(reshape(theData,1,numel(theData)));
                        theType = 'string';
                    otherwise
                        theData = string(theData);
                        theType = 'string';
                end

                h5create(filename,datasetName,size(theData),'Datatype',theType);
                h5write(filename,datasetName,theData);
            end
        end


        H5G.close(gid(2));
    end

    
    %Close the nirs group
    H5G.close(gid(1));


end



%Close the file
H5F.close(fid);

res=1;



end