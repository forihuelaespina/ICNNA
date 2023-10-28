function obj = set(obj,varargin)
% TIMELINE/SET DEPRECATED (v1.2). Set object properties and return the updated object
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
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
%See also addCondition, addConditionEvents, setConditionEvents
%





%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): 29-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED (v1.2).
%   + Nested method cropOrRemoveEvents has now been separated
%   to a private method.
%



warning('ICNNA:timeline:set:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for setting the attribute ' ...
         'e.g. timeline.' lower(varargin{1}) ' = ... ']); 



propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch lower(prop)
    case 'length'
        obj.length = val;
        % if (isscalar(val) && (val==floor(val)))
        % 
        %     %Remove or crop events beyond the new length.
        %     [obj,res]=obj.cropOrRemoveEvents(val);
        %     if (res)
        %         warning('ICNA:timeline:set:EventsCropped',...
        %             ['Events lasting beyond the new length ' ...
        %              'will be cropped or removed.']);
        %     end
        % 
        %     if val>obj.length
        %         %Generate extra timestamps
        %         initStamp = 0;
        %         if ~isempty(obj.timestamps)
        %             initStamp = obj.timestamps(end);
        %         end
        %         extraTimestamps = initStamp + ...
        %             (1:val-obj.length) / get(obj,'NominalSamplingRate');
        %         obj.timestamps = [obj.timestamps; extraTimestamps'];
        %     elseif val<obj.length
        %         %Remove the later timestamps
        %         obj.timestamps(val+1:end) = [];
        %     end
        % 
        %     obj.length = val;
        % 
        % else
        %     error('ICNA:timeline:set:InvalidParameterValue',...
        %             'Value must be a scalar natural/integer.');
        % end

    case 'nominalsamplingrate'
        obj.nominalSamplingRate = val;
        % if (isscalar(val) && val>0)
        %     obj.nominalSamplingRate = val;
        % else
        %     error('ICNA:timeline:set:InvalidParameterValue',...
        %             'Value must be a scalar natural/integer.');
        % end

    case 'starttime'
        obj.starttime = val;
        % if (ischar(val) || isvector(val) || isscalar(val))
        %     obj.startTime = datenum(val);
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a date (whether a string, datevec or datenum).');
        % end

    case 'timestamps'
        obj.timestamps = val;
        % if (isvector(val) && ~ischar(val) ...
        %         && all(val(1:end-1)<val(2:end)) ...
        %         && numel(val)==obj.length)
        %     %ensure it is a column vector
        %     val = reshape(val,numel(val),1);
        %     obj.timestamps = val;
        % else
        %     error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
        %           'Value must be a vector of length get(obj,''Length'').');
        % end

    otherwise
      error('ICNNA:timeline:set:InvalidParameterValue',...
            ['Property ' prop ' not valid.'])
   end
end
assertInvariants(obj);

end