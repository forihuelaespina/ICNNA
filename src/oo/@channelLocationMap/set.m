function obj = set(obj,varargin)
%CHANNELLOCATIONMAP/SET DEPRECATED. Set object properties and return the updated object
%
% obj = set(obj,varargin) Sets the indicated property propName and
%    return the updated object
%
%
%
%% Properties
%
% ID - Numerical ID
% Description - Description string
% nChannels - Number of channels
% nOptodes - Number of optodes
% surfacePositioningSystems - Surface Positioning System. Currently
%       only the international '10/20' and 'UI 10/10'
%       (default) systems [JurcakV2007] are supported.
% stereotacticPositioningSystems - Stereotactic Positioning System.
%       Currently only the 'MNI' (default) and 'Talairach'
%       systems are supported.
%
%
%% References
%
%   [JurcakV2007] Jurcak, V.; Tsuzuki, D.; Dan, I. "10/20, 10/10,
%   and 10/5 systems revisited: Their validity as relative
%   head-surface-based positioning systems" NeuroImage 34 (2007) 1600–1611
%
%
%
% Copyright 2012-23
% @author: Felipe Orihuela-Espina
%
% See also get, display
%



%% Log
%
%
% File created: 26-Nov-2012
% File last modified (before creation of this log): 10-Sep-2013
%
% 8-Sep-2013: Support for updating number of optodes. Also the pairings
%       conforming the channels now automatically updates thenselves
%       when updating the number of channels.
%
% 29-Apr-2020: Bug fixed. Setting the number of optodes, was
%       checking on the number of channels. It now checks for the number of
%       optodes correctly.
%
% 20-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED.
%
%


warning('ICNNA:channelLocationMap:set:Deprecated',...
        ['DEPRECATED. Use struct like syntax for setting the attribute ' ...
         'e.g. channelLocationMap.' lower(varargin{1}) ' = ... ']); 





propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch lower(prop)

       case 'id'
           obj.id = val;
           % if (isscalar(val) && isreal(val) && ~ischar(val) ...
           %  && (val==floor(val)) && (val>0))
           %  %Note that a char which can be converted to scalar
           %  %e.g. will pass all of the above (except the ~ischar)
           %      obj.id = val;
           % else
           %     error('ICNA:channelLocationMap:set:InvalidID',...
           %           'Value must be a scalar natural/integer');
           % end

       case 'description'
           obj.description = val;
           % if (ischar(val))
           %     obj.description = val;
           % else
           %     error('ICNA:channelLocationMap:set:InvalidPropertyValue',...
           %           'Value must be a string');
           % end
           
       case 'nchannels'
           obj.nChannels = val;
        % if (isscalar(val) && (floor(val)==val) ...
        %         && val>=0)
        %     if val > obj.nChannels
        %         %Add new channels
        %         obj.chLocations(end+1:val,:) = nan(val-obj.nChannels,3);
        %         obj.pairings(end+1:val,:) = nan(val-obj.nChannels,2);
        %         obj.chSurfacePositions(end+1:val) = {''};
        %         obj.chStereotacticPositions(end+1:val,:) = ...
        %                                      nan(val-obj.nChannels,3);
        %         obj.chOptodeArrays(end+1:val) = nan(val-obj.nChannels,1);
        %         obj.chProbeSets(end+1:val) = nan(val-obj.nChannels,1);
        %     elseif val < obj.nChannels
        %         %Discard the latter channels
        %         obj.chLocations = obj.chLocations(1:val,:);
        %         obj.pairings = obj.pairings(1:val,:);
        %         obj.chSurfacePositions = obj.chSurfacePositions(1:val);
        %         obj.chStereotacticPositions = ...
        %                         obj.chStereotacticPositions(1:val,:);
        %         obj.chOptodeArrays = obj.chOptodeArrays(1:val);
        %         obj.chProbeSets = obj.chProbeSets(1:val);
        %     end
        %     obj.nChannels = val;
        % else
        %     error('ICNA:channelLocationMap:set:InvalidParameterValue',...
        %             'Value must be a positive integer or 0.');
        % end

       case 'noptodes'
           obj.nOptodes = val;
        % if (isscalar(val) && (floor(val)==val) ...
        %         && val>=0)
        %     if val > obj.nOptodes
        %         %Add new optodes
        %         obj.optodesLocations(end+1:val,:) = nan(val-obj.nOptodes,3);
        %         obj.optodesSurfacePositions(end+1:val) = {''};
        %         obj.optodesOptodeArrays(end+1:val) = nan(val-obj.nOptodes,1);
        %         obj.optodesProbeSets(end+1:val) = nan(val-obj.nOptodes,1);
        %     elseif val < obj.nOptodes
        %         %Discard the latter optodes
        %         obj.optodesLocations = obj.optodesLocations(1:val,:);
        %         obj.optodesSurfacePositions = obj.optodesSurfacePositions(1:val);
        %         obj.optodesOptodeArrays = obj.optodesOptodeArrays(1:val);
        %         obj.optodesProbeSets = obj.optodesProbeSets(1:val);
        %     end
        %     obj.nOptodes = val;
        % else
        %     error('ICNA:channelLocationMap:set:InvalidParameterValue',...
        %             'Value must be a positive integer or 0.');
        % end

    case 'surfacepositioningsystem'
        obj.surfacePositioningSystem=val;
        % if (ischar(val))
        %     if (strcmpi(val,'10/20') ...
        %        || strcmpi(val,'UI 10/10'))
        %         obj.surfacePositioningSystem=val;
        %         %Unset those positions which are not part of the
        %         %positioning system
        %         [valid]=channelLocationMap.isValidSurfacePosition(...
        %                                     obj.surfacePositions,...
        %                                     obj.surfacePositioningSystem);
        %         obj.surfacePositions(~valid)={''};
        %     else
        %     error('ICNA:channelLocationMap:set:InvalidParameterValue',...
        %             ['Currently valid surface positioning systems are: ' ...
        %             '''10/20'' and ''UI 10/10''.']);
        %     end
        % else
        %     error('ICNA:channelLocationMap:set:InvalidParameterValue',...
        %             'Value must be a string indicating a positioning system.');
        % end


    case 'stereotacticpositioningsystem'
        obj.stereotacticPositioningSystem=val;
        % if (ischar(val))
        %     if (strcmpi(val,'MNI') ...
        %        || strcmpi(val,'Talairach'))
        %         obj.stereotacticPositioningSystem=val;
        %     else
        %     error('ICNA:channelLocationMap:set:InvalidParameterValue',...
        %             ['Currently valid stereotactic positioning systems are: ' ...
        %             '''MNI'' and ''Talairach''.']);
        %     end
        % else
        %     error('ICNA:channelLocationMap:set:InvalidParameterValue',...
        %             'Value must be a string indicating a positioning system.');
        % end


   otherwise
      error('ICNNA:channelLocationMap:set:InvalidPropertyName',...
            ['Property ' prop ' not valid.'])
   end
end
assertInvariants(obj);


end
