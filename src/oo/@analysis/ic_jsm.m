function d=ic_jsm(s1,s2)
%DEPRECATED. Square root of the Jensen-Shannon divergence between 2 signals
%
% function d=ic_jsm(s1, s2)
%
%Calculates square root of the Jensen-Shannon divergence between 2 signals.
%
%Note that whilst the Jensen-Shannon divergence is not a metric, its square
%root its indeed a metric. See the [Fuglede, 2004]
%
%% Parameters:
%
% s1,s2 - Row vectors representing the signals time courses.
%
%% Output:
%
%The square root of the Jensen-Shannon divergence between 2 signals.
%
%
% Copyright 2007-23
% @author: Felipe Orihuela-Espina
%
%  See also jsm
%




%% Log
%
% File created: 27-Feb-2007
% File last modified (before creation of this log): N/A. This method had
%   not been updated since creation.
%
% 11-Jun-2023: FOE
%   + Added this log. Got rid of old label @date.
%   + Although the method was deprecated already I have now added a
%   warning message.
%   + Method moved from folder private/ to main class folder and explictly
%   declared as static in the class definition.
%


warning('ICNNA:analysis:ic_jsm:Deprecated','DEPRECATED. Use jsm instead.'); 

d=jsm(s1,s2);

% %Calculate their histograms, with bins centered in the same positions
% nBins=10;
% maxVal=max(max(s1),max(s2));
% minVal=min(min(s1),min(s2));
% step=(maxVal-minVal)/(nBins-1);
% bins=minVal:step:maxVal; %Bins centres
% [histS1,outS1]=hist(s1,bins);
% [histS2,outS2]=hist(s2,bins);
% %Note that outS1 and outS2 should have the same values!
% %Note that histSx has only positive values!
% 
% %Calculate the cumulative density functions
% % histS1=cumulativeDensity(histS1);
% % histS2=cumulativeDensity(histS2);
% 
% %Avoid those inconvenient 0s for which the KL divergence
% %is not defined
% %%eps is a MATLAB function which returns a very small number
% histS1(find(histS1==0))=eps;
% histS2(find(histS2==0))=eps;
% 
% %Normalize, so probabilities add up to ~1
% P1=histS1/sum(histS1);
% P2=histS2/sum(histS2);
% 
% %%Report ======================================
% %Calculate the JSD based metric
% d = kldiv(outS1,P1,P2,'jsm');



end
