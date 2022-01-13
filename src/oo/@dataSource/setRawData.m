function obj=setRawData(obj,r,c)
% DATASOURCE/SETRAWDATA Set the dataSource's raw data
%
% obj=setRawData(obj,r) Sets the dataSource raw data to r.
%
% obj=setRawData(obj,r,convert) Sets the dataSource raw data to r.
%   If convert==true, a new image is added resulting from
%   converting this rawData into a StructuredData.
%
%% Remarks
%
%   #================================================#
%   | If dataSource is lock, all previous existing   |
%   | Structured data element will also be cleared!!  |                                                    |
%   #================================================#
%
%
% Copyright 2008
% @date: 13-Jun-2008
% @author Felipe Orihuela-Espina
%
% See also assertInvariants, clearRawData, clearStructuredData
%

convertOnInit=false;
if (exist('c','var'))
    convertOnInit=c;
end

if (isa(r,'rawData'))
    if (obj.lock)
        obj=clearStructuredData(obj);
    end
    obj.rawData=r;
    if (convertOnInit)
        obj=addStructuredData(obj,convert(obj.rawData));
    end
    assertInvariants(obj);
else
    error('Argument r is not of class ''rawData''.');
end