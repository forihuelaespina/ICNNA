function setBundle(obj,tmpE,tmpB,tmpp)
%Sets the total space, base space and projection of the bundle
%
% setBundle(obj,E,B)
% setBundle(obj,E,B,p)
% obj.setBundle(...)
%
% @li In principle the projection does NOT have to be 1-to-1 ergo the
%   number of rows of E and B do not have to comply.
% @li If p is not provided a naive bijective projection is created. See
%   parameters section below.
%
%   
%% Parameters
%
%   .E - Table. Default is empty.
%       The total space. Each row is a family of (vector) spaces. Each
%       column will be a vector space on its own.
%   .B - Table. Default is empty.
%       The base space. Each row is a point in the base space.
%   .p - Optional. 
%       A table with two columns;
%           + 'FamilyOfSpaces' pointing to one row of E, and
%           + 'BaseSpacePoint' pointing to one row of B
%       By default a bijective implicit projection p:E->B
%           where the j-th row of E is associated to the j-th row of B.
%           In this case, E and B ought to have the same number of rows.
%
%
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
%
% See also icnna.data.core.experimentBundle
%


%% Log
%
% File created: 26-Jul-2025
%
% -- ICNNA v1.3.1
%
% 26-Jul-2025: FOE 
%   + File created. 
%
%


nFamilySpaces = size(tmpE,1);
nBasePoints   = size(tmpB,1);

if ~exist('tmpp','var')
    %By default, attempt a naive bijective projection between the
    % total space and the base space.
    assert(nFamilySpaces == nBasePoints,...
           ['Default bijective projection is not possible if ' ...
            'the total space E and the base space B do not have ' ...
            'the same cardinality.']);
    nCases = nFamilySpaces;
    tmpp = table('Size',[nCases 2],...
        'VariableTypes',{'uint32','uint32'},...
        'VariableNames',{'FamilyOfSpaces','BaseSpacePoint'});
    tmpp.FamilyOfSpaces(1:nCases) = 1:nCases;
    tmpp.BaseSpacePoint(1:nCases) = 1:nCases;
end


%In principle the projection does NOT have to be 1-to-1 ergo the
%number of rows of E and B do not have to comply. No need to assert.

%If projection is present, make sure all entries exist.
assert(all(ismember(tmpp.FamilyOfSpaces,1:nFamilySpaces)),...
        'icnna:data:core:experimentBundle:setBundle:InvalidProjection',...
        ['Some family of spaces of projection p may not exits in the ' ...
        'total space E.']);
assert(all(ismember(tmpp.FamilyOfSpaces,1:nBasePoints)),...
        'icnna:data:core:experimentBundle:setBundle:InvalidProjection',...
        ['Some base points of projection p may not exits in the ' ...
        'base space B.']);



obj.E = tmpE;
obj.B = tmpB;
obj.p = tmpp;


end