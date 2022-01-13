function [clm]=import_ETG4000_3DChannelPosition(filename)
%Reads the raw ETG-4000 3D optode position as recorded by the Polhemus
%
% [clm]=import_ETG4000_3DChannelPosition(filename)
%
%
%
%
%% Remarks
%
% Hitachi's 3D optode positions file are difficult to read since
%the fields in each file may differ (despite being the same version).
%For instance, the sub-field MODE of the field or section FileInfo
%might or might not be present.
%
%
%
%
%% Parameters
%
% filename - The ETG-4000/Polhemus 3D positional data file to import.
%       Likely to have '.pos' file extension
%
%
%% Output
%
% clm -  A channel location map
%
% 
% Copyright 2012-13
% @date: 22-Dec-2012
% @author: Felipe Orihuela-Espina
% @modified: 13-Mar-2016
%
% See also channelLocationMap
%

%% Log
%
% 13-Mar-2016: Flexibilized input file structure to accept "small"
%       variations in the FileInfo section fields
%
% 12-Oct-2013: Minor bug fixed. Optode arrays mode changed from "adults"
%       to "adult"
%
% 10-Sep-2013: Support for optodes locations added.
%       * Improved code for auxiliar function estimateChannelLocation
%




% Open the data file for conversion
fidr = fopen(filename,'r');
if fidr == -1
    error('Unable to read %s\n', filename);
end


% h = waitbar(0,'Reading header...',...
%     'Name','Importing raw data (ETG-4000)');



%% Reading the header ================================
[fieldInfo,found]=readField(fidr,'FileInfo');
if found
    info_id = fieldInfo.id;
    tmpVersion = fieldInfo.version;
    nProbes = fieldInfo.nProbes;
end

%Not being used at the moment
[fieldInfo,found]=readField(fidr,'User',tmpVersion);
if found
    user = fieldInfo;
end






% x=0.05;
% waitbar(x,h,'Reading Data - 5%');
%       +probes - An array of struct
%           +mode
%           +optodeNum - Number of optodes
%           +optodeCoords - The actual coordinates.
probes=struct('mode',{},'optodeNum',{},'optodeCoords',{});


for pp=1:nProbes
    [fieldInfo,found]=readField(fidr,['Probe' num2str(pp)],tmpVersion);
    if found
        probes(pp).mode = fieldInfo.mode;
        probes(pp).optodeNum = fieldInfo.optodeNum;
    end

end

% x=0.07;
% waitbar(x,h,'Reading Data - 5%');


[fieldInfo,found]=readField(fidr,'MRI',tmpVersion);
if found
    mri = fieldInfo;
end



refLocations = struct('name',{},'location',{});
refLocationsSet={'LeftEar';'RightEar';'Nasion';'Back';'Top'};
for ll=1:numel(refLocationsSet)
    lloc=refLocationsSet{ll};
    [fieldInfo,found]=readField(fidr,lloc,tmpVersion);
    if found
        refLocations(end+1).name = fieldInfo.name;
        refLocations(end).location(1) = fieldInfo.x;
        refLocations(end).location(2) = fieldInfo.y;
        refLocations(end).location(3) = fieldInfo.z;
    end
    %Note the default direction of the axis!
    %  X axes => From RE (Negative) to LE (Positive)
    %  Y axes => From Nz (Negative) to Iz (Positive)
    %
    %In order to express the coordinates as if the head
    %was looking "frontwards" as it is usually represented
    %in papers (e.g. [JurcackV2007]) Optode coordinates
    %must be rotated 180% (or pi radians)
    %around the Z axes!
    refLocations(end).location=mesh3D_rotation(...
        refLocations(end).location,...
        pi,[0 0 0],[0 0 1]);
end
                                

