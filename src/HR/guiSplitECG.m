function guiSplitECG(elem)
%A GUI for splitting an ecg/dataSource into blocks according to a ETG-4000 NIRS session
%
% guiSplitECG(elem)
%
%% Parameters:
%
% elem - An ecg object or a dataSource (with an active ecg/structuredData)
%
%
% Copyright 2010
% @date: 21-Jul-2010
% @author Felipe Orihuela-Espina
% @modified: 27-Nov-2010
%
% See also rawData_BioHarnessECG, ecg, dataSource, rawData_ETG4000,
%   guiHR
%


if (isa(elem,'dataSource'))
    elem = getStructuredData(elem,get(elem,'ActiveStructured'));
end
if (~isa(elem,'ecg'))
    error('ICAF:guiSplitECG:InvalidInputParameter',...
          'Unexpected input elem.');
end


%% Initialize the figure
%...and hide the GUI as it is being constructed
screenSize=get(0,'ScreenSize');
%width=screenSize(3)-round(screenSize(3)/10);
%height=screenSize(4)-round(screenSize(4)/5);
width=800;
height=200;
f=figure('Visible','off',...
         'Position',[1,1,width,height]);
%set(f,'CloseRequestFcn',{@OnQuit_Callback});
movegui(f,'center');
set(f,'NumberTitle','off');
set(f,'MenuBar','none'); %Hide MATLAB figure menu


%% Add components
fontSize=13;
bgColor=get(f,'Color');

uicontrol(f,'Style', 'text',...
       'String', 'Output filenames prefix:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.77 0.25 0.15]);
uicontrol(f,'Style', 'edit',...
       'Tag','outputFilenameEditBox',...
       'String','ECG0001',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.28 0.77 0.5 0.15]);

uicontrol(f,'Style', 'text',...
       'String', 'Reference fNIRS file (ETG-4000):',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.52 0.25 0.15]);
uicontrol(f,'Style', 'edit',...
       'Tag','nirsFilenameEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Units','normalize',...
       'Position', [0.28 0.52 0.5 0.15]);
uicontrol(f,'Style', 'pushbutton',...
       'String', 'Browse...',...
       'Tag','nirsBrowseButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Position', [0.82 0.52 0.15 0.15],...
       'Callback',{@OnNIRSBrowse_Callback});
uicontrol(f,'Style', 'text',...
       'String', ['The split tool assumes block experiment design. ' ...
                  'Event related design not currently supported.'],...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Position', [0.05 0.27 0.9 0.15]);
   
uicontrol(f,'Style', 'pushbutton',...
       'String', 'Split',...
       'Tag','splitButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Enable','on',...
       'Position', [0.58 0.02 0.18 0.2],...
       'Callback',{@OnSplit_Callback});
uicontrol(f,'Style', 'pushbutton',...
       'String', 'Close',...
       'Tag','closeButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','center',...
       'Units','normalize',...
       'Position', [0.78 0.02 0.18 0.2],...
       'Callback',{@OnQuit_Callback});
   
   
%% On Opening
handles = guihandles(f); %NOTE that only include those whose 'Tag' are not empty


guidata(f,handles);


%% Make GUI visible
set(f,'Name','guiSplitECG');
set(f,'Visible','on');
waitfor(f);

%% OnNIRSBrowse callback
%Browse for the file of the fNIRS session
function OnNIRSBrowse_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

[FileName,PathName] = uigetfile('*.csv','WindowStyle');
if isequal(FileName,0)
    %disp('Operation ''Open fNIRS'' cancelled')
else
    %Do not open the file yet. Just store the name.
    handles=guidata(hObject);
    set(handles.nirsFilenameEditBox,'String',[PathName FileName]);
    guidata(hObject,handles);
end
end



%% OnSplit callback
%Ask for a destination folder and splits the ecg in blocks
function OnSplit_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);

%filename = 'LGCMC0002a'; %only for testing
filename = get(handles.outputFilenameEditBox,'String');

directory_name = uigetdir('','Select destination folder');
%directory_name='./data'; %Only for quick testing
if directory_name~=0
    directory_name(find(directory_name=='\'))='/';
    directory_name=[directory_name '/'];
    
    rawNIRSfilename=get(handles.nirsFilenameEditBox,'String');
    
    [baseECG,blocksECGs,lastECG]=...
                    splitECGbyRawNIRS(elem,rawNIRSfilename);
    theData = baseECG;
    save([directory_name filename '_ECG_first20secs.mat'],'theData');
    clear theData baseECG
    
    for ii=1:length(blocksECGs)
        theData = blocksECGs(ii).taskecg;
        save([directory_name filename ...
            '_ECG_Stim' blocksECGs(ii).stim ...
            '_Block' num2str(blocksECGs(ii).block) '.mat'],...
            'theData');
        clear theData
    end
    clear blocksECGs
    
    theData = lastECG;
    save([directory_name filename '_ECG_last20secs.mat'],'theData');
    clear theData lastECG
    
    
    
%     r = rawData_ETG4000;
%     try
%         %Read the fNIRS file
%         r = import(r,get(handles.nirsFilenameEditBox,'String'));
%         %r = import(r,'./data/LGCMC0002a_MES_Probe1.csv'); %for testing only
%     catch ME
%         warndlg([ME.identifier ': ' ME.message ...
%             'Unable to read ETG-4000 fNIRS file.'],'ICAF:guiSplitECG');
%         return;
%     end
%     
%     startTime = datenum(get(r,'Date'));
%     timestamps = get(r,'Timestamps');
%     tmpTimes=sec2datevec(timestamps);    
%     
%     %Step 1: Crop the ECG data corresponding to the fNIRS session time
%     initTime = startTime + datenum(tmpTimes(:,1)');
%     endTime = startTime + datenum(tmpTimes(:,end)');
%     cropped_elem = cropECG(elem,initTime,endTime);
%     
%     %Step 2: Save cropped ECG data to a .csv file
%     %ecg2csv(cropped_elem,[directory_name filename '_ECG_cropped.csv']);
%     %rawData = rawData_BioHarnessECG;
%     %rawData=import(rawData,[directory_name filename '_ECG_cropped.csv']);
% 
%     %Step 3: Extract "pre" block (very first 20 seconds)
%     sr=get(cropped_elem,'SamplingRate');
%     intervalSamples = 20 * sr;
%     tmp_elem = crop(cropped_elem,1,intervalSamples);
%     theData = dataSource;
%     if exist('rawData','var')
%         theData = setRawData(theData,rawData);
%     else
%         theData = unlock(theData);
%     end
%     theData = addStructuredData(theData,tmp_elem);
%     save([directory_name filename '_ECG_first20secs.mat'],'theData');
%     clear theData
% 
%     %Step 4: Extract block timings
%     %(assumes block design - no event related design)
%     marks = get(r,'Marks');
%     nStim = max(marks);
%     for ss=1:nStim
%         idx = find(marks == ss);
%         partition = reshape(idx,2,numel(idx)/2)';
%         nBlocks = size(partition,1);
%         
%         for bb=1:nBlocks
%             initTime = startTime + datenum(tmpTimes(:,partition(bb,1))');
%             endTime = startTime + datenum(tmpTimes(:,partition(bb,2))');
%             
%             tmp_elem = cropECG(cropped_elem,initTime,endTime);
%             
%             theData = dataSource;
%             if exist('rawData','var')
%                 theData = setRawData(theData,rawData);
%             else
%                 theData = unlock(theData);
%             end
%             theData = addStructuredData(theData,tmp_elem);
%             save([directory_name filename ...
%                     '_ECG_Stim' char(ss+64) ...
%                     '_Block' num2str(bb) '.mat'],...
%                 'theData');
%             clear theData
% %%%%%ONLY FOR TESTING
% %             if bb==1
% %             ecg2csv(tmp_elem,[directory_name filename ...
% %                     '_ECG_cropped_Stim' char(ss+64) ...
% %                     '_Block' num2str(bb) '.csv']);
% %             end
% %%%%%%%%%%%%%%%%%%%%%%%%%%
%         end %Blocks
%     end %Stim
%     
%     %Step 5: Extract "post" block (very last 20 seconds)
%     totalSamples=get(cropped_elem,'NSamples');
%     tmp_elem = crop(cropped_elem,...
%                     totalSamples-intervalSamples,totalSamples);
%     theData = dataSource;
%     if exist('rawData','var')
%         theData = setRawData(theData,rawData);
%     else
%         theData = unlock(theData);
%     end
%     theData = addStructuredData(theData,tmp_elem);
%     save([directory_name filename '_ECG_last20secs.mat'],'theData');
%     clear theData

    msgbox('Done!');
end

end


%% OnQuit callback
%Clear memory and exit the application
function OnQuit_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
delete(get(gcf,'Children'));
delete(gcf);
end

end

