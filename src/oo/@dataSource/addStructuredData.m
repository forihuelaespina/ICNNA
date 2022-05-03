function obj=addStructuredData(obj,i)
% DATASOURCE/ADDSTRUCTUREDDATA Add a new structured data
%
% obj=addStructuredData(obj,i) Add a new structured data i to the
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
% Copyright 2008-13
% @date: 25-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 4-Jan-2013
%
% See also removeStructuredData, setStructuredData
%

%% log
%
% 02-May-2022 (ESR): To solve the ID problem it was necessary to update 
% the code and make all classes public. 
% + When the data structure is empty it is necessary to assign the ID to it.
%   obj.structured(1)= {i};
%

type=get(obj,'Type');
if (isempty(type))
    if ~isa(i,'structuredData')
        error('ICNA:dataSource:addStructuredData:InvalidParameterClass',...
              [inputname(2) ' is not a structured data']);
    end
else
    if ~isa(i,type)
        error('ICNA:dataSource:addStructuredData:InvalidParameterType',...
              [inputname(2) ' is not of valid ''Type''.']);
    end
end    
    

idx=findStructuredData(obj,get(i,'ID'));
if isempty(idx)
    if (isempty(obj.structured))
        obj.structured(1)= {i};
        obj.activeStructured=get(i,'ID');
    else
        obj.structured(end+1)={i};
    end
else
    warning('ICNA:dataSource:addStructuredData:RepeatedID',...
        'A structured data with the same ID has already been defined.');
end
assertInvariants(obj);