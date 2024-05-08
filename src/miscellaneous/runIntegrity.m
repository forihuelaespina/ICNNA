function element=runIntegrity(element,options)
%Recursively check the integrity for element and all its children
%
% E=runIntegrity(E)
%
% Subj=runIntegrity(Subj)
%
% Sess=runIntegrity(Sess)
%
% DSrc=runIntegrity(DSrc)
%
% SData=runIntegrity(SData)
%
% [...]=runIntegrity(...,options)
%
%
%
%% Parameters
%
% E - An experiment object
%
% Subj - A subject object
%
% Sess - A session object
%
% DSrc - A dataSource object
%
% options - A struct with the selected tests and other options
%   .testInRawWhenPossible - Although test in raw data is often
%       device dependent, some integrity tests are faster and/or
%       more accurate when carried out on raw data, than on converted
%       data. Set this option to true (default), to attempt carrying out
%       some tests in raw data. Whenever it is unfeasible to make
%       the test in raw data, the "normal" test will still be carried
%       out.
%   .whichChannels - A row vector of channels. Restrict the integrity
%       check to the selected channels. By default, integrity is check
%       in all channels. This is regardless of whether integrity
%       will be forced or not in channels were integrity has already
%       been previously check.
%   .verbose - Show(defualt)/Hide progress messages
%
%
%% Output
%
% The same input element but with the integrity test run.
%   
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also structuredData.checkIntegrity, getIntegrityReport,
%   addVisualIntegrity
%


%% Log
%
% File created: 8-Jul-2008
% File last modified (before creation of this log): 29-Oct-2010
%
% 24-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Started to update the get/set methods calls for struct like access.
%


optTestInRawWhenPossible=true;
optVerbose=true;
if isfield(options,'testInRawWhenPossible')
    optTestInRawWhenPossible=options.testInRawWhenPossible;
end
if isfield(options,'verbose')
    optVerbose=options.verbose;
end
if isfield(options,'whichChannels')
    whichChannels=options.whichChannels;
end


if (isa(element,'structuredData'))
	%Find the tests
	classType=class(element);
	tests=options.(classType);
	testNames=fieldnames(tests);
	tmpTests=cell(1,2*length(testNames));
	for ll=1:length(testNames) 
		tmpTests(2*ll-1)={testNames{ll}};
		tmpTests(2*ll)={tests.(testNames{ll})};
    end
    if (optVerbose)
        tmpTests(end+1)={'verbose'};
        tmpTests(end+1)={true};
    end
    %call the check integrity
    if exist('whichChannels','var')
        element=checkIntegrity(element,whichChannels,tmpTests{:});
    else
        element=checkIntegrity(element,tmpTests{:});
    end
    if (optVerbose)
        disp([datestr(now,13) ': Integrity Report. ']);
        [~,R]=getIntegrityReport(element);
        disp(R);
        disp([datestr(now,13) ': runIntegrity - Done. ']);
        disp('');
    end
	
elseif (isa(element,'dataSource'))
	%Get the active data if any
	activeIdx=element.activeStructured;
	if (activeIdx~=0)
        if (optVerbose)
            disp([datestr(now,13) ': runIntegrity - Active Data ']);
        end

        child=getStructuredData(element,activeIdx);
        theStatus = child.integrity;

        classType=class(child);
        flagSuccess.(classType) = struct();
            
        flagTested = false;
        if (optTestInRawWhenPossible)
            rawChild = element.rawData;
            if ~isempty(rawChild)
                [theStatusInRaw,flagSuccess] = ...
                        runIntegrityOnRaw(rawChild,theStatus,options);
                %If any channel did not undergo any test, still needs to be
                %marked.
                idxRaw = find(getStatus(theStatusInRaw) == theStatusInRaw.UNCHECK);
                theStatusInRaw = setStatus(theStatusInRaw,idxRaw,theStatusInRaw.FINE);
                flagTested = true;
            end
        end

        if flagTested
            %Ignore those tests successfully run in raw data
            tmpOptions = options;
            
            names = fieldnames(flagSuccess.(classType));
            for nn=1:length(names)
                if (isfield(flagSuccess.(classType),names{nn}) ...
                    & flagSuccess.(classType).(names{nn}) == true ...
                    & flagSuccess.(classType).(names{nn}) == true)
                    tmpOptions.(classType).(names{nn}) = false;
                end
            end
            %Run only those test which have not been run yet
            child=runIntegrity(child,tmpOptions);
            %Finally, conciliate the integrity results
            theStatus2 = child.integrity;
            tmpIntegrityInRawValues = getStatus(theStatusInRaw);
            tmpIntegrityIdx = find(tmpIntegrityInRawValues ...
                                    ~= integrityStatus.FINE);
            theStatus2 = setStatus(theStatus2,tmpIntegrityIdx,...
                                  tmpIntegrityInRawValues(tmpIntegrityIdx));
            child.integrity = theStatus2;
            
        else %Proceed to normal test
            child=runIntegrity(child,options);
        end
        element=setStructuredData(element,activeIdx,child);
	end

elseif (isa(element,'session'))
	%Visit all dataSource
	childIDList=getDataSourceList(element);
    nChildren=length(childIDList);
	for childID=childIDList
        if (optVerbose)
            pos=find(childID==childIDList);
            disp([datestr(now,13) ': runIntegrity - Data Source ' ...
                    num2str(pos) '/' num2str(nChildren)]);
        end

		child=getDataSource(element,childID);
		child=runIntegrity(child,options);
		element=setDataSource(element,childID,child);
	end

elseif (isa(element,'subject'))
	%Visit all Sessions
	childIDList=getSessionList(element);
    nChildren=length(childIDList);
	for childID=childIDList
        if (optVerbose)
            pos=find(childID==childIDList);
            disp([datestr(now,13) ': runIntegrity - Session ' ...
                    num2str(pos) '/' num2str(nChildren)]);
        end

		child=getSession(element,childID);
		child=runIntegrity(child,options);
		element=setSession(element,childID,child);
	end

elseif (isa(element,'experiment'))
	%Visit all Subjects
	childIDList=getSubjectList(element);
    nChildren=length(childIDList);
	for childID=childIDList
        if (optVerbose)
            pos=find(childID==childIDList);
            disp([datestr(now,13) ': runIntegrity - Subject ' ...
                    num2str(pos) '/' num2str(nChildren)]);
        end

		child=getSubject(element,childID);
		child=runIntegrity(child,options);
		element=setSubject(element,childID,child);
	end
end




end