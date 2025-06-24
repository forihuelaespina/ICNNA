function res=eq(obj,obj2)
%RAWDATA/EQ Compares two objects.
%
% obj1==obj2 Compares two objects.
%
% res=eq(obj1,obj2) Compares two objects.
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
%
% See also icnna.data.core.rawData
%


%% Log of old class |rawData| before the creation of this class.
%
% File created: 11-Jul-2008
% File last modified (before creation of this log): N/A This method had
%   not been updated since creation.
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Updated calls to get attributes using the struct like syntax
%   + Removed some old commented code no longer in use.
%   + Added support for new property classVersion
%

%% Log
%
% 2-Feb-2025: FOE
%   + Method created. Part of the code is inherited from
%   old class |rawData| (dating back to 2008 - See above).
%   + Property .date is now of type datetime.
%   + Added support for new property .path
%   + Added support for new property .dataFiles
%
%

res=true;
if ~isa(obj2,'rawData')
    res=false;
    return
end

res = res && (obj.classVersion==obj2.classVersion);
res = res && (obj.id==obj2.id);
res = res && (strcmp(obj.description,obj2.description));
res = res && (strcmp(obj.path,obj2.path));
res = res && (obj.date==obj2.date);
res = res && (testCase.verifyThat(obj.dataFiles,IsEqualTo(obj2.dataFiles)));
    %See https://uk.mathworks.com/help/matlab/ref/matlab.unittest.constraints.dictionarycomparator-class.html
end