function display(obj)
%ROI/DISPLAY Command window display of an object
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also roi
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(obj.id)]);
disp(['   name: ' obj.name]);
disp(['   Subregions: ' num2str(getNSubregions(obj))])
for ss=1:getNSubregions(obj)
    disp(mat2str(obj.subregions{ss}));
end
disp(' ');
