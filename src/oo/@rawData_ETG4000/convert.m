function nimg=convert(obj,varargin)
%RAWDATA_ETG4000/CONVERT Convert raw light intensities to a neuroimage
%
% obj=convert(obj) Convert raw light intensities to a fNIRS
%   neuroimage, using the modified Beer-Lambert law (MBLL).
%
% obj=convert(obj,optionName,optionValue) Convert raw light
%   intensities to a fNIRS neuroimage, using the modified
%   Beer-Lambert law (MBLL) with additional options specified
%   by one or more optionName, optionValue pair arguments.
%
%
% This function performs the modified Beer-Lambert law (MBLL) conversion.
%
% Converts NIRS light intensities to haemoglobin concentration
%changes using the MBLL conversion. This corresponds to solving
%the equation system:
%
%   / Du_a^l1 \   / e_HbO2^?1    e_Hb^l1 \/ DHbO2 \
%   |   ...   | = |    ...         ...   ||  DHHb |    (Eq. 1)
%   \ Du_a^lm /   \ e_HbO2^?m    e_Hb^lm /\       /
%
%   where D() represents variations, u_a^l1 is the macroscopic absorption
% coefficient of the tissue in [mm^-1] measured at wavelength l1 nm,
% and e_HbO2^l1 and e_HHb^l1 represents the specific absorption
% coeffients for oxy- and deoxy- haemoglobin at wavelength l1 in nm.
%
% The macroscopic absorption of the tissue can be calculated
%from the light intensities using the modified Beer Lambert law:
%
%   $$ A  = log_10 \frac{I_0}{I}  = e \cdot c \cdot d \cdot DPF + G $$
%
% where $A$ is the attenuation measured in optical densities,
% $Io$ is the light intensity incident
% on the medium, $I$ is the light intensity transmitted
% through the medium, $e$ is the specific extinction coefficient of the
% absorbing compound measured in $[\mu molar \times cm]$, $c$ is the
% concentration of the absorbing compound in the solution measured
% in $[\mu molar]$, $d$ is the distance between the points where the light
% enters and leaves the medium in $[cm]$ and G is the Geometrical term
% to account for scattering losses.
%
% See below for further discussion.
%
%% The Beer-Lambert law:
% 
%The absorption of light intensity in a non-scattering medium
%is described by the Beer-Lambert Law. This law states that for
%an absorbing compound dissolved in a non-absorbing medium, the
%attenuation ($A$) is proportional to the concentration of the
%compound in the solution ($c$) and the optical pathlength ($d$):
%
%    $ A  = log_10 \frac{I_0}{I}  = e \cdot c \cdot d $$
%
%where A is the attenuation measured in optical densities,
%Io is the light intensity incident on the medium, I is the
%light intensity transmitted through the medium, $e$ is the
%specific extinction coefficient of the absorbing compound
%measured in micromolar per cm, $c$ is the concentration of the
%absorbing compound in the solution measured in micromolar,
%and d is the distance travelled by the photons between the
%points where the light enters and leaves the medium. 
%
%    $ A  = log_10 \frac{I_0}{I}  = e \cdot c \cdot d $$
%
%The product e.c is known as the (macroscopic) absorption
%coefficient of the medium µa.
%
%       $$A = \mu_a \cdot d \iff \frac{A}{\mu_a} = d$$
%   [Okada2003b, pg. 2916]
%   [Sassaroli2004, pg. N256]
%
%% The modified Beer-Lambert law
%
%When a highly scattering medium is considered, the
%Beer-Lambert relationship must be modified to include
%   (i) an additive term, G, due to scattering losses and
%   (ii) a multiplier, to account for the increased optical
%   pathlength due to scattering. The true optical distance
%   is known as the differential pathlength (DP) and the
%   scaling factor as the differential pathlength factor (DPF):
%
%    $$ DP  = DPF \cdot d $$
%
%where $d$ is the geometrical distance. The $DP$ can be approximated
%by the mean distance $L$ [Hiraoka, 1993, pg 1860].
%
% $L$ is the path in the DPF sense or mean path length and
%is calculated as the product of the separation distance
%of probes ($d=3cm$) (i.e. the distance between the optodes,
%or similarly the distance from the light entering point
%to the tissue to the exiting point) multiplied by
%the accepted DPF in normal adult head (6.26 at 807m
%according to Duncan,1995).
%
% $$ DPF=\frac{L}{d} \iff  L=DPF \cdot d $$
%   [Sassaroli, 2004]
%   [Hiraoka, 1993]
%
%$L$ is an approximation to the real DP (differential
%pathlength) [Hiraoka, 1993, pg 1860]. This approximation
%has been criticised:
% According to [Okada2003b, pg. 2921] it is innappropiate
% to use the mean path length L as an alternative to the
% effective path length $DPF\cdot d$ in the activation region.
%
% Using the wrong $DPF(\lambda)$ has the same effect as calculating
%with the wrong chromophore extinction spectra [Kohl,1998, pg. 1772]
%However, for optode distances larger than 2.5cm, the DPF
%is almost wavelength independent [[van der Zee, 1990]
%in Hiraoka, 1993], [[van der Zee, 1990] in Duncan, 1995]. 
%In addition it has been argued that comparing
%MBLL based NIRS signal amplitudes across different
%measurements is not valid unless the partial path length is
%determined [Hoshi, 2005]
%
%
%The modified Beer-Lambert law which incorporates these two
%additions is then expressed as:
%
%   $$ A  = log_10 \frac{I_0}{I}  = e \cdot c \cdot d \cdot DPF + G $$
%
% Since $G$ is unknown, but can be considered constant during
%measurement, taking differences in the above equation:
%
%  $$ (A2-A1)  = (c2-c1) \cdot e \cdot d \cdot DPF $$
%
%Replicating this equation at each different measured wavelength
%results in the system of equation in Eq. 1.
%
% The DPF is adimensional but depends on the wavelength...
%
%% DPF value and Wavelength dependency of the DPF
%
%  The DPF is usually summarised as a simple value.
%In this function, by default a value 6.26 at 807m
%[Duncan, 1995] will be used, but the user can provide
%a different one. For instance, for newborn babies an accepted
%value is $DPF=4.99$ at 807m [Duncan, 1995], for males it might
%be more correct to use 6.09 or for females 6.42.
%[Essenpreis, 1993, pg 421] gets an average $DPF=6.32\pm 0.46$
%at 800 nm for adults.
%
%But the DPF is not really a constant value, but rather
%it depends on the wavelength lambda. In the original fOSA code
%this wavelength dependency is achieved by fixing
%the DPF value to a standard value (e.g. 6.26) and then
%using a wavelength dependent factor, the so called kDPF.
%
%
% $kDPF(\lambda)$ is the correction for the differential pathlength 
%factor, a wavelength dependent factor to correct the accepted
%general $DPF$ value (which comes as wavelength independent).
%
%fOSA 1 reads it from a file call abscoeff
%which has been copied in ICNA to read from
%it as well, and fOSA 2.1 reads it from table_coeff.
%In this sense, you can think of kDPF as:
%
%  $$ DPF(\lambda)=kDPF(\lambda) \cdot DPF_{accepted} $$
%
%To be precise, kDPF does multiply the extinction coefficient
%rather than the DPF in fOSA code, i.e. rather than adapting
%DPF_accepted to a wavelength dependent version, he actually
%leave that as it is, and apply the correction factor to
%something which is already wavelength dependent. See
%[Essenpreis, 1993] for the wavelength dependency of the DPF.
%
%
%% Optical density and Absorbance:
%
% Optical density is the absorbance of an optical element for a given
% wavelength l per unit distance:
%
%  $$ OD = \frac{A}{l} $$
%
% Hence:
%
%  $$ OD = c \cdot e \cdot DPF $$
%
% Please note that sometimes $OD$ is defined exactly the same as
%absorbance i.e. $OD=A$. This is similar to simply considering $l=1$.
%
%
%% Remarks
%
% This function started as a variation from my mbll.m function
%which in turn was derived from fOSA (Koh). However, because of
%the many changes plus more importantly the change in paradigm
%to OOP, it is by now a complete different code (with possibly
%only the line REALLY implementing the MBLL remaining from the
%original fOSA code).
%
%In addition, I have also look at OT-Analysis Kit (Gomez,
% 2006) and Saager kit.
%
%    +========================================+
%    | IMPORTANT                              |
%    +========================================+
%    | Some comments have been literally      |
%    | copied from BORG UCL site              |
%    |                                        |
%    | http://www.medphys.ucl.ac.uk/research/ |
%    |borg/research/NIR_topics/nirs.htm       |
%    +========================================+
%
% The coefficients file table_abscoeff are that of fOSA. This file
% is simply a data file, however it has been "implemented" as a
% method. Please refer to the method for more information.
%
%   rawData_ETG4000@table_abscoeff
%
% Currently the separation distance between the optodes
%is fixed to 30 mm.
%
% DPF correction is implemented and seem to be working properly
%but I haven't made the option available yet.
%For one of the wavelengths of the HITACHI ETG-4000 NIRS 
%(830 nm) the kDPF is 0.934.
% Unfortunately, it is not easy to estimate DPF for
%short wavelengths and in fact, the file abscoeff does
%not include the kDPF value at 695 nm (which happens to be
%one of the wavelengths at which the NIRS machine works!)
%fOSA simply considers kDPF(l=695)=1 to get around this
%problem, so do I.
%
%% Known bugs
%
% At the moment the code is assuming that light intensities
%are recorded at two wavelengths. However, there may be
%other devices which record more than 2 wavelengths. In
%that case, this code will not work properly.
%
% The Hitachi ETG-4000 OTS operates at two wavelengths:
%   695 +/- 20nm
%   830 +/- 20nm
%
%with and optical intensity of 2.0mW per wavelength (see ETG-4000
%Instruction manual, Section 12 pg. 12-1). The deviation from the
%nominal wavelength is recorded in the raw light intensity files,
%but this function simply ignores the variation and assumes those
%nominal wavelengths as the working wavelengths.
%
% Please note that the optode "effective" wavelengths at
% the different channels at which the optode is working might
% slightly differ from the "nominal" wavelengths.
% These effective wavelengths are also available at the
% Hitachi file, for each of the channels.
% However I'm not taking that into account at the moment,
% and I consider the nominal waveleghts to be the effective
% wavelengths.
%
%% Parameters
%
% obj - The rawData_ETG4000 object to be converted to a nirs_neuroimage
%
% Options - optionName, optionValue pair arguments
%   'AllowOverlappingConditions' - Permit adding conditions to the
%       timeline with an events overlapping behaviour.
%           0 - Overlapping conditions
%           1 - (Default) Non-overlapping conditions
%
%% References
%
% [Duncan, 1995] Duncan, A. et al (1995) "Optical pathlength measurements
% on adult head and the head of the newborn infant using phase
% resolved optical spectroscopy" Physics in Medicine and Biology 40:295-304
%
% [Essenpreis, 1993] Essenpreis, M. et al (1993) "Spectral dependence
%of temporal point spread functions in human tissues" APPLIED OPTICS
%32(4):418-425
%
% [Hiraoka, 1993] Hiraoka, M et al (1993) "A Monte Carlo investigation
%of optical pathlength in inhomogeneous tissue and its application
%to near-infrared spectroscopy" Physics in Medicine and Biology
%38:1859-1876
%
% [Hoshi, 2005] Hoshi, et al (2005) "Reevaluation of near infrared light
%propagation in the adult human head: implications for functional
%near infrared spectroscopy" Journal or Biomedical Optics 10(6):064032
%
% [Kohl, 1998] Kohl, M. et al (1998) "Determination of the wavelength
%dependence of the differential pathlength factor from near
%infrared pulse signals" Physics in Medicine and Biology 43:1771-1782
%
% [Okada, 2003b] Okada and Delpy (2003) "Near-infrared light
%propagation in an adult head model. II. Effect of superficial
%tissue thickness on the sensitivity of the near-infrared
%spectroscopy signal" APPLIED OPTICS 42(16):2915-2922
%
% [Sassaroli, 2004] Sassaroli and Fantini (2004) "Comment on the
% modified Beer-Lambert law for scattering media" Physics in
% Medicine and Biology  49:N255-N257
%
% 
% Copyright 2008-23
% Copyright over some comments belong to their authors.
% @author: Felipe Orihuela-Espina
% 
%
% See also rawData_ETG4000, import, neuroimage, NIRS_neuroimage
%



