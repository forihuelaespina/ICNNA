function [I,R]=getIntegrityReport(element,options)
%Generates an integrity report
%
% [I,R]=getIntegrityReport(E) Generates an integrity report for an
%       experiment.
%
% [I,R]=getIntegrityReport(Subj) Generates an integrity report for a
%       subject.
%
% [I,R]=getIntegrityReport(Sess) Generates an integrity report for a
%       session.
%
% [I,R]=getIntegrityReport(DSrc) Generates an integrity report for a
%       dataSource.
%
% [I,R]=getIntegrityReport(SData) Generates an integrity report for a
%       structuredData. Note that this case is similar to the call
%                   double(get(SData,'Integrity'))
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
% SData - A structuredData object
%
%% Output
%
% I - An index matrix of three columns <Subject, Session, DataSource>.
%   If an element does no apply, it will be set to NaN.
%
% R - An integrity matrix with one row per case (<Subject, Session,
%   DataSource>) and as many columns as channels. If not all
%   cases have the same number of channels, the matrix will be
%   filled with NaN.
%   
%
%
% 
% Copyright 2009
% date: 1-Dec-2009
% Author: Felipe Orihuela-Espina
% modified: 1-Dec-2009
%
% See also runIntegrity, addVisualIntegrity
%



opt.verbose=false;
if exist('options','var')
    if isfield(options,'verbose')
        opt.verbose=options.verbose;
    end
end


if (isa(element,'structuredData'))
	%Base case
    I = nan(1,3);
    R = double(get(element,'Integrity'));
	
elseif (isa(element,'dataSource'))
    %Treat as base case
    I = [NaN NaN get(element,'ID')];
    R = [];
	%Get the active data if any
	activeIdx=get(element,'ActiveStructured');
	if (activeIdx~=0)
        child=getStructuredData(element,activeIdx);
        R = double(get(child,'Integrity'));
	end

elseif (isa(element,'session'))
	%Visit all dataSource
	childIDList=getDataSourceList(element);
    nChildren=length(childIDList);
    I = zeros(0,3); %<Subject,Session,DataSource>
    R = []; %I can't guess the number of channels
	for childID=childIDList
        if (opt.verbose)
            pos=find(childID==childIDList);
            disp([datestr(now,13) ': Integrity report - Data Source ' ...
                    num2str(pos) '/' num2str(nChildren)]);
        end

		child=getDataSource(element,childID);
        if isempty(R)
            [I,R]=getIntegrityReport(child,opt);
            sessdefinition = get(element,'Definition');
            I(:,2) = get(sessdefinition,'ID');
        else
            [tmpI,tmpR]=getIntegrityReport(child,opt);
            tmpI(:,2) = get(element,'ID');
            I = [I; tmpI];
            %Match number of columns (channels) in R
            if size(R,2) < size(tmpR,2)
                %Increase the number of columns of R
                [nRows,nCols] = size(R);
                tmpRR = nan(nRows,size(tmpR,2));
                tmpRR(1:nRows,1:nCols)=R;
                R = tmpRR;
            elseif size(R,2) > size(tmpR,2)
                %Increase the number of columns of tmpR
                [nRows,nCols] = size(tmpR);
                tmpRR = nan(nRows,size(R,2));
                tmpRR(1:nRows,1:nCols)=tmpR;
                tmpR = tmpRR;
            end   
            R = [R; tmpR];
        end
	end

elseif (isa(element,'subject'))
	%Visit all Sessions
	childIDList=getSessionList(element);
    nChildren=length(childIDList);
    I = zeros(0,3); %<Subject,Session,DataSource>
    R = []; %I can't guess the number of channels
	for childID=childIDList
        if (opt.verbose)
            pos=find(childID==childIDList);
            disp([datestr(now,13) ': Integrity report - Session ' ...
                    num2str(pos) '/' num2str(nChildren)]);
        end

		child=getSession(element,childID);
        if isempty(R)
            [I,R]=getIntegrityReport(child,opt);
            I(:,1) = get(element,'ID');
        else
            [tmpI,tmpR]=getIntegrityReport(child,opt);
            tmpI(:,1) = get(element,'ID');
            I = [I; tmpI];
            %Match number of columns (channels) in R
            if size(R,2) < size(tmpR,2)
                %Increase the number of columns of R
                [nRows,nCols] = size(R);
                tmpRR = nan(nRows,size(tmpR,2));
                tmpRR(1:nRows,1:nCols)=R;
                R = tmpRR;
            elseif size(R,2) > size(tmpR,2)
                %Increase the number of columns of tmpR
                [nRows,nCols] = size(tmpR);
                tmpRR = nan(nRows,size(R,2));
                tmpRR(1:nRows,1:nCols)=tmpR;
                tmpR = tmpRR;
            end   
            R = [R; tmpR];
        end
	end

elseif (isa(element,'experiment'))
	%Visit all Subjects
	childIDList=getSubjectList(element);
    nChildren=length(childIDList);
    I = zeros(0,3); %<Subject,Session,DataSource>
    R = []; %I can't guess the number of channels
	for childID=childIDList
        if (opt.verbose)
            pos=find(childID==childIDList);
            disp([datestr(now,13) ': Integrity report - Subject ' ...
                    num2str(pos) '/' num2str(nChildren)]);
        end

		child=getSubject(element,childID);
        if isempty(R)
            [I,R]=getIntegrityReport(child,opt);
        else
            [tmpI,tmpR]=getIntegrityReport(child,opt);
            I = [I; tmpI];
            %Match number of columns (channels) in R
            if size(R,2) < size(tmpR,2)
                %Increase the number of columns of R
                [nRows,nCols] = size(R);
                tmpRR = nan(nRows,size(tmpR,2));
                tmpRR(1:nRows,1:nCols)=R;
                R = tmpRR;
            elseif size(R,2) > size(tmpR,2)
                %Increase the number of columns of tmpR
                [nRows,nCols] = size(tmpR);
                tmpRR = nan(nRows,size(R,2));
                tmpRR(1:nRows,1:nCols)=tmpR;
                tmpR = tmpRR;
            end   
            R = [R; tmpR];
        end
	end
end