% refLocations = struct('name',{},'location',{});
% %Left ear
% [fieldInfo,found]=readField(fidr,'LeftEar',tmpVersion);
% if found
%     refLocations(1).name = fieldInfo.name;
%     refLocations(end).location(1) = fieldInfo.x;
%     refLocations(end).location(2) = fieldInfo.y;
%     refLocations(end).location(3) = fieldInfo.z;
% end
%     %Note the default direction of the axis!
%     %  X axes => From RE (Negative) to LE (Positive)
%     %  Y axes => From Nz (Negative) to Iz (Positive)
%     %
%     %In order to express the coordinates as if the head
%     %was looking "frontwards" as it is usually represented
%     %in papers (e.g. [JurcackV2007]) Optode coordinates
%     %must be rotated 180% (or pi radians)
%     %around the Z axes!
%     
% refLocations(end).location=mesh3D_rotation(...
%                                     refLocations(end).location,...
%                                     pi,[0 0 0],[0 0 1]);
% 
% 
% 
% [fieldInfo,found]=readField(fidr,'RightEar',tmpVersion);
% if found
%     refLocations(end+1).name = fieldInfo.name;
%     refLocations(end).location(1) = fieldInfo.x;
%     refLocations(end).location(2) = fieldInfo.y;
%     refLocations(end).location(3) = fieldInfo.z;
% end
% refLocations(end).location=mesh3D_rotation(...
%                                     refLocations(end).location,...
%                                     pi,[0 0 0],[0 0 1]);
% 
% [fieldInfo,found]=readField(fidr,'Nasion',tmpVersion);
% if found
%     refLocations(end+1).name = fieldInfo.name;
%     refLocations(end).location(1) = fieldInfo.x;
%     refLocations(end).location(2) = fieldInfo.y;
%     refLocations(end).location(3) = fieldInfo.z;
% end
% refLocations(end).location=mesh3D_rotation(...
%                                     refLocations(end).location,...
%                                     pi,[0 0 0],[0 0 1]);
% 
% 
% [fieldInfo,found]=readField(fidr,'Back',tmpVersion); %Inion
% if found
%     refLocations(end+1).name = fieldInfo.name;
%     refLocations(end).location(1) = fieldInfo.x;
%     refLocations(end).location(2) = fieldInfo.y;
%     refLocations(end).location(3) = fieldInfo.z;
% end
% refLocations(end).location=mesh3D_rotation(...
%                                     refLocations(end).location,...
%                                     pi,[0 0 0],[0 0 1]);
% 
% 
% [fieldInfo,found]=readField(fidr,'Top',tmpVersion);
% if found
%     refLocations(end+1).name = fieldInfo.name;
%     refLocations(end).location(1) = fieldInfo.x;
%     refLocations(end).location(2) = fieldInfo.y;
%     refLocations(end).location(3) = fieldInfo.z;
% end
% refLocations(end).location=mesh3D_rotation(...
%                                     refLocations(end).location,...
%                                     pi,[0 0 0],[0 0 1]);
% 






%Remember! This actually refer to optodes locations; not channels.
%step=0.90/nProbes;
for pp=1:nProbes

%     substep=0.05*step;
%     x=x+substep;
%     waitbar(x,h,['Reading Data - ' num2str(round(x)) '%']);

    nOptodes=probes(pp).optodeNum;
%    substep=(0.95*substep)/nOptodes;
    for oo=1:nOptodes

        [fieldInfo,found]=readField(fidr,['Probe' num2str(pp) '-ch' num2str(oo)],tmpVersion);
        if found
            x = fieldInfo.x;
            y = fieldInfo.y;
            z = fieldInfo.z;
            probes(pp).optodeCoords(oo,:)=[x y z];
            e = fieldInfo.e;
            r = fieldInfo.r;
            nx = fieldInfo.nx;
            ny = fieldInfo.ny;
            nz = fieldInfo.nz;
        end
        
        
%        x=x+substep;
%        waitbar(x,h,['Reading Data - ' num2str(round(x)) '%']);
    end
    
    
    
    %Note the default direction of the axis!
    %  X axes => From RE (Negative) to LE (Positive)
    %  Y axes => From Nz (Negative) to Iz (Positive)
    %
    %In order to express the coordinates as if the head
    %was looking "frontwards" as it is usually represented
    %in papers (e.g. [JurcackV2007]) Optode coordinates
    %must be rotated 180% (or pi radians)
    %around the Z axes!
    [tmpCoords]=mesh3D_rotation(probes(pp).optodeCoords,...
        pi,[0 0 0],[0 0 1]);
    probes(pp).optodeCoords=tmpCoords;
    
    
end    
    
%Angle
%Not used at the moment
[fieldInfo,found]=readField(fidr,'Angle',tmpVersion);
if found
    angle(1) = fieldInfo.x;
    angle(2) = fieldInfo.y;
    angle(3) = fieldInfo.z;
end


%Measure
%Not used at the moment
[fieldInfo,found]=readField(fidr,'Measure',tmpVersion);
if found
    measure = fieldInfo;
end



%waitbar(1,h,'Reading Data - 100%');

fclose(fidr);

%Finally store everything in a channelLocationMap
%waitbar(0,h,'Storing Data - 0%');

clm=channelLocationMap;
clm=set(clm,'ID',1); %Assign ID=1 for no particular reason
%Save reference points locations
clm=addReferencePoints(clm,refLocations);
%Save optodes locations as reference points as well
optodesCoordinates = nan(0,3);
optodesTypes = nan(0,1);
optodesProbeSets = nan(0,1);
optodesOptodeArrays = nan(0,1);

