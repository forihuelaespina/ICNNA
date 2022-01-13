function [dbCons,ver]=getDBConstants(v)
%Get a list of constants for accessing the a database
%
% [dbCons,version]=getDBConstants get the list of
%   constant of the current database version, and the current
%   version number.
%
% [dbCons]=getDBConstants(version) retrive the constants for
%   a particular version
%
% The constants values defined varies depending on the database version.
%Please refer to the database help file to find out the database version.
%
%Independent variable columns always precede dependent
%variable columns.
%Regardless of the version, the constants always include a constant
%.COL_LAST_INDEPENDENT which holds an index to the last
%independent variable.
%
%
%
% Copyright 2008-9
% date: 28-Nov-2008
% Author: Felipe Orihuela-Espina
%
% See also experimentSpace, generateDB
%

ver=1; %Current version
if exist('v','var')
    ver=v;
end


%%Inpendent Variables
switch (ver)
    case 1
        %== Independent Variables
        dbCons.COL_SUBJECT    =1;
        dbCons.COL_SESSION    =2;
        dbCons.COL_DATASOURCE =3;
        dbCons.COL_STRUCTUREDDATA=4;
        dbCons.COL_CHANNEL    =5;
        dbCons.COL_SIGNAL     =6;
        dbCons.COL_STIMULUS   =7;  % a.k.a. as condition
        dbCons.COL_BLOCK      =8;  % a.k.a. as trial
        dbCons.COL_LAST_INDEPENDENT=dbCons.COL_BLOCK;
        %== Independent Variables
        dbCons.COL_MEAN_BASELINE = 1+dbCons.COL_LAST_INDEPENDENT;
        dbCons.COL_STD_BASELINE = 2+dbCons.COL_LAST_INDEPENDENT;
        dbCons.COL_MEAN_TASK = 3+dbCons.COL_LAST_INDEPENDENT;
        dbCons.COL_STD_TASK = 4+dbCons.COL_LAST_INDEPENDENT;
        dbCons.COL_TASK_MINUS_BASELINE = 5+dbCons.COL_LAST_INDEPENDENT;
        dbCons.COL_AREA_UNDER_CURVE_TASK = 6+dbCons.COL_LAST_INDEPENDENT;
        dbCons.COL_TIME_TO_PEAK = 7+dbCons.COL_LAST_INDEPENDENT;
        dbCons.COL_TIME_TO_NADIR = 8+dbCons.COL_LAST_INDEPENDENT;
        
    otherwise
        error('Version number not recognised');
end
