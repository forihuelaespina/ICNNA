function [element,exitStatus]=guiSubject(element)
%guiSubject GUI for creating or updating subjects
%
% s=guiSubject() displays a graphical user interface (GUI) for
%   creating a new subject with the default ID. The function
%   returns the new subject, or empty value
%   if the action is cancelled or the window close without saving.
%
% s=guiSubject(s) displays a graphical user interface (GUI) for
%   updating the subject s. The function returns the updated
%   subject, or the unchanged subject if the action is cancelled
%   or the window closed without saving.
%
% [s,exitStatus]=guiSubject(...) exitStatus keep a record of
%   whether the subject has been saved at some point. This is
%   convenient to distinguish when the action has been
%   cancelled or not, since for instance
%   s=guiSubject(s) followed by cancel will return the same
%   object as s=guiSubject(s) followed by saved and close if
%   no modification is made to the object.
%   ExitStatus is 0 if the subject
%   has not been saved at any moment, or 1 if
%   the subject has been saved at some point regardless of
%   whether it has been modified or not.
%   
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also guiICNA, subject
%

%% Log
%
%
% File created: 23-Apr-2008
% File last modified (before creation of this log): 30-Jan-2012
%
% 24-May-2023: FOE
%   + Added this log.
%   + Got rid of old labels @date and @modified.
%   + I have now addressed the long standing issue with accessing
%   the icons folder when the working directory is not that of ICNNA
%   using function mfilename. 
%   + Started to update the get/set methods calls to struct like syntax
%


exitStatus=0;


%% Initialize the figure
%...and hide the GUI as it is being constructed
width=600;
height=420;
f=figure('Visible','off','Position',[100,150,width,height]);
set(f,'NumberTitle','off');
set(f,'MenuBar','none'); %Hide MATLAB figure menu
set(f,'CloseRequestFcn',{@OnClose_Callback});

%% Add components
%Menus
menuFile = uimenu('Label','Subject',...
    'Tag','menuFile');
    uimenu(menuFile,'Label','Save',...
        'Tag','OptSave',...
        'Callback',{@OnSaveElement_Callback},... 
        'Accelerator','S');
    uimenu(menuFile,'Label','Save And Close',...
        'Tag','OptSaveAndClose',...
        'Callback',{@OnSaveAndClose_Callback},... 
        'Accelerator','C');
    uimenu(menuFile,'Label','Quit',...
        'Tag','OptQuit',...
        'Callback',{@OnClose_Callback},... 
        'Accelerator','Q');
menuSession = uimenu('Label','Session',...
    'Tag','menuSession');
    uimenu(menuSession,'Label','Add Session',...
        'Tag','OptAddSession',...
        'Separator','on',...
        'Callback',{@OptAddSession_Callback});
    uimenu(menuSession,'Label','Update Session',...
        'Tag','OptUpdateSession',...
        'Callback',{@OptUpdateSession_Callback});
    uimenu(menuSession,'Label','Remove Session',...
        'Tag','OptRemoveSession',...
        'Callback',{@OptRemoveSession_Callback});
    uimenu(menuSession,'Label','Import Session (fOSA)',...
        'Tag','OptImportfOSAfile',...
        'Callback',{@ImportfOSAfile_Callback});
menuTools = uimenu('Label','Tools',...
    'Tag','menuTools');
    uimenu(menuTools,'Label','Check integrity...',...
        'Tag','OptCheckIntegrity',...
        'Callback',{@OptCheckIntegrity_Callback});


