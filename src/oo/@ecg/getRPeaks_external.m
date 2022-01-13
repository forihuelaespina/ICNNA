function [rPeaks,threshold]=getRPeaks(HRsignal,thresh)
%ECG/GETRPEAKS Indexes of samples at which the QRS complexes wave peaks
%
% [rPeaks,threshold]=getRPeaks(HRsignal) finds the indexes of
% samples at which the QRS complexes wave peaks, or R peaks
% using an automatic statistically optimal threshold (See
% section Algorithm).
%
% rPeaks=getRPeaks(HRsignal,thresh) finds the indexes of samples
% at which the QRS complexes wave peaks, or R peaks using the
% specified threshold.
%
%% Algorithm
%
% It uses a Laplacian of a Gaussian over the raw ecg signal to detect
%discontinuities. Then it applies a threshold to the LoG and finally groups
%continuous groups peaks (thinning). The threshold can be computed
%automatically using Calvard and Riddler optimal threhsolding algorithm,
%or manually selected (parameter thresh).
%
%
% Laplacian of the Gaussian
%
% LoG 1D Masks: [-2 0 2]
% Laplacian of the Gaussian a.k.a. Mexican hat (*)
% * Combination of low and high pass filter
% * A Laplacian smoothed by a Gaussian
% * Mask (7x7):
%    0  0 -1 -1 -1  0  0
%    0 -1 -3 -3 -3 -1  0
%   -1 -3  0  7  0 -3 -1
%   -1 -3  7 24  7 -3 -1
%   -1 -3  0  7  0 -3 -1
%    0 -1 -3 -3 -3 -1  0
%    0  0 -1 -1 -1  0  0
%
%Masks of different sizes:
%LoG=[1 -2 1];
%LoG=[4 -8 4];
%LoG=[1 -8 1];
%LoG=[1 2 -16 2 1];
%LoG=[1 3 -7 -24 -7 3 1]; <- This is the one currently used
%
%
%
%% Remarks
%
% This function updates the property threshold.
%
%
%% Parameter
%
% HRsignal - Raw ECG (electrocardiogram) data series
%
% thresh - Optional. A threshold established manually.
%
%% Output
%
% A column vector of samples indexes to the R peaks
%
%
% Copyright 2009
% Author: Felipe Orihuela-Espina
% Date: 19-Jan-2009
%
% See also ecg, getRR, getBPM
%



%% Deal with some options
opt.visualize=false;
if exist('options','var')
    if(isfield(options,'visualize'))
        opt.visualize=options.visualize;
    end
end

LoG=[1 3 -7 -24 -7 3 1];
normFactor=1/sum(LoG);

tmp1=normFactor*conv(HRsignal,LoG);
tmp1(1:floor(length(LoG)/2))=[];
tmp1(end-floor(length(LoG)/2)+1:end)=[];
tmp1=-1*(HRsignal-tmp1);

if exist('thresh','var')
    threshold=thresh;
else
    threshold=ecg.optimalThreshold(abs(tmp1));
end
rPeaks=find(tmp1>threshold)'; %Indexes to R peaks



%Group together
tmpIdx=find(rPeaks(2:end)==rPeaks(1:end-1)+1);
rPeaks(tmpIdx)=[];

%Manually discard the boundaries; which obviously are always detected
rPeaks(end)=[];
rPeaks(1)=[];
%%%%%%%%%%%%% REPLACING R-PEAKS by Delaram Jarchi

L = 100;
%a=1;b=size(data,1);
[X N] = Build_traj(HRsignal,L);
[U V rc d] = SVD_traj(X);
[U V rca1] = Group(U,V,[2:10]);
y1 = Reconstruct(rca1,N,L);

yy = peakdet(y1,0.2);
newy=yy(:,2);

%%%%%%%%% 0.1 12
% L1 = 100;
% [X1 N1] = Build_traj(newy,L);
% [U1 V1 rc1 d1] = SVD_traj(X1);
% [U1 V1 rca2] = Group(U1,V1,[3:6]);
% yn1 = Reconstruct(rca2,N1,L1);
%figure,plot(y1)
%hold on 
%plot(newy,'r')
%%%%%%%%%

%yy1 = peakdet(yn1,50);
%yy1 = peakdet(newy-mean(newy),(1.5)*mean(newy));
help1 = newy-mean(newy);
yy1 = peakdet(help1.^2,1.5*mean(help1.^2));
index = find(help1(yy1(:,1))<0);
if(size(index,1)>0)
yy1(index,[])=[];
%disp('yes')
end
rPeaks = yy(yy1(:,1),1);

