function [cbv,cbf,cmro2]=calculateHaemodynamics(oxyHae,deoxyHae,options)
%Calculates the CBV, the CBF and the CMRO2 from the haemoglobin signals
%
% [cbv,cbf,cmro2]=calculateHaemodynamics(oxyHae,deoxyHae,options)
%
% Calculates the cerebral blood volume (CBV), the cerebral
%blood flow (CBF) and the cerebral metabolic rate of oxygen
%(CMRO2) starting from the relative changes in the oxy- and
%deoxy- haemoglobin signals.
%
%
%   Changes in CBF, CBV, and CMRO2 are referred collectively
%   as haemodynamic response to activation (Buxton, 2004).
%   Following an increase in neural activity in the brain,
%   the local CBF increases much more than the CMRO2, and
%   as result oxygen extraction fraction decreases with
%   activation. The blood oxygenation level dependent (BOLD)
%   signal change is sensitive to changes in CBF, CMRO2
%   and CBV.
%
% Properly speaking the function does not actually finds CMRO2 but the
% ratio D(CMRO2)/CMRO2
%
%
%
%%=====================================================
% DPF correction: From relative changes to absolute changes
%%=====================================================
%
%Absolute changes in haemoglobin species HBO2 and HHb
%in microMolar can be used to estimate the haemodynamics
%parameters CBF (Edwards,1988 ??) and CBV (Wyatt, 1990).
%This function starts from relative changes in haemoglobin
%given in microMolar x cm. In order to obtain absolute
%changes in microMolar it is necessary to correct for
%the DPF (see applyDPF.m). Following sections of these
%comments assume that the correction has already been
%performed.
%
%%=====================================================
%A) Calculation of the Cerebral Blood Volume (CBV)
%%=====================================================
%
%   CBV determines the total amount of blood in the brain (Buxton, 2004),
%   and thus the total haemoglobin present. Total Haemoglobin is related to
%   CBV by the cerebral haematocrit (Bennet, 2006 and Wyatt, 1990):
%
%               Total Hb
%       CBV = -----------   [ml/100gr]
%                 H.R
%
%   where H is the large vessel (arterial) haematocrit
%   and R is the cerebral to large vessels haematocrit ratio.
%   
%   According to Boas et al (Boas, 2003) if the haematocrit
%   is considered constant, the total Hb is proportional to CBV.
%
%
% For a detailed conversion and units see my notebook
%(29-Nov-2007), but here is a summary.
%
%
%                                10^-6 mol
%                        HbT    -----------
%                                     l
%                     -------------------------
%                                     gr
%                        phi      ---------
%     10^-3 l                      10^-3 l
% CBV -------- = ----------------------------------------
%      100gr                         gr
%                        H'      ---------
%                                 10^-1 l
%                     ----------------------- * R [-]
%                                    gr
%                        M       ---------
%                                   mol
%
%
% where:
%   HbT is the absolute change in total Hb expressed in microMolar
%       (i.e. microMols per liter), which is our DPF corrected
%       HbT values.
%   phi is the brain tissue density. Estimated to be 1.05
%       gr/10^-3 l by (Nelson, 1971) and (Pellicer, 2002) and
%       used by (Wyatt, 1990). This tissue density is necessary
%       to correct HbT units from microMolar to moles per 100
%       grames of tissue as required by Wyatt's relation.
%   H' is the large vessel haematocrit in [gr/deciliter] as used
%       by (Wyatt,1990). Wyatt did actually extract a blood sample
%       from the subjects to get this value. We do not
%       have that information, however, (Gupta, 1997) assumed
%       to be 15 [gr/deciliter]
%   M is the molecular weight of the haemoglobin molecule.
%       Its use is neccessary to convert H' to H and thus
%       correct for the units as neccessary. It has been
%       calculated to be 64500 [gr/mol] (see OMLC web site
%       omlc.ogi.edu/spectra/haemoglobin/index.html)
%   R is the cerebral to large vessels haematocrit ratio.
%       Wyatt (based on [Lammerstma????]), assumes this
%       value to be 0.69. But a discussion in [Okazawa, 1996]
%       gives some more published values for R:
%        *[Lammertsma in [Okazawa, 1996]]
%           0.69+/-0.07 but subjects were patients with brain
%           tumor or cerebrovascular disease except 1 healthy
%           subject. This value was the one used by [Wyatt, 1990]
%           and has also been used by [Meek,1998], [Pellicer2002]
%           and [Boas et al,2003].
%        *[Okazawa,1996] 0.88+/-0.06 based on 12 healthy
%           subjects
%        *[Loufti in [Okazawa,1996]] 0.87+/- 0.03 in 3
%           healthy subjects
%       Based on all this, I will used the value 0.88 by
%       [Okazawa,1996] as it is the one based on the largest
%       study of healthy people.
%
%With all the above we can rewrite the above equation as:
%
%        10^-3 l     10^-5 M        10^-3 l
%   CBV --------- = ---------- HbT ---------
%        100 gr      phi.R.H'       100 gr
%
% and substituting the values:
%
%        10^-3 l     10^-5.64500            10^-3 l
%   CBV --------- = ------------------ HbT ---------
%        100 gr      1.05 . 0.88 . 15        100 gr
%
%
%where HbT is expressed in [10^-6 mol/l] which is our case
%after the DPF correction. Note that the factor before HbT
%can be seen as a constant.
%
%
%%=====================================================
%B) Calculation of the Cerebral Blood Flow (CBF)
%%=====================================================
%
%   CBF is the amount of blood that passes through brain
%   at a given moment (source: Wikipedia). It is measured in
%   [mlitres/gr of brain tissue/minute]
%
%   Normal ranges are values around 50 ml/100 gr.minute.
%   Values above 55 are hyperemia (and risks increase if
%   intracraneal pressure), values below 20 are ischemia,
%   leading to tissue death below 8.
%
%   Grubb at al (1974) established a relationship between
%   CBV and CBF
%
%                10^-3 l                     10^-3 l
%           CBV --------- = 0.80.CBF^0.38 --------------
%                100 gr                    100gr.minute
%
%   This relation has been used to model the haemodynamic
%   response to cerebral activation (Buxton, 2004). However
%   this relation has some important drawbacks as pointed
%   out by (Boas, 2003). Some other more complicated models
%   have been used to estimate CBF from CBV (Boas, 2003).
%   Nevertheless, and with all its limitations, this relation
%   has been used by a number of authors (Boas, 2003 discussion)
%
%   Being this just a first approach, I will stick to
%   Grubb's relation, though I might want to improve it
%   later on...
%
%   From Grubb's relation it follows that:
%
%           CBF = (CBV/0.80)^(1/0.38)
%
%
%
%%=====================================================
%C) Calculation of the Cerebral Metabolic Rate of Oxygen (CMRO2)
%%=====================================================
%
%   CMRO2 is given by the difference of oxygen flowing into
%and out of a brain region. If the arterial oxigen saturation
%SaO2 is assumed to be SaO2=1, then the relative changes in
%CMRO2 is given by [[Mayhew, 2001b] in [Boas, 2003]]
%
%                       /     D(CBF)   \ /            D([HbR])  \
%                       | 1+---------- | | 1+ gamma_R---------- |
% /    D(CMRO2)  \      \      CBF_o   / \             [HbR]_o  / 
% | 1+---------- | = ----------------------------------------------
% \    CMRO2_o   /              /           D([HbT]) \
%                               | 1+gammaT---------- |    
%                               \           [HbT]_o  /
%
%
% where:
%
% - the subindex _o indicates baseline values
% - gammaR and gammaT, represent the factors which relates
% the fractional haemoglobin changes in the venous compartment
% to those across all vascular compartments.
% - D(...) is the variation of ... Sorry not greek Delta character
% available :(
%
% Properly speaking the function does not actually finds CMRO2
%but the ratio D(CMRO2)/CMRO2
%
% See also gammaR, gammaT
%
%
%% Parameters:
%
%oxyHae,deoxyHae - the relative changes in oxy and deoxy haemoglobin
%       signals in microMolar x cm.
%       By default, data is assumed not to be DPF corrected. The function
%       will correct them in order to calculate CBV, CBF and CMRO2. See
%       the options.DPF for more.
% options - Optional. A struct to allow selecting some options
%   options.DPF: Indicates whether the signals in F are DPF corrected or
%       not. By default is set to false.
%
%% Output:
%
%The cerebral blood volume (CBV) and cerebral blood flow (CBF) estimated
%from the oxy and deoxy signals as explained above.
%
%
% Copyright 2007-17
% @date: 6-Mar-2007
% @author: Felipe Orihuela-Espina
% @modified: 28-Jun-2017
%
%
% See also gammaR, gammaT
%


%% Log
%
% 1-Jul-2017: Felipe Orihuela Espina
%   Further improved comments.
%   Option to plot the figure generated and code for figure generation
%   updated
%   Incorporated to ICNA.
%
% 20-Dec-2007: Felipe Orihuela Espina
% Some comments improved.
% Values of H and R updated.
% Units checked.
%


%Deal with some options
opt.DPF=false;
opt.plotFigure = false;
if (exist('options','var'))
    if(isfield(options,'DPF'))
        opt.DPF=options.DPF;
    end
    if(isfield(options,'plotFigure'))
        opt.plotFigure=options.plotFigure;
    end
end

%--------------------------------------------------
%Calculation of HbT in [10^-6 mol/l]
%--------------------------------------------------
if(opt.DPF) %Data is DPF corrected... therefore do nothing
    oxyHaeDPF=oxyHae;
    deoxyHaeDPF=deoxyHae;
else %Data is NOT DPF corrected...therefore do correct. Default!
    oxyHaeDPF=applyDPF(oxyHae);
    deoxyHaeDPF=applyDPF(deoxyHae);    
end

totalHb=oxyHaeDPF+deoxyHaeDPF; %in [10^-6 mol/l]


%--------------------------------------------------
%A) Calculation of the Cerebral Blood Volume (CBV)
%--------------------------------------------------
%        10^-3 l     10^-5 M        10^-3 l
%   CBV --------- = ---------- HbT ---------
%        100 gr      phi.R.H'       100 gr
%
%where HbT is expressed in [10^-6 mol/l]
H=15; %[gr/10^-1 l] ; Value from [Gupta,1997]
M=64500; %[gr/mol] ; Value from OMLC
R=0.88; %[-] dimensionless ; Value from [Okazawa, 1996]
phi=1.05; %[gr/10^-3 l] ; Value from [Nelson1971] and [Pellicer2002]
%((10^-5*M)/(phi*R)) %This constant should be equal to 0.89
                     %when R=0.69; See [Zotter, 2007, pg 240]
