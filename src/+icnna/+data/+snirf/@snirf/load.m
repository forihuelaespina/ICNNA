function [res]=load(filename)
%Loads an snirf file
%
% [res]=load(filename)
%
%
%
%% Input parameters
%
% filename - String. The filename including the path whether
%   absolute or relative to current working directory.
% 
%% Output parameters
%
% res - A icnna.data.snirf.snirf object. A snirf object
%   with the information loaded from the file.
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
% 19-May-2023: FOE
%   File created.
%
% 19-Aug-2023: FOE
%   + Found a few bugs while writing the method write, e.g. metaDataTags
%   were not correctly capitalized which leads to mandatory tags being
%   stored as additional. Fix these bugs.
%   + Added a few extra comments
%
% 3-Mar-2024: FOE
%   + Bug fixed. probe.landmarkLabels is an optional field but was being
%   treated as a mandatory field.
%   + Bug fixed. Reading of '/data' group was "only" looking in '/nirs'
%   group excluding the possibility of more than one neuroimage.
%


%Create the object
res = icnna.data.snirf.snirf();

%Read the file
[temp,~] = icnna.data.snirf.snirf.readHD5file(filename);

%Now, comes the tricky part; copying the read info into the object
%This is not trivial. It requires for instance regrouping the unfolded
%groups.
%
%Use brute force by now
res.formatVersion = temp.formatVersion;

[theNirsFields]=findFields(temp,'nirs*');
for iDataset = 1:length(theNirsFields)

    tmp = struct();
    %Read metaDataTags
        %In snirf, the mandatory metaDataTags are first capitalized
        %whereas in ICNNA attributes are first lower case. An attempt
        %to load these directly will send the mandatory fields to the
        %additional dictionary.
        tmpTags = temp.(theNirsFields{iDataset}).metaDataTags; %raw struct with field names uncorrected
        tmpFieldNames = fieldnames(tmpTags);
        mandatoryFields = {'frequencyUnit', 'lengthUnit', ...
                            'manufacturerName', 'measurementDate', ...
                            'measurementTime', 'subjectID', ...
                            'timeUnit'}; %These are the ones needing amendment
        for iField = length(tmpFieldNames):-1:1
            iFieldName = tmpFieldNames{iField};
            idx = strcmpi(iFieldName,mandatoryFields);
            if any(idx)
                pos = find(idx);
                tmpTags.(mandatoryFields{pos}) = string(tmpTags.(iFieldName));
                tmpTags = rmfield(tmpTags,iFieldName);
            end
        end
        tmpTags.measurementDate = string(strip(tmpTags.measurementDate,'both',char(0)));
        tmpTags.measurementTime = string(strip(tmpTags.measurementTime,'both',char(0)));
    tmp.metaDataTags = icnna.data.snirf.metaDataTags(tmpTags);

    %Read probe
    tmpProbe = temp.(theNirsFields{iDataset}).probe;
    % %Those fields read as a string array need to be converted to cell
    % %arrays
    % if isfield(tmpProbe,'landmarkLabels')
    %     %The landmarkLabels is read as a string array. Convert to cell array
    %     tmpProbe.landmarkLabels = cellstr(tmpProbe.landmarkLabels);
    %         %PENDING: There are some space padding on the right of the labels. It
    %         %may be convenient to clean them.
    % end
    tmp.probe = icnna.data.snirf.probe(tmpProbe);

    %Read data blocks
    [theDataFields]=findFields(temp.(theNirsFields{iDataset}),'data*');
    for iDataBlock = 1:length(theDataFields)
        tmp2 = struct();
        tmp2.dataTimeSeries = temp.(theNirsFields{iDataset}).(theDataFields{iDataBlock}).dataTimeSeries;
        tmp2.time = temp.nirs(iDataset).(theDataFields{iDataBlock}).time;

        [theMeasurementsFields]=findFields(temp.(theNirsFields{iDataset}).(theDataFields{iDataBlock}),'measurementList*');
        for iMeas = 1:length(theMeasurementsFields)
            tmp3 = temp.(theNirsFields{iDataset}).(theDataFields{iDataBlock}).(theMeasurementsFields{iMeas});
            tmp2.measurementList(iMeas) = icnna.data.snirf.measurement(tmp3);
        end
        tmp.data(iDataBlock) = icnna.data.snirf.dataBlock(tmp2);
    
    end

    %Read stimulus
    [theStimFields]=findFields(temp.(theNirsFields{iDataset}),'stim*');
    for iStim = 1:length(theStimFields)
        tmp.stim(iStim) = icnna.data.snirf.stim(temp.(theNirsFields{iDataset}).(theStimFields{iStim}));
    end

    %Read aux
    [theAuxFields]=findFields(temp.(theNirsFields{iDataset}),'aux*');
    for iAux = 1:length(theAuxFields)
        tmp.aux(iAux) = icnna.data.snirf.auxBlock(temp.(theNirsFields{iDataset}).(theAuxFields{iAux}));
    end

    res.nirs(iDataset) = icnna.data.snirf.nirsDataset(tmp);

end


end




%% AUXILIARY FUNCTION
function [tmpFields]=findFields(inputStruct,expression)
%Lists all fields that abide to a regular expression
%
%   [theFields]=findFields(inputStruct,expression)
%
% inputStruct - A struct to be searched.
% expression - String. A regular expression for filtering fields.
%
% theFields - (:,1) Cell array. List of fields in inputStruct for which
%       the name abide by regexp
%
tmpFields = fieldnames(inputStruct);
nFields = length(tmpFields);
for iField = nFields:-1:1
    startIndex = regexp(tmpFields{iField},expression);
    if isempty(startIndex)
        tmpFields(iField) = [];
    end
end

end