%yy1 = peakdet(newy,30);
% figure,subplot(3,1,1),plot(newy-mean(newy))
% hold on
% plot(yy1(:,1),newy(yy1(:,1)),'*')
% 
% data1 = data(a:b,2);
% subplot(3,1,2),plot(data(a:b,2))
% hold on 
% plot(yy(yy1(:,1),1),data1(yy(yy1(:,1),1)),'*r')
% subplot(3,1,3),plot(y1)
% hold on
% plot(yy(yy1(:,1),1),y1(yy(yy1(:,1),1)),'*g')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Visualization =========================================
if (opt.visualize)
    lineWidth=1.5;
    fontSize=13;
    
    %R peaks detection
    figure
    set(gcf,'Units','normalized');
    set(gcf,'Position',[0.02, 0.05, 0.92, 0.85]);
    set(gcf,'Units','pixels'); %Return to default
    
    hold on
    plot(HRsignal,'b-','LineWidth',lineWidth);
    plot(tmp1,'r-','LineWidth',lineWidth);
    getY=axis;
    for ii=1:length(rPeaks)
        plot([rPeaks(ii) rPeaks(ii)],[getY(3) getY(4)],'k--', ...
                'LineWidth',lineWidth)
    end
    title(['LoG 1D Mask: ' mat2str(LoG) '; Thrsh: ' num2str(threshold)])
    box on, grid on

end

function [X N] = Build_traj(x1,L)

N=length(x1);
if L>N/2;L=N-L;end
 K=N-L+1;
 X=zeros(L,K);
for i=1:K
    X(1:L,i)=x1(i:L+i-1);
end

end
function [U,V,rc,d] = SVD_traj(X)

   % X= X-mean(mean(X));
    
    S=X*X'; 
   % S=cov(X);
    
	[U,autoval]=eig(S);
	[d,i]=sort(-diag(autoval));  
    d=-d;
    U=U(:,i);sev=sum(d); 
	%plot((d./sev)*100),hold on,plot((d./sev)*100,'rx');
    %title('Singular Spectrum');xlabel('Eigenvalue Number');ylabel('Eigenvalue (% Norm of trajectory matrix retained)')
    V=(X')*U; 
    rc=U*V';

end
function y = Reconstruct(rca,N,L)

  K=N-L+1; 
  y=zeros(N,1);  
  Lp=min(L,K);
  Kp=max(L,K);

   for k=0:Lp-2
     for m=1:k+1;
      y(k+1)=y(k+1)+(1/(k+1))*rca(m,k-m+2);
     end
   end

   for k=Lp-1:Kp-1
     for m=1:Lp;
      y(k+1)=y(k+1)+(1/(Lp))*rca(m,k-m+2);
     end
   end

   for k=Kp:N
      for m=k-Kp+2:N-Kp+1;
       y(k+1)=y(k+1)+(1/(N-k))*rca(m,k-m+2);
     end
   end

end
function [U V rca] = Group(U,V,I)

   Vt=V';
   rca=U(:,I)*Vt(I,:);

end
function [maxtab, mintab]=peakdet(v, delta, x)
%PEAKDET Detect peaks in a vector
%        [MAXTAB, MINTAB] = PEAKDET(V, DELTA) finds the local
%        maxima and minima ("peaks") in the vector V.
%        MAXTAB and MINTAB consists of two columns. Column 1
%        contains indices in V, and column 2 the found values.
%      
%        With [MAXTAB, MINTAB] = PEAKDET(V, DELTA, X) the indices
%        in MAXTAB and MINTAB are replaced with the corresponding
%        X-values.
%
%        A point is considered a maximum peak if it has the maximal
%        value, and was preceded (to the left) by a value lower by
%        DELTA.

% Eli Billauer, 3.4.05 (Explicitly not copyrighted).
% This function is released to the public domain; Any use is allowed.

maxtab = [];
mintab = [];

v = v(:); % Just in case this wasn't a proper vector

if nargin < 3
  x = (1:length(v))';
else 
  x = x(:);
  if length(v)~= length(x)
    error('Input vectors v and x must have same length');
  end
end
  
if (length(delta(:)))>1
  error('Input argument DELTA must be a scalar');
end

if delta <= 0
  error('Input argument DELTA must be positive');
end

mn = Inf; mx = -Inf;
mnpos = NaN; mxpos = NaN;

lookformax = 1;

for i=1:length(v)
  this = v(i);
  if this > mx, mx = this; mxpos = x(i); end
  if this < mn, mn = this; mnpos = x(i); end
  
  if lookformax
    if this < mx-delta
      maxtab = [maxtab ; mxpos mx];
      mn = this; mnpos = x(i);
      lookformax = 0;
    end  
  else
    if this > mn+delta
      mintab = [mintab ; mnpos mn];
      mx = this; mxpos = x(i);
      lookformax = 1;
    end
  end
end
end
end
