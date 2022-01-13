function obj=setProbeSetInfo(obj,idx,pInfo)
%RAWDATA_ETG4000/SETPROBESETINFO Set the information associated to the probe sets
%
% obj=setProbeSetInfo(obj,idx,pInfo) Updates the information
%   associated to one or more probe sets.
%   Indexes lower than 0 or above the current
%   number of probe sets will be ignored.
%
% obj=setProbeSetInfo(obj,idx,[]) Reset the information
%   associated to one or more probe sets to the default values.
%   Indexes lower than 0 or above the current
%   number of probe sets will be ignored.
%
%
%% Remarks
%
% This method does not alter the light raw data itself. Setting a
%probe set to not read status, will not nullify its data (if existing),
%which will remain latent in case the probe set is reset to read any time
%later. TO nullify the data, you need to do that "manually" using:
%
%       lRD = get(obj,'lightRawData');
%       lRD(:,:,myProbeSetIdx) = nan;
%       obj = set(obj,'lightRawData',lRD);
%
% You shall proceed similarly also for the stimulus marks, timestamps,
%body movement marks, removal marks and preScan marks.
%
% However, remember that only the information from those probe sets
%marked as read will be used during the conversion to a nirs_neuroimage.
%
%
%% Parameters
%
% idx - A vector of indexes to probe sets.
%
% pInfo - A nx1 struct of probe sets information records where n is the
%       length of idx. Each probe set information record contains the
%       following fields:
%           .read - A binary record (0 -not read (default); 1 -read)
%               of the probes imported so far.  For instance, when reading
%               48 channels from 2 probe sets, one can read the second
%               probe set first; in that case,
%                   .probesetInfo(1).read=0;
%                   .probesetInfo(2).read=1;
%                 and the length of probesetInfo will be 2, indicating
%               that the second probe set has been imported but not
%               the first.
%                   It follows that the total number of probe sets imported
%               is the sum of this field across the .probesetInfo array.
%                 This is not an attribute read from the data file itself,
%               but allows ICNA to track more than one probe set.
%           .type - A cell array of string indicating whether the probe set
%               is for adults or neonates. It might be expected that the 
%               type is shared across all probe sets, but no effort
%               is made to check this.
%               Available as from HITACHI file version 1.21
%           .mode - A string containing the mode for the probe
%               set which determines the number and type of the
%               optode arrays used. Currently accepted modes are:
%                   + '3x3' (2 optode arrays; 2x12=24 channels) - Default
%                   + '3x5' (1 optode arrays; 22 channels)
%                   + '4x4' (1 optode arrays; 24 channels)
%               Note that the number of optode
%               arrays may be larger than the number of probe sets
%               (e.g. 1 probe set to mode 3x3 actually has 2 optode
%               arrays). Note that the number of channels can actually
%               be calculated from the mode.
%
%
%
%
% Copyright 2012-2016
% @date: 26-Dec-2012
% @author: Felipe Orihuela-Espina
% @modified: 14-Jan-2016
%
% See also getProbeSetInfo, addProbeSetInfo
%


%% Log
%
% 14-Jan-2016 (FOE): Bug fixed and comments improved.
%   Attempts to access to obj.probesInfo were changed to obj.probesetInfo
%   Also, added method addProbeSetInfo to the "see also" section.
%





if isempty(pInfo)
    %Reset the information for the selected probes sets
    idx(idx<1)=[];
    idx(idx>length(obj.probesetInfo))=[];
    for ps=idx
        obj.probesetInfo(ps).read=0;
        obj.probesetInfo(ps).type='adult';
        obj.probesetInfo(ps).mode='3x3';
    end
            
else
    
assert(numel(idx)==numel(pInfo),...
        ['ICNA:rawData_ETG4000:setProbesInfo:InvalidParameterValue',...
         ' Number of probes sets indexes mismatches number of ' ...
         'associated probes sets information records.']);
idx=reshape(idx,numel(idx),1); %Ensure both are vectors
pInfo=reshape(pInfo,numel(pInfo),1);

tempIdx=find(idx<1 || idx>length(obj.probesetInfo));
idx(tempIdx)=[];
pInfo(tempIdx)=[];

%Check the struct fields and for each field its info
nElem=length(pInfo);
for ee=1:nElem
    names = fieldnames(pInfo);
    nFields = length(names);
    for ff=1:nFields
        switch (names{ff})
            case 'read'
                val=pInfo(ee).read;
                if (isscalar(val) && (val == 0 || val == 1))
                    %Valid; do nothing
                else 
                  error('ICNA:rawData_ETG4000:setProbesInfo:InvalidFieldValue',...
                      ['Field .read in ' num2str(ff) ...
                       '-th probe set information record must be ' ...
                       'either a 0 -not read-, or 1 -read.']);
                end
            
            case 'type'
                val=pInfo(ee).type;
                if (ischar(val) && (strcmpi(val,'adult') ...
                                    || strcmpi(val,'neonates')))
                                    %This may temporarily introduced a bug
                                    %as I'm not sure what HITACHI uses for
                                    %other types of probes different from
                                    %the adult.
                    %Valid; do nothing. Lower just for the sake of it
                    pInfo(ee).type=lower(pInfo(ee).type);
                    
                else 
                  error('ICNA:rawData_ETG4000:setProbesInfo:InvalidFieldValue',...
                      ['Field .type in ' num2str(ff) ...
                       '-th probe set information record must be ' ...
                       'a recognized string (e.g. ''adult'').']);
                end
            
                
            case 'mode'
                val=pInfo(ee).mode;
                if isempty(val)
                    pInfo(ee).mode = '3x3'; %Switch for the default
                elseif (ischar(val) && (strcmp(val,'3x3') ...
                                    || strcmp(val,'4x4') ...
                                    || strcmp(val,'3x5')))
                    %Valid; do nothing
                else 
                  error('ICNA:rawData_ETG4000:setProbesInfo:InvalidFieldValue',...
                      ['Field .mode in ' num2str(ff) ...
                       '-th probe set information record must be ' ...
                       'a recognized string (e.g. ''3x3'').']);
                end
                

            otherwise
                error('ICNA:rawData_ETG4000:setProbesInfo:InvalidField',...
                      ['Invalid field ' names{ff} ' in ' num2str(ff)...
                       '-th probe set information record.']);
        end
    end
end

%Finally set the probes sets info
pInfo = orderfields(pInfo, obj.probesetInfo(idx));
%Orders the fields in pInfo so that fields are in the same order
%as those in obj.probesetInfo. If this field sorting is not done
%then the assignment below will result in error:
%       "Subscripted assignment between dissimilar structures."
%Structures pInfo and obj.probesInfo must have the same fields.
obj.probesetInfo(idx)=pInfo;

end
assertInvariants(obj);

