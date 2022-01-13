function obj=setStructuredData(obj,id,i)
% DATASOURCE/SETSTRUCTUREDDATA Replace a structured data element
%
% obj=setStructuredData(obj,id,newStructuredData) Replace structured
%   data element whose ID==id with the new element. If the structured
%   data element whose ID==id has not been
%   defined, then nothing is done.
%
%The new structuredData must be of the valid ''Type''.
%See dataSource for more information, otherwise a error is generated.
%
%
% Copyright 2008
% @date: 25-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also addStructuredData, removeStructuredData, getStructuredData
%


type=get(obj,'Type');
if (isempty(type))
    if ~isa(i,'structuredData')
        error([inputname(2) ' is not a structured data']);
    end
else
    if ~isa(i,type)
        error([inputname(2) ' is not of valid ''Type''.']);
    end
end    
    

idx=findStructuredData(obj,id);
if (~isempty(idx))
    obj.structured(idx)={i};
end
assertInvariants(obj);