function obj=addStructuredData(obj,sd)
% DATASOURCE/ADDSTRUCTUREDDATA Add a new structured data
%
% obj=addStructuredData(obj,sd) Add a new structured data i to the
%   dataSource. If a structured data with the same ID has
%   already been defined within
%   the dataSource, then a warning is issued
%   and nothing is done. If the new structured data is the first to be
%   inserted, it automatically becomes the active structured data.
%
%
%The new structuredData must be of the valid ''Type''.
%See dataSource for more information, otherwise a error is generated.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also removeStructuredData, setStructuredData
%




%% Log
%
% File created: 25-Apr-2008
% File last modified (before creation of this log): 4-Jan-2013
%
% 24-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Updated calls to get attributes using the struct like syntax
%



type=obj.type;
if (isempty(type))
    if ~isa(sd,'structuredData')
        error('ICNNA:dataSource:addStructuredData:InvalidParameterClass',...
              [inputname(2) ' is not a structured data']);
    end
else
    if ~isa(sd,type)
        error('ICNNA:dataSource:addStructuredData:InvalidParameterType',...
              [inputname(2) ' is not of valid ''Type''.']);
    end
end    
    

idx=findStructuredData(obj,sd.id);
if isempty(idx)
    obj.structured(end+1)={sd};
    tmpActive = obj.activeStructured;
    if (~isempty(obj.structured))
        tmpActive = sd.id;
    end
    obj.activeStructured = tmpActive;
else
    warning('ICNNA:dataSource:addStructuredData:RepeatedID',...
        'A structured data with the same ID has already been defined.');
end
assertInvariants(obj);



end