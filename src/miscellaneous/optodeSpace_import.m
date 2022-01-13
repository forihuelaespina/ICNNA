function optodeSpace=optodeSpace_import(filename)
%DEPRECATED Reads the raw ETG-4000 3D optode position as recorded by the polhemus
%
% optodeSpace=optodeSpace_import(filename)
%
%
%% Deprecated
%
% This function has now been deprecated. Use new class channelLocationMap
%and function import_ETG4000_3DChannelPosition instead.
%
%
%% Parameters
%
% filename - The ETG-4000/Polhemus 3D positional data file to import.
%       Likely to have '.pos' file extension
%
%
%% Output
%
% optodeSpace - A struct with the following fields
%       +id
%       +version
%       +productName
%       +probe
%       +type
%       +user
%           +type
%           +id
%           +comment
%           +sex
%           +age
%       +probes - An array of struct
%           +mode
%           +optodeNum - Number of optodes
%           +left ear
%           +right ear
%           +nasion
%           +inion (back)
%           +top
%           +optodeCoords - The actual coordinates.
%           +angle
%
% 
% Copyright 2009-13
% @date: 10-Mar-2009
% @author: Felipe Orihuela-Espina
% @modified: 27-Aug-2013
%
% See also rawData_ETG4000, optodeSpace_plot3
%

% Open the data file for conversion
fidr = fopen(filename,'r');
if fidr == -1
    error('Unable to read %s\n', filename);
end


h = waitbar(0,'Reading header...',...
    'Name','Importing raw data (ETG-4000)');

%% Reading the header ================================
temp=findField(fidr,'FileInfo');
temp=findSubField(fidr,'ID');
optodeSpace.id=temp(find(temp=='=')+1:end); %Ignore fieldName and read the rest
temp=findSubField(fidr,'VER');
optodeSpace.version=temp(find(temp=='=')+1:end);
temp=findSubField(fidr,'ProductName');
optodeSpace.productName=temp(find(temp=='=')+1:end);
temp=findSubField(fidr,'PROBE');
optodeSpace.probe=str2num(temp(find(temp=='=')+1:end));
temp=findSubField(fidr,'TYPE');
optodeSpace.type=str2num(temp(find(temp=='=')+1:end));

temp=findField(fidr,'User');
temp=findSubField(fidr,'Name');
optodeSpace.user.type=temp(find(temp=='=')+1:end);
temp=findSubField(fidr,'ID');
optodeSpace.user.id=temp(find(temp=='=')+1:end);
temp=findSubField(fidr,'Comment');
optodeSpace.user.comment=temp(find(temp=='=')+1:end);
temp=findSubField(fidr,'Sex');
optodeSpace.user.sex=temp(find(temp=='=')+1:end);
temp=findSubField(fidr,'Age');
tempAge=temp(find(temp=='=')+1:end);
optodeSpace.user.age=str2num(tempAge(1:end-2));%Ignore the 'y'


x=0.05;
waitbar(x,h,'Reading Data - 5%');

