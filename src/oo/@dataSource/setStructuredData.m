function obj=setStructuredData(obj,id,sd)
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
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also addStructuredData, removeStructuredData, getStructuredData
%


%% Log
%
% File created: 25-Apr-2008
% File last modified (before creation of this log): N/A. This had not
%   been modified since creation
%
% 25-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Started to update the get/set methods calls for struct like access.
%




type=obj.type;
if (isempty(type))
    if ~isa(sd,'structuredData')
        error([inputname(2) ' is not a structured data']);
    end
else
    if ~isa(sd,type)
        error([inputname(2) ' is not of valid ''Type''.']);
    end
end    
    

idx=findStructuredData(obj,id);
if (~isempty(idx))
    obj.structured(idx)={sd};
end
assertInvariants(obj);


end