%Note, than when we include H'=15 in the constant, CBV << HbT!!
cbv=((10^-5*M)/(phi*R*H))*totalHb;
%%Watch out! It can yield negative volumes when HbT is negative!!
%%In addition, note how small are my CBV values in [10^-3 l/100gr]
%%when compared to those from Grubb's (1974) which seems to
%%range between 2.1 and 5.3, or those of Gupta (1997) which
%%range between 1 and 11 (Gupta's fig 2). Note alse that Gupta's HbT
%%ranging between -9 and 9 microMolar (fig 1) which is ten times
%%larger (1 order of magnitude) than ours...Hmmm
%%This obviously is a weakness to use Grubb's relation to
%%calculate CBF since it may not apply for this range.



%--------------------------------------------------
%B) Calculation of the Cerebral Blood Flow (CBF)
%--------------------------------------------------
%           CBV=0.80.CBF^0.38       =>  CBF=(CBV/0.80)^(1/0.38)
cbf=(cbv/0.80).^(1/0.38);
%[totalHb cbv (cbv/0.80) cbf]
%The above operation can lead to some complex numbers if cbv is negative
%%So just to play safe, use only the real value...
cbf=real(cbf);

%%Since CBV values are so small (well below 1), the resulting
%%CBF values, are very close to 0. Far from Grubb's range
%%between 22 and 143 [10^-3 l/100gr.minute]

