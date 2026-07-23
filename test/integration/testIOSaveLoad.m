classdef testIOSaveLoad < matlab.unittest.TestCase
% testIOSaveLoad - Unit test for round trips save/load
%
% This belong to \test\integration\ as it traverses two
%functions:
%
%   icnna.io.save
%   icnna.io.load
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
% Type methods('testIOSaveLoad') for a list of methods
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also icnna.io.save, icnna.io.load
%


%% Log
%
% -- ICNNA v1.4.2.1
%
% 23-Jul-2026: FOE
%   + File and class created. Added initial tests.
%
%       * testIOSaveLoad_RoundTripNoWarnings



    methods (Test)

        function testIOSaveLoad_RoundTripNoWarnings(testCase)
            %Test whether a full save/load round trip works adequately for files saved equal or after v1.4.2.1.
            % 
            %
            %% Remarks
            %
            % This test will need to evolve when the interim
            %convention is dropped and ICNNA no longer
            %accepts '@experiment' as a document-level class.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % True if the interim convention is upheld and the
            % save-load round trip recovers the correct document.
            %

            filename = fullfile('.','testRoundTrip.mat');
            testCase.addTeardown(@() delete(filename));

            E = experiment();
            originalVersion = classVersion(E);

            % icnna.io.save always emits its interim-convention notice by design
            testCase.verifyWarning(@() icnna.io.save(E, filename), ...
                'icnna:io:save:interimConvention');

            % A fresh, current-version file should load with no warnings at all
            loaded = testCase.verifyWarningFree(@() icnna.io.load(filename));

            testCase.verifyClass(loaded, 'experiment');
            testCase.verifyEqual(classVersion(loaded), originalVersion);
        end

    end

end