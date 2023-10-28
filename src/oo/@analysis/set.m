function obj = set(obj,varargin)
% ANALYSIS/SET DEPRECATED (v1.2). Set object properties and return the updated object
%
% obj = set(obj,'PropertyName',propertyValue) Set object properties
%       and return the updated object
%
%% Properties
% 'ID' - The numeric identifier
% 'Name' - The instance name. Updating the analsyis name, also
%       updates the name of the associated Experiment Space.
% 'Description' -  The instance description. Updating the analsyis
%       description, also
%       updates the description of the associated Experiment Space.
% 'Metric' -  Current selected metric
% 'Embedding' -  Current selected embedding technique
% 'ExperimentSpace' -  The associated Experiment Space
% 'FeatureSpace' -  The Feature Space
% 'ProjectionSpace' -  The Projection Space
% 'PatternDistance' - Matrix of pairwise distances in the Feature Space
% 'PatternIndexes' -  List of pattern indexes linking Feature and
%           Projection Spaces
% 'NPatterns' -  Number of patterns in the Feature and Projection Space
% 'RunStatus' - Current status
% 'ProjectionDimensionality' - Dimension of the Projection Space
% 'SubjectsIncluded' - List of subjects' ID included in the analysis
% 'SessionsIncluded' - List of sessions' ID included in the analysis
% 'ChannelGroups' - List of channel groups included in the analysis
% 'SignalDescriptors' - List of signals (2nd col) and the generating
%       data sources (2nd col) included in the analysis
%
% Copyright 2008-23
% last update: 28-Nov-2008
%
% See also analysis, get
%





%% Log
%
% File created: 26-May-2008
% File last modified (before creation of this log): 28-Nov-2008
%
% 7-Jun-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED (v1.2).
%



warning('ICNNA:analysis:set:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for setting the attribute ' ...
         'e.g. analysis.' lower(varargin{1}) ' = ... ']); 



propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch lower(prop)
    case 'id'
        obj.id = val;
        % if (isscalar(val) && isreal(val) && ~ischar(val) ...
        %     && (val==floor(val)) && (val>0))
        %     %Note that a char which can be converted to scalar
        %     %e.g. will pass all of the above (except the ~ischar)
        %     obj.id = val;
        % else
        %     error('ICNA:analysis:set:ID:InvalidInput',...
        %           'Value must be a scalar natural/integer');
        % end
 
    case 'name'
        obj.name = val;
        % if (ischar(val))
        %     obj.name = val;
        %     obj.F=set(obj.F,'Name',val);
        % else
        %     error('ICNA:analysis:set:Name:InvalidInput',...
        %           'Value must be a string');
        % end

    case 'description'
        obj.description = val;
        % if (ischar(val))
        %     obj.description = val;
        %     obj.F=set(obj.F,'Description',val);
        % else
        %     error('ICNA:analysis:set:Description:InvalidInput',...
        %           'Value must be a string');
        % end

    case 'experimentspace'
        obj.experimentSpace = val;
        % if (isa(val,'experimentSpace'))
        %     obj.F = val;
        % else
        %     error('ICNA:analysis:set:ExperimentSpace:InvalidInput',...
        %           'Value must be of class experimentSpace');
        % end
        % obj.runStatus=false;

    case 'metric'
        obj.metric=m;
        % if (ischar(val))
        %     m=lower(val);
        %     switch (m)
        %         case 'euc' %DEPRECATED
        %             obj.metric='euclidean';
        %         case 'euclidean'
        %             obj.metric=m;
        %         case 'corr'
        %             obj.metric=m;
        %         case 'jsm'
        %             obj.metric=m;
        %         case 'geo' %DEPRECATED
        %             obj.metric='geo_euclidean';
        %         case 'geo_euclidean'
        %             obj.metric=m;
        %         case 'geo_corr'
        %             obj.metric=m;
        %         case 'geo_jsm'
        %             obj.metric=m;
        %         otherwise
        %             error('ICNA:analysis:set:Metric:InvalidInput',...
        %                   ['Selected distance metric not recognised.' ...
        %                 'Currently accepted values are ' ...
        %                 '''euclidean'', ''corr'', ''jsm'', ' ...
        %                 '''geo_euclidean'', ''geo_corr'' and ' ...
        %                 '''geo_jsm''.']);
        %     end
        % else
        %     error('ICNA:analysis:set:Metric:InvalidInput',...
        %           'Metric must be a string.');
        % end
        % obj.runStatus=false;

    case 'embedding'
        obj.embedding=m;
        % if (ischar(val))
        %     m=lower(val);
        %     switch (m)
        %         case 'cmds'
        %             obj.embedding=m;
        %         case 'cca'
        %             obj.embedding=m;
        %             %case 'lle'
        %             %    obj.embedding=m;
        %         otherwise
        %             error('ICNA:analysis:set:Embedding:InvalidInput',...
        %                 ['Selected embedding technique not recognised. ' ...
        %                 'Currently accepted values are ''cmds'' and ' ...
        %                 '''cca''.']);
        %     end
        % else
        %     error('ICNA:analysis:set:Embedding:InvalidInput',...
        %           'Embedding technique must be a string.');
        % end
        % obj.runStatus=false;
        
    case 'projectiondimensionality'
        obj.projectionDimensionality=val;
        % if (isscalar(val) && isreal(val) && ~ischar(val) ...
        %         && (floor(val)==val) && val>0)
        %     obj.projectionDimensionality=val;
        % else
        %     error('ICNA:analysis:set:ProjectionDimensionality:InvalidInput',...
        %           'Projection dimensionality must be a positive integer.');
        % end
        % obj.runStatus=false;

    case 'subjectsincluded'
        obj.subjectsIncluded=val;
        % %Should be a vector of IDs
        % if isempty(val)
        %     obj.subjectsIncluded=[];
        % elseif (isreal(val) && ~ischar(val)...
        %         && all(all(floor(val)==val)) && all(all(val>0)))
        %     %It is not check whether the selected channels
        %     %exist
        %     obj.subjectsIncluded=unique(reshape(val,1,numel(val)));
        % else
        %     error('ICNA:analysis:set:SubjectsIncluded:InvalidInput',...
        %           'Subjects included must be a matrix of positive integers.');
        % end
        % obj.runStatus=false;

    case 'sessionsincluded'
        obj.sessionsIncluded=val;
        % %Should be a vector of IDs
        % if isempty(val)
        %     obj.sessionsIncluded=[];
        % elseif (isreal(val) && ~ischar(val)...
        %         && all(all(floor(val)==val)) && all(all(val>0)))
        %     %It is not check whether the selected channels
        %     %exist
        %     obj.sessionsIncluded=unique(reshape(val,1,numel(val)));
        % else
        %     error('ICNA:analysis:set:SessionsIncluded:InvalidInput',...
        %           'Sessions included must be a matrix of positive integers.');
        % end
        % obj.runStatus=false;

       
    case 'channelgroups'
        obj.channelGrouping=val;
        % %Should be a matrix where
        % %each row is a group, and 
        % %each value is a channel.
        % if isempty(val)
        %     obj.channelGrouping=val;
        % elseif (isreal(val) && ~ischar(val)...
        %         && all(all(floor(val)==val)) && all(all(val>0)))
        %     %It is not check whether the selected channels
        %     %exist
        %     obj.channelGrouping=val;
        % else
        %     error('ICNA:analysis:set:ChannelGroups:InvalidInput',...
        %           'Channel groups must be a matrix of positive integers.');
        % end
        % obj.runStatus=false;
           
    case 'signaldescriptors'
        obj.signalDescriptors=val;
        % %An Mx2 matrix of signal descriptors <dataSource,signal Idx>
        % %Note that by now it only accepts 1 data source
        % %See "the curse of the data source" in analysis.
        % if isempty(val)
        %     obj.signalDescriptors=val;
        % elseif (isreal(val) && ~ischar(val) && size(val,2)==2 ...
        %         && all(all(floor(val)==val)) && all(all(val>0)))
        %     %Accept only 1 data source (i.e. all data Source are the same)
        %     tmpVal=val(:,1);
        %     tmpVal=tmpVal-tmpVal(1);
        %     if (all(tmpVal==0))
        %         obj.signalDescriptors=val;
        %     else
        %         error('ICNA:analysis:set:SignalDescriptors:SingleDataSourceViolation',...
        %           ['Current version requires all signals '...
        %            'to belong to the same dataSource. Please'...
        %            'type ''help analysis'' for more information.']);
        %     end
        % else
        %     error('ICNA:analysis:set:SignalDescriptors:InvalidInput',...
        %           ['Signal descriptor must be a Mx2 matrix '...
        %            '<dataSource,signal Idx>.']);
        % end
        % obj.runStatus=false;
           
        
    otherwise
      error('ICNA:analysis:set:UndefinedProperty',...
            ['Property ' prop ' not valid.'])
   end
end



end