%% Log
%
% File created: 13-May-2008
% File last modified (before creation of this log): 23-Jan-2014
%
%
% 23-Jan-2014: New option available. Conditions can now be accepted
%   with overlapping behaviour. Default remains non overlapping behaviour.
%
% 12-Oct-2013: Bug fixed. The 3x3 mode was creating 48 channels
%   even for one probe only. Also updated the oaInfo to incorporate
%   the optodeTopoArrangement although of course this remains empty.
%
%
% 3-Dec-2023 (FOE): Comments improved.
%   + Got rid of old labels @date and @modified.
%   + Started to use get/set methods for struct like access.
%   + Updated error codes to use 'ICNNA' instead of 'ICNA'
%


opt.allowOverlappingConditions = 1; %Default. Non-overlapping conditions
while ~isempty(varargin) %Note that the object itself is not counted.
    optName = varargin{1};
    if length(varargin)<2
        error('ICNNA:rawData_ETG4000:convert:InvalidOption', ...
            ['Option ' optName ': Missing option value.']);
    end
    optValue = varargin{2};
    varargin(1:2)=[];
    
    switch lower(optName)
        case 'allowoverlappingconditions'
            %Check that the value is acceptable
            %   0 - Overlapping conditions
            %   1 - Non-overlapping conditions
            if (optValue==0 || optValue==1)
                opt.allowOverlappingConditions = optValue;
            else
                error('ICNNA:rawData_ETG4000:convert:InvalidOption', ...
                     ['Option ' optName ': Unexpected value ' num2str(optValue) '.']);
            end
            
        otherwise
            error('ICNNA:rawData_ETG4000:convert:InvalidOption', ...
                  ['Invalid option ' optName '.']);
    end
