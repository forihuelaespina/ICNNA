classdef testCompareVersions < matlab.unittest.TestCase
% testCompareVersions - Unit test for icnna.util.compareVersions
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
% Type methods('testCompareVersions') for a list of methods
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also icnna.util.compareVersions
%


%% Log
%
% -- ICNNA v1.4.2.1
%
% 23-Jul-2026: FOE
%   + File and class created. Added initial tests.
%
%       * testCompareVersion_Equal
%       * testCompareVersion_LowerThan
%       * testCompareVersion_GreaterThan
%       * testCompareVersion_LowerOrEqual
%       * testCompareVersion_GreaterOrEqual
%       * testCompareVersion_InvalidOperator.
%
%



    methods (Test)

        function testCompareVersion_Equal(testCase)
            %Test the comparison of two equal version strings
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % True if the comparison result matches expectation
            %

            %Equal length
            testCase.verifyTrue(icnna.util.compareVersions('1.4.0','1.4.0','=='));
            %Zero padded
            testCase.verifyTrue(icnna.util.compareVersions('1.4','1.4.0','=='));
        end

        function testCompareVersion_LowerThan(testCase)
            %Test the comparison of lower-than for versions strings.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % True if the comparison result matches expectation
            %

            %Numeric not lexicographic
            testCase.verifyTrue(icnna.util.compareVersions('1.2','1.10','<'));
            %Padded
            testCase.verifyTrue(icnna.util.compareVersions('1.4','1.4.1','<'));
        end


        function testCompareVersion_GreaterThan(testCase)
            %Test the comparison of greater-than for versions strings.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % True if the comparison result matches expectation
            %

            %Numeric not lexicographic
            testCase.verifyTrue(icnna.util.compareVersions('1.10','1.2','>'));
        end

        function testCompareVersion_LowerOrEqual(testCase)
            %Test the comparison of lower or equal for versions strings.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % True if the comparison result matches expectation
            %

            %Regular case
            testCase.verifyTrue(icnna.util.compareVersions('1.1.3','1.2','<='));
            %At equality
            testCase.verifyTrue(icnna.util.compareVersions('1.2','1.2','<='));
        end

        function testCompareVersion_GreaterOrEqual(testCase)
            %Test the comparison of greater or equal for versions strings.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % True if the comparison result matches expectation
            %

            %Regular case
            testCase.verifyTrue(icnna.util.compareVersions('1.2','1.1.3','>='));
            %At equality
            testCase.verifyTrue(icnna.util.compareVersions('1.2','1.2','>='));
        end


        function testCompareVersion_InvalidOperator(testCase)
            %Test the comparison of versions strings with an invalid operator.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % True if the comparison result matches expectation
            %

            testCase.verifyError(@() icnna.util.compareVersions('1.0','1.0','~='),...
                    'icnna:util:compareVersion:InvalidOperator');
        end

    end

end