channelCoordinates = nan(0,3);
channelProbeSets = nan(0,1);
channelOptodeArrays = nan(0,1);

pairings = nan(0,2); %Pairs <emisor,detector> conforming the channels

currOA=1; %Current optode array
oaInfo=struct('mode',{},'type',{},...
                    'chTopoArrangement',{},...
                    'optodesTopoArrangement',{});
%Collect optodes and channels information
currOptode =0;
for pp=1:nProbes
    nOptodes=probes(pp).optodeNum;
    optodesCoordinates = [optodesCoordinates; probes(pp).optodeCoords];
    optodesTypes = [optodesTypes; getOptodeTypes(probes(pp).mode)];
    optodesProbeSets = [optodesProbeSets; repmat(pp,nOptodes,1)];
    
    %Estimate channel locations from optode positions
    [temp,optodePairs] = estimateChannelLocation(probes(pp));
    nChannelsInThisProbeSet = size(temp,1);
    channelCoordinates=[channelCoordinates; temp];
	channelProbeSets = [channelProbeSets; repmat(pp,nChannelsInThisProbeSet,1)];
    
    pairings=[pairings; optodePairs+currOptode];
    currOptode = currOptode+nOptodes;
    
    switch (probes(pp).mode)
        case 1 %2 optode arrays 3x3
            optodesOptodeArrays = [optodesOptodeArrays; ...
                                    repmat(currOA,nOptodes/2,1)];
            channelOptodeArrays = [channelOptodeArrays; ...
                                    repmat(currOA,nChannelsInThisProbeSet/2,1)];
            oaInfo(currOA).mode = 'HITACHI_ETG4000_3x3';
            oaInfo(currOA).type = 'adult';
            oaInfo(currOA).chTopoArrangement = [3.5   0.5; ...
                1.5   0.5; ...
                4.5   1.5; ...
                2.5   1.5; ...
                0.5   1.5; ...
                3.5   2.5; ...
                1.5   2.5; ...
                4.5   3.5; ...
                2.5   3.5; ...
                0.5   3.5; ...
                3.5   4.5; ...
                1.5   4.5]; %coordinates for south right orientation;
            oaInfo(currOA).optodesTopoArrangement = [4.5   0.5; ...
                2.5   0.5; ...
                0.5   0.5; ...
                4.5   2.5; ...
                2.5   2.5; ...
                0.5   2.5; ...
                4.5   4.5; ...
                2.5   4.5; ...
                0.5   4.5]; %coordinates for south right orientation;
            currOA=currOA+1;
                        
            optodesOptodeArrays = [optodesOptodeArrays; ...
                                    repmat(currOA,nOptodes/2,1)];
            channelOptodeArrays = [channelOptodeArrays; ...
                                    repmat(currOA,nChannelsInThisProbeSet/2,1)];
            oaInfo(currOA).mode = 'HITACHI_ETG4000_3x3';
            oaInfo(currOA).type = 'adult';
            oaInfo(currOA).chTopoArrangement = [3.5   0.5; ...
                1.5   0.5; ...
                4.5   1.5; ...
                2.5   1.5; ...
                0.5   1.5; ...
                3.5   2.5; ...
                1.5   2.5; ...
                4.5   3.5; ...
                2.5   3.5; ...
                0.5   3.5; ...
                3.5   4.5; ...
                1.5   4.5]; %coordinates for south right orientation;
            oaInfo(currOA).optodesTopoArrangement = [4.5   0.5; ...
                2.5   0.5; ...
                0.5   0.5; ...
                4.5   2.5; ...
                2.5   2.5; ...
                0.5   2.5; ...
                4.5   4.5; ...
                2.5   4.5; ...
                0.5   4.5]; %coordinates for south right orientation;
            currOA=currOA+1;
            
            
        case 2 %4x4
            optodesOptodeArrays = [optodesOptodeArrays; ...
                                    repmat(currOA,nOptodes,1)];
            channelOptodeArrays = [channelOptodeArrays; ...
                                    repmat(currOA,nChannelsInThisProbeSet,1)];
            oaInfo(currOA).mode = 'HITACHI_ETG4000_4x4';
            oaInfo(currOA).type = 'adult';
            oaInfo(currOA).chTopoArrangement = [5.5   0.5; ...
                3.5   0.5; ...
                1.5   0.5; ...
                6.5   1.5; ...
                4.5   1.5; ...
                2.5   1.5; ...
                0.5   1.5; ...
                5.5   2.5; ...
                3.5   2.5; ...
                1.5   2.5; ...
                6.5   3.5; ...
                4.5   3.5; ...
                2.5   3.5; ...
                0.5   3.5; ...
                5.5   4.5; ...
                3.5   4.5; ...
                1.5   4.5; ...
                6.5   5.5; ...
                4.5   5.5; ...
                2.5   5.5; ...
                0.5   5.5; ...
                5.5   6.5; ...
                3.5   6.5; ...
                1.5   6.5]; %coordinates for south right orientation;
            oaInfo(currOA).optodesTopoArrangement = [6.5   0.5; ...
                4.5   0.5; ...
                2.5   0.5; ...
                0.5   0.5; ...
                6.5   2.5; ...
                4.5   2.5; ...
                2.5   2.5; ...
                0.5   2.5; ...
                6.5   4.5; ...
                4.5   4.5; ...
                2.5   4.5; ...
                0.5   4.5; ...
                6.5   6.5; ...
                4.5   6.5; ...
                2.5   6.5; ...
                0.5   6.5]; %coordinates for south right orientation;
            currOA=currOA+1;

            
            
            
        case 3 %3x5
            optodesOptodeArrays = [optodesOptodeArrays; ...
                                    repmat(currOA,nOptodes,1)];
            channelOptodeArrays = [channelOptodeArrays; ...
                                    repmat(currOA,nChannelsInThisProbeSet,1)];
            oaInfo(currOA).mode = 'HITACHI_ETG4000_3x5';
            oaInfo(currOA).type = 'adult';
            oaInfo(currOA).chTopoArrangement = [3.5   0; ...
                2.5   0; ...
                1.5   0; ...
                0.5   0; ...
                4   0.5; ...
                3   0.5; ...
                2   0.5; ...
                1   0.5; ...
                0   0.5; ...
                3.5   1; ...
                2.5   1; ...
                1.5   1; ...
                0.5   1; ...
                4   1.5; ...
                3   1.5; ...
                2   1.5; ...
                1   1.5; ...
                0   1.5; ...
                3.5   2; ...
                2.5   2; ...
                1.5   2; ...
                0.5   2]; %coordinates for south right orientation;
            oaInfo(currOA).optodesTopoArrangement = [4   0; ...
                3   0; ...
                2   0; ...
                1   0; ...
                0   0; ...
                4   2; ...
                3   2; ...
                2   2; ...
                1   2; ...
                0   2; ...
                4   4; ...
                3   4; ...
                2   4; ...
                1   4; ...
                0   4]; %coordinates for south right orientation;
            currOA=currOA+1;
            
            
        otherwise
            error('ICNA:import_ETG4000_3DChannelPosition',...
                ['Unexpected probe set mode ''' ...
                probes(pp).mode ''' ' ...
                'for probes set #' num2str(pp)]);
    end
end


%Update optodes information
nOptodes = getNTotalOptodes(probes);
clm=set(clm,'NOptodes',nOptodes);
clm=setOptode3DLocations(clm,1:nOptodes,optodesCoordinates);
clm=setOptodeTypes(clm,1:nOptodes,optodesTypes);
clm=setOptodeProbeSets(clm,1:nOptodes,optodesProbeSets);
clm=setOptodeOptodeArrays(clm,1:nOptodes,optodesOptodeArrays);


%Update channel information
nChannels = size(channelCoordinates,1);
clm=set(clm,'NChannels',nChannels);
clm=setChannel3DLocations(clm,1:nChannels,channelCoordinates);
clm=setChannelProbeSets(clm,1:nChannels,channelProbeSets);
clm=setChannelOptodeArrays(clm,1:nChannels,channelOptodeArrays);

clm=setPairings(clm,1:nChannels,pairings);

%Update optode arrays information
clm=setOptodeArraysInfo(clm,1:length(oaInfo),oaInfo);



%waitbar(1,h,'Storing Data - 100%');
%close(h);


end




%%=============================================================
%% Auxiliar functions
%%=============================================================
function fieldName = getFieldName(lineString)
%Extract the field name
idx=find(lineString==']');
if (isempty(idx))
    fieldName='';
else
    fieldName=lineString(2:idx(1)-1); %The field also starts with '['
end
end

function [lineString,found]=findField(fidr,fieldName)
%Finds the line containing the field specified
currPos=ftell(fidr);
lineString=[];
temp='';
found=false;
%nextField = false;
while ~found && ~feof(fidr) %&& ~nextField
    lineString = fgetl(fidr);
    temp=getFieldName(lineString);
    found=strcmpi(temp,fieldName);
    %nextField = lineString(1)=='[' && lineString(end)==']';
end
if (feof(fidr) && ~found) 
    warning(['Field ''' fieldName ...
            ''' not found. Attempting to continue.']);
end
% if ((feof(fidr) || nextField) && ~found) 
%     warning(['Field ''' fieldName ...
%             ''' not found. Attempting to continue.']);
% end
% if nextField && ~found
%     %Go back one line, so that I can still look
%     %for the corresponding new field
%     fseek(fidr, currPos, 'bof');
% end    
end

function fieldName = getSubFieldName(lineString)
%Extract the field name
idx=find(lineString=='=');
if (isempty(idx))
    fieldName='';
else
    fieldName=lineString(1:idx(1)-1);
end
end

function [lineString,found]=findSubField(fidr,fieldName)
%Finds the line containing the subfield specified
currPos=ftell(fidr);
lineString=[];
temp='';
found =false;
nextField = false;
while ~found && ~feof(fidr) && ~nextField
    lineString = fgetl(fidr);
    temp=getSubFieldName(lineString);
    found=strcmpi(temp,fieldName);
    nextField = lineString(1)=='[' && lineString(end)==']';
end
if ((feof(fidr) || nextField) && ~found) 
    warning(['Sub-Field ''' fieldName ...
            ''' not found. Attempting to continue.']);
end
if nextField && ~found
    %Go back one line, so that I can still look
    %for the corresponding new field
    fseek(fidr, currPos, 'bof');
end    
end





function [channelCoordinates,optodePairs]=estimateChannelLocation(probeSet)
%Calculate the position of channels from a probeSet
%
%% Source-detector pairs and corresponding channels
%
% Mode 1 => 2 array in a '3x3' configuration
%
% Optode pair | Channel No.
%-------------+--------------
%     1-2     |     1
%     2-3     |     2
%     1-4     |     3               1--(1)--2--(2)--3
%     2-5     |     4               |       |       |
%     3-6     |     5              (3)     (4)     (5)
%     4-5     |     6               |       |       |
%     5-6     |     7               4--(6)--5--(7)--6
%     4-7     |     8               |       |       |
%     5-8     |     9              (8)     (9)    (10)
%     6-9     |    10               |       |       |
%     7-8     |    11               7--(11)-8--(12)-9
%     8-9     |    12
%                           Channel number in brackets
%
%
%
%
%
% Mode 2 => 1 array in a '4x4' configuration

%   Example: HITACHI ETG-4000 4x4 optode array
%
%   S - Light Source           S---1---D---2---S---3---D
%   D - Light Detector         |       |       |       |
%   1,..,24 - Channel          4       5       6       7
%                              |       |       |       |
%                              D---8---S---9---D--10---S
%                              |       |       |       |
%                             11      12      13      14
%                              |       |       |       |
%                              S--15---D--16---S--17---D
%                              |       |       |       |
%                             18      19      20      21
%                              |       |       |       |
%                              S--22---D--23---S--24---D
%
%
%
% Optode pair | Channel No.
%-------------+--------------
%     1-2     |     1
%     2-3     |     2
%     3-4     |     3
%     1-5     |     4
%     2-6     |     5
%     3-7     |     6
%     4-8     |     7
%     5-6     |     8
%     6-7     |     9
%     7-8     |    10
%     5-9     |    11
%     6-10    |    12
%     7-11    |    13
%     8-12    |    14
%     9-10    |    15
%    10-11    |    16
%    11-12    |    17
%     9-13    |    18
%    10-14    |    19
%    11-15    |    20
%    12-16    |    21
%    13-14    |    22
%    14-15    |    23
%    15-16    |    24
%
%
%
%
%
% Mode 3 => 1 array in a '3x5' configuration
%
%   S - Light Source        S---1---D---2---S---3---D---4---S
%   D - Light Detector      |       |       |       |       |
%   1,..,24 - Channel       5       6       7       8       9
%                           |       |       |       |       |
%                           D--10---S--11---D--12---S--13---D
%                           |       |       |       |       |
%                           14      15      16      17      18
%                           |       |       |       |       |
%                           S--19---D--20---S--21---D--22---S
%
% Optode pair | Channel No.
%-------------+--------------
%     1-2     |     1
%     2-3     |     2
%     3-4     |     3
%     4-5     |     4
%     1-6     |     5
%     2-7     |     6
%     3-8     |     7
%     4-9     |     8
%     5-10    |     9
%     6-7     |    10
%     7-8     |    11
%     8-9     |    12
%     9-10    |    13
%     6-11    |    14
%     7-12    |    15
%     8-13    |    16
%     9-14    |    17
%    10-15    |    18
%    11-12    |    19
%    12-13    |    20
%    13-14    |    21
%    14-15    |    22
%
%
%
%% Parameters
%
% probeSet - A struct with the following fields:
%           +mode
%           +optodeNum - Number of optodes
%           +optodeCoords - The actual coordinates.
%
%
%% Output
%
% channelCoordinates - An nx3 matrix with the 3D coordinates for the
%   channels. Number of channels n will depend on the probe mode.
%
%
% 
% Copyright 2013
% @date: 28-Aug-2013
% @author: Felipe Orihuela-Espina
% @modified: 10-Sep-2013
%
% See also channelLocationMap
%

%% Log
%
% 10-Sep-2013: Reorder the optode pairs so that the emisor is always
%       on the first column, and the detector on the second.
%

mode=probeSet.mode;
optodeCoors=probeSet.optodeCoords;


channelCoordinates=[];

switch (mode)
    case 1 %3x3
        optodePairs=[...
            1 2; ...
            3 2; ...
            1 4; ...
            5 2; ...
            3 6; ...
            5 4; ...
            5 6; ...
            7 4; ...
            5 8; ...
            9 6; ...
            7 8; ...
            9 8];
        optodePairs=[optodePairs; optodePairs+9];
        
    
    case 2 %4x4
        optodePairs=[...
            1 2; ...
            3 2; ...
            3 4; ...
            1 5; ...
            6 2; ...
            3 7; ...
            8 4; ...
            6 5; ...
            6 7; ...
            8 7; ...
            9 5; ...
            6 10; ...
           11 7; ...
            8 12; ...
            9 10; ...
           11 10; ...
           11 12; ...
            9 13; ...
           14 10; ...
           11 15; ...
           16 12; ...
           14 13; ...
           14 15; ...
            16 15];
    
        
    case 3 %3x5
        optodePairs=[...
            1 2; ...
            3 2; ...
            3 4; ...
            5 4; ...
            1 6; ...
            7 2; ...
            3 8; ...
            9 4; ...
            5 10; ...
            7 6; ...
            7 8; ...
            9 8; ...
            9 10; ...
           11 6; ...
            7 12; ...
           13 8; ...
            9 14; ...
           15 10; ...
           11 12; ...
           13 12; ...
           13 14; ...
           15 14];

   
    otherwise
        warning('ICNA:import_ETG4000_3DChannelPosition',...
            ['Optode array mode not recognised. ' ...
            'Channel locations will not be calculated.']);
end

nChannels = size(optodePairs,1);
channelCoordinates=zeros(nChannels,3);
for ch=1:nChannels
    o1=optodeCoors(optodePairs(ch,1),:);
    o2=optodeCoors(optodePairs(ch,2),:);
    channelCoordinates(ch,:)=(o1+o2)/2;
end

end



function nOptodes = getNTotalOptodes(probes)
%Gets the total number of optodes
nProbes=length(probes);
nOptodes=0;
for pp=1:nProbes
    nOptodes=nOptodes+probes(pp).optodeNum;
end
end


function oTypes=getOptodeTypes(mode)
%Receives a probe mode and generates a vector of optodes types for that
%probe
oTypes = [];
switch (mode)
    case 1 %3x3
            %Two optode arrays for this mode
        oTypes=[channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR];
        oTypes=[oTypes;...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR];
            
    case 2 %4x4
        oTypes=[channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR];
    case 3 %3x5
        oTypes=[channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR; ...
                channelLocationMap.OPTODE_TYPE_DETECTOR; ...
                channelLocationMap.OPTODE_TYPE_EMISOR];
    otherwise
        warning('ICNA:import_ETG4000_3DChannelPosition',...
            ['Optode array mode not recognised. ' ...
            'Optode types will not be calculated.']);
end


end






function [fieldInfo,found]=readField(fidr,fieldName,theVersion)
%Encapsulates the reading of the different fields
%
%It permits that the fields appear in different order in the
%input file
%
%% Input
% fidr - file identifier
% fieldName - String indicating the field name
%
%% Output
%
% fieldInfo - A struct of varying subfields; the subfields depends
%   on the subfields of the field.
% found - A flag indicating whether the section has been found.
% theVersion - Optional. A string indicating the file version. If not
%   indicated it will be set to '2.00'.
%

fieldInfo = struct;
fieldInfo.fieldName = fieldName;
fseek(fidr, 0, 'bof');

%Some preliminar checking (since I do not know how to make the
%switch statement responsive to a regular expression)
if regexpi(fieldName,'Probe\d+-ch\d+')
    fieldInfo.probeNumber = str2double(fieldName(6:find(fieldName=='-')-1));
    fieldInfo.channelNumber = str2double(fieldName(find(fieldName=='-')+3:end));
    %disp(['Reading ' fieldName ': Probe=' num2str(fieldInfo.probeNumber) ...
    %        '; Ch=' num2str(fieldInfo.channelNumber)])
    fieldName = 'ProbeK-chN';
elseif regexpi(fieldName,'Probe\d+')
    fieldInfo.probeNumber = str2double(fieldName(6:end));
    fieldName = 'ProbeK';
end    

found=false;
            

switch(fieldName)
    case 'FileInfo'
        %Declare fields
        fieldInfo.id = [];
        fieldInfo.version = [];
        fieldInfo.productName = [];
        fieldInfo.nProbes = [];
        fieldInfo.type = [];

        [~,found]=findField(fidr,'FileInfo');
        if found
            temp=findSubField(fidr,'ID');
            fieldInfo.id = str2double(temp(find(temp=='=')+1:end)); %Ignore fieldName and read the rest
            %This is not the channelLocationMap ID!
            temp=findSubField(fidr,'VER');
            fieldInfo.version=temp(find(temp=='=')+1:end);
            theVersion = fieldInfo.version;
            temp=findSubField(fidr,'ProductName');
            fieldInfo.productName=temp(find(temp=='=')+1:end);
            temp=findSubField(fidr,'PROBE'); %number of probes
            fieldInfo.nProbes=str2double(temp(find(temp=='=')+1:end));
            temp=findSubField(fidr,'TYPE');
            fieldInfo.type=str2double(temp(find(temp=='=')+1:end));
            
            
            if version_IsHigherOrEqual(theVersion,'2.00')
                temp=findSubField(fidr,'MODE');
                fieldInfo.mode=str2double(temp(find(temp=='=')+1:end)); %Possibly 'ETG'
            else
                %Previous versions. Do nothing, but still declare the subfields
                fieldInfo.mode = [];
            end
            
        end



        
    case 'User'
        %Declare fields
        fieldInfo.type = [];
        fieldInfo.id = [];
        fieldInfo.comment = [];
        fieldInfo.sex = [];
        fieldInfo.age = [];
        fieldInfo.birth = [];

        [~,found]=findField(fidr,'User');
        if found
            temp=findSubField(fidr,'Name');
            fieldInfo.type=temp(find(temp=='=')+1:end);
            temp=findSubField(fidr,'ID');
            fieldInfo.id=temp(find(temp=='=')+1:end);
            temp=findSubField(fidr,'Comment');
            fieldInfo.comment=temp(find(temp=='=')+1:end);
            temp=findSubField(fidr,'Sex');
            fieldInfo.sex=temp(find(temp=='=')+1:end);
            temp=findSubField(fidr,'Age');
            tempAge=temp(find(temp=='=')+1:end);
            fieldInfo.age=str2double(tempAge(1:end-2));%Ignore the 'y'
            
            if version_IsHigherOrEqual(theVersion,'2.00')
                temp=findSubField(fidr,'Birth');
                fieldInfo.birth=temp(find(temp=='=')+1:end); %Birth date in yyyy/mm/dd format
            else
                %Previous versions. Do nothing
            end
            
        end
        
        
        
    case 'MRI'
        %Declare fields
        fieldInfo.markColor = [];
        fieldInfo.markColorSel = [];
        fieldInfo.markSize = [];
        fieldInfo.voxel = [];
        fieldInfo.head = [];
        fieldInfo.brain = [];
        fieldInfo.set = [];
            
        if version_IsHigherOrEqual(theVersion,'2.00')
            
            [~,found]=findField(fidr,'MRI');
            %Not currently used. Possibly reserved by HITACHI for future
            %overimposing the NIRS on top of an structural MRI
            if found
                temp=findSubField(fidr,'MarkColor');
                fieldInfo.markColor=str2double(temp(find(temp=='=')+1:end));
                temp=findSubField(fidr,'MarkColorSel');
                fieldInfo.markColorSel=str2double(temp(find(temp=='=')+1:end));
                temp=findSubField(fidr,'MarkSize');
                fieldInfo.markSize=str2double(temp(find(temp=='=')+1:end));
                temp=findSubField(fidr,'Voxel');
                fieldInfo.voxel=temp(find(temp=='=')+1:end);
                temp=findSubField(fidr,'Head');
                fieldInfo.head=temp(find(temp=='=')+1:end);
                temp=findSubField(fidr,'Brain');
                fieldInfo.brain=temp(find(temp=='=')+1:end);
                temp=findSubField(fidr,'Set');
                fieldInfo.set=str2double(temp(find(temp=='=')+1:end));
            end
        else
            %Previous versions. Do nothing
        end
        
        
    case {'LeftEar','RightEar','Nasion','Back','Top'}
        %Declare fields
        fieldInfo.name = [];
        fieldInfo.x = []; 
        fieldInfo.y = []; 
        fieldInfo.z = []; 

        [~,found]=findField(fidr,fieldName);
        if found
            fieldInfo.name = lower(fieldName);
            if strcmp(fieldInfo.name,'back')
                fieldInfo.name = 'inion';
            end
            temp=findSubField(fidr,'X');
            fieldInfo.x=str2double(temp(find(temp=='=')+1:end));
            temp=findSubField(fidr,'Y');
            fieldInfo.y=str2double(temp(find(temp=='=')+1:end));
            temp=findSubField(fidr,'Z');
            fieldInfo.z=str2double(temp(find(temp=='=')+1:end));
        end
        

        
    case 'ProbeK'
        %Declare fields
        fieldInfo.mode = []; 
        fieldInfo.optodeNum = []; 

        [~,found]=findField(fidr,['Probe' num2str(fieldInfo.probeNumber)]);
        if found
            temp=findSubField(fidr,'MODE');
            fieldInfo.mode=str2double(temp(find(temp=='=')+1:end));
            temp=findSubField(fidr,'ChNum');
            %for some reason they call it channel when they refer
            %to optodes.
            fieldInfo.optodeNum=str2double(temp(find(temp=='=')+1:end));
        end
        
        
        
    case 'ProbeK-chN'
        %Declare fields
        fieldInfo.x = []; 
        fieldInfo.y = []; 
        fieldInfo.z = []; 
        fieldInfo.e = [];
        fieldInfo.r = [];
        fieldInfo.nx = [];
        fieldInfo.ny = [];
        fieldInfo.nz = [];
        
        [~,found]=findField(fidr,['Probe' num2str(fieldInfo.probeNumber) ...
                        '-ch' num2str(fieldInfo.channelNumber)]);
        temp=findSubField(fidr,'X');
        fieldInfo.x=str2double(temp(find(temp=='=')+1:end));
        temp=findSubField(fidr,'Y');
        fieldInfo.y=str2double(temp(find(temp=='=')+1:end));
        temp=findSubField(fidr,'Z');
        fieldInfo.z=str2double(temp(find(temp=='=')+1:end));

        if version_IsHigherOrEqual(theVersion,'2.00')
            %No idea what these are...
            temp=findSubField(fidr,'E');
            e=str2double(temp(find(temp=='=')+1:end));
            temp=findSubField(fidr,'R');
            r=str2double(temp(find(temp=='=')+1:end));
            temp=findSubField(fidr,'NX');
            nx=str2double(temp(find(temp=='=')+1:end));
            temp=findSubField(fidr,'NY');
            ny=str2double(temp(find(temp=='=')+1:end));
            temp=findSubField(fidr,'NZ');
            nz=str2double(temp(find(temp=='=')+1:end));
        else
            %Previous versions. Do nothing
        end

        
        

    case 'Angle'
        %Declare fields
        fieldInfo.x = []; 
        fieldInfo.y = []; 
        fieldInfo.z = []; 

        [~,found]=findField(fidr,'Angle');
        temp=findSubField(fidr,'X');
        fieldInfo.x=str2double(temp(find(temp=='=')+1:end));
        temp=findSubField(fidr,'Y');
        fieldInfo.y=str2double(temp(find(temp=='=')+1:end));
        temp=findSubField(fidr,'Z');
        fieldInfo.z=str2double(temp(find(temp=='=')+1:end));
        
        

        
        
    case 'Measure'
        %Declare fields
        fieldInfo.spaceData = [];

        if version_IsHigherOrEqual(theVersion,'2.00')
            %Measure
            %Not used at the moment
            [~,found]=findField(fidr,'Measure');
            if found
                temp=findSubField(fidr,'3DSpaceData');
                fieldInfo.spaceData=temp(find(temp=='=')+1:end);
            end
        else
            %Previous versions. Do nothing
        end
        
        
    otherwise
        %Do nothing; a warning has already been issued by findField
        %warning('ICNA:import_ETG4000_3DChannelPosition',...
        %        ['Field "' fieldName '" not found.']);
end

end
