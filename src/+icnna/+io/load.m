function [theObject] = load(filename)
% Load a document-level ICNNA .mat file, flagging reduced-fidelity legacy files.
%
% [theObject] = icnna.io.load(filename)
%
% Canonical entry point for reading a document-level ICNNA object from disk.
% It detects files that predate class-versioning integrity (v1.4.2.1) and
% warns the user WITHOUT failing, then returns the object as loaded.
% 
% No migration is performed for old files: for faithful recovery of a
% flagged file, open it with the ICNNA release that wrote it (see ICNNA
% past releases in /stable), migrate and re-save.
%
%% Behaviour
%
% In the past, ICNNA did not provided a document-level entry point neither
% for save or load. There was no concept of an ICNNA document, and
% consequently, the user can save individual ICNNA objects e.g. save
% an instance of legacy classes @experiment or @experimentSpace were
% the most common. Strictly, this is, and will still be, allowed in the
% foreseeable future, but it is now an explicitly discouraged practice).
%
% From v1.4.2.1, detection of what to load from a file is future-looking.
% Once files are saved with the
% @icnna.data.core.document (which will become available in ICNNA
% version vX.X.X), then that variable will be the one saved/loaded
% by default. Until then, a header/version heuristic is used:
%
%   @li (i)  If the document carries an embedded ICNNA metadata block, its
%            stored ICNNA/per-class versions drive the decision precisely.
%   @li (ii) Otherwise, the LEGACY heuristic applies, with two independent
%       checks:
%       @li warn icnna:io:legacyFile when the creation date is undetermined
%           or precedes VERSIONING_INTEGRITY_DATE, and
%       @li warn icnna:io:staleClassVersion when the loaded top-level
%           object's classVersion is older than the current class version.
% 
%           Either or both may fire. Either case, the object is loaded
%           and returned regardless (accept-loss policy).
%   @li (iii) If the file holds an ICNNA object that is NOT document-level
%            (e.g. a lone @structuredData), no load is attempted: the user
%            is informed that icnna.io.load handles only document-level
%            files only and he is redirected to use MATLAB's load
%            directly (error icnna:io:load:notDocumentLevel).
%   @li (iv) If the file holds no ICNNA object, then it is out of scope
%            for this function (error icnna:io:load:notDocumentLevel).
%
%% Legacy compatibility (mirror of doc/ICNNA-Version.log, KNOWN ISSUES)
%
% Loading a pre-v1.4.2.1 file may silently coerce or lose these properties:
%
%   |condition.cevents|       table -> struct    May load populated but values
%                                                are meaningles (worst case)
%   |timeline.startTime|      datenum -> datetime may reset to a default date
%   |timeline.conditions|     was |conds|        may be empty
%   |rawData.dataFiles|       dictionary->struct  may be missing/defaulted
%   |metaDataTags.additional| cell/dict->struct   may be missing/defaulted
%   |metaDataTags| (whole)    class renamed       object may fail to load
%
% Faithful recovery: open with the originating release (/stable), migrate
% and re-save.
%
%% Remarks
%
% Read-only: this function never modifies the loaded file. This function
% uses |whos('-file',...)| to identify the document object by CLASS without
% loading and reports the stored class name even when that
% class no longer exists on the path. Inside this function, unqualified
% |load| / |whos| are reached via MATLAB's builtins.
%
%% Assumptions
%
% |filename| is a MATLAB .mat file (any of v6/v7/v7.3). The creation date is
% read from the standard 116-byte descriptive header; if it cannot be
% parsed, the file is treated as legacy (fail-safe to a warning).
%
%% Error handling
%
%   @li icnna:io:load:fileNotFound     - |filename| does not exist.
%   @li icnna:io:load:notDocumentLevel - the file holds an ICNNA object that
%       is not document-level or does NOT hold any ICNNA object at all;
%       use MATLAB's load directly.
%   @li icnna:io:load:multipleDocuments - the file holds multiple ICNNA
%       document-level objects e.g. an @experiment and an @experimentSpace.
%       While this behaviour was acceptable in old ICNNA versions, this
%       is now discouraged;
%       use MATLAB's load directly.
%
% Warnings (non-fatal; the object is still returned):
%   @li icnna:io:legacyFile        - file predates versioning integrity.
%   @li icnna:io:staleClassVersion - a loaded object is below current version.
%
%% Input parameters
%
% filename - char[] | string.
%   File name inc. path to the .mat file to load.
%
%% Output
%
% theObject - ({experiment | experimentSpace} now;
%               @icnna.data.core.document once available).
%   The document-level ICNNA object
%
%
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
%   + File created.
%   + Document-level load with two-tier (embedded-metadata /
%     header-date + classVersion) legacy detection.
%
% 23-Jul-2026: FOE
%   + Bug fix: Fix small typo on creationDate date format:
%       "EEE" -> "eee"  (the capital case yields an error).
%   + Bug fix: The "Created on:" date-extraction regex assumed only
%       whitespace padding follows the date up to the end of the 116-byte
%       header. True for classic v6/v7 files, but -v7.3 (HDF5) files append
%       "HDF5 schema X.XX ." after the date, so the old regex captured that
%       trailing text too and the date always failed to parse. Since
%       icnna.io.save forces -v7.3, EVERY freshly-saved file was spuriously
%       flagged as legacy. Fixed by matching the date's explicit shape
%       (weekday/month/day/time/year) instead of "everything to end of
%       string", so extraction now stops at the year regardless of what
%       follows. Found via testIOSaveLoad's round-trip test.
%