%--------------------------------------------------
%C) Calculation of the Cerebral Metabolic Rate of Oxygen (CMRO2)
%--------------------------------------------------
%
%                       /     D(CBF)   \ /            D([HbR])  \
%                       | 1+---------- | | 1+ gamma_R---------- |
% /    D(CMRO2)  \      \      CBF_o   / \             [HbR]_o  / 
% | 1+---------- | = ----------------------------------------------
% \    CMRO2_o   /              /           D([HbT]) \
%                               | 1+gammaT---------- |    
%                               \           [HbT]_o  /


pv =0.005; %Partial Volume Factor Assumed by (Boas et al, 2003)
            %I am not very sure how this parameter works...
so2=0.65; %Baseline oxygen saturation (SO2) as assumed by Boas et al, 2003
hbt0 = 100*10^-6; %100microM Assumed by (Boas et al, 2003)
hbr0 = (1-so2)*hbt0; %35microM (Boas et al, 2003) assumed [HbT]_o=100microM and oxygen saturationof 0.65

cbf0 = cbf(1);
%cbf(2:end)=cbf(2:end)-cbf(1); %Correct for the "baseline" being the first sample...
temp=deoxyHaeDPF;
%hbr0 = temp(1);
%temp(2:end)=temp(2:end)-hbr0; %Correct for the "baseline" being the first sample...
temp=temp-hbr0; %Correct for the "baseline" being the first sample...
%hbt0 = totalHb(1)
totalHb=totalHb-hbt0; %Correct for the "baseline" being the first sample...

