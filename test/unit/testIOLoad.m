classdef testIOLoad < matlab.unittest.TestCase
% testIOLoad - Unit test for icnna.io.load
%
%
%
%% Remarks
%
% A matlab.unittest test class is just a MATLAB class that inherits
% from matlab.unittest.TestCase. Each test is a method in a methods
% (Test) block.
%
% Each test method receives testCase as its first argument (this is
% the test runner's handle to assertion methods).
%
% Calls to:
%
%   verifyClass(obj, ?ClassName) checks the object's type.
%       The ? is MATLAB's metaclass operator.
%
% In general, verify* methods are "soft" assertions - the test continues
% even if one fails. There's also assert* (stops the test method) and
% fatalAssert* (stops the entire test suite). For unit tests, verify*
% is the most common.                %
%
%
%
%
%% Methods
%
% Type methods('testIOLoad') for a list of methods
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
% 23-Jul-2026: FOE
%   + File and class created. Added initial tests.
%
%       * testIOLoad_WarnsBeforeIntegrityBoundary
%       * testIOLoad_NoWarnOnBoundaryDate
%       * testIOLoad_WarnsOnUndeterminedDate
%


    methods (Test)


        function testIOLoad_WarnsBeforeIntegrityBoundary(testCase)
            %Test whether icnna.io.load yields a warn when attempting to read a file dated before the VERSIONING_INTEGRITY_DATE
            % 
            % The VERSIONING_INTEGRITY_DATE is 16-Jul-2026.
            %
            %
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % True if the legacy file is detected.
            %


            filename = fullfile('.','testLegacy.mat');
            testCase.addTeardown(@() delete(filename));

            %Create a dummy file containing an empty experiment
            E = experiment();
            %Save it using MATLAB's default (instead of '-v7.3')
            save(filename,'E');


            %Tamper the date to a date PREVIOUS to VERSIONING_INTEGRITY_DATE
            %
            %For a pre--v7.3 MAT-file (MAT-file Level 5, the
            % default produced by save), the first 128 bytes
            % header have a fixed layout:
            % 
            % Bytes (1-based)	Length	Contents
            % 1–116	    116	Descriptive text (ASCII). MATLAB writes something like "MATLAB 5.0 MAT-file, Platform: ..., Created on: Thu Jul 23 14:56:12 2026" padded with spaces.
            % 117–124	8	Subsystem data offset (usually all zeros).
            % 125–126	2	Version (0x0100 for current Level 5 files).
            % 127–128	2	Endian indicator ('IM' or 'MI').

            fid = fopen(filename, 'r+');    % read/write, do not truncate
            assert(fid ~= -1);
            hdr = fread(fid, 116, '*char')'; % Read the 116-byte descriptive text
            %disp(hdr)
            %This may show something like:
            %
            %   MATLAB 5.0 MAT-file, Platform: PCWIN64, Created on: Thu Jul 23 14:56:12 2026
            %
            
            % now proceed to modify the header
            newHdr = regexprep(hdr, ...
                'Created on:.*$', ...
                'Created on: Mon Jan  7 00:00:00 2020');

            % Must remain exactly 116 bytes
            newHdr = sprintf('%-116s', newHdr);
            newHdr = newHdr(1:116);

            fseek(fid, 0, 'bof');
            fwrite(fid, newHdr, 'char');

            fclose(fid);


            %Finally test
            loaded = testCase.verifyWarning(@() icnna.io.load(filename),...
                'icnna:io:legacyFile');
            testCase.verifyClass(loaded, 'experiment');


        end


        function testIOLoad_NoWarnOnBoundaryDate(testCase)
            %Test that icnna.io.load yields no warn when attempting to read a file dated on the VERSIONING_INTEGRITY_DATE
            % 
            % The VERSIONING_INTEGRITY_DATE is 16-Jul-2026.
            %
            %
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % True if the legacy file was created exactly the boundary date.
            %


            filename = fullfile('.','testLegacy.mat');
            testCase.addTeardown(@() delete(filename));

            %Create a dummy file containing an empty experiment
            E = experiment();
            %Save it using MATLAB's default (instead of '-v7.3')
            save(filename,'E');


            %Tamper the date to a date EQUAL to VERSIONING_INTEGRITY_DATE
            %
            %For a pre--v7.3 MAT-file (MAT-file Level 5, the
            % default produced by save), the first 128 bytes
            % header have a fixed layout:
            % 
            % Bytes (1-based)	Length	Contents
            % 1–116	    116	Descriptive text (ASCII). MATLAB writes something like "MATLAB 5.0 MAT-file, Platform: ..., Created on: Thu Jul 23 14:56:12 2026" padded with spaces.
            % 117–124	8	Subsystem data offset (usually all zeros).
            % 125–126	2	Version (0x0100 for current Level 5 files).
            % 127–128	2	Endian indicator ('IM' or 'MI').

            fid = fopen(filename, 'r+');    % read/write, do not truncate
            assert(fid ~= -1);
            hdr = fread(fid, 116, '*char')'; % Read the 116-byte descriptive text
            %disp(hdr)
            %This may show something like:
            %
            %   MATLAB 5.0 MAT-file, Platform: PCWIN64, Created on: Thu Jul 23 14:56:12 2026
            %

            % now proceed to modify the header
            newHdr = regexprep(hdr, ...
                'Created on:.*$', ...
                'Created on: Thu Jul 16 00:00:00 2026');

            % Must remain exactly 116 bytes
            newHdr = sprintf('%-116s', newHdr);
            newHdr = newHdr(1:116);

            fseek(fid, 0, 'bof');
            fwrite(fid, newHdr, 'char');

            fclose(fid);

            %Finally test
            loaded = testCase.verifyWarningFree(@() icnna.io.load(filename));
            testCase.verifyClass(loaded, 'experiment');


        end


        function testIOLoad_WarnsOnUndeterminedDate(testCase)
            %Test that icnna.io.load yields a warn when it can't extract a date at all e.g. there is a corrupt date.
            % 
            %
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % True if load is unable to establish the creation date,
            % e.g. the file contains a corrupt date.
            %


            filename = fullfile('.','testLegacy.mat');
            testCase.addTeardown(@() delete(filename));

            %Create a dummy file containing an empty experiment
            E = experiment();
            %Save it using MATLAB's default (instead of '-v7.3')
            save(filename,'E');


            %Corrupt the date
            %
            %For a pre--v7.3 MAT-file (MAT-file Level 5, the
            % default produced by save), the first 128 bytes
            % header have a fixed layout:
            % 
            % Bytes (1-based)	Length	Contents
            % 1–116	    116	Descriptive text (ASCII). MATLAB writes something like "MATLAB 5.0 MAT-file, Platform: ..., Created on: Thu Jul 23 14:56:12 2026" padded with spaces.
            % 117–124	8	Subsystem data offset (usually all zeros).
            % 125–126	2	Version (0x0100 for current Level 5 files).
            % 127–128	2	Endian indicator ('IM' or 'MI').

            fid = fopen(filename, 'r+');    % read/write, do not truncate
            assert(fid ~= -1);
            hdr = fread(fid, 116, '*char')'; % Read the 116-byte descriptive text
            %disp(hdr)
            %This may show something like:
            %
            %   MATLAB 5.0 MAT-file, Platform: PCWIN64, Created on: Thu Jul 23 14:56:12 2026
            %

            % now proceed to modify the header
            newHdr = regexprep(hdr, ...
                'Created on:.*$', ...
                'Created on: Foo Foo 61 00:00:00 2026');

            % Must remain exactly 116 bytes
            newHdr = sprintf('%-116s', newHdr);
            newHdr = newHdr(1:116);

            fseek(fid, 0, 'bof');
            fwrite(fid, newHdr, 'char');

            fclose(fid);

            %Finally test
            loaded = testCase.verifyWarning(@() icnna.io.load(filename),...
                'icnna:io:legacyFile');
            testCase.verifyClass(loaded, 'experiment');


        end



    end

end