%% Preliminaries

% Boundary before which files cannot carry a serialized classVersion stamp.
% Set to the v1.4.2.1 release date (interim: 16-Jul-2026 where stamping began).
VERSIONING_INTEGRITY_DATE = datetime(2026,7,16);

%% 1. Existence check.
narginchk(1,1);

if ~(ischar(filename) || (isstring(filename) && isscalar(filename)))
    error('icnna:io:load:invalidInput', ...
        'Filename must be a character vector or string scalar.');
end

filename = char(filename);

if ~isfile(filename)
    error('icnna:io:load:fileNotFound', ...
        'File "%s" does not exist.', filename);
end



%% 2. Query the file for variables and types inside.
info = whos('-file',filename);

%% 3. Read MAT-file header
%    Peek the 116-byte header (hdr=fread(fid,116,'*char')'). Parse
%    format ('MATLAB x.y MAT-file') and the
%    'Created on: <date>' field -> creationDate (datetime). Handle the
%    single-space day padding (e.g. 'Sun Feb  7'); on parse failure leave
%    creationDate empty (treated as legacy).

[creationDate, ~] = readMatFileHeader(filename);



%% 4. Locate the document-level object
% Classify from `info` (step 2):
%    - document-level class present (@experiment/@experimentSpace, later
%      @icnna.data.core.document) -> proceed;
%    - ICNNA object present but not document-level or absent->
%      error('icnna:io:load:notDocumentLevel', ...);
%    - multiple ICNNA object -> error('icnna:io:load:multipleDocuments', ...).

[docVarName, ~] = findDocumentObject(info);


%% 5. Load only the document variable:
%       loaded = load(filename, docVarName);
%       theObject = loaded.(docVarName);

loaded    = builtin('load', filename, docVarName);
theObject = loaded.(docVarName);

%% 6. Version detection:
%    (i)  if embedded ICNNA metadata present -> decide from it (future).
%    (ii) else legacy heuristic:
%           if isempty(creationDate) || creationDate < VERSIONING_INTEGRITY_DATE
%               warning('icnna:io:legacyFile', ...);   % point to help/doc
%           end
%           % top-level Tier 2 (deep walk deferred):
%           if compareVersions(classVersion(theObject), <current>) < 0
%               warning('icnna:io:staleClassVersion', ...);
%           end
%    (<current> = classVersion of a fresh default-constructed instance of
%     the same class.)


status = checkLegacyFile(theObject,creationDate,...
                         VERSIONING_INTEGRITY_DATE);

if status.isLegacy
    if isempty(creationDate)
        whenStr = 'an undetermined date';
    else
        whenStr = char(creationDate);
    end
    warning('icnna:io:legacyFile', ...
        ['"%s" was created on %s, before ICNNA introduced class-versioning ' ...
        'integrity (v1.4.2.1). Although the file has been loaded, some ' ...
        'legacy properties may have been silently coerced or lost. See help ' ...
        'icnna.io.load for the affected properties. For faithful recovery, ' ...
        'open with the release that wrote it (/stable) and re-save. ' ...
        'Proceeding with the loaded values.'], filename, whenStr);

end


if status.isStale
    warning('icnna:io:staleClassVersion', ...
            ['Object class version (%s) is older than the ' ...
            'current class definition (%s).'], ...
            status.loadedVersion,status.currentVersion);
end


end






%% AUXILIARY FUNCTIONS

function [creationDate, matFileVersion] = readMatFileHeader(filename)
% Read the descriptive header of a MATLAB MAT-file.
%
% [creationDate, matFileVersion] = readMatFileHeader(filename)
%
% Reads the standard 116-byte descriptive header without loading the MAT
% file contents. The function extracts:
%
%   - the MAT-file format/version string (e.g. 'MATLAB 5.0 MAT-file')
%   - the creation date, if present.
%
% If the creation date cannot be parsed, creationDate is returned empty.
%
%% Input
%   filename - char[]
%       MAT-file name.
%
%% Output
%   creationDate - datetime ([] if unavailable)
%       The file creation date.
%   matFileVersion - char[] ([] if unavailable)
%       The matlab version with which the file was created.
%
%
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
%   + Function created.
%

creationDate  = [];
matFileVersion = [];

fid = fopen(filename,'r');
if fid == -1
    return;
end

cleaner = onCleanup(@() fclose(fid));

hdr = fread(fid,116,'*char')';

%% MAT-file format/version
token = regexp(hdr,...
    '^(MATLAB\s+[\d\.]+\s+MAT-file)',...
    'tokens','once');

if ~isempty(token)
    matFileVersion = token{1};
end

%% Creation date
% Formatted as eee MMM d HH:mm:ss yyyy
%
% (3-letter weekday, 3-letter month, 1-2 digit day,
% HH:MM:SS, 4-digit year - each separated by \s+ so
% it tolerates the single-digit-day double-space case too.)
%
token = regexp(hdr,...
    'Created on:\s*([A-Za-z]{3}\s+[A-Za-z]{3}\s+\d{1,2}\s+\d{2}:\d{2}:\d{2}\s+\d{4})',...
    'tokens','once');

if isempty(token)
    return;
end
dateString = strtrim(token{1});

% First try the documented format.
try
    dateString = regexprep(strtrim(token{1}), '\s+', ' ');
        %Normalize to single spaces so that the InputFormat below holds.

    creationDate = datetime( ...
        dateString,...
        'InputFormat','eee MMM d HH:mm:ss yyyy');

catch
    % Fallback lets MATLAB infer the format. This copes with slight
    % differences between MATLAB releases.
    try
        creationDate = datetime(dateString);
    catch
        creationDate = [];
    end

end

end







function [docVarName, docClass] = findDocumentObject(info)
% Locate the document-level ICNNA object in a MAT-file.
%
%   [docVarName, docClass] = findDocumentObject(info)
%
%% Input parameters
%   info : output of whos('-file',filename)
%
%% Output parameters
%   docVarName : variable name holding the document
%   docClass   : class name of the document object
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
%   + Function created.
%


%% Preliminaries
varNames   = {info.name};
classNames = {info.class};

%% Locate document objects

docClasses = documentClasses();
        %icnna.io private function.
        % A curated list of what ICNNA recognises as a document.
        % Note that it is invoked by plain name, not package-qualified,
        % i.e. documentClasses rather than icnna.io.documentClasses


docIdx = find(ismember(classNames,docClasses));

if numel(docIdx) > 1
    error('icnna:io:load:multipleDocuments', ...
         'The MAT-file contains more than one document-level ICNNA object.');
end

if (numel(docIdx) == 1)
    docVarName = varNames{docIdx};
    docClass   = classNames{docIdx};
    return;
end

% No document-level object. .
error('icnna:io:load:notDocumentLevel', ...
    ['No document-level ICNNA object was found in this file. ' ...
    'If it contains individual ICNNA objects (e.g. a ' ...
    'single structuredData), load them directly with MATLAB''s LOAD.']);


end








function status = checkLegacyFile(theObject,creationDate,versioningIntegrityDate)
% Warn if a loaded ICNNA object may have reduced fidelity.
%
% status = checkLegacyFile(theObject,creationDate,versioningIntegrityDate)
%
%% Error handling
% In principle, this routine should not throw errors but merely emits warnings.
%
%% Input parameters
%
% theObject
% creationDate
% versioningIntegrityDate - datetime
%       The VERSIONING_INTEGRITY_DATE
%
%% Output
%
% status - struct with the following fields
%       .isLegacy - logical.
%                   True if the creationDate < versioningIntegrityDate.
%                   False otherwise.
%       .isStale  - logical.
%                   True if loaded version precedes current version.
%                   False otherwise.
%       .loadedVersion - char[]. Default ''.
%                   The version of the loaded object instance.
%       .currentVersion - char[]. Default ''.
%                   The current version of the object's class.
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
%   + Function created.
%



status.isLegacy       = false;
status.isStale        = false;
status.loadedVersion  = '';
status.currentVersion = '';


%% Tier 1 (future)
% Once document-level metadata is introduced, this section should inspect
% the embedded ICNNA version information and make the decision from that
% instead of using the creation-date heuristic.


%% Tier 2 - creation date heuristic

status.isLegacy = isempty(creationDate) || ...
    creationDate < versioningIntegrityDate;


%% Top-level classVersion comparison
try
    status.loadedVersion = classVersion(theObject);

    % Fresh instance gives the current class version.
    currentObject  = feval(class(theObject));
    status.currentVersion = classVersion(currentObject);

    status.isStale = icnna.util.compareVersions(status.loadedVersion,...
                                                status.currentVersion,'<');

catch ME

    % Legacy classes may not implement classVersion(), or default
    % construction may fail. Since this routine is advisory only,
    % silently ignore any such failures.

    %#ok<NASGU>

end

end