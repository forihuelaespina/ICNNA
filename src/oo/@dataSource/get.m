function val = get(obj, propName)
% DATASOURCE/GET Get properties from the specified object
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
% Copyright 2008-14
% @date: 12-May-2008
% @author Felipe Orihuela-Espina
% @modified: 23-Jan-2014
%
% See also dataSource, structuredData, set
%

%% Log
%
% 23-Jan-2014: In guessing/getting the type from a raw data, conversion
%   does now allow for overlapping conditions.
%


switch propName
case 'ID'
   val = obj.id;
case 'Name'
   val = obj.name;
case 'DeviceNumber'
   val = obj.deviceNumber;
case 'Type'
    %Find the type on the fly
    val='';
    if ~(isempty(obj.structured))
        val=class(obj.structured{obj.activeStructured});
    else
        %Try to guess it from the rawData if it has been defined.
        r=getRawData(obj);
        if ~isempty(r)
            %fprintf(1,['Unable to establish dataSource type from structuredData. ' ...
            %           'Trying\nto guess it from rawData.\n']);
            val=class(convert(r,'AllowOverlappingConditions',0));
                %Temporally allow for overlapping conditions to make less
                %restrictive.
        end
    end
case 'Lock'
   val = obj.lock;
case 'RawData'
   val = obj.rawData;
case 'ActiveStructured'
   val = obj.activeStructured;
otherwise
   error([propName,' is not a valid property'])
end