function display(obj)
%NEUROIMAGE/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also neuroimage
%


%% Log
%
%
% File created: 27-Apr-2008
% File last modified (before creation of this log): 22-Dec-2012
%
% 20-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(obj.id)]);
disp(['   Description: ' obj.description]);
disp(['   Num. Samples: ' num2str(obj.nSamples)]);
disp(['   Num. Channels: ' num2str(obj.nChannels)]);
disp(['   Num. Signals: ' num2str(obj.nSignals)]);
disp('   Timeline: ');
display(obj.timeline);
disp(' ');
disp('   Integrity: ');
disp(['     ' mat2str(double(obj.integrity))]);
disp(' ');
disp('   Channel Location Map: ');
display(obj.chLocationMap);
disp(' ');


end
