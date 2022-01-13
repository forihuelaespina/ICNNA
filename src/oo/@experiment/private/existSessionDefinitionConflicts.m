function found=existSessionDefinitionConflicts(obj,def)
%EXPERIMENT/EXISTSESSIONDEFINITIONCONFLICTS
%Check conflicts between session definitions.
%
% found=checkSessionDefinitionConflicts(obj,subject)
%   Check conflicts between existing session definitions in the
%   experiment, and those in the subject.
%
% found=checkSessionDefinitionConflicts(obj,defs)
%   Check conflicts between existing session definitions in the
%   experiment, and those in defs. Parameter defs can be single
%   sessionDefinition or a set of them in a cell array.
%   
%In all cases, the function return true if a conflict has been
%found or false if no conflicts has been found (free of conflicts).
%
% Copyright 2008
% @date: 11-Jul-2008
% @author Felipe Orihuela-Espina
%
% See also experiment, subject, sessionDefinition, assertInvariants

found=false; %true if a conflict has been found.
if isa(def,'sessionDefinition')
    id=get(def,'ID');
    expDef=getSessionDefinition(obj,id);
    if (~isempty(expDef))
        found = ~(def == expDef);
    end

elseif isa(def,'subject')
    defs=collectSessionDefinitionsFromSubject(obj,def);
    found=existSessionDefinitionConflicts(obj,defs);

else %Must be a cell array of sessionDefinitions
    nDefs=length(def);
    for ss=1:nDefs
        found=existSessionDefinitionConflicts(obj,def{ss});
        if found
            break
        end
    end
end
    