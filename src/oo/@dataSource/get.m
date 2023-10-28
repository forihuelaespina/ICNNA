function val = get(obj, propName)
% DATASOURCE/GET DEPRECATED (v1.2). Get properties from the specified object
%and return the value
%
% val = get(obj, propName) Gets value of the property propName 
%
%
%% Properties
%
% 'ID' - The object identifier
% 'Name' - The name
% 'Device number' - A number identifying the device from which the data
%   originated
% 'Type' - The type of the data source. See dataSource for more
%   information on this attribute.
% 'Lock' - Whether existing the structured data arise from the
%   defined raw data.
% 'RawData' - The raw Data if defined or an empty matrix if not defined.
% 'ActiveStructured' - The ID of the currently active structuredData
%
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also dataSource, structuredData, set
%

%% Log
%
%



%% Log
%
% File created: 12-May-2008
% File last modified (before creation of this log): 23-Jan-2014
%
% 23-Jan-2014: 
%   + Added this log. 
%  + In guessing/getting the type from a raw data, conversion
%   does now allow for overlapping conditions.
%
% 21-May-2023: FOE
%   + Got rid of old labels @date and @modified.
%   + As I started to add get/set methods for struct like access
%   to attributes in the main class file, I also updated this
%   method to simply redirect to those.
%   + Declare method as DEPRECATED (v1.2).
%   Bug fixed:
%   + 1 error was still not using error code.
%

warning('ICNNA:dataSource:get:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for accessing the attribute ' ...
         'e.g. dataSource.' lower(propName) '.']); 
    %Maintain method by now to accept different capitalization though.



switch lower(propName)
case 'id'
   val = obj.id;
case 'name'
   val = obj.name;
case 'devicenumber'
   val = obj.deviceNumber;
case 'type'
   val = obj.type;
    % %Find the type on the fly
    % val='';
    % if ~(isempty(obj.structured))
    %     val=class(obj.structured{obj.activeStructured});
    % else
    %     %Try to guess it from the rawData if it has been defined.
    %     r=getRawData(obj);
    %     if ~isempty(r)
    %         %fprintf(1,['Unable to establish dataSource type from structuredData. ' ...
    %         %           'Trying\nto guess it from rawData.\n']);
    %         val=class(convert(r,'AllowOverlappingConditions',0));
    %             %Temporally allow for overlapping conditions to make less
    %             %restrictive.
    %     end
    % end
case 'lock'
   val = obj.lock;
case 'rawdata'
   val = obj.rawData;
case 'activestructured'
   val = obj.activeStructured;
otherwise
   error('ICNNA:dataSource:get:InvalidProperty',...
        [propName,' not found.'])
end



end