function obj=importFromClearView(obj,srcFilename)
%IMAGEPARTITION/IMPORTFROMCLEARVIEW Imports a partition from a ClearView file
%
% obj=importFromClearView(obj,srcDir) Imports the ROIs of an Image
%   Partition from a ClearView AOIs file.
%
%If the image partition already held any ROI the new ones
%will be merged with the existing ones. If you want to remove
%existing ROIs prior to importing then use method clear.
%
%Currently this function assumes that the ROIs are defined in the
%same order that they are declared. In other words, ROIs declared
%later are considered on top of ROIs defined earlier.
%
%% Parameters
%
% srcFilename - The source file containing all the ROIs names and vertex
%       coordinates.
%           FILE FORMAT: The Clear View file format for exporting an
%               image partition is simple. Each line represent a polygon
%               preceded by the ROIs name. If a ROI is composed of more
%               than one subregions, it has as many lines as needed, but
%               they still are preceded by the ROIs names.
%
% 
% Copyright 2008-9
% date: 22-Dec-2008
% Author: Felipe Orihuela-Espina
%
% See also eyeTrack, imagePartition, roi, clear
%

%Deal with options
opt.verbose=true;


fidr=fopen(srcFilename);
if fidr==1
    error('ICAF:imagePartition:importFromClearView','Unable to read file.');
end


tmpRoisNames=cell(1,0);

id=1;
fileline=1; %For tracking errors/warnings only
while ~feof(fidr)
    %Read roiName
    roiName='';
    c=fscanf(fidr,'%c',1);
    c2=double(c);
    while c2~=9 %char 9 is the \t
        roiName=[roiName c];
        c=fscanf(fidr,'%c',1);
        c2=double(c);
    end
    
    roiVertexes=fscanf(fidr,'%d,%d',Inf);
    roiVertexes=reshape(roiVertexes,2,numel(roiVertexes)/2)';

    idx=findROI(obj,roiName);
    if isempty(idx)
        %Create a new ROI
        rr=roi(id,roiName);
        rr=addSubregion(rr,roiVertexes);
        obj=addROI(obj,rr);
        id=id+1;
    elseif length(idx)==1
        %Add a new subregion/polygon to the existing ROI
        tmpID=get(getROI(obj,idx),'ID');
        rr=roi(tmpID,roiName);
        rr=addSubregion(rr,roiVertexes);
        obj=addROI(obj,rr,1); %Merge with existing region
    else %if length(idx)>1
        warning('ICAF:imagePartition:importFromClearView',...
            ['Ambiguous name conflict. ' ...
             'Skipping region ' roiName ' at line ' fileline '.']);
    end
    
    fileline=fileline+1;
end
fclose(fidr);




