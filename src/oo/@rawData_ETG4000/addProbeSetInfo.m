function obj=addProbeSetInfo(obj,pInfo)
%RAWDATA_ETG4000/ADDPROBESETINFO Add a probe set
%
% obj=addProbeSetInfo(obj) Add one probe set.
%   Increases by one the number of probe sets slots enlarging the data
%   structures as appropriate. Default values for
%   the read (0), type (adult) and mode (3x3) will be used. This
%   information can be further updated using the setProbeSetInfo method. 
%
% obj=addProbeSetInfo(obj,pInfo) Add one or more probe sets with the
%   indicated information.
%   Increases the number of probe sets slots enlarging the data structures
%   as appropriate.
%
% The enlarged data structres will be filled by default data.
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
% pInfo - Optional. A nx1 struct of probe sets information records
%       where n is the number of probe sets to add.
%       Each probe set information record contains the
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
% Copyright 2016
% @date: 14-Jan-2016
% @author: Felipe Orihuela-Espina
% @modified: 14-Jan-2016
%
% See also getProbeSetInfo, setProbeSetInfo
%

if (~exist('pInfo','var') || isempty(pInfo))
    %Set the default information
    pInfo(1).read=0;
	pInfo(1).type='adult';
    pInfo(1).mode='3x3';

else
    
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
                  error('ICNA:rawData_ETG4000:addProbesetInfo:InvalidFieldValue',...
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
                  error('ICNA:rawData_ETG4000:addProbeSetInfo:InvalidFieldValue',...
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
                  error('ICNA:rawData_ETG4000:addProbeSetInfo:InvalidFieldValue',...
                      ['Field .mode in ' num2str(ff) ...
                       '-th probe set information record must be ' ...
                       'a recognized string (e.g. ''3x3'').']);
                end
                

            otherwise
                error('ICNA:rawData_ETG4000:addProbeSetInfo:InvalidField',...
                      ['Invalid field ' names{ff} ' in ' num2str(ff)...
                       '-th probe set information record.']);
        end
    end
end
   

end

tempProbeNumber = length(pInfo); %Number of probe sets to add


pInfo = orderfields(pInfo, obj.probesetInfo);
%Orders the fields in pInfo so that fields are in the same order
%as those in obj.probesetInfo. If this field sorting is not done
%then the assignment below will result in error:
%       "Subscripted assignment between dissimilar structures."
%Structures pInfo and obj.probesInfo must have the same fields.

%Finally add the probe set at the end of currently declared probeSets
obj.probesetInfo(end+1:end+tempProbeNumber)=pInfo;

    %but also enlarge data structures
    
        %NOTE: In MATLAB, an assignment:
        %   + a=nan(0,0,0) leads to an empty array 0-by-0-by-0 with ndims 3
        %   + a=nan(0,n) leads to an empty array 0-by-n with ndims 2
        %   + a=nan(0,0,n) leads to an empty array 0-by-0-by-n with
        %           ndims 3, iff n~=1!!
        %but unfortunately
        %   + a=nan(0,0) leads to an empty array [] with ndims 2
        %   + a=nan(0,0,1) leads to an empty array [] with ndims 2
        
    
        %Note that the solution analogous to the one used for the
        %other matrices below:
        %  obj.lightRawData(:,:,end+1:tempProbeNumber)=...
        %               nan(size(obj.lightRawData,1),...
        %                   size(obj.lightRawData,2),...
        %                   tempProbeNumber-size(obj.marks,3)));
        %...won't work here if tempProbeNumber happens to be 1 (i.e.
        %everytime the first probes set is imported!)

        obj.lightRawData(:,:,end+1:end+tempProbeNumber)=nan;

    %Note that the more obvious/simpler line:
    %
    %   obj.marks(:,end+1:tempProbeNumber)=nan;
    %
    %won't work properly if obj.marks is empty; as it will change
    %its size from 0-by-0 to 1-by-1 rather than 0-by-1
    obj.marks(:,end+1:end+tempProbeNumber)=...
        	nan(size(obj.marks,1),tempProbeNumber);
    obj.timestamps(:,end+1:end+tempProbeNumber)=...
        	nan(size(obj.timestamps,1),tempProbeNumber);
    obj.bodyMovement(:,end+1:end+tempProbeNumber)=...
        	nan(size(obj.bodyMovement,1),tempProbeNumber);
    obj.removalMarks(:,end+1:end+tempProbeNumber)=...
        	nan(size(obj.removalMarks,1),tempProbeNumber);
    obj.preScan(:,end+1:end+tempProbeNumber)=...
        	nan(size(obj.preScan,1),tempProbeNumber-size(obj.preScan,2));

assertInvariants(obj);


end