end


%fprintf('Converting intensities to Hb data ->  0%%');


%Start by catching the list of imported probe sets. This will
%be useful at several points during the conversion.
importedPSidx = [];
for pp=1:get(obj,'nProbeSets')
    if obj.probesetInfo(pp).read
        importedPSidx = [importedPSidx pp];
    end
end

if isempty(importedPSidx)
    %Can't do much more, can I? So just return the default neuroimage
    nimg=nirs_neuroimage(1);
    return
end


%Some basic initialization
nSamples  = size(obj.lightRawData,1);
nSignals  = length(obj.wLengths);
nChannels = obj.nChannels;
nWlengths = length(obj.nominalWavelengthSet);
nimg = nirs_neuroimage(1,[nSamples,nChannels,nSignals]);


%dpf=lower('ok');
dpf=lower('no');
coefficients=rawData_ETG4000.table_abscoeff;
optodeSeparation = 3; %Separation distance between the optodes in [cm]

%Check the optode types
%Assume they are all equal and simply get it from the first imported
%probes set
avgDPF = 6.26; %Average DPF accepted value for normal adult head
switch (obj.probesetInfo(importedPSidx(1)).type)
    case 'adult'
        %Do nothing. Use the default above.
    otherwise
        if strcmp(dpf,'ok')
            warning('ICNNA:rawData_ETG4000:convert:InexactDPF',...
                    ['The DPF for probe type ''' ...
                        obj.probesetInfo(pp).type ''' is not currently ' ...
                     'available. The DPF for the ''adult'' probe ' ...
                     'type (6.26) will be used instead.']);
        end
end


%Note that the channels may be spread across different probes sets,
%Thus, temporarily bring them all together in a single matrix.
%Also, take advantage of the loop for collecting the information
%for the channelLocationMap.
tmpLRD = []; %Light raw data
chProbeSets = [];
chOptodeArrays = [];
oaInfo = struct('mode',{},'type',{},...
                'chTopoArrangement',{},...
                'optodesTopoArrangement',{});
oa=1;
for pp=importedPSidx
    switch (obj.probesetInfo(pp).mode)
        case '3x3'
            probeSet_nCh = 24;
            %Two optode arrays
            %   S - Light Source           S---1---D---2---S
            %   D - Light Detector         |       |       |
            %   1,..,12 - Channel          3       4       5
            %                              |       |       |
            %                              D---6---S---7---D
            %                              |       |       |
            %                              8       9      10
            %                              |       |       |
            %                              S--11---D--12---S
            oaInfo(oa).mode = 'HITACHI_ETG4000_3x3';
            oaInfo(oa).type = obj.probesetInfo(pp).type;
            oaInfo(oa).chTopoArrangement = [3.5   0.5; ...
                1.5   0.5; ...
                4.5   1.5; ...
                2.5   1.5; ...
                0.5   1.5; ...
                3.5   2.5; ...
                1.5   2.5; ...
                4.5   3.5; ...
                2.5   3.5; ...
                0.5   3.5; ...
                3.5   4.5; ...
                1.5   4.5]; %coordinates for south right orientation;
            oa_nCh=size(oaInfo(oa).chTopoArrangement,1);
            chOptodeArrays = [chOptodeArrays; oa*ones(oa_nCh,1)];
            oa=oa+1;
            oaInfo(oa).mode = 'HITACHI_ETG4000_3x3';
            oaInfo(oa).type = obj.probesetInfo(pp).type;
            oaInfo(oa).chTopoArrangement = [3.5   0.5; ...
                1.5   0.5; ...
                4.5   1.5; ...
                2.5   1.5; ...
                0.5   1.5; ...
                3.5   2.5; ...
                1.5   2.5; ...
                4.5   3.5; ...
                2.5   3.5; ...
                0.5   3.5; ...
                3.5   4.5; ...
                1.5   4.5]; %coordinates for south right orientation;
            oa_nCh=size(oaInfo(oa).chTopoArrangement,1);
            chOptodeArrays = [chOptodeArrays; oa*ones(oa_nCh,1)];
            oa=oa+1;
            
        case '4x4'
            probeSet_nCh = 24;
            %   S - Light Source           S---1---D---2---S---3---D
            %   D - Light Detector         |       |       |       |
            %   1,..,24 - Channel          4       5       6       7
            %                              |       |       |       |
            %                              D---8---S---9---D--10---S
            %                              |       |       |       |
            %                             11      12      13      14
            %                              |       |       |       |
            %                              S--15---D--16---S--17---D
            %                              |       |       |       |
            %                             18      19      20      21
            %                              |       |       |       |
            %                              S--22---D--23---S--24---D
            oaInfo(oa).mode = 'HITACHI_ETG4000_4x4';
            oaInfo(oa).type = obj.probesetInfo(pp).type;
            oaInfo(oa).chTopoArrangement = [5.5   0.5; ...
                3.5   0.5; ...
                1.5   0.5; ...
                6.5   1.5; ...
                4.5   1.5; ...
                2.5   1.5; ...
                0.5   1.5; ...
                5.5   2.5; ...
                3.5   2.5; ...
                1.5   2.5; ...
                6.5   3.5; ...
                4.5   3.5; ...
                2.5   3.5; ...
                0.5   3.5; ...
                5.5   4.5; ...
                3.5   4.5; ...
                1.5   4.5; ...
                6.5   5.5; ...
                4.5   5.5; ...
                2.5   5.5; ...
                0.5   5.5; ...
                5.5   6.5; ...
                3.5   6.5; ...
                1.5   6.5]; %coordinates for south right orientation;
            oa_nCh=size(oaInfo(oa).chTopoArrangement,1);
            chOptodeArrays = [chOptodeArrays; oa*ones(oa_nCh,1)];
            oa=oa+1;
        case '3x5'
            probeSet_nCh = 22;
            %   S - Light Source        S---1---D---2---S---3---D---4---S
            %   D - Light Detector      |       |       |       |       |
            %   1,..,24 - Channel       5       6       7       8       9
            %                           |       |       |       |       |
            %                           D--10---S--11---D--12---S--13---D
            %                           |       |       |       |       |
            %                           14      15      16      17      18
            %                           |       |       |       |       |
            %                           S--19---D--20---S--21---D--22---S
            oaInfo(oa).mode = 'HITACHI_ETG4000_3x5';
            oaInfo(oa).type = obj.probesetInfo(pp).type;
            oaInfo(oa).chTopoArrangement = [3.5   0; ...
                2.5   0; ...
                1.5   0; ...
                0.5   0; ...
                4   0.5; ...
                3   0.5; ...
                2   0.5; ...
                1   0.5; ...
                0   0.5; ...
                3.5   1; ...
                2.5   1; ...
                1.5   1; ...
                0.5   1; ...
                4   1.5; ...
                3   1.5; ...
                2   1.5; ...
                1   1.5; ...
                0   1.5; ...
                3.5   2; ...
                2.5   2; ...
                1.5   2; ...
                0.5   2]; %coordinates for south right orientation;
            oa_nCh=size(oaInfo(oa).chTopoArrangement,1);
            chOptodeArrays = [chOptodeArrays; oa*ones(oa_nCh,1)];
            oa=oa+1;
        otherwise
            error('ICNNA:rawData_ETG4000:convert:UnexpectedProbeMode',...
                ['Unexpected probe set mode ''' ...
                obj.probesetInfo(pp).mode ''' ' ...
                'for probes set #' num2str(pp)]);
    end
    chProbeSets = [chProbeSets; pp*ones(probeSet_nCh,1)];
    tmpLRD = [tmpLRD obj.lightRawData(:,1:nWlengths*probeSet_nCh,pp)];
end

    
    
%Allocate some memory
c_oxy = zeros(nSamples,nChannels);
c_deoxy = zeros(nSamples,nChannels);

%% Convert intensities
%wwait=waitbar(0,'Converting intensities->Hb data... 0%');

for ch = 1:nChannels
    %For each channel, the light intensities have been recorded at several
    %wavelengths (e.g. two for for the case of the Hitachi ETG-4000).
    
    %waitbar(ch/nChannels,wwait,...
    %            ['Converting intensities->Hb data...',...
    %              sprintf('%2.0f',(ch/nChannels)*100),'%']);
    %fprintf('\b\b\b%02.0f%%',(ch/nChannels)*100);

    % Picking up the indices for low and high wavelength pairs
        %%Note that each channel has a number light intensities measured at
        %%different wavelengths.
        %%With this indexes, a system of equations is built for each
        %%channel.
        %%For devices which measure light at more than 2 wavelengths, this
        %%approach will not work.
    low=(ch*2)-1;
    high=(ch*2);
    
    
        
    % To check that absolute intensity does not reach below zero
    tmpLRD(:,low) =tmpLRD(:,low)+(tmpLRD(:,low)==0);
    tmpLRD(:,high)=tmpLRD(:,high)+(tmpLRD(:,high)==0);
    
    % To calculate the attenuation for both wavelengths based on indices and not rows
    attlo = -log10(tmpLRD(:,low)/tmpLRD(1,low));
    atthi = -log10(tmpLRD(:,high)/tmpLRD(1,high));
    
    od = [attlo atthi]; %Optical Density: OD = A/d
    
    % Pathlength fixed at a separation distance and DPF in mm
    % abscoeff is a file that contains the cofficient in /mM/cm
    absorb=zeros(2);
    if strcmp(dpf,'ok')
        path = optodeSeparation * avgDPF;
        % To calculate the concentation changes for 2 wavelengths (wl) using the table (abscoeff)
        for wl = 1:2
            index = find (coefficients(:,1) == obj.wLengths(wl));%1 is the column holding the wavelength
            %%%Watch out! See remarks
            kDPF = coefficients(index, 8); %8 is the column holding the DPF
            %wavelength dependent value.
            mua_HHb= coefficients(index,2); % de-oxy
            mua_HbO2= coefficients(index,3); % oxy
            absorb(wl,1) = mua_HHb * kDPF;     % de-oxy-corrected
            absorb(wl,2) = mua_HbO2 * kDPF;    % oxy-corrected
        end
        
    elseif strcmp(dpf,'no')
        
        path = 1;
        % To calculate the concentation changes for 2 wavelengths (wl) using the table (abscoeff)
        for wl = 1:2
            index = find (coefficients(:,1) == obj.wLengths(wl));
            mua_HHb= coefficients(index,2); % de-oxy
            mua_HbO2= coefficients(index,3); % oxy
            absorb(wl,1) = mua_HHb;     % de-oxy
            absorb(wl,2) = mua_HbO2;    % oxy
        end
    end
    
    od=od'; %fOSA uses od with size <nWLengths,nSamples>, 
            %so I need to transpose
    for num = 1:nSamples
        %%%LAMBERT LAW: A=log10 [Io/I]=e.c.d.DPF   =>   c=A/(e.d.DPF)= OD/(e.DPF)
        %%%where DPF depends on the path defined by the optode separation
        %%%and the avgDPF
        %conc(num,:) = 1000* inv(absorb) * (od(num,:)/path); % uM /*To convert from mM->uM*/
                %Optical density defined above
        conc(:,num) = 1000* inv(absorb) * (od(:,num)/path); % uM /*To convert from mM->uM*/
            %The above is possibly the only line remaining from fOSA
    end % for each sample
    c_deoxy(:,ch) = conc(1,:)';
    c_oxy(:,ch) = conc(2,:)';
    
end     % for each channel pair

c_hb=zeros(nSamples,nChannels,2);
c_hb(:,:,nirs_neuroimage.OXY)=c_oxy;
c_hb(:,:,nirs_neuroimage.DEOXY)=c_deoxy;
nimg.data = c_hb;

%fprintf('\n');

%Now update the channel location map information
%nimg=set(nimg,'ProbeMode',obj.probeMode); %DEPRECATED CODE
%waitbar(1,wwait,'Updating channel location map...');
%fprintf('Updating channel location map...\n');
clm = nimg.chLocationMap;
clm = setChannelProbeSets(clm,1:nChannels,chProbeSets);
clm = setChannelOptodeArrays(clm,1:nChannels,chOptodeArrays);
clm = setOptodeArraysInfo(clm,1:length(oaInfo),oaInfo);
    %At this point, neither, the channel 3D locations, the stereotactic
    %positions nor the surface positions are known.
    %Neither is known anything about the optodes.
nimg.chLocationMap = clm;


%% Set signal tags
nimg=setSignalTag(nimg,nirs_neuroimage.OXY,'HbO_2');
nimg=setSignalTag(nimg,nirs_neuroimage.DEOXY,'HHb');

%% Extract the timeline
%waitbar(1,wwait,'Extracting timeline from marks...');
%fprintf('Extracting timeline from marks...\n');

theTimeline=timeline(nSamples);
%It should be expected that all marks across all imported probe
%sets should be equal. Check that (issuing a warning if that is
%not the case), and work only with the marks of the first imported
%probe set
tmpMarks = obj.marks(:,importedPSidx); %Isolate the marks of interest
%Check that marks across imported probe sets are equal
for pp=importedPSidx(2:end)
    if any(tmpMarks(:,importedPSidx(1))~=tmpMarks(:,importedPSidx(pp)))
        warning('ICNNA:rawData_ETG4000:convert:UnequalMarks',...
                ['Different stimulus marks found across probe sets. ' ...
                'The conversion will proceed using those marks only ' ...
                'of the first probe set, ignoring the rest.']);
        break;
    end
end

%Proceed with the marks of the first probe set
tmpMarks=tmpMarks(:,1); %Note that tmpMarks already has only those
                        %of imported probe sets
conds=sort(unique(tmpMarks))';
conds(1)=[]; %Remove the 0;
tags='ABCDEFGHIJ'; %The ETG-4000 only admits until condition J
for cc=conds
    idx=find(tmpMarks==cc);
    onsets=idx(1:2:end);
    endings=idx(2:2:end);
    if (length(onsets)==length(endings))
        %Do nothing
        %Each onset has its ending defined
    elseif (length(onsets)-1==length(endings))
        %the last onset is unmatched, i.e. the trial should
        %finish by the end of the recording
        warning('ICNNA:rawData_ETG4000:convert:MissedTrialEnding',...
                ['Missed end of trial for condition ' tags(cc) '. ' ...
                'Setting end of trial to the end of the recording.']);
        endings=[endings; nSamples];
    else
        warning('ICNNA:rawData_ETG4000:convert:CorruptCondition',...
                ['Corrupt block/trial definitions for condition ' ...
                tags(cc) '. Ignoring block/trial definitions.']);
        onsets=zeros(0,1);
        endings=zeros(0,1);
    end
    durations=endings-onsets;
    stim=[onsets durations];
    theTimeline=addCondition(theTimeline,tags(cc),stim,...
                                opt.allowOverlappingConditions);
end

%... and now the same with the timestamps
tmpTimestamps = obj.timestamps;
%It should be expected that all timestamps across all imported probe
%sets should be equal. Check that (issuing a warning if that is
%not the case), and work only with the timestamps of the first imported
%probe set
tmpTimestamps = tmpTimestamps(:,importedPSidx);
        %Isolate the timestamps of interest
%Check that timestamps across imported probe sets are equal
for pp=importedPSidx(2:end)
    if any(tmpTimestamps(:,importedPSidx(1))~=tmpTimestamps(:,importedPSidx(pp)))
        warning('ICNNA:rawData_ETG4000:convert:UnequalTimestamps',...
                ['Different timestamps found across probe sets. ' ...
                'The conversion will proceed using those timestamps only ' ...
                'of the first probe set, ignoring the rest.']);
        break;
    end
end
tmpTimestamps=tmpTimestamps(:,1);  %Note that tmpTimestamps already
                        %has only those of imported probe sets
theTimeline.timestamps = tmpTimestamps;

theTimeline.startTime = obj.date;
theTimeline.nominalSamplingRate = obj.samplingRate;

nimg.timeline = theTimeline;




%close (wwait);



end