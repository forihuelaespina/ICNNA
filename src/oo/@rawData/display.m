function display(obj)
%RAWDATA/DISPLAY Command window display of a rawData
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also rawData, get, set
%


%% Log
%
% File created: 12-May-2008
% File last modified (before creation of this log):  N/A This method had
%   not been updated since creation.
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%   + Now also displays new attribute classVersion
%


disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   id: ' num2str(obj.id)]);
disp(['   description: ' obj.description]);
disp(['   date: ' obj.date]);
disp(' ');


end
