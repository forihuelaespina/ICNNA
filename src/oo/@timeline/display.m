function display(obj)
%TIMELINE/DISPLAY Command window display of a timeline
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008-12
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 31-Dec-2012
%
% See also timeline, get, set
%

disp(' ');
disp([inputname(1),'= ']);
disp(['   Length: ' num2str(get(obj,'Length'))]);
disp(['   Start time: ' datestr(get(obj,'StartTime'))]);
tmpTimestamps=get(obj,'Timestamps');
if isempty(tmpTimestamps)
    disp('   Timestamps [s]: N/A');
else
    disp('   Timestamps [s]: ');
    %disp(mat2str(get(obj,'Timestamps')));
    disp(['       init: ' num2str(tmpTimestamps(1))]);
    disp(['       end: ' num2str(tmpTimestamps(end))]);
end

disp(['   Nominal Sampling Rate [Hz]: ' ...
        num2str(get(obj,'NominalSamplingRate'))]);
disp('   Exclusory State: ');
disp(mat2str(obj.exclusory));
if isempty(obj.conditions)
    disp('   conditions: {}'); 
else
    nConditions=get(obj,'NConditions');
    disp(['   Conditions: ' num2str(nConditions)]); 
    for ii=1:nConditions
        disp(['=== Condition ''' obj.conditions{ii}.tag '''']);
        cevents=obj.conditions{ii}.events;
        ceventsInfo=obj.conditions{ii}.eventsInfo;
        if (isempty(cevents))
            disp('   No events defined for this condition.');
        else
            disp('   [Onsets Durations] - Info');
            nEvents=size(cevents,1);
            for ee=1:nEvents
                eInfo = ceventsInfo{ee};
                if isempty(eInfo)
                    disp(mat2str(cevents(ee,:)));
                elseif isstruct(eInfo)
                    names = fieldnames(eInfo);
                    disp([mat2str(cevents(ee,:)) ' - struct with ' ...
                            num2str(length(names)) ' fields.']);
                elseif iscell(eInfo)
                    disp([mat2str(cevents(ee,:)) ' - cell array ' ...
                            'of size ' mat2str(size(eInfo)) '.']);
                elseif ~ischar(ceventsInfo{ee})
                    disp([mat2str(cevents(ee,:)) ' - ' mat2str(eInfo)]);
                else
                    disp([mat2str(cevents(ee,:)) ' - ' eInfo]);
                end
            end
        end
    end
end
disp(' ');
