function obj=checkIntegrity(obj,varargin)
%SUBJECT/CHECKINTEGRITY Check the integrity of the subject
%
% obj=checkIntegrity(obj) Check the integrity for the active
%	image of all the sessions of the subject.
%
%
%Default integrity tests will be applied. See
%neuroimage.checkIntegrity and their subclasses for options.
%
%
%
%
% Copyright 2008
% @date: 17-Jun-2008
% @author Felipe Orihuela-Espina
%
% See also integrityStatus, nirs_neuroimage, neuroimage.checkIntegrity
%

ids=getSessionList(obj);
for ii=ids
    idx=findSession(obj,ii);
    obj.sessions(idx)=checkIntegrity(obj.sessions(idx),varargin);
end

