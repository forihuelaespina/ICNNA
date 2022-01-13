function display(obj)
%STRUCTUREDDATA/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008
% @date: 27-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also structuredData
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(obj.id)]);
disp(['   Description: ' obj.description]);
disp(['   Num. Samples: ' num2str(size(obj.data,1))]);
disp(['   Num. Channels: ' num2str(size(obj.data,2))]);
%watch out!! Size will return 1 in the third dimension if data is empty
%see MATLAB's help on size for more info.
if (isempty(obj.data))
    disp('   Num. Signals: 0');
else
    disp(['   Num. Signals: ' num2str(size(obj.data,3))]);
    for tt=1:length(obj.signalTags)
        disp(obj.signalTags{tt});
    end
end
%disp(['   Data: ']);
%disp(obj.data);
disp('   Timeline: ');
t=timeline(obj.timeline);
display(t);
disp('   Integrity: ');
disp(['     ' mat2str(double(obj.integrity))]);
disp(' ');
