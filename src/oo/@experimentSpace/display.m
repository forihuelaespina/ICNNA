function display(obj)
%EXPERIMENTSPACE/DISPLAY Command window display
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2008-12
% @date: 27-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 10-Jul-2012
%
% See also experimentSpace
%

disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(get(obj,'ID'))]);
disp(['   Name: ' get(obj,'Name')]);
disp(['   Description: ' get(obj,'Description')]);
if (get(obj,'RunStatus'))
disp('   Computed status?: READY');
else
disp('   Computed status?: NOT COMPUTED');
end 
disp(['   Block Splitting [baseline samples, max. rest samples]: ' ...
      '[' num2str(get(obj,'BaselineSamples')) ', ' ...
          num2str(get(obj,'RestSamples')) ']' ]);
if (get(obj,'Resampled'))
    disp(['   Resampling [Baseline, Task, Rest]: ' ...
          '[' num2str(get(obj,'RS_Baseline')) ', ' ...
              num2str(get(obj,'RS_Task')) ', ' ...
              num2str(get(obj,'RS_Rest')) ']' ]);
end 
if (get(obj,'Averaged'))
    disp('   Averaged across blocks: TRUE');
end 
disp(['   Window selection [window onset, duration, break delay]: ' ...
      '[' num2str(get(obj,'WS_Onset')) ', ' ...
          num2str(get(obj,'WS_Duration')) ', ' ...
          num2str(get(obj,'WS_BreakDelay')) ']' ]);
if (get(obj,'Normalized'))
    disp(['   Normalized [Method, Scope, Dimension]: ' ...
          '[' get(obj,'NormalizationMethod') ', '...
              get(obj,'NormalizationScope') ', ' ...
              get(obj,'NormalizationDimension') ']']);
    switch (get(obj,'NormalizationMethod'))
        case 'normal'
            disp(['       [Mean, Variance]: ' ...
                  '[' num2str(get(obj,'NormalizationMean')) ', ' ...
                      num2str(get(obj,'NormalizationVar')) ']' ]);                         
        case 'range'
            disp(['       [Min, Max]: ' ...
                  '[' num2str(get(obj,'NormalizationMin')) ', ' ...
                      num2str(get(obj,'NormalizationMax')) ']' ]);                         
    end
end 
disp(['   Num. Points: ' num2str(length(obj.Fvectors))]);
disp('   Session Names: ');
sessNames=get(obj,'SessionNames');
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
