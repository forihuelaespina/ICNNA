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
% File created: 29-Aug-2025
%
% -- ICNNA v1.3.1
%
% 29-Aug-2025: FOE 
%   + File created. 
%

% Create a new instance of the same class
newObj = feval(class(obj));


metaClass  = metaclass(obj);
props = metaClass.PropertyList; % List of properties
    %Note that using properties(obj) only retrieve the names
    %of the (public) properties, whereas this call get a lot
    %of additional information e.g. private properties,
    %features of the properties e.g. whether it is dependent, etc


% Manually copy each property

% 1) set all conditions for which the order matters first, and
newObj.sites = obj.sites;
idx = arrayfun(@(val) strcmp(val.Name, 'sites'), props);
idx = find(idx);
props(idx) = [];

newObj.setBundle(obj.E,obj.B,obj.p);
idx = arrayfun(@(val) strcmp(val.Name, 'E'), props);
idx = find(idx);
props(idx) = [];
idx = arrayfun(@(val) strcmp(val.Name, 'B'), props);
idx = find(idx);
props(idx) = [];
idx = arrayfun(@(val) strcmp(val.Name, 'p'), props);
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