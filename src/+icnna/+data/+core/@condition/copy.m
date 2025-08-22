function newObj = copy(obj)
% Deep copy method
%
%   newObj = obj.copy()
%   newObj = copy(obj)
%
%
% The method is NOT called deepcopy to follow MATLAB's convention
% regarding handle objects deep copy methods that are just simply
% called "copy".
%
%
%% Remarks
%
% Surprisingly, matlab does not provide an off-the-shelf solution
%to get deep copies of handle objects. The closest thing it provides
%is the class matlab.mixin.Copyable
%
% https://uk.mathworks.com/help/matlab/ref/matlab.mixin.copyable-class.html
% 
% but as explained in MATLAB's help, this has certain limitations, and
% in any case still requires that subclasses of matlab.mixin.Copyable
% implement the method copyElement which somewhat defeats the purpose.
%
% Ergo this method...
%
% Strictly speaking a true deep copy is not achieved. For instance,
%constant private properties such as the classVersion cannot
%get copied.
%
% Also note that depending on the class, the order in which the properties
%are copied does matter!. In other words a blind loop over properties
%may not suffice.
%
% Bottom line, in MATLAB creating deep copies of handle objects (or as
%close to it as possible e.g. excusing constant private properties)
%is left to the programmer...
%
%
%% Output
%
% newObj - A deep copy of obj
%
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
%
% See also icnna.data.core.timeline
%


%% Log
%
% File created: 9-Jul-2025
%
% -- ICNNA v1.3.1
%
% 9-Jul-2025: FOE 
%   + File created. Initial code created with the help of copilot and
%   then modified e.g. to skip dependent properties.
%

% Create a new instance of the same class
newObj = feval(class(obj));


metaClass  = metaclass(obj);
props = metaClass.PropertyList; % List of properties
    %Note that using properties(obj) only retrieve the names
    %of the (public) properties, whereas this call get a lot
    %of additional information e.g. private properties,
    %features of the properties e.g. whether it is dependent, etc


%% BEWARE!!
%
%Watch out! In the conditions class, the order in which the properties
%are copied does matter!. For instance,
%
% Let be a condition c such that:
%
% >> c = icnna.data.core.condition
% >> c.addEvents([5 5; 10 2; 15 10])
% >> c.unit = 'seconds'
% >> c.nominalSamplingRate = 2
% >> c.timeUnitMultiplier = -3
% >> c.cevents
% ans =
% 
%   3×4 table
% 
%     onsets    durations    amplitudes        info    
%     ______    _________    __________    ____________
% 
%      5000        5000          1         {0×0 double}
%     10000        2000          1         {0×0 double}
%     15000       10000          1         {0×0 double}
%
% Now, create a deep copy of c where the deep copy is attempted
%"directly" using a blind loop over properties;
%
%
% >> c2 = copy(c)
%
% ...but alas!
% >> c2.cevents
% ans =
% 
%   3×4 table
% 
%     onsets     durations    amplitudes        info    
%     _______    _________    __________    ____________
% 
%       5e+06      5e+06          1         {0×0 double}
%       1e+07      2e+06          1         {0×0 double}
%     1.5e+07      1e+07          1         {0×0 double}
%
% ...because the property cevents was set before the timeUnitMultiplier
%and the set method of the timeUnitMultiplier further modifies the cevents
%now is like c2 has "applied" the timeUnitMultiplier twice!
%
%That is, in this case, a straight away blind loop over properties
%yields an invalid copy.
%
%
% So the solution is to:
% 1) set all attributes for which the order matters first, and
% 2) do the rest in a blind loop
%


% Manually copy each property

% 1) set all conditions for which the order matters first, and
newObj.unit = obj.unit;
idx = arrayfun(@(val) strcmp(val.Name, 'unit'), props);
idx = find(idx);
props(idx) = [];

newObj.nominalSamplingRate = obj.nominalSamplingRate;
idx = arrayfun(@(val) strcmp(val.Name, 'nominalSamplingRate'), props);
idx = find(idx);
props(idx) = [];

newObj.timeUnitMultiplier = obj.timeUnitMultiplier;
idx = arrayfun(@(val) strcmp(val.Name, 'timeUnitMultiplier'), props);
idx = find(idx);
props(idx) = [];




% 2) do the rest in a blind loop
for i = 1:numel(props)
    value = obj.(props(i).Name);

    if ~strcmp(props(i).SetAccess,'none') && ~props(i).Dependent
        % Handle nested handle objects
        if isa(value, 'handle')
            newObj.(props(i).Name) = value.copy(); % Recursive copy
        else
            newObj.(props(i).Name) = value; % Direct copy for non-handle types
        end
    end
end


%Finally, some home-tyding
if ~strcmp(newObj.classVersion,obj.classVersion)
    warning('icnna:data:core:condition:copy:DifferentClassVersion', ...
            ['The copy has a different .classVersion: ' ...
             'newObj.classVersion ''' newObj.classVersion ''''...
             '; obj.classVersion '''  obj.classVersion '''.']);
end

end