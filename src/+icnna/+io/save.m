function save(theObject, filename)
% Save a document-level ICNNA object to a .mat file in ICNNA's uniform format.
%
%   icnna.io.save(theObject, filename)
%
% Canonical persistence entry point for ICNNA. Writes a document-level ICNNA
% object to disk in a single, uniform MAT format (v7.3 / HDF5) so that files
% written from now on are self-describing and consistently recoverable.
%
%% Behaviour
%
%   @li The object is stored in MAT v7.3 (HDF5) format regardless of the
%       user's MAT-file preference, giving one uniform, partially-loadable,
%       self-describing container.
%   @li INTERIM convention (pending @icnna.data.core.document): an
%       icnna:io:save:interimConvention
%       warning notice is emitted noting this predates the unified
%       document class and will become |icnnaDoc|.
%   @li Only DOCUMENT-LEVEL objects are supported. Saving isolated objects
%       (e.g. a lone @structuredData) is out of scope; use MATLAB's save.
%
%% Remarks
%
% Forcing v7.3 makes future files uniform and h5-recoverable, at the cost
% that non-HDF5 MAT readers (e.g. Python scipy.io.loadmat without h5py) can
% no longer read them. ICNNA-native use and SNIRF export are unaffected.
%
% This is a naive, going-forward save (at v1.4.2.1). A formal persistence
% layer arrives with the storageAdapter (roadmap v1.4.3.5).
%
%% Error handling
%
%   @li icnna:io:save:unsupportedObject - |theObject| is not a supported
%       document-level ICNNA class.
%   @li icnna:io:save:cannotWrite - the file could not be written.
%
%% Input parameters
%
% theObject - {icnna.data.core.experiment | icnna.data.core.experimentSpace}
%   (interim; @icnna.data.core.document once available). The document-level
%   ICNNA object to persist.
%
% filename - char row vector | string scalar. Default: none (required).
%   Full path of the target .mat file.
%
%% Output
%
% N/A
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also icnna.io.load
%


%% Log
%
% -- ICNNA v1.4.2.1
%
% 21-Jul-2026: FOE
%   + File created.
%   + Uniform document-level save forcing MAT v7.3, pending
%     the unified document class and the storageAdapter persistence layer.
%



%% 1. Validate theObject is a supported document-level class
%    (@experiment -> 'E' ; @experimentSpace -> 'S'); else
%    error('icnna:io:save:unsupportedObject', ...).
validateDocumentObject(theObject);


%% 2. Emit the interim/deprecation notice (E/S convention predates
%    icnna.data.core.document; will become 'icnnaDoc').
%
emitSaveDeprecationNotice(theObject);

%% 3. Assign to the chosen variable name and write forcing '-v7.3':
writeMatFile(theObject,filename);

end





%% AUXILIARY FUNCTION

function validateDocumentObject(theObject)
% Ensure the object is a supported document-level ICNNA object.
%
%   validateDocumentObject(theObject)
%
%% Input parameters
%
% theObject - {@experiment | @experimentSpace | icnna.data.core.document}
%   The document-level variable to be saved.
%
%% Output
%
%  N/A.
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also icnna.io.save
%


%% Log
%
% -- ICNNA v1.4.2.1
%
% 21-Jul-2026: FOE
%   + Function created.
%

docClasses = documentClasses();
        %icnna.io private function.
        % A curated list of what ICNNA recognises as a document.
        % Note that it is invoked by plain name, not package-qualified,
        % i.e. documentClasses rather than icnna.io.documentClasses

if ~ismember(class(theObject),docClasses)
    error('icnna:io:save:unsupportedObject', ...
        ['Objects of class "%s" are not supported by ' ...
        'icnna.io.save. Use MATLAB''s save instead. ' ...
        'ICNNA suggests you use it with flag ''-v7.3'' or above.'], ...
        class(theObject));
end

end





function emitSaveDeprecationNotice(theObject)
% Warn that the interim persistence convention is temporary.
%
%   emitSaveDeprecationNotice(theObject)
%
%% Input parameters
%
% theObject - {@experiment | @experimentSpace | icnna.data.core.document}
%   The document-level variable to be saved.
%
%% Output
%
%  N/A.
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also icnna.io.save
%


%% Log
%
% -- ICNNA v1.4.2.1
%
% 21-Jul-2026: FOE
%   + Function created.
%

if isa(theObject,'icnna.data.core.document')
    return;
end

warning('icnna:io:save:interimConvention', ...
    ['This file is being written using the interim persistence ' ...
    'convention. Future ICNNA releases will store document-level ' ...
    'objects as "icnnaDoc".']);

end





function writeMatFile(theObject,filename)
% Write the MAT-file in ICNNA's canonical format.
%
%   writeMatFile(theObject,filename)
%
%% Input parameters
%
% theObject - {@experiment | @experimentSpace | icnna.data.core.document}
%   The document-level variable itself.
% filename - char[]
%   Output filename inc. path.
%
%% Output
%
%  N/A.
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also icnna.io.save
%


%% Log
%
% -- ICNNA v1.4.2.1
%
% 21-Jul-2026: FOE
%   + Function created.
%

try
    switch class(theObject)
        case 'experiment'
            E = theObject;
            builtin('save', filename, 'E', '-v7.3');
    
        case 'experimentSpace'
            S = theObject;
            builtin('save', filename, 'S', '-v7.3');
    
        case 'icnna.data.core.document'
            icnnaDoc = theObject;
            builtin('save', filename, 'icnnaDoc', '-v7.3');

        otherwise
            error('icnna:io:save:documentLevelObjectClassUnknown', ...
                'Document-level object''s class %s unknown.', ...
                class(theObject));

    
    end

catch ME
    if strcmp(ME.identifier, 'icnna:io:save:documentLevelObjectClassUnknown')
        rethrow(ME); % Preserve as-is
    end
    error('icnna:io:save:cannotWrite', ...
        'Unable to write "%s": %s', filename, ME.message);
end

end



