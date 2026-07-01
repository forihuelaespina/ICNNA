classdef testCondition < matlab.unittest.TestCase
% testCondition - Unit test for icnna.data.core.condition
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
% Type methods('testCondition') for a list of methods
% 
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.condition
%


%% Log
%
% -- ICNNA v1.4.2
%
% 17-Jun-2026: FOE
%   + File and class created. Added initial tests.
%
%       * testDefaultConstruction
%       * testIDtype
%       * testDefaultPropertyValue_name
%       * testDefaultPropertyValue_nEvents
%       * testDefaultPropertyValue_unit
%       * testDefaultPropertyValue_timeUnitMultiplier
%       * testDefaultPropertyValue_nominalSamplingRate
%       * testDefaultPropertyValue_conditionEvents
%       * testSettingProperty_id
%
% 19-Jun-2026: FOE
%   + Attempted to add some new tests but encounter a problem with
%   attempting to deal with silent typecasting. In the end, I needed
%   to modify the original classes before I could make new tests.
%
% 23-Jun-2026: FOE
%   + Some tests moved to new test unit testIdentifiableObject.m
%       * testIDType
%       * testDefaultPropertyValue_id
%       * testDefaultPropertyValue_name
%       * testSettingProperty_id
%       * testSettingProperty_name
%   + Thinned down remaining tests
%       * testDefaultPropertyValue_id
%       * testDefaultPropertyValue_name
%       * testSettingProperty_id
%       * testSettingProperty_name
%   + Added some new tests:
%       * testSettingProperty_unit
%       * testSettingProperty_timeUnitMultiplier
%       * testSettingProperty_nominalSamplingRate
%       * testInvalidInput_Cevents_nonStruct
%
% 1-Jul-2026: FOE
%   + Added some new tests:
%       * testCopyConstruction
%       * testInvalidInput_Cevents_missingFields
%       * testUnitConversion_samplesToSecondsAndBack
%       * testTimeUnitMultiplierEffect
%       * testDeprecated_tag
%       * testDataLabels
%
%


    methods (Access = private)
        function assignProperty(~, obj, prop, val)
            %Auxiliar method so that I can test property value assignments
            % using verifyError.
            obj.(prop) = val;
        end
    end



    methods (Test)


        %% Default construction and inherited properties

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

            obj = icnna.data.core.condition();
            testCase.verifyClass(obj,?icnna.data.core.condition);
        end

        function testCopyConstruction(testCase)
            %Verify that a copy constructor creates an equal object.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The soft assert over the object's copy construction.
            %

            obj = icnna.data.core.condition();
            %Make sure it cannot be confused with the default case by
            %altering some of the default values.
            obj.id = 7; 
            obj.timeUnitMultiplier = 7;
            newEvents = [struct('onsets', 4, 'durations', 2, 'amplitudes', 1, 'info', {'Event1'}), ...
                struct('onsets', 1, 'durations', 3, 'amplitudes', 2, 'info', {2})];
            obj.cevents = newEvents;
            %Now call the copy constructor
            obj2 = icnna.data.core.condition(obj);
            testCase.verifyClass(obj2,?icnna.data.core.condition);

            %Finally, check that both objects are equal
            testCase.verifyEqual(obj,obj2);

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

            %Confirm the inherited default arrives correctly through the subclass
            obj = icnna.data.core.condition();
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

            %Confirm the inherited default arrives correctly through the subclass
            obj = icnna.data.core.condition();
            testCase.verifyClass(obj.name,?char);
            testCase.verifyEqual(obj.name,'condition0001');
        end





        function testDefaultPropertyValue_nEvents(testCase)
            %Test the default property value for derived property |nEvents|
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The soft assert over the default obj.nEvents
            %

            obj = icnna.data.core.condition();
            testCase.verifyFalse(isnan(obj.nEvents));
            testCase.verifyEqual(obj.nEvents, 0);
        end

        function testDefaultPropertyValue_unit(testCase)
            %Test the default property value for property |unit|
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The soft assert over the default obj.unit
            %

            obj = icnna.data.core.condition();
            testCase.verifyClass(obj.unit,?char);
            testCase.verifyEqual(obj.unit,'samples');
        end

        function testDefaultPropertyValue_timeUnitMultiplier(testCase)
            %Test the default property value for property |timeUnitMultiplier|
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The soft assert over the default obj.timeUnitMultiplier
            %

            obj = icnna.data.core.condition();
            testCase.verifyClass(obj.timeUnitMultiplier,?int16);
            testCase.verifyTrue(isscalar(obj.timeUnitMultiplier));
            testCase.verifyFalse(isnan(obj.timeUnitMultiplier));
            testCase.verifyEqual(obj.timeUnitMultiplier, int16(0)); %Valued 0
        end

        function testDefaultPropertyValue_nominalSamplingRate(testCase)
            %Test the default property value for property |nominalSamplingRate|
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The soft assert over the default obj.nominalSamplingRate
            %

            obj = icnna.data.core.condition();
            testCase.verifyEqual(obj.nominalSamplingRate, 1);
        end

        function testDefaultPropertyValue_conditionEvents(testCase)
            %Test the default property value for property |cevents|
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The soft assert over the default obj.cevents
            %

            obj = icnna.data.core.condition();
            testCase.verifyTrue(isstruct(obj.cevents));
            testCase.verifyTrue(isempty(obj.cevents));

        end



        %% Setting properties and adding events

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

            %Confirm the dispatch chain works (condition's subsasgn reaches
            % identifiableObject's subsasgn)
            obj = icnna.data.core.condition();
            %By default should be 1.
            testCase.verifyEqual(obj.id,uint32(1));

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

            %All other verification happens in the superclass test unit.

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

            obj = icnna.data.core.condition();
            %By default should be 'condition0001'.
            testCase.verifyEqual(obj.name,'condition0001');
            obj.name = 'silly';
            testCase.verifyEqual(obj.name,'silly');
            %...and of course it should remain char []
            testCase.verifyClass(obj.name, ?char);

            %All other verification happens in the superclass test unit.
        end

        function testSettingProperty_cevents(testCase)
            %Test that setting a new |cevents| value sticks.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The soft assert over property |cevents| value setting.
            %

            obj = icnna.data.core.condition();
            %By default should be 'condition0001'.
            newEvents = [struct('onsets', 4, 'durations', 2, 'amplitudes', 1, 'info', {'Event1'}), ...
                         struct('onsets', 1, 'durations', 3, 'amplitudes', 2, 'info', {2})];
            obj.cevents = newEvents;  % Assign new event data
            testCase.verifyEqual(obj.onsets,[1;4]);
                %Note the reordering of the events according to the onset.
            testCase.verifyEqual(obj.durations,[3;2]);
            testCase.verifyEqual(obj.amplitudes,[2;1]);

            testCase.verifyEqual(isequal({obj.cevents.info}',{2;'Event1'}),true);
            %...and of course it should remain struct []
            testCase.verifyClass(obj.cevents, ?struct);

            testCase.verifyEqual(obj.nEvents,2);
            testCase.verifyEqual(obj.eventTimes,[1 3 4; 4 2 6]);


        end



        function testSettingProperty_unit(testCase)
            %Test that setting a new |unit| value sticks.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The soft assert over property |unit| value setting.
            %

            obj = icnna.data.core.condition();
            %By default should be 'samples'.
            testCase.verifyEqual(obj.unit,'samples');
            obj.unit = 'seconds';
            testCase.verifyEqual(obj.unit,'seconds');
            %...and of course it should remain char []
            testCase.verifyClass(obj.unit, ?char);

            %It should not allow setting it to a different value, 
            % other than {'samples','seconds'}
            %

            testCase.verifyError( ...
                @() testCase.assignProperty(obj, 'unit', 'hello'), ...
                'MATLAB:validators:mustBeMember'); 


            testCase.verifyWarning( ...
                @() testCase.assignProperty(obj, 'unit', "samples"), ...
                'icnna:data:core:condition:set_unit:ImplicitTypecast');
            %Is there typecasting from string?

        end



        function testSettingProperty_timeUnitMultiplier(testCase)
            %Test that setting a new |timeUnitMultiplier| value sticks.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The soft assert over property |timeUnitMultiplier| value setting.
            %

            obj = icnna.data.core.condition();
            %By default should be 0.
            obj.timeUnitMultiplier = 3;
            testCase.verifyWarningFree( ...
                @() testCase.assignProperty(obj, 'timeUnitMultiplier', 3)); %Note that this
                                                                %implicit
                                                                %typecasting
                                                                %(from double
                                                                %to int16) is
                                                                %safe, so no
                                                                %warning.
            testCase.verifyEqual(obj.timeUnitMultiplier,int16(3));
            %...and of course it should remain int16
            testCase.verifyClass(obj.timeUnitMultiplier, ?int16);


            testCase.verifyError( ...
                @() testCase.assignProperty(obj, 'timeUnitMultiplier', NaN), ...
                'icnna:data:core:condition:set_timeUnitMultiplier:mustBeNonNan');

            %It should not allow setting it to a different type, e.g. char
            %
            %Note: When trying to assign a single character, there will be
            %no error but just the implicit typecasting warning.
            %However when assigning multiple characters, there will be both
            %the warning and the error, but the error will occur BEFORE
            %the warning, ergo I need to verify for the error in such case.
            %
            testCase.verifyWarning( ...
                @() testCase.assignProperty(obj, 'timeUnitMultiplier', 'h'), ...
                'icnna:data:core:condition:set_timeUnitMultiplier:ImplicitTypecast');
            %Single char -> warning

            testCase.verifyError( ...
                @() testCase.assignProperty(obj, 'timeUnitMultiplier', 'hello'), ...
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
                @() testCase.assignProperty(obj, 'timeUnitMultiplier', "hello"), ...
                'MATLAB:validation:UnableToConvert');

            testCase.verifyError( ...
                @() testCase.assignProperty(obj, 'timeUnitMultiplier', [3 7]), ...
                'MATLAB:validation:IncompatibleSize');

        end


        function testSettingProperty_nominalSamplingRate(testCase)
            %Test that setting a new |nominalSamplingRate| value sticks.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The soft assert over property |nominalSamplingRate| value setting.
            %

            obj = icnna.data.core.condition();
            %By default should be 1.
            testCase.verifyEqual(obj.nominalSamplingRate,1);
            obj.nominalSamplingRate = 2.3;
            testCase.verifyEqual(obj.nominalSamplingRate,2.3);
            %...and of course it should remain double
            testCase.verifyClass(obj.nominalSamplingRate, ?double);

            testCase.verifyError( ...
                @() testCase.assignProperty(obj, 'nominalSamplingRate', NaN), ...
                'MATLAB:validators:mustBeNonNan');

            %It should not allow setting it to a different type, e.g. char
            %
            %Note: When trying to assign a single character, there will be
            %no error but just the implicit typecasting warning.
            %However when assigning multiple characters, there will be both
            %the warning and the error, but the error will occur BEFORE
            %the warning, ergo I need to verify for the error in such case.
            %
            testCase.verifyWarning( ...
                @() testCase.assignProperty(obj, 'nominalSamplingRate', 'h'), ...
                'icnna:data:core:condition:set_nominalSamplingRate:ImplicitTypecast');
                                                    %Single char -> warning

            testCase.verifyError( ...
                @() testCase.assignProperty(obj, 'nominalSamplingRate', 'hello'), ...
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
                @() testCase.assignProperty(obj, 'nominalSamplingRate', "hello"), ...
                'MATLAB:validators:mustBeNonNan');

            testCase.verifyError( ...
                 @() testCase.assignProperty(obj, 'nominalSamplingRate', [3 7]), ...
                'MATLAB:validation:IncompatibleSize');

        end



        %% Edge cases and error conditions

        function testInvalidInput_Cevents_nonStruct(testCase)
            %Test edge case for |cevents|; assignment of non-struct values.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The assert over invalid inputs for property |cevents|.
            %

            obj = icnna.data.core.condition();
            newEvents = [struct('onsets', 4, 'durations', 2, 'amplitudes', 1, 'info', {'Event1'}), ...
                struct('onsets', 1, 'durations', 3, 'amplitudes', 2, 'info', {2})];
            
            %Implicit typecasting
            testCase.verifyError( ...
                @() testCase.assignProperty(obj, 'cevents', struct2table(newEvents)), ...
                'icnna:data:core:condition:set_cevents:MissingFields');
                         %Table -> Error
                         %Matlab's typecasting to struct from table, i.e.
                         %struct(val) does produce a struct, BUT NOT the
                         %struct [] with the table columns as fields.
                         %Instead, it produces a single struct with a lot
                         %of fields, e.g. ndims, props, etc from where
                         %such struct array can be recovered, but
                         %importantly so that there is no information lost
                         %from the original table. So while:
                         %
                         %  obj.cevents = struct2table(newEvents)
                         %
                         % would "pass" the interception of the subasgn,
                         %because struct(struct2table(newEvents)) is indeed
                         %a struct, but this will fail when "checking" the
                         %fields of the struct. 
                         % 
                         % What will NOT fail however is:
                         %
                         %  obj.cevents =
                         %  table2struct(struct2table(newEvents))
                         %
                         %In summary struct(sometable) is NOT the same a
                         % table2struct(sometable)!

             testCase.verifyWarningFree( ...
                 @() testCase.assignProperty(obj, 'cevents', table2struct(struct2table(newEvents))));


        end



        function testInvalidInput_Cevents_missingFields(testCase)
            %Test edge case for |cevents|; assignment of struct with missing fields.
            %
            % Structs missing required fields should result in error.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The assert over invalid inputs for property |cevents|.
            %

            obj = icnna.data.core.condition();
            newEvents = [struct('onsets', 4, 'durations', 2, 'amplitudes', 1, 'info', {'Event1'}), ...
                struct('onsets', 1, 'durations', 3, 'amplitudes', 2, 'info', {2})];
            %Now remove one field at a time, and try to assign,
            theFields = fieldnames(newEvents);
            nFields = numel(theFields);
            for iField = 1:nFields
                tmpField  = theFields{iField};
                tmpEvents = rmfield(newEvents,tmpField);
                testCase.verifyError( ...
                    @() testCase.assignProperty(obj, 'cevents', tmpEvents), ...
                    'icnna:data:core:condition:set_cevents:MissingFields');

            end


        end



        function testDeprecated_tag(testCase)
            %Test that attribute |tag| yields a deprecated warning.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The assert over the throw of warning for (deprecated)
            % property |tag|.
            %

            obj = icnna.data.core.condition();
            testCase.verifyWarning( ...
                @() testCase.assignProperty(obj, 'tag', 'deprecatedValue'), ...
                'icnna:data:core:condition:tag:Deprecated');
        end


        %% Behavioural tests

        function testUnitConversion_samplesToSecondsAndBack(testCase)
            %Check the effect of changing unit to 'seconds' and back to samples.
            % 
            % This test verify onsets/durations convert via nominalSamplingRate.
            % Also check for roundings.
            %
            %% Remark
            % Although the test is designed oriented to the change in
            % |unit| as the central element, but internally it ALSO test
            % for the effect of changing the nominalSamplingRate.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The assert over the effect of changing |unit| to 'seconds' and back to samples.
            %

            obj = icnna.data.core.condition();
            %Remember, the default is samples
            newEvents = [struct('onsets', 4, 'durations', 2, 'amplitudes', 1, 'info', {'Event1'}), ...
                struct('onsets', 1, 'durations', 3, 'amplitudes', 2, 'info', {2})];
            tmpNominalSamplingRate  = 5; %in [Hz]

            %Sort newEvents by onset
            [~, sortIdx] = sort([newEvents.onsets]);
            newEvents = newEvents(sortIdx);

            obj.nominalSamplingRate = tmpNominalSamplingRate; %in [Hz]
            obj.cevents = newEvents;
            %Check no change despite the nominal sampling rate being
            %different from 1 (since events are in samples, and the
            %setting of the |nominalSamplingRate| occurred BEFORE
            %setting the events, the values should not be affected
            %by the sampling rate i.e. it is assumed the user was
            %conscious that he was setting the values at the
            %current sampling rate).
            testCase.verifyEqual(obj.cevents,newEvents);

            %...but if we change the nominal sampling rate now,
            %because the condition aims at keeping the marks
            %at the same time (in seconds), we should see the
            %samples altered accordingly
            obj.nominalSamplingRate = 2*tmpNominalSamplingRate; %in [Hz]
            %Manually, pre-calculate the expected response
            tmpTimeEvents = [[newEvents.onsets]' [newEvents.durations]' ...
                [newEvents.onsets]'+[newEvents.durations]'];
            %Convert the precalculated response to seconds using the ratio
            %between the original nominal sampling rate of newEvents (that's 5Hz)
            %and the present nominal sampling rate of the condition (2*5Hz =  10Hz).
            tmpTimeEvents = round(tmpTimeEvents*(obj.nominalSamplingRate/tmpNominalSamplingRate));
            testCase.verifyEqual(obj.eventTimes, tmpTimeEvents);
                    % Verify event times after conversion

            %Going back to the "original" |nominalSamplingRate| of 5Hz (the
            % one standing when the the newEvents were originally assigned
            % to |cevents| should bring us back to the original values.
            obj.nominalSamplingRate = 5;
            testCase.verifyEqual(obj.cevents,newEvents);

            %Now change to seconds
            obj.unit = 'seconds';
            testCase.verifyEqual(obj.unit, 'seconds');

            %Change the nominalSampling rate
            obj.nominalSamplingRate = 2*tmpNominalSamplingRate; %in [Hz]
            %...this still should not alter the events values, because
            %the time is in seconds anyway which is what is preserved by
            %the condition.
            tmpOnsetsInSeconds = [newEvents.onsets]'./tmpNominalSamplingRate;
            testCase.verifyEqual(obj.onsets, tmpOnsetsInSeconds);
            tmpDurationsInSeconds = [newEvents.durations]'./tmpNominalSamplingRate;
            testCase.verifyEqual(obj.durations, tmpDurationsInSeconds);

            %Manually, pre-calculate the expected response
            tmpTimeEvents = [[newEvents.onsets]' [newEvents.durations]' ...
                             [newEvents.onsets]'+[newEvents.durations]'];
            %Convert the precalculated response to seconds
            tmpTimeEvents = tmpTimeEvents./tmpNominalSamplingRate;
            %If attempted directly i.e.:
            %   testCase.verifyEqual(obj.eventTimes, tmpTimeEvents);
            %this will result in an error because of rounding precision.
            %Hence allowing for a small tolerance:
            testCase.verifyTrue(all(all(abs(obj.eventTimes - tmpTimeEvents)<2*eps)));
                    % Verify event times after conversion


            %...and back to samples
            obj.unit = 'samples';
            tmpOnsetsInSeconds = round([newEvents.onsets]'*(obj.nominalSamplingRate/tmpNominalSamplingRate));
            testCase.verifyEqual(obj.onsets, tmpOnsetsInSeconds);
            tmpDurationsInSeconds = round([newEvents.durations]'*(obj.nominalSamplingRate/tmpNominalSamplingRate));
            testCase.verifyEqual(obj.durations, tmpDurationsInSeconds);



    
        end 



        function testTimeUnitMultiplierEffect(testCase)
            %Check the effect of changing the |timeUnitMultiplier| when unit is 'seconds'
            % 
            % This test verify the correct scaling.
            %
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The assert over the effect of changing the |timeUnitMultiplier|.
            %

            obj = icnna.data.core.condition();
            %Remember, the default is samples
            newEvents = [struct('onsets', 4, 'durations', 2, 'amplitudes', 1, 'info', {'Event1'}), ...
                struct('onsets', 1, 'durations', 3, 'amplitudes', 2, 'info', {2})];

            %Sort newEvents by onset
            [~, sortIdx] = sort([newEvents.onsets]);
            newEvents = newEvents(sortIdx);

            obj.cevents = newEvents;
            obj.unit = 'seconds'; %Easier to work in seconds for this test.


            %The actual test, modify the |timeUnitMultiplier|
            testValue = -3; % Convert to milliseconds
            obj.timeUnitMultiplier = testValue;
            testCase.verifyEqual(obj.timeUnitMultiplier, int16(testValue));
           
            % Verify that the onsets and durations are scaled correctly
            expectedOnsets    = ([newEvents.onsets]'./obj.nominalSamplingRate)./(10^testValue);
            expectedDurations = ([newEvents.durations]'./obj.nominalSamplingRate)./(10^testValue);

            testCase.verifyEqual(obj.onsets,    expectedOnsets);
            testCase.verifyEqual(obj.durations, expectedDurations);


            %...and back
            obj.timeUnitMultiplier = 0;
            testCase.verifyEqual(obj.onsets,    [newEvents.onsets]'./obj.nominalSamplingRate);
            testCase.verifyEqual(obj.durations, [newEvents.durations]'./obj.nominalSamplingRate);



        end



        function testDataLabels(testCase)
            %Verify that |dataLabels| returns correct field names
            % 
            %% Input parameters
            %
            % testCase - The test runner's handle to assertion methods.
            %
            %% Output
            %
            % The assert over invalid inputs for property |dataLabels|.
            %

            obj = icnna.data.core.condition();
            tmpLabels = obj.dataLabels; %String array
            evtLabels = fieldnames(obj.cevents); %Cell array

            testCase.verifyTrue(numel(tmpLabels)==numel(evtLabels));
            nLabels = numel(tmpLabels);
            for iLabel = 1:nLabels
                testCase.verifyEqual(tmpLabels(iLabel), string(evtLabels{iLabel}));
            end


        end


    end

end