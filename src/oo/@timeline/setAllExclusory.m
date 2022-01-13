function obj=setAllExclusory(obj,exclusoryState)
%TIMELINE/SETALLEXCLUSORY Set the exclusory behaviour for all conditions
%
% obj=setAllExclusory(obj) Sets the behaviour among every pair
%    of conditions to exclusory.
%
% obj=setAllExclusory(obj,exclusoryState) Sets the exclusory
%    behaviour among all pair of conditions to exclusoryState.
%	  exclusoryState=0 => Non exclusory behaviour
%	  exclusoryState=1 => Exclusory behaviour
%
% @li If provided exclusoryState is either 0 or 1, otherwise
%it is ignored and nothing is done.
%
%
%
% Copyright 2008
% @date: 29-May-2008
% @author Felipe Orihuela-Espina
%
% See also switchExclusory, setExclusory
%

if (~exist('exclusoryState','var'))
    exclusoryState=1;
end

if ((exclusoryState==1) || (exclusoryState==0))
    obj.exclusory(:)=exclusoryState;
    diag= eye(size(obj.exclusory));
    obj.exclusory(diag==1)=0;
else
    return;
end
assertInvariants(obj);