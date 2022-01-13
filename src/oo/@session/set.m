function obj = set(obj,varargin)
% SESSION/SET Set object properties and return the updated object
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
% Copyright 2008-12
% @date: 12-May-2008
% @author Felipe Orihuela-Espina
% @modified: 12-Jun-2012
%
% See also session, get
%
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
            warning('ICNA:session:set:sessionDefinition',...
                ['Updating the definition may result in sources ' ...
                'being removed.']);
            nElements=length(obj.sources);
            for ii=nElements:-1:1
                id=get(obj.sources{ii},'ID');

                %Check that it complies with the definition
                if ~(ismember(id,IDList))
                    %Remove this source
                    obj.sources(ii)=[];
                elseif ~(strcmp(...
                        get(getSource(obj.definition,id),'Type'),...
                        get(obj.sources{ii},'Type')))
                    %Remove this source
                    obj.sources(ii)=[];
                end
            end
                        
        else
            error('Value must be a sessionDefinition');
        end

    case 'date'
        obj.date = val;

%From the definition
    case 'id'
        obj.definition = set(obj.definition,'ID',val);
    case 'name'
        obj.definition = set(obj.definition,'Name',val);
    case 'description'
        obj.definition = set(obj.definition,'Description',val);

    otherwise
      error(['Property ' prop ' not valid.'])
   end
end
assertInvariants(obj);