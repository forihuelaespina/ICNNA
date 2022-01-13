function [M] = mbll(T,options)
%Reconstruction using the Modified Beer-Lambert law (MBLL).
%
% M=mbll(T) - Reconstructs 3D tensor of raw light intensities to a 3D 
%   neuroimage tensor, using the modified Beer-Lambert law (MBLL).
%
% M=mbll(T,options) - Reconstructs 3D tensor of raw light intensities 
%   to a 3D  neuroimage tensor, using the modified Beer-Lambert law
%   (MBLL) with the chosen options.
%
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
% Reconstruction is made channel-wise. Currently, overdetermines systems
% are not supported (e.g. 8 wavelengths and 3 parameters, or broadband).
% Currently only topological reconstruction is permited, i.e. interoptode
% distance is unique (although configurable).
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
%which in turn was derived from fOSA (Koh), then became a method
%of class rawData_ETG-4000 (convert) and later further isolated
%to serve other classes. Because of
%the many changes plus more importantly the change in paradigm
%to OOP, it is by now a complete different code (with possibly
%only the line REALLY implementing the MBLL remaining from the
%original fOSA code, and even this has been "trasposed").
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
% is simply a data file. Please refer to the function for more information.
%
%   util/table_abscoeff
%
%
%
% Currently the separation distance between the optodes
%is fixed to 30 mm.
%
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
% T - 3D tensor of raw light intensities. The first dimension indexes time
%   samples, the second dimensions indexes channels and the third
%   dimension indexes nominal acquisition wavelengths (or optical filters).
%   Nominal wavelengths can be configured using the 'wavelengths'
%   option.
%
% M - 3D neuroimage tensor. The first dimension indexes time
%   samples, the second dimensions indexes channels and the third
%   dimension indexes reconstructed chromophores (1 - Oxy and 2- Deoxy).
%
% Options - optionName, optionValue pair arguments
%   'dpf' - Differential pathlength factor (DPF) used for reconstruction.
%       By default is set to 6.26 (Average DPF accepted value for normal
%       adult head). Set to [] if you want to reconstruct without DPF.
%   'iod' - Interoptode distance in [cm]. By default is set to 3cm.
%   'wavelengths' - A row vector of nominal wavelengths set in [nm]. By 
%   default is set to [695 830] nm (corresponding to those of the
%   HITACHI ETG-4000 for historical reasons of ICNNA). The number of
%   wavelengths must match size(T,3) and size(M,3).
%
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
% Copyright 2008-18
% Copyright over some comments belong to their authors.
% @date: 13-May-2008
% @author: Felipe Orihuela-Espina
% @modified: 25-Abr-2018
% 
%
% See also import, neuroimage, NIRS_neuroimage, rawData_ETG4000,
%   rawData_NIRScout,
%





%% Log
%
% 12-Apr-2018: FOE. Extraction from rawData_ETG-4000.convert method
%   and improved.
%
% 25-Apr-2018: FOE. Bug fix. Oxy and deoxy were returned swapped.
%



opt.dpf = 6.26; %Average DPF accepted value for normal adult head.
                %Set to [] to reconstruct without dpf correction.
opt.iod = 3; %Interoptode distance in [cm]
opt.wavelengths = [695 830]; %In [nm]
if (exist('options','var') && isstruct(options))
    if isfield(options,'dpf')
        opt.dpf = options.dpf;
    end
    if isfield(options,'iod')
        opt.iod = options.iod;
    end
    if isfield(options,'wavelengths')
        opt.wavelengths = options.wavelengths;
    end
end





%Some basic initialization
nWlengths=length(opt.wavelengths);
assert(nWlengths == size(T,3), ...
    'Unexpected number of nominal wavelengths.');


M=nan(size(T));
nSamples=size(M,1);
nChannels = size(M,2);
nSignals=size(M,3); %Number of reconstructed parameters in priciple
            %should match the number of wavelengths (this won't
            %be the case for overdetermined systems.

coefficients=table_abscoeff();
mua_HHb= coefficients(:,2); % de-oxy
mua_HbO2= coefficients(:,3); % oxy
kDPF = coefficients(:, 8); %8 is the column holding the DPF
           


%% Prepare the absorption coefficients
% Pathlength fixed at a separation distance and DPF in mm
% abscoeff is a file that contains the cofficient in /mM/cm
absorb=zeros(2);
if ~isempty(opt.dpf)
    path = opt.iod * opt.dpf;
    % To calculate the concentation changes for 2 wavelengths (wl) using the table (abscoeff)
    for wl = 1:nWlengths
        index = find (coefficients(:,1) == opt.wavelengths(wl));%1 is the column holding the wavelength
        %%%Watch out! See remarks
        %wavelength dependent value.
        absorb(wl,1) = mua_HHb(index) * kDPF(index);     % de-oxy-corrected
        absorb(wl,2) = mua_HbO2(index) * kDPF(index);    % oxy-corrected
    end
    
else %Reconstruct without DPF
    path = 1;
    % To calculate the concentation changes for 2 wavelengths (wl) using the table (abscoeff)
    for wl = 1:nWlengths
        index = find (coefficients(:,1) == opt.wavelengths(wl));
        absorb(wl,1) = mua_HHb(index);     % de-oxy
        absorb(wl,2) = mua_HbO2(index);    % oxy
    end
    
    
end

%% Convert intensities
for ch = 1:nChannels
    Tch = squeeze(T(:,ch,:)); %Extract channel
        
    % Check that absolute intensity does not reach below zero
	Tch=Tch+(Tch==0);
    
    % Calculate attenuations; A=log10 [I/I0]
    A=nan(size(Tch));
    for wl=1:nWlengths
        %A(:,wl) = -log10(Tch(:,wl)/Tch(1,wl)); %Old fOSA used only the first
        k=min(50,size(Tch,1)); %fOSA v2.2 uses the mean of first 50 samples (but I need to ensure there are at least 50 samples
        A(:,wl) = -log10(Tch(:,wl)/mean(Tch(1:k,wl))); 
    end
    od=A/path; %Optical Density: OD = A/d

    for num = 1:nSamples
        %%%LAMBERT LAW: A=log10 [Io/I]=e.c.d.DPF   =>   c=A/(e.d.DPF)= OD/(e.DPF)
        %%%where DPF depends on the path defined by the optode separation
        %%%and the avgDPF
        conc(num,:) = od(num,:)* inv(absorb)'; 
    end % for each sample
    
    
    %Watch out! See absorb matrix! Oxy is in conc(:,2) and deoxy in conc(:,1)
    M(:,ch,1)=conc(:,2);
    M(:,ch,2)=conc(:,1);
    
end     % for each channel pair

M = 1000 * M; % uM /*To convert from mM->uM*/


end






