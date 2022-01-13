function display(obj)
%CHANNELLOCATIONMAP/DISPLAY Command window display of an channelLocationMap
%
%Produce a string representation of the object, which is
%then displayed on the with an output similar to the standard
%MATLAB output.
%
% Copyright 2012-13
% @date: 26-Nov-2012
% @author: Felipe Orihuela-Espina
% @modified: 8-Sep-2013
%
% See also optodeArray, get, set
%

%% Log
%
% 8-Sep-2013: Support for visualizing optodes and pairings information
%



disp(' ');
disp([inputname(1),'= ']);
disp(' ');
disp(['   ID: ' num2str(obj.id)]);
disp(['   Description: ' obj.description]);

nChannels=get(obj,'nChannels');
disp(['   Num. Channels: ' num2str(nChannels)]);
nOptodes=get(obj,'nOptodes');
disp(['   Num. Optodes: ' num2str(nOptodes)]);

if nChannels>0
    disp(['   Channel surface positions (' ...
            get(obj,'SurfacePositioningSystem') ...
            '), 3D Locations (X,Y,Z) ' ...
            'and associated optode pairings <Emisor,Detector>:']);
    chPos_surface=getChannelSurfacePositions(obj);
    chPos_3d=getChannel3DLocations(obj);
    pairings=getPairings(obj);
    for ch=1:nChannels
        surfaceStr=chPos_surface{ch};
        if isempty(surfaceStr)
            surfaceStr='N/A';
        end
        disp(['Ch#' num2str(ch) ...
            '  ' surfaceStr ...
            '  ' num2str(chPos_3d(ch,:))...
            '  ' num2str(pairings(ch,:))]);
    end
    
    disp(' ')
    disp(['   Channel stereotactic positions (' ...
            get(obj,'StereotacticPositioningSystem') ...
            ') - (X,Y,Z):']);
    chPos_stereotactic=getChannelStereotacticPositions(obj);
    for ch=1:nChannels
        disp(['Ch#' num2str(ch) '  ' num2str(chPos_stereotactic(ch,:))]);
    end

    disp(' ')
    
end    
    
if nOptodes>0
    disp(['   Optode surface positions (' ...
            get(obj,'SurfacePositioningSystem') ...
            '), Type and 3D Locations (X,Y,Z):']);
    oPos_surface=getOptodeSurfacePositions(obj);
    oPos_Type=getOptodeTypes(obj);
    oPos_3d=getOptode3DLocations(obj);
    for oo=1:nOptodes
        surfaceStr=oPos_surface{oo};
        if isempty(surfaceStr)
            surfaceStr='N/A';
        end
        switch (oPos_Type(oo))
            case obj.OPTODE_TYPE_UNKNOWN
                typeStr='U';
            case obj.OPTODE_TYPE_EMISOR
                typeStr='S'; %Source
            case obj.OPTODE_TYPE_DETECTOR
                typeStr='D';
            otherwise
                error('ICNA:channelLocationMap:display:UnexpectedOptodeType',...
                        'Unexpected optode type.');
        end
        disp(['Op#' num2str(oo) ...
            '  ' surfaceStr ...
            '  ' typeStr ...
            '  ' num2str(oPos_3d(oo,:))]);
    end
    
    %Optodes do not have stereotactic positions
    
    disp(' ')
end


    
%Reference points
refPoints=getReferencePoints(obj);
if ~isempty(refPoints)
    disp('   Reference Points; Name and 3D Locations (X,Y,Z):');
    nRefPoints = length(refPoints);
    for rp=1:nRefPoints
        disp([refPoints(rp).name ...
            '  ' num2str(refPoints(rp).location)]);
    end
    disp(' ')
end

%Optode arrays
[ch_optArrays,oaInfo]=getChannelOptodeArrays(obj);
[o_optArrays,~]=getOptodeOptodeArrays(obj);
nOAs=length(oaInfo);
for oa = 1:nOAs
    disp(['Optode array #' num2str(oa)]);
    names = fieldnames(oaInfo(oa));
    nFields=length(names);
    for ff=1:nFields
        fieldVal= oaInfo(oa).(names{ff});
        if isempty(fieldVal)
            disp(['  .' names{ff} ': N/A']);
        elseif ~ischar(fieldVal)
            disp(['  .' names{ff} ': ' mat2str(fieldVal)]);
        else
            disp(['  .' names{ff} ': ' fieldVal]);
        end
    end
    chIdx=find(ch_optArrays==oa)';
    if isempty(chIdx)
        disp('  This optode array has no associated channels.');
    else
        disp(['  Associated channels: ' num2str(chIdx)]);
    end
    oIdx=find(o_optArrays==oa)';
    if isempty(chIdx)
        disp('  This optode array has no associated optodes.');
    else
        disp(['  Associated optodes: ' num2str(oIdx)]);
    end
end
chIdx=find(isnan(ch_optArrays))';
if ~isempty(chIdx)
    disp(['Channels not associated to optode arrays: ' num2str(chIdx)]);
end
oIdx=find(isnan(o_optArrays))';
if ~isempty(oIdx)
    disp(['Optodes not associated to optode arrays: ' num2str(oIdx)]);
end


%Probe sets
disp(' ')
ch_probSets=getChannelProbeSets(obj);
o_probSets=getOptodeProbeSets(obj);
probSets=unique(ch_probSets)';
probSets(isnan(probSets))=[];
for ps = probSets
    disp(['Probe set #' num2str(ps)]);
    chIdx=find(ch_probSets==ps)';
    disp(['  Associated channels: ' num2str(chIdx)]);
    oIdx=find(o_probSets==ps)';
    disp(['  Associated optodes: ' num2str(oIdx)]);
end
chIdx=find(isnan(ch_probSets))';
if ~isempty(chIdx)
    disp(['Channels not associated to probe sets: ' num2str(chIdx)]);
end
oIdx=find(isnan(o_probSets))';
if ~isempty(oIdx)
    disp(['Optodes not associated to probe sets: ' num2str(oIdx)]);
end


disp(' ');


end