nProbes = 1;
step=0.95/nProbes;
for pp=1:nProbes
    temp=findField(fidr,['Probe' num2str(pp)]);
    temp=findSubField(fidr,'MODE');
    optodeSpace.probes(pp).mode=str2num(temp(find(temp=='=')+1:end));
    temp=findSubField(fidr,'ChNum');
        %for some reason they call it channel when they refer
        %to optodes.
    optodeSpace.probes(pp).optodeNum=str2num(temp(find(temp=='=')+1:end));

    %Left ear
    temp=findField(fidr,'LeftEar');
    temp=findSubField(fidr,'X');
    optodeSpace.probes(pp).leftear(1)=...
        str2num(temp(find(temp=='=')+1:end));
    temp=findSubField(fidr,'Y');
    optodeSpace.probes(pp).leftear(2)=...
        str2num(temp(find(temp=='=')+1:end));
    temp=findSubField(fidr,'Z');
    optodeSpace.probes(pp).leftear(3)=...
        str2num(temp(find(temp=='=')+1:end));

    %Right ear
    temp=findField(fidr,'RightEar');
    temp=findSubField(fidr,'X');
    optodeSpace.probes(pp).rightear(1)=...
        str2num(temp(find(temp=='=')+1:end));
    temp=findSubField(fidr,'Y');
    optodeSpace.probes(pp).rightear(2)=...
        str2num(temp(find(temp=='=')+1:end));
    temp=findSubField(fidr,'Z');
    optodeSpace.probes(pp).rightear(3)=...
        str2num(temp(find(temp=='=')+1:end));

    %Nasion
    temp=findField(fidr,'Nasion');
    temp=findSubField(fidr,'X');
    optodeSpace.probes(pp).nasion(1)=...
        str2num(temp(find(temp=='=')+1:end));
    temp=findSubField(fidr,'Y');
    optodeSpace.probes(pp).nasion(2)=...
        str2num(temp(find(temp=='=')+1:end));
    temp=findSubField(fidr,'Z');
    optodeSpace.probes(pp).nasion(3)=...
        str2num(temp(find(temp=='=')+1:end));

    %Inion
    temp=findField(fidr,'Back');
    temp=findSubField(fidr,'X');
    optodeSpace.probes(pp).inion(1)=...
        str2num(temp(find(temp=='=')+1:end));
    temp=findSubField(fidr,'Y');
    optodeSpace.probes(pp).inion(2)=...
        str2num(temp(find(temp=='=')+1:end));
    temp=findSubField(fidr,'Z');
    optodeSpace.probes(pp).inion(3)=...
        str2num(temp(find(temp=='=')+1:end));

    %Top
    temp=findField(fidr,'Top');
    temp=findSubField(fidr,'X');
    optodeSpace.probes(pp).top(1)=...
        str2num(temp(find(temp=='=')+1:end));
    temp=findSubField(fidr,'Y');
    optodeSpace.probes(pp).top(2)=...
        str2num(temp(find(temp=='=')+1:end));
    temp=findSubField(fidr,'Z');
    optodeSpace.probes(pp).top(3)=...
        str2num(temp(find(temp=='=')+1:end));

    substep=0.05*step;
    x=x+substep;
    waitbar(x,h,['Reading Data - ' num2str(round(x)) '%']);
    

    nOptodes=optodeSpace.probes(pp).optodeNum;
    substep=(0.95*substep)/nOptodes;
    for oo=1:nOptodes
        temp=findField(fidr,['Probe' num2str(pp) '-ch' num2str(oo)]);
        temp=findSubField(fidr,'X');
        x=str2num(temp(find(temp=='=')+1:end));
        temp=findSubField(fidr,'Y');
        y=str2num(temp(find(temp=='=')+1:end));
        temp=findSubField(fidr,'Z');
        z=str2num(temp(find(temp=='=')+1:end));
        optodeSpace.probes(pp).optodeCoords(oo,:)=[x y z];
         
        x=x+substep;
        waitbar(x,h,['Reading Data - ' num2str(round(x)) '%']);
    end
         %Note the default direction of the axis!
         %  X axes => From RE (Negative) to LE (Positive)
         %  Y axes => From Nz (Negative) to Iz (Positive)
         %
         %In order to express the coordinates as if the head
         %was looking "frontwards" as it is usually represented
         %in papers (e.g. [JurcackV2007]) Optode coordinates
         %must be rotated 180% (or pi radians)
         %around the Z axes!
         [tmpLE]=mesh3D_rotation(optodeSpace.probes(pp).leftear,...
             pi,[0 0 0],[0 0 1]);
         optodeSpace.probes(pp).leftear=tmpLE;
         [tmpRE]=mesh3D_rotation(optodeSpace.probes(pp).rightear,...
             pi,[0 0 0],[0 0 1]);
         optodeSpace.probes(pp).rightear=tmpRE;
         [tmpNz]=mesh3D_rotation(optodeSpace.probes(pp).nasion,...
             pi,[0 0 0],[0 0 1]);
         optodeSpace.probes(pp).nasion=tmpNz;
         [tmpIz]=mesh3D_rotation(optodeSpace.probes(pp).inion,...
             pi,[0 0 0],[0 0 1]);
         optodeSpace.probes(pp).inion=tmpIz;
         [tmpCz]=mesh3D_rotation(optodeSpace.probes(pp).top,...
             pi,[0 0 0],[0 0 1]);
         optodeSpace.probes(pp).top=tmpCz;
         [tmpCoords]=mesh3D_rotation(optodeSpace.probes(pp).optodeCoords,...
             pi,[0 0 0],[0 0 1]);
         optodeSpace.probes(pp).optodeCoords=tmpCoords;

    %Angle
    temp=findField(fidr,'Angle');
    temp=findSubField(fidr,'X');
    optodeSpace.probes(pp).angle(1)=...
        str2num(temp(find(temp=='=')+1:end));
    temp=findSubField(fidr,'Y');
    optodeSpace.probes(pp).angle(2)=...
        str2num(temp(find(temp=='=')+1:end));
    temp=findSubField(fidr,'Z');
    optodeSpace.probes(pp).angle(3)=...
        str2num(temp(find(temp=='=')+1:end));

end
waitbar(1,h,['Reading Data - 100%']);

fclose(fidr);
waitbar(1,h);
close(h);



%%=============================================================
%%Auxiliar functions
%%=============================================================
function fieldName = getFieldName(lineString)
%Extract the field name
idx=find(lineString==']');
if (isempty(idx))
    fieldName='';
else
    fieldName=lineString(2:idx(1)-1); %The field also starts with '['
end
end

function [lineString]=findField(fidr,fieldName)
%Finds the line containing the field specified
temp='';
found=false;
while ~found && ~feof(fidr)
    lineString = fgetl(fidr);
    temp=getFieldName(lineString);
    found=strcmpi(temp,fieldName);
end
if (feof(fidr) && ~found)
    error('Field not found. Reached end of file.');
end
end

function fieldName = getSubFieldName(lineString)
%Extract the field name
idx=find(lineString=='=');
if (isempty(idx))
    fieldName='';
else
    fieldName=lineString(1:idx(1)-1);
end
end

function [lineString]=findSubField(fidr,fieldName)
%Finds the line containing the subfield specified
temp='';
found =false;
while ~found && ~feof(fidr)
    lineString = fgetl(fidr);
    temp=getSubFieldName(lineString);
    found=strcmpi(temp,fieldName);
end
if (feof(fidr) && ~found)
    error('Field not found. Reached end of file.');
end
end

end
