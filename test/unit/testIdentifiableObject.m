classdef testIdentifiableObject < matlab.unittest.TestCase
% testIdentifiableObject - Unit test for icnna.data.core.identifiableObject
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
% Type methods('testIdentifiableObject') for a list of methods
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.identifiableObject
%


%% Log
%
% -- ICNNA v1.4.2
%
% 23-Jun-2026: FOE
%   + File and class created from tests moved here from testCondition.m
%
%       * testDefaultConstruction
%       * testIDType
%
%       * testDefaultPropertyValue_id
%       * testDefaultPropertyValue_name
%
%       * testSettingProperty_id
%       * testSettingProperty_name
%

    methods (Access = private)
        function assignProperty(~, obj, prop, val)
            %Auxiliar method so that I can test property value assignments
            % using verifyError.
            obj.(prop) = val;
        end
    end



    methods (Test)

        %% Default construction

        function testDefaultConstruction(testCase)
            %Verify that a default object can be created
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The soft assert over the default object construction.
            %

            obj = icnna.data.core.identifiableObject();
            testCase.verifyClass(obj,?icnna.data.core.identifiableObject);
        end

        function testIDtype(testCase)
            %Test that obj.id is a uint32 scalar
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The soft assert over the type of obj.id.
            %

            obj = icnna.data.core.identifiableObject();
            testCase.verifyTrue(isscalar(obj.id));
            testCase.verifyFalse(isnan(obj.id));
            testCase.verifyClass(obj.id,?uint32);

        end

        function testDefaultPropertyValue_id(testCase)
            %Test the default property value for property |id|
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The soft assert over the default obj.id
            %

            obj = icnna.data.core.identifiableObject();
            testCase.verifyClass(obj.id,?uint32);
            testCase.verifyEqual(obj.id,uint32(1));
        end


        function testDefaultPropertyValue_name(testCase)
            %Test the default property value for property |name|
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The soft assert over the default obj.name
            %

            obj = icnna.data.core.identifiableObject();
            testCase.verifyClass(obj.name,?char);
            testCase.verifyEqual(obj.name,'object0001');
        end


        %% Setting properties 

        function testSettingProperty_id(testCase)
            %Test that setting a new |id| value sticks.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The soft assert over property |id| value setting.
            %

            obj = icnna.data.core.identifiableObject();
            %By default should be 1.
            obj.id = 7;
            testCase.verifyWarningFree( ...
                @() testCase.assignProperty(obj, 'id', 7)); %Note that this
                                                            %implicit
                                                            %typecasting
                                                            %(from double
                                                            %to uint32) is
                                                            %safe, so no
                                                            %warning.
            testCase.verifyEqual(obj.id,uint32(7));
            %...and of course it should remain uint32
            testCase.verifyClass(obj.id, ?uint32);


            testCase.verifyError( ...
                @() testCase.assignProperty(obj, 'id', NaN), ...
                'icnna:data:core:identifiableObject:set_id:mustBeNonNan');

            %It should not allow setting it to a different type, e.g. char
            %
            %Note: When trying to assign a single character, there will be
            %no error but just the implicit typecasting warning.
            %However when assigning multiple characters, there will be both
            %the warning and the error, but the error will occur BEFORE
            %the warning, ergo I need to verify for the error in such case.
            %
            testCase.verifyWarning( ...
                @() testCase.assignProperty(obj, 'id', 'h'), ...
                'icnna:data:core:identifiableObject:set_id:ImplicitTypecast');
                                                    %Single char -> warning

            testCase.verifyError( ...
                @() testCase.assignProperty(obj, 'id', 'hello'), ...
                'MATLAB:validation:IncompatibleSize');
                                                    %Multiple char -> error
                                                    %Note that the
                                                        %isscalar will
                                                        %throw the error
                                                        %before the
                                                        %typecasting is
                                                        %attempted ergo the
                                                        %"incompatibleSize"
            testCase.verifyError( ...
                @() testCase.assignProperty(obj, 'id', "hello"), ...
                'MATLAB:validation:UnableToConvert');

            testCase.verifyError( ...
                 @() testCase.assignProperty(obj, 'id', [3 7]), ...
                'MATLAB:validation:IncompatibleSize');

        end



        function testSettingProperty_name(testCase)
            %Test that setting a new |name| value sticks.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The soft assert over property |name| value setting.
            %

            obj = icnna.data.core.identifiableObject();
            %By default should be 'object0001'.
            obj.name = 'silly';
            testCase.verifyEqual(obj.name,'silly');
            %...and of course it should remain char []
            testCase.verifyClass(obj.name, ?char);

            %It should not allow setting it to a different type, e.g.
            %double
            %
            testCase.verifyWarning( ...
                @() testCase.assignProperty(obj, 'name', 65), ...
                'icnna:data:core:identifiableObject:set_name:ImplicitTypecast'); 
                %Is there typecasting to 'A'?

            testCase.verifyError( ...
                @() testCase.assignProperty(obj, 'name', struct()), ...
                'MATLAB:validation:UnableToConvert'); 

            testCase.verifyError( ...
                @() testCase.assignProperty(obj, 'name', ['Fo'; 'ol']), ...
                'MATLAB:validation:IncompatibleSize'); 
                % ['Fo'; 'ol'] creates a 2x2 char array, which violates
                % the (1,:) constraint.

            testCase.verifyWarning( ...
                @() testCase.assignProperty(obj, 'name', "hello"), ...
                'icnna:data:core:identifiableObject:set_name:ImplicitTypecast');
                %Is there typecasting from string?

            testCase.verifyWarning( ...
                @() testCase.assignProperty(obj, 'name', [65 67]), ...
                'icnna:data:core:identifiableObject:set_name:ImplicitTypecast');
            %Is there typecasting to 'AC'?

        end

    end

end

