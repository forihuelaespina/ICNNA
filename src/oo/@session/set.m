function obj = set(obj,varargin)
% SESSION/SET DEPRECATED (v1.2). Set object properties and return the updated object
%
% obj = set(obj,varargin) Set object properties and return 
%   the updated object
%
%% Properties
%
% 'Definition' - Session definition
% 'Date' - Date
%
% == Extracted from the sessionDefinition
% 'ID' - The session ID
% 'Name' - The session name
% 'Description' - The session description
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also session, get
%





%% Log
%
% File created: 12-May-2008
% File last modified (before creation of this log): 12-Jun-2012
%
% 24-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Started to update the get/set methods calls for struct like access
%   + Declare method as DEPRECATED (v1.2).
%



warning('ICNNA:session:set:Deprecated',...
        ['DEPRECATED (v1.2). Use struct like syntax for setting the attribute ' ...
         'e.g. session.' lower(varargin{1}) ' = ... ']); 

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch lower(prop)
    case 'definition'
        if (isa(val,'sessionDefinition'))
            obj.definition = val;
            IDList=getSourceList(obj.definition);
            warning('ICNNA:session:set:sessionDefinition',...
                ['Updating the definition may result in sources ' ...
                'being removed.']);
            nElements=length(obj.sources);
            for ii=nElements:-1:1
                tmpDS = obj.sources{ii};
                id=tmpDS.id;

                %Check that it complies with the definition
                if ~(ismember(id,IDList))
                    %Remove this source
                    obj.sources(ii)=[];
                elseif ~(strcmp(...
                        get(getSource(obj.definition,id),'Type'),...
                        tmpDS.type))
                    %Remove this source
                    obj.sources(ii)=[];
                end
            end
                        
        else
            error('ICNNA:session:set:sessionDefinition',...
                  'Value must be a sessionDefinition');
        end

    case 'date'
        obj.date = val;

%From the definition
    case 'id'
        tmp = obj.definition;
        tmp.id = val;
        obj.definition = tmp;
    case 'name'
        tmp = obj.definition;
        tmp.name = val;
        obj.definition = tmp;
    case 'description'
        tmp = obj.definition;
        tmp.description = val;
        obj.definition = tmp;

    otherwise
      error('ICNNA:session:set:InvalidProperty',...
                  ['Property ' prop ' not found.'])
   end
end
assertInvariants(obj);


end