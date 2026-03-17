function res=version_IsHigherOrEqual(verStr1,verStr2)
%DEPRECATED. Compares 2 version strings and decides whether ver1>=ver2
%
% res=version_IsHigherOrEqual(verStr1,verStr2) Compares 2 version
%       strings and decides whether ver1>=ver2
%
% This function is deprecated since ICNNA version 1.4.0.
% Please use icnna.util.compareVersion instead.
% 
% Copyright 2008-25
% @author: Felipe Orihuela-Espina
%
% See also icnna.util.compareVersion
%


%% Log
%
% File created: 25-Apr-2008
% File last modified (before creation of this log): 22-Dec-2008
%
% 14-Dec-2025: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Deprecated function.
%


warning('icnna:util:version_isHigherOrEqual:Deprecated',...
         ['This function is now deprecated (since v1.4.0). ' ...
          'Please use icnna.util.compareVersions instead.']);


res=false;
idx1=find(verStr1=='.',1,'first');
if isempty(idx1)
    ver1_token = verStr1;
    verStr1=[];
else
    ver1_token = verStr1(1:idx1-1);
    verStr1=verStr1(idx1+1:end);
end
idx2=find(verStr2=='.',1,'first');
if isempty(idx2)
    ver2_token = verStr2;
    verStr2=[];
else
    ver2_token = verStr2(1:idx2-1);
    verStr2=verStr2(idx2+1:end);
end


ver1_token = str2double(ver1_token);
ver2_token = str2double(ver2_token);


if ver1_token > ver2_token
    res=true;
elseif ver1_token < ver2_token
    res=false;
else %ver1_token == ver2_token 
    if isempty(verStr2)
        res=true;
    elseif isempty(verStr1)
        res=false;
    else %There are still sub-tokens for both versions
        %Check sub-tokens
        res=version_IsHigherOrEqual(verStr1,verStr2);
    end
end

end
