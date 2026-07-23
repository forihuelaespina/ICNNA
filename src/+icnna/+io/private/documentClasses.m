function classes = documentClasses()
% List the ICNNA classes recognised as document-level for MAT-file I/O.
%
% classes = documentClasses()
%
% Returns a curated list of what ICNNA recognises as a document.
%
% Single source of truth for what icnna.io.load and icnna.io.save treat as a
% "document-level" object: the top-level unit persisted to, and recovered
% from, a MAT-file. Both functions query this list, so their notion of what
% constitutes a document can never drift apart.
%
%% Behaviour
%
% Returns a curated cell array of class-name strings. Being a "document" is a
% deliberate design decision, not something discovered from the class
% hierarchy, hence an explicit allow-list rather than an isa()-based test:
%
%   @li 'experiment'               - legacy top-level container (interim).
%   @li 'experimentSpace'          - legacy analysis-space container (interim).
%   @li 'icnna.data.core.document' - the unified document class (future; not
%                                    yet available, listed so both I/O
%                                    functions are ready the day it lands).
%
% The list trends SMALLER over time: the roadmap converges on the single
% icnna.data.core.document, at which point the interim legacy entries retire.
%
%% Remarks
%
% This is a PRIVATE helper. It lives in +icnna/+io/private/, so it is callable
% (by simple name i.e. documentClasses, unqualified i.e. rather than
% icnna.io.documentClasses) ONLY from the functions in +icnna/+io/, namely
% icnna.io.load and icnna.io.save. It is intentionally NOT part of the public
% icnna.io API and is invisible to users and to the rest of the toolbox.
%
%% Assumptions
%
% Names must match EXACTLY the class strings reported by whos('-file',...) and
% by class(obj): case-sensitive, legacy classes unqualified, packaged classes
% fully qualified.
%
%% Input parameters
%
%  None.
%
%% Output
%
% classes - cell[1xN] of char[]
%   The curated list of document-level class names.
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also icnna.io.load, icnna.io.save
%


%% Log
%
% -- ICNNA v1.4.2.1
%
% 21-Jul-2026: FOE
%   + Function created. Single source of truth for the document-level class
%     list shared by icnna.io.load and icnna.io.save, removing the previous
%     cross-file duplication of the list. Placed in +icnna/+io/private/ so it
%     stays out of the public API (private-folder visibility).


% SINGLE SOURCE OF TRUTH for what counts as a "document" across
% icnna.io.load and icnna.io.save. Add or retire document classes HERE only.
classes = { ...
    'experiment', ...            % legacy document (interim)
    'experimentSpace', ...       % legacy document (interim)
    'icnna.data.core.document'}; % unified document (future)
end