gr =gammaR;
gt =gammaT;

term1 = 1+(cbf/cbf0);
term2 = 1+(gr*(temp/hbr0));
numerator = term1.*term2;
denominator = 1+(gt*(totalHb/hbt0));

cmro2=(numerator./denominator)-1;
cmro2=cmro2/cmro2(1);
cmro2=cmro2*pv;
cmro2=cmro2-cmro2(1); %Correct for the "baseline" being the first sample...
%cmro2=applyDPF(cmro2)


%%--------------------------------------------------
%=================  Graficas
opt.lineWidth = 2;
if opt.plotFigure
    fontSize=13;
    figure, hold on
    %Set Figure screen size
    set(gcf,'Units','normalized');
    set(gcf,'Position',[0.02, 0.04, 0.9, 0.87]);
    set(gcf,'Units','pixels'); %Return to default
    
    %plot(totalHb,'g-','LineWidth',2)
    %plot(totalHb/H,'g--','LineWidth',2)
    %plot(cbv,'r--','LineWidth',2)
    [AX,hHbT,hCBV]=plotyy(1:1:length(totalHb),totalHb, ...
                          1:1:length(totalHb),cbv);
    
    axis(AX(1));
    set(hHbT,'Color','g','LineWidth',opt.lineWidth);
    hOxy = plot(oxyHaeDPF,'r-','LineWidth',opt.lineWidth);
    hDeoxy = plot(deoxyHaeDPF,'b-','LineWidth',opt.lineWidth);
    
    axis(AX(2));
    set(hCBV,'Color','m','LineStyle','--','LineWidth',opt.lineWidth);
    hCBF = plot(10*cbf,'k--','LineWidth',opt.lineWidth);
    %plot(term1,'g-','LineWidth',opt.lineWidth)
    %plot(term2,'b-','LineWidth',opt.lineWidth)
    %plot(numerator,'r--','LineWidth',opt.lineWidth)
    %plot(denominator,'k--','LineWidth',opt.lineWidth)
    hCMRO2= plot(cmro2,'c--','LineWidth',opt.lineWidth);
    box on, grid on
    %legend('term1 (cbf)','term2 (hbr)','numerator','denominator (hbt)','cmro2')
    %legend('HbO2 (DPF corrected)','HHb (DPF corrected)','HbT','cbv','cbf','cmro2')
    %legend('HbT/H','CBV','CBF','CMRO2')
    %legend('cmro2')
    
    xlabel('Time [s]','FontSize',fontSize);
    %ylabel('\Delta Hb [\mu Molar]','FontSize',fontSize);
    set(AX(1),'XLim',[1 length(totalHb)]);
    set(AX(2),'XLim',[1 length(totalHb)]);
    %set(AX(2),'YLim',get(AX(1),'YLim'))
    %set(AX(2),'YTick',get(AX(1),'YTick'))
    set(get(AX(1),'Ylabel'),'String','\Delta Hb [\mu Molar]','FontSize',fontSize);
    set(get(AX(2),'Ylabel'),'String','CBV [ml/100gr] / CBF [ml/100gr/min] / D(CMRO_2)/CMRO_2 [A.U.]','FontSize',fontSize);
    set(AX(1),'FontSize',fontSize);
    set(AX(2),'FontSize',fontSize);
    l=legend([hOxy, hDeoxy, hHbT, hCBV, hCBF, hCMRO2],'HbO_2','HbR','HbT','CBV','10*CBF','D(CMRO_2)/CMRO_2');
    set(l,'FontSize',fontSize);
end