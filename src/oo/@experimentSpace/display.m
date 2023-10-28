function display(obj)
%EXPERIMENTSPACE/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also experimentSpace
%


%% Log
%
% File created: 27-Apr-2008
% File last modified (before creation of this log): 10-Jul-2012
%
% 7-Jun-2023: FOE
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
disp(['   ID: ' num2str(obj.id)]);
disp(['   Name: ' obj.name]);
disp(['   Description: ' obj.description]);
if (obj.runStatus)
    disp('   Computed status?: READY');
else
    disp('   Computed status?: NOT COMPUTED');
end 
disp(['   Block Splitting [baseline samples, max. rest samples]: ' ...
      '[' num2str(obj.baselineSamples) ', ' ...
          num2str(obj.restSamples) ']' ]);
if (obj.resampled)
    disp(['   Resampling [Baseline, Task, Rest]: ' ...
          '[' num2str(obj.rs_baseline) ', ' ...
              num2str(obj.rs_task) ', ' ...
              num2str(obj.rs_rest) ']' ]);
end 
if (obj.averaged)
    disp('   Averaged across blocks: TRUE');
end 
disp(['   Window selection [window onset, duration, break delay]: ' ...
      '[' num2str(obj.ws_onset) ', ' ...
          num2str(obj.ws_duration) ', ' ...
          num2str(obj.ws_breakDelay) ']' ]);
if (obj.normalized)
    disp(['   Normalized [Method, Scope, Dimension]: ' ...
          '[' obj.normalizationMethod ', '...
              obj.normalizationScope ', ' ...
              obj.normalizationDimension ']']);
    switch (obj.normalizationMethod)
        case 'normal'
            disp(['       [Mean, Variance]: ' ...
                  '[' num2str(obj.normalizationMean) ', ' ...
                      num2str(obj.normalizationVar) ']' ]);                         
        case 'range'
            disp(['       [Min, Max]: ' ...
                  '[' num2str(obj.normalizationMin) ', ' ...
                      num2str(obj.normalizationMax) ']' ]);                         
    end
end 
disp(['   Num. Points: ' num2str(length(obj.Fvectors))]);
disp('   Session Names: ');
sessNames=obj.sessionNames;
nSessions=length(sessNames);
if nSessions==0
    disp('      Sessions not yet defined.');
else
    for ss=1:nSessions
        disp(['      Sess. ' num2str(sessNames(ss).sessID) ...
            ': ' sessNames(ss).name]);
    end
end

disp(' ');


end
