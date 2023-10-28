function res=eq(obj,obj2)
%CHANNELLOCATIONMAP/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2012-23
% @author: Felipe Orihuela-Espina
%
% See also channelLocationMap
%

%% Log
%
%
% File created: 26-Nov-2012
% File last modified (before creation of this log): 8-Sep-2013
%
% 8-Sep-2013: Support for comparing optodes related information as well
%       as pairings.
%   + Added this log.
%
% 20-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%



res=true;
if ~isa(obj2,'channelLocationMap')
    res=false;
    return
end

res = res && (obj.id==obj2.id);
res = res && (strcmp(obj.description,obj2.description));


res = res && (obj.nChannels==obj2.nChannels);
res = res && (obj.nOptodes==obj2.nOptodes);
if ~res
    return
end

%Compare each channel positions
clm1_3d=getChannel3DLocations(obj);
clm2_3d=getChannel3DLocations(obj2);
%res = res && (all(all(oa1_3d==oa2_3d)));
res = res && (isequalwithequalnans(clm1_3d,clm2_3d));
if ~res
    return
end

%Compare each optode positions
clm1_3d=getOptode3DLocations(obj);
clm2_3d=getOptode3DLocations(obj2);
%res = res && (all(all(oa1_3d==oa2_3d)));
res = res && (isequalwithequalnans(clm1_3d,clm2_3d));
if ~res
    return
end

%Compare optode types and pairings
clm1_oTypes=getOptodeTypes(obj);
clm2_oTypes=getOptodeTypes(obj2);
res = res && (isequalwithequalnans(clm1_oTypes,clm2_oTypes));
clm1_pairings=getPairings(obj);
clm2_pairings=getPairings(obj2);
res = res && (isequalwithequalnans(clm1_pairings,clm2_pairings));
if ~res
    return
end



%Compare each reference point positions
clm1_rp=getReferencePoints(obj);
clm2_rp=getReferencePoints(obj2);
res = res && isequal(clm1_rp,clm2_rp);
if ~res
    return
end

res = res && (strcmpi(obj.surfacePositioningSystem,...
                      obj2.surfacePositioningSystem));
res = res && (strcmpi(obj.stereotacticPositioningSystem,...
                      obj2.stereotacticPositioningSystem));
if ~res
    return
end
clm1_surface=getChannelSurfacePositions(obj);
clm2_surface=getChannelSurfacePositions(obj2);
for ch=1:obj.nChannels
    res = res && (strcmpi(clm1_surface{ch},clm2_surface{ch}));
end
clm1_surface=getOptodeSurfacePositions(obj);
clm2_surface=getOptodeSurfacePositions(obj2);
for ch=1:obj.nOptodes
    res = res && (strcmpi(clm1_surface{ch},clm2_surface{ch}));
end
if ~res
    return
end

clm1_stereotactic=getChannelStereotacticPositions(obj);
clm2_stereotactic=getChannelStereotacticPositions(obj2);
res = res && (isequalwithequalnans(clm1_stereotactic,clm2_stereotactic));
if ~res
    return
end

%Compare optode arrays
[ch_optArrays1,oaInfo1]=getChannelOptodeArrays(obj);
[ch_optArrays2,oaInfo2]=getChannelOptodeArrays(obj2);
res = res && (isequalwithequalnans(ch_optArrays1,ch_optArrays2));
[optodes_optArrays1,oaInfo1]=getOptodeOptodeArrays(obj);
[optodes_optArrays2,oaInfo2]=getOptodeOptodeArrays(obj2);
res = res && (isequalwithequalnans(optodes_optArrays1,optodes_optArrays2));
if ~res
    return
end
%At this point, both objects have the same number of optode arrays
%declared, and with the same IDs. Only remain to check whether
%the info arrays are the same
    res = res && (isequal(oaInfo1,oaInfo2));
% optArrays=ch_optArrays1;
% for oa = optArrays
%     res = res && (isequal(oaInfo1(oa),oaInfo2(oa)));
% %     names = fieldnames(oaInfo1(oa));
% %     nFields=length(names);
% %     for ff=1:nFields
% %         res = res && (isequal(oaInfo1(oa),oaInfo2(oa)));
% %     end
% end
if ~res
    return
end


%Probe sets
ch_probSets1=getChannelProbeSets(obj);
ch_probSets2=getChannelProbeSets(obj2);
res = res && (isequalwithequalnans(ch_probSets1,ch_probSets2));
optodes_probSets1=getOptodeProbeSets(obj);
optodes_probSets2=getOptodeProbeSets(obj2);
res = res && (isequalwithequalnans(optodes_probSets1,optodes_probSets2));
if ~res
    return
end

