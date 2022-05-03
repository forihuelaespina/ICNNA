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
% 3-Apr-2019: FOE.
%   + Updated following the definition of get/set.property methods in
%   the class main file. This is now a simple wrapper to ignore case.
%   Further, note that MATLAB automatically takes care of yielding
%   an error message if the property does not exist.
%
% 20-February-2022 (ESR): We simplify the code
%   + We simplify the code. All cases are in the dataSource class.
%   + We create a dependent property inside of the dataSource class 
%
% 24-March-2022 (ESR): Lowercase
%   + These cases are to convert the capitalization to lower case so that 
%   they can all be called correctly.
%
     tmp = lower(propName);
    
    switch (tmp)

           case 'activestructured'
                val = obj.activeStructured;
           case 'devicenumber'
                val = obj.deviceNumber;
           case 'id'
                val = obj.id;  
           case 'lock'
                val = obj.lock;
           case 'name'
                val = obj.name;
           case 'rawdata'
                val = obj.rawData;
           case 'type'
                val = obj.type;

        otherwise 
               error([propName,' is not a valid property'])
    end
end