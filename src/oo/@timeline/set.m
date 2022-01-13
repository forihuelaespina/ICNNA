function obj = set(obj,varargin)
% TIMELINE/SET Set object properties and return the updated object
%
% obj = set(obj,'PropertyName',propertyValue) Set object properties and
%   return the updated object
%
%% Properties
%
% 'Length' - Length of the timeline in number of samples
%When updating the 'Length', if the current timeline has
%events defined that last beyond the new size, this operation
%will issue a warning before cropping or removing those events.
% 'NominalSamplingRate' - Declared sampling rate in Hz. It may
%       differ from the real sampling rate (see get(obj,'SamplingRate')).
%       This is used for automatically generating timesamples
%       when these latter are unknown. Note however that setting the
%       nominalSamplingRate does not recompute (existing) timestamps.
% 'StartTime' - An absolute start date
% 'Timestamps' - A vector (of 'Length'x1) of timestamps in seconds
%       expressed relative to the startTime. From these, the real
%       average sampling rate (different from the nominal sampling
%       rate) is calculated.
%
%
%
%
% Copyright 2008-12
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 29-Dec-2012
%
%See also get, addCondition, addConditionEvents, setConditionEvents
%
propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch lower(prop)
    case 'length'
        if (isscalar(val) && (val==floor(val)))
            
            %Remove or crop events beyond the new length.
            res=cropOrRemoveEvents(val);
            if (res)
                warning('ICNA:timeline:set:EventsCropped',...
                    ['Events lasting beyond the new length ' ...
                     'will be cropped or removed.']);
            end
            
            if val>obj.length
                %Generate extra timestamps
                initStamp = 0;
                if ~isempty(obj.timestamps)
                    initStamp = obj.timestamps(end);
                end
                extraTimestamps = initStamp + ...
                    (1:val-obj.length) / get(obj,'NominalSamplingRate');
                obj.timestamps = [obj.timestamps; extraTimestamps'];
            elseif val<obj.length
                %Remove the later timestamps
                obj.timestamps(val+1:end) = [];
            end
            
            obj.length = val;
            
        else
            error('ICNA:timeline:set:InvalidParameterValue',...
                    'Value must be a scalar natural/integer.');
        end

    case 'nominalsamplingrate'
        if (isscalar(val) && val>0)
            obj.nominalSamplingRate = val;
        else
            error('ICNA:timeline:set:InvalidParameterValue',...
                    'Value must be a scalar natural/integer.');
        end

    case 'starttime'
        if (ischar(val) || isvector(val) || isscalar(val))
            obj.startTime = datenum(val);
        else
            error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a date (whether a string, datevec or datenum).');
        end

    case 'timestamps'
        if (isvector(val) && ~ischar(val) ...
                && all(val(1:end-1)<val(2:end)) ...
                && numel(val)==obj.length)
            %ensure it is a column vector
            val = reshape(val,numel(val),1);
            obj.timestamps = val;
        else
            error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a vector of length get(obj,''Length'').');
        end

    otherwise
      error('ICNA:timeline:set:InvalidParameterValue',...
            ['Property ' prop ' not valid.'])
   end
end
assertInvariants(obj);

%% Auxiliar Nested functions
function res=cropOrRemoveEvents(newLength)
    res=false;
    nCond=get(obj,'NConditions');
    for cc=1:nCond
        ctag=getConditionTag(obj,cc);
        [e,eInfo]=getConditionEvents(obj,ctag);
        if (~isempty(e))
            onsets=e(:,1);
            %Remove those events which start after the new length
            idx=find(onsets>newLength);
            if (~isempty(idx))
                res=true;
            end
            e(idx,:)=[];
            eInfo(idx)=[];
            %Crop those events which start before the new lengh
            %but last beyond that length
            onsets=e(:,1);
            durations=e(:,2);
            endings=onsets+durations;
            idx=find(endings>newLength);
            if (~isempty(idx))
                res=true;
            end
            e(idx,2)=newLength-onsets(idx);
        end
        obj=setConditionEvents(obj,ctag,e,eInfo);
    end
end
end