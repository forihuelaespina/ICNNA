function exportToTxt(obj,filename)
%IMAGEPARTITION/EXPORTTOTXT Exports the image partition to a text file
%
% exportToTxt(obj,filename) Exports the image partition to
%       the selected file.
%
%% Parameters:
%
% filename - The destination file. If the file exists it will be
%   overwritten.
%
% 
% Copyright 2009
% date: 1-Jul-2009
% Author: Felipe Orihuela-Espina
%
% See also eyeTrack, imagePartition, roi, clear, importFromClearView
%

if ispc
    fidr=fopen(filename,'wt');
else
    fidr=fopen(filename,'w');
end

if fidr==-1
    error('ICAF:imagePartition:exportToFile','Unable to open file.');
end

roiList=getROIList(obj);
for rrId=roiList
    rr=getROI(obj,rrId);
    for kk=1:getNSubregions(rr)
        polygon=getSubregion(rr,kk);
        count = fprintf(fidr,'%s', get(rr,'Name'));
        count = fprintf(fidr, [char(9) '%i,%i'], ...
                        polygon');%char 9 is the \t
        count = fprintf(fidr,'\n');
    end
end

fclose(fidr);
