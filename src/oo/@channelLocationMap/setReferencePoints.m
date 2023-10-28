function obj=setReferencePoints(obj,idx,rpInfo)
%CHANNELLOCATIONMAP/SETREFERENCEPOINTS Set the information associated to the reference points
%
% obj=setReferencePoints(obj,idx,rpInfo) Updates the information
%   associated to one or more reference points.
%   Indexes lower than 0 will be ignored. Indexes above the current
%   number of reference points will be ignored. Empty information records
%   (i.e. []) will be ignored. To remove reference points please refer
%   to method removeReferencePoints.
%
%
% Please refer to addReferencePoints, removeReferencePoints
%   for adding new and eliminating reference points.
%
%
%% Parameters
%
% idx - A vector of indexes to reference points.
%
% rpInfo - A nx1 struct of reference points information records where n is the
%       length of idx. Each reference point information record contains the
%       following fields:
%           .name - A string with the reference location name. In
%               particular the following locations are expected to
%               have standard names:
%                   + 'nasion' or 'Nz': dent at the upper root of the
%                       nose bridge;
%                   + 'inion' or 'Iz': external occipital protuberance;
%                   + 'leftear' or 'LPA': left preauricular point, an
%                       anterior root of the center of the peak
%                       region of the tragus;
%                   + 'rightear' or 'RPA': right preauricular point
%                   + 'top' or 'Cz': Midpoint between Nz and Iz
%           .location - The "real-world" 3D locations of the reference
%               point
%
%
%
%
% Copyright 2013-23
% @author: Felipe Orihuela-Espina
%
% See also getReferencePoints, addReferencePoints, removeReferencePoints,
%


%% Log
%
% File created: 27-Aug-2013
% File last modified (before creation of this log): 8-Sep-2013
%
% 8-Sep-2013: Updated "links" of the See also section
%   + Added this log.
%
% 20-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%



if isempty(rpInfo)
    %Do nothing
            
else
    
assert(numel(idx)==numel(rpInfo),...
        ['ICNA:channelLocationMap:setReferencePoints:InvalidParameterValue',...
         ' Number of reference points indexes mismatches number of ' ...
         'associated reference points information records.']);
idx=reshape(idx,numel(idx),1); %Ensure both are vectors
rpInfo=reshape(rpInfo,numel(rpInfo),1);

%Ignore idx below 1 and above existing number of reference points
tempIdx=find(idx<1 || idx>length(obj.referencePoints));
idx(tempIdx)=[];
rpInfo(tempIdx)=[];

%Check the struct fields and for each field its info
nElem=length(rpInfo);
for ee=1:nElem
    names = fieldnames(rpInfo);
    nFields = length(names);
    for ff=1:nFields
        switch (names{ff})
            case 'name'
                val=rpInfo(ee).name;
                if isempty(val)
                    rpInfo(ee).name = ''; %Switch for an empty string
                  warning('ICNA:channelLocationMap:setReferencePoints',...
                      ['Name in ' num2str(ff) ...
                       '-th reference point information record is empty.']);
                elseif ischar(val)
                    %Valid; do nothing
                    %NOTE: Locations with standard names are saved with
                    %special capitalizations
                    switch lower(rpInfo(ee).name)
                        case {'nasion','inion','leftear','rightear','top'}
                            rpInfo(ee).name=lower(rpInfo(ee).name);
                        otherwise
                            %Do nothing
                    end
                    
                else 
                  error('ICNA:channelLocationMap:setReferencePoints:InvalidFieldValue',...
                      ['Name in ' num2str(ff) ...
                       '-th reference point information record must be a string.']);
                end
                
                
            case 'location'
                val=rpInfo(ee).location;
                if isempty(val)
                    rpInfo(ee).location = nan(1,3);
                        %Switch for an empty matrix
                elseif (~ischar(val) && ~iscell(val) && ~isstruct(val) ...
                        && numel(val)==3)
                    %Is a matrix; Valid but may need adjustments
                    rpInfo(ee).location = reshape(val,1,3);
                                        
                else 
                  error('ICNA:channelLocationMap:setReferencePoints:InvalidFieldValue',...
                      ['Location in ' num2str(ff) ...
                       '-th reference point information record must be ' ...
                       'a 3D <x,y,z> location vector.']);
                end

            otherwise
                error('ICNA:channelLocationMap:setReferencePoints:InvalidField',...
                      ['Invalid field ' names{ff} ' in ' num2str(ff)...
                       '-th reference point information record.']);
        end
    end
end

%Finally set the reference points info
if isempty(obj.referencePoints)
    rpInfo = orderfields(rpInfo, struct('name',{},'location',{}));
        %Note that this line should actually do the work as well
        %in case obj.referencePoints is not empty, so the if will be
        %strictly unnecessary. However, I have prefer to leave the
        %if for code clarity.
else
    rpInfo = orderfields(rpInfo, obj.referencePoints(idx));
end
%Orders the fields in rpInfo so that fields are in the same order
%as those in obj.referencePoints. If this field sorting is not done
%then the assignment below will result in error:
%       "Subscripted assignment between dissimilar structures."
%Structures rpInfo and obj.referencePoints must have the same fields.
obj.referencePoints(idx)=rpInfo;

end
assertInvariants(obj);

end