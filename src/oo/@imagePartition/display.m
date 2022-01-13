function display(obj)
%IMAGEPARTITION/DISPLAY Command window display of an imagePartition
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also imagePartition
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(get(obj,'ID'))]);
disp(['   Name: ' get(obj,'Name')]);
disp(['   Size [Width Height]: ' ...
        mat2str(get(obj,'Size')) ' pixels']);
disp(['   Screen Resolution [Width Height]: ' ...
        mat2str(get(obj,'ScreenResolution')) ' pixels']);
tmp=get(obj,'AssociatedFile');
if ~isempty(tmp)
    disp(['   Associated File: ' tmp]);
end
disp(['   roi: ' num2str(getNROIs(obj))]);
idList=getROIList(obj);
for ii=idList
    ssd = getROI(obj,ii);
    name = get(ssd,'Name');
    disp(['      *' num2str(ii) ': ' name]);
end
disp(' ');
