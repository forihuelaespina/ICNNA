function [res,info]=readHD5file(filename)
%Loads the content of an HD5 file
%
% [res,info]=readHD5file(filename)
%
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
%% Output parameters
%
% res - Struct. A struct with the information read from the file.
%   Groups are "unfolded" into separate fields.
%
% info - Struct.  A struct with the meta-data read from the file.
%   This is analogous to calling;
%       info = h5info(filename)
%
%
%
% Copyright 2023-24
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.snirf.snirf
%


%% Log
%
% 19-May-2023: FOE
%   File created.
%
% 4-Mar-2024: FOE
%   Bug fixed. Reading the transposed matrix (See remark above).
%



% Get the structure
info = h5info(filename);

%Now read the tree in preorder
res = readNode(info,'',filename);


end



function [resNode]=readNode(structNodeInfo,structNodeName,filename)
%Reads an array of datasets


    %Each node has at least 3 elements;
    % - Name
    % - Datasets - These can be read directly using h5read. Each dataset
    %       becomes a field of the structure
    % - Groups - These cannot be read directly, so they become new
    %       nodes to traverse.
    
    resNode = struct();
    %Read datasets
    nDatasets = length(structNodeInfo.Datasets);
    for iSet = 1:nDatasets
        tmpName = [structNodeName '/' structNodeInfo.Datasets(iSet).Name];
        %disp(structNodeInfo.Datasets(iSet).Name)
        tmp = h5read(filename,tmpName);
        if isnumeric(tmp)
            tmp=tmp'; %See note above.
        end
        resNode.(structNodeInfo.Datasets(iSet).Name) = tmp;
    end
    
    
    %Read groups
    nGroups = length(structNodeInfo.Groups);
    for iGroup = 1:nGroups
        tmpName = structNodeInfo.Groups(iGroup).Name;
        %disp(tmpName)
        tmp = readNode(structNodeInfo.Groups(iGroup),tmpName,filename);
        %Parse the group name
        idx = find(tmpName == '/',1,'last');
        if ~isempty(idx)
            tmpName = tmpName(idx+1:end);
        end
        %disp(['** ' tmpName])
        resNode.(tmpName) = tmp;
    end


end