%Toolbars
toolbar = uitoolbar(f,'Tag','toolbar');
[localDir,~,~] = fileparts(mfilename('fullpath'));
iconsFolder=[localDir filesep 'icons' filesep];
tempIcon=load([iconsFolder 'addSession.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_AddSession',...
        'Separator','on','TooltipString','Add a new Session',...
        'ClickedCallback',{@OptAddSession_Callback});
tempIcon=load([iconsFolder 'updateSession.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_UpdateSession',...
        'TooltipString','Updates Session Information',...
        'ClickedCallback',{@OptUpdateSession_Callback});
tempIcon=load([iconsFolder 'removeSession.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_RemoveSession',...
        'TooltipString','Removes a Session',...
        'ClickedCallback',{@OptRemoveSession_Callback});
tempIcon=load([iconsFolder 'importfOSAfile.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_ImportfOSAfile',...
        'TooltipString','Import data from fOSA',...
        'ClickedCallback',{@ImportfOSAfile_Callback});
tempIcon=load([iconsFolder 'checkIntegrity.mat']);
    uipushtool(toolbar,'CData',tempIcon.cdata,...
        'Tag','toolbarButton_CheckIntegrity',...
        'Separator','on',...
        'TooltipString','Check integrity of active data',...
        'ClickedCallback',{@OptCheckIntegrity_Callback});


fontSize=16;
bgColor=get(f,'Color');
uicontrol(f,'Style', 'text',...
       'String', 'ID:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.9 0.2 0.08]);
uicontrol(f,'Style', 'edit',...
       'Tag','idEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdateElement_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.9 0.1 0.08]);
uicontrol(f,'Style', 'text',...
       'String', 'Name:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.35 0.9 0.2 0.08]);
uicontrol(f,'Style', 'edit',...
       'Tag','nameEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdateElement_Callback},...
       'Units','normalize',...
       'Position', [0.56 0.9 0.4 0.08]);
uicontrol(f,'Style', 'text',...
       'String', 'Age:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.8 0.2 0.08]);
uicontrol(f,'Style', 'edit',...
       'Tag','ageEditBox',...
       'BackgroundColor','w',...
       'FontSize',fontSize,...
       'HorizontalAlignment','left',...
       'Callback',{@OnUpdateElement_Callback},...
       'Units','normalize',...
       'Position', [0.22 0.8 0.5 0.08]);

sexPanel = uipanel(f,'Title','Sex',...
        'BorderType','etchedin',...
		'FontSize',fontSize,...
        'BackgroundColor',get(f,'Color'),...
        'Position',[0.01 0.6 0.35 0.15],...
		'Parent',f);
uicontrol(sexPanel,'Style', 'radiobutton',...
       'String', '(M)ale',...
       'Tag','maleSexRButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-4,...
       'HorizontalAlignment','right',...
       'Min',0,'Max',1,'Value',1,...
       'Units','normalize',...
       'Position', [0.1 0.1 0.45 0.9],...
       'Callback',{@maleSexRButton_Callback});
uicontrol(sexPanel,'Style', 'radiobutton',...
       'String', '(F)emale',...
       'Tag','femaleSexRButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-4,...
       'HorizontalAlignment','right',...
       'Min',0,'Max',1,'Value',0,...
       'Units','normalize',...
       'Position', [0.5 0.1 0.45 0.9],...
       'Callback',{@femaleSexRButton_Callback});

handPanel = uipanel(f,'Title','Hand',...
        'BorderType','etchedin',...
		'FontSize',fontSize,...
        'BackgroundColor',get(f,'Color'),...
        'Position',[0.4 0.6 0.55 0.15],...
		'Parent',f);
uicontrol(handPanel,'Style', 'radiobutton',...
       'String', '(R)ight',...
       'Tag','rightHandRButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-4,...
       'HorizontalAlignment','right',...
       'Min',0,'Max',1,'Value',0,...
       'Units','normalize',...
       'Position', [0.05 0.1 0.2 0.9],...
       'Callback',{@rightHandRButton_Callback});
uicontrol(handPanel,'Style', 'radiobutton',...
       'String', '(L)eft',...
       'Tag','leftHandRButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-4,...
       'HorizontalAlignment','right',...
       'Min',0,'Max',1,'Value',1,...
       'Units','normalize',...
       'Position', [0.3 0.1 0.2 0.9],...
       'Callback',{@leftHandRButton_Callback});
uicontrol(handPanel,'Style', 'radiobutton',...
       'String', '(A)mbidextrous',...
       'Tag','ambidextrousHandRButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize-4,...
       'HorizontalAlignment','right',...
       'Min',0,'Max',1,'Value',0,...
       'Units','normalize',...
       'Position', [0.55 0.1 0.4 0.9],...
       'Callback',{@ambidextrousHandRButton_Callback});



uicontrol(f,'Style', 'text',...
       'String', 'Sessions:',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.01 0.5 0.2 0.08]);
colNames = {'Name','Date','NDataSources'};
uitable(f,...
        'Tag','sessionsTable',...
        'Enable','Inactive',...
        'FontSize',fontSize,...
        'ColumnName',colNames,... 
        'Units','normalize',...
        'Position',[0.05 0.18 0.9 0.3]);
    
uicontrol(f,'Style', 'pushbutton',...
       'String', 'Save',...
       'Tag','saveButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.3 0.05 0.18 0.08],...
       'Callback',{@OnSaveElement_Callback});

uicontrol(f,'Style', 'pushbutton',...
       'String', 'Save and Close',...
       'Tag','saveAndCloseButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.5 0.05 0.28 0.08],...
       'Callback',{@OnSaveAndClose_Callback});

uicontrol(f,'Style', 'pushbutton',...
       'String', 'Cancel',...
       'Tag','cancelButton',...
       'BackgroundColor',bgColor,...
       'FontSize',fontSize,...
       'HorizontalAlignment','right',...
       'Units','normalize',...
       'Position', [0.8 0.05 0.18 0.08],...
       'Callback',{@OnClose_Callback});
   

%% On Opening
handles = guihandles(f); %NOTE that only include those whose 'Tag' are not empty

if (exist('element','var'))
    handles.currentElement.data=element;
    handles.currentElement.saved=true;
else %Create a new one
    handles.currentElement.data=subject;
    handles.currentElement.saved=false;
    element=[];
end
guidata(f,handles);
myRedraw(f);

 
%% Make GUI visible
if (isempty(element))
    set(f,'Name','ICNA - Add Subject');
else
    set(f,'Name','ICNA - Update Subject');
end
set(f,'Visible','on');
waitfor(f);


%% maleSexRButton Callback
function maleSexRButton_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
set(handles.maleSexRButton,'Value',1);
set(handles.femaleSexRButton,'Value',0);
handles.currentElement.data=set(handles.currentElement.data,'Sex','M');
handles.currentElement.saved=false;
guidata(f,handles);


end

%% femaleSexRButton Callback
function femaleSexRButton_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
set(handles.maleSexRButton,'Value',0);
set(handles.femaleSexRButton,'Value',1);
handles.currentElement.data=set(handles.currentElement.data,'Sex','F');
handles.currentElement.saved=false;
guidata(f,handles);

end

%% leftHandRButton Callback
function leftHandRButton_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
set(handles.leftHandRButton,'Value',1);
set(handles.rightHandRButton,'Value',0);
set(handles.ambidextrousHandRButton,'Value',0);
handles.currentElement.data=set(handles.currentElement.data,'Hand','L');
handles.currentElement.saved=false;
guidata(f,handles);

end

%% rightHandRButton Callback
function rightHandRButton_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
set(handles.leftHandRButton,'Value',0);
set(handles.rightHandRButton,'Value',1);
set(handles.ambidextrousHandRButton,'Value',0);
handles.currentElement.data=set(handles.currentElement.data,'Hand','R');
handles.currentElement.saved=false;
guidata(f,handles);

end

%% ambidextrousHandRButton Callback
function ambidextrousHandRButton_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.

handles=guidata(hObject);
set(handles.leftHandRButton,'Value',0);
set(handles.rightHandRButton,'Value',0);
set(handles.ambidextrousHandRButton,'Value',1);
handles.currentElement.data=set(handles.currentElement.data,'Hand','A');
handles.currentElement.saved=false;
guidata(f,handles);

end



%% OptAddSession callback
%Opens the window for adding a new session to the subject
function OptAddSession_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no subject currently opened.',...
        'guiSubject','modal');
else
    
    existingElements=getSessionList(handles.currentElement.data);
    if (isempty(existingElements))
        newId=1;
    else
        newId=max(existingElements)+1;
    end
    sdef=sessionDefinition(newId);
    s=session(sdef);

    [s,exitStatus]=guiSession(s);
    if (exitStatus==1)
        handles.currentElement.data=addSession(handles.currentElement.data,s);
        handles.currentElement.saved=false;
        guidata(hObject,handles);
    end
end
myRedraw(hObject);
end

%% OptUpdateSession callback
%Opens the window for update a session information
function OptUpdateSession_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no subject currently opened.',...
        'guiSubject','modal');
else
    options.Resize='off';
    options.WindowStyle='modal';
    while 1 %Get a valid (existing or new) id, or cancel action
        answer = inputdlg('Session ID:','Update which session?',...
                          1,{''},options);
        if (isempty(answer)) %Action cancelled
            break;
        else
            tmpID=str2double(answer{1});
            if (isscalar(tmpID) && isreal(tmpID) ...
                && (tmpID == floor(tmpID)))
                break;
            end
        end
    end
            
    if (~isempty(answer))
        elemID=str2double(answer{1});
        existingElements=getSessionList(handles.currentElement.data);
        if (ismember(elemID,existingElements))
            s=getSession(handles.currentElement.data,elemID);
        else           
            button = questdlg(['Session ID not found. ' ...
                'Would you like to create a new session ' ...
                'with the given ID?'],'Create New Session',...
                'Yes','No','No');
            switch(button)
                case 'Yes'
                    %Note that the session will be created, even
                    %if the user click the cancel button on the
                    %guiSession!!
                    s=session(elemID);
                    handles.currentElement.data=...
                        addSession(handles.currentElement.data,s);
                    handles.currentElement.saved=false;
                    guidata(hObject,handles);
                    myRedraw(hObject);
                case 'No'
                    return
            end
        end
        
        %Now update
        [s,exitStatus]=guiSession(s);
        if (exitStatus==1)
            handles.currentElement.data=...
                setSession(handles.currentElement.data,...
                            elemID,s);
            handles.currentElement.saved=false;
            guidata(hObject,handles);
        end
        myRedraw(hObject);
    end
end
end

%% OptRemoveSession callback
%Opens the window for eliminating a session from the subject
function OptRemoveSession_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
if (isempty(handles.currentElement.data))
    warndlg('There''s no subject currently opened.',...
        'Remove Session','modal');
else
    options.Resize='off';
    options.WindowStyle='modal';
    answer = inputdlg('Session ID:','Remove session?',1,{''},options);
    if (isempty(answer)) %Cancel button pressed
    else
        answer=str2double(answer);
        if (~isnan(answer))
            ss=getSession(handles.currentElement.data,answer);
            if (~isempty(ss))
                s=removeSession(handles.currentElement.data,answer);
                handles.currentElement.data=s;
                handles.currentElement.saved=false;
                guidata(hObject,handles);
            else
                warndlg('Session not found','Remove Session','modal');
            end
        else
            warndlg('Session ID not recognised','Remove Session','modal');
        end
    end
end
myRedraw(hObject);
end

%% OptCheckIntegrity callback
%List the available integrity tests and checks the integrity appropriately
function OptCheckIntegrity_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
handles.currentElement.data=guiCheckIntegrity(handles.currentElement.data);
handles.currentElement.saved=false;
guidata(hObject,handles);
end

%% ImportfOSAfile Callback
%Import fOSA data file
function ImportfOSAfile_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);

%First select the file
[FileName,PathName] = uigetfile('*.mat','WindowStyle');
if isequal(FileName,0)
    %disp('Operation ''Import fOSA data'' cancelled')
else

    importData=true;
    button=questdlg(['A new session will be created for this subject. ' ...
        'The subject name will be updated. ' ...
        'Would you like to proceed?'],'Import fOSA data', ...
        'Yes','Cancel','Cancel');
    switch (button)
        case 'Yes'
            importData=true;
        case 'Cancel'
            importData=false;
    end

    if (importData)
        s=importfOSAfile(handles.currentElement.data,[PathName FileName]);
        set(s,'ID',get(handles.currentElement.data,'ID'));
        handles.currentElement.data=s;
        handles.currentElement.saved=false;
        guidata(hObject,handles);
        myRedraw(hObject);
    end
end

end

%% OnClose callback
%On Closing this window. Check whether data needs saving
function OnClose_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
closeWindow=true;
if (~handles.currentElement.saved)
    element=[];
    %Offer the possibility of saving
    button = questdlg(['Current data is not saved. ' ...
        'Would you like to save the latest changes before ' ...
        'closing it?'],...
        'Close window','Save','Close','Cancel','Close');
    switch (button)
        case 'Save'
            OnSaveElement_Callback(hObject,eventData);
            closeWindow=true;
        case 'Close'
            closeWindow=true;
        case 'Cancel'
            closeWindow=false;
    end
end
 
if (closeWindow)
    clear handles.currentElement.data    
    delete(get(gcf,'Children'));
    delete(gcf);
    %close(gcf);
end
end

%% OnSaveElement Callback
%Save the changes to the element
function OnSaveElement_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
OnUpdateElement_Callback(hObject,eventData)
handles = guidata(f);
element=handles.currentElement.data;
exitStatus=1;
handles.currentElement.saved=true;
guidata(f,handles);
end

%% OnSaveAndClose callback
%On Save and Closing this window
function OnSaveAndClose_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
OnSaveElement_Callback(hObject,eventData);
OnClose_Callback(hObject,eventData);
end

%% OnUpdateElement callback
%Updates the current element with new information
function OnUpdateElement_Callback(hObject,eventData)
% hObject - Handle of the object, e.g., the GUI component,
%   for which the callback was triggered.  See GCBO
% eventdata - Reserved for later use.
handles=guidata(hObject);
tmpElement=handles.currentElement.data;
tmpId=str2double(get(handles.idEditBox,'String'));
if isnan(tmpId)
    warndlg('Invalid ID.','Update subject');
    set(handles.idEditBox,'String',tmpElement.id);
else
    if (isreal(tmpId) && ~ischar(tmpId) && isscalar(tmpId) ...
            && floor(tmpId)==tmpId && tmpId>0)
        tmpElement=set(tmpElement,'ID',tmpId);
    else
        warndlg('Invalid ID','Update Subject');
    end
end

tmpElement=set(tmpElement,'Name',get(handles.nameEditBox,'String'));

if (~isempty(get(handles.ageEditBox,'String')))
    n=str2double(get(handles.ageEditBox,'String'));
    if (isnan(n))
        warndlg('Invalid age','Update Subject');
    else
        tmpElement=set(tmpElement,'Age',n);
    end
else
    tmpElement=set(tmpElement,'Age',0);    
end
handles.currentElement.data=tmpElement;
handles.currentElement.saved=false;
guidata(hObject,handles);
end



end

%% AUXILIAR FUNCTIONS
function myRedraw(hObject)
%So that the GUI keeps it information up to date, easily
% hObject - Handle of the object, e.g., the GUI component,
handles=guidata(hObject);

    set(handles.maleSexRButton,'Value',0);
    set(handles.femaleSexRButton,'Value',0);

    set(handles.leftHandRButton,'Value',0);
    set(handles.rightHandRButton,'Value',0);
    set(handles.ambidextrousHandRButton,'Value',0);

if (isempty(handles.currentElement.data)) %Clear
    set(handles.idEditBox,'String','');
    set(handles.nameEditBox,'String','');
    set(handles.ageEditBox,'String','');
    set(handles.leftHandRButton,'Value',0);
    set(handles.rightHandRButton,'Value',0);
    set(handles.ambidextrousHandRButton,'Value',0);
    set(handles.sessionsTable,'RowName',[]);
    set(handles.sessionsTable,'Data',[]);

else %Refresh the Information
    s=subject(handles.currentElement.data);
    set(handles.idEditBox,'String',num2str(s.id));
    set(handles.nameEditBox,'String',s.name);
    set(handles.ageEditBox,'String',num2str(s.age));
    sex=s.sex;
    switch (sex)
        case 'M'
            set(handles.maleSexRButton,'Value',1);
        case 'F'
            set(handles.femaleSexRButton,'Value',1);
    end        
    hand=s.hand;
    switch (hand)
        case 'L'
            set(handles.leftHandRButton,'Value',1);
        case 'R'
            set(handles.rightHandRButton,'Value',1);
        case 'A'
            set(handles.ambidextrousHandRButton,'Value',1);
    end

    sessions=getSessionList(s);
    data=cell(s.nSessions,3); %Three columns are currently displayed
                            %Name,Date,NDataSources
    rownames=zeros(1,s.nSessions);
    pos=1;
    for ii=sessions
        sess=getSession(s,ii);
        sessDef = sess.definition;
        rownames(pos)=sessDef.id;
        data(pos,1)={sessDef.name};
        data(pos,2)={sess.date};
        data(pos,3)={sess.nDataSources};
        pos=pos+1;
    end
    set(handles.sessionsTable,'RowName',rownames);
    set(handles.sessionsTable,'Data',data);
end
end
