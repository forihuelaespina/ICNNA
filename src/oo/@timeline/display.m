function display(obj)
%TIMELINE/DISPLAY Command window display of a timeline
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also timeline
%


%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): 31-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%   + Now also displays new attribute classVersion
%



disp(' ');
disp([inputname(1),'= ']);
disp(' ');
try
    disp(['   Class version: ' num2str(obj.classVersion)]);
catch
    disp('   Class version: N/A');
end
disp(['   Length: ' num2str(obj.length)]);
disp(['   Start time: ' datestr(obj.startTime)]);
tmpTimestamps=obj.timestamps;
if isempty(tmpTimestamps)
    disp('   Timestamps [s]: N/A');
else
    disp('   Timestamps [s]: ');
    %disp(mat2str(get(obj,'Timestamps')));
    disp(['       init: ' num2str(tmpTimestamps(1))]);
    disp(['       end: ' num2str(tmpTimestamps(end))]);
end

disp(['   Nominal Sampling Rate [Hz]: ' ...
        num2str(obj.nominalSamplingRate)]);
disp('   Exclusory State: ');
disp(mat2str(obj.exclusory));
if isempty(obj.conditions)
    disp('   conditions: {}'); 
else
    nConditions=obj.nConditions;
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
