function [C,outSD] = invertMBLL(A,montage,inSD,options)
% Reconstruct changes in concentrations from optical density (and/or absorbance).
%
% [Cnimg]    = icnna.op.invertMBLL(Animg) 
%
% [C, outSD] = icnna.op.invertMBLL(A, montage, inSD, options)
% [C, outSD] = icnna.op.invertMBLL(OD,montage, inSD, options)
%
%
%% The Beer-Lambert law
%
%The attenuation of light intensity in a non-scattering medium
%is described by the Beer-Lambert Law. This law states that for
%an absorbing compound dissolved in a non-absorbing medium, the
%attenuation (as measured by absorbance $A$ or optical density $OD$)
%is proportional to the concentrations of the compounds in the
%solution ($c_i$) and the optical pathlength ($d$):
%
%    $ OD  = ln \frac{I_0}{I_d} 
%         = \mu_a \cdot d  
%         = d \cdot (\sum_i e_i \cdot c_i) $
%
%    $ A  = 2.303 \cdot log_10 \frac{I_0}{I_d} 
%         = \mu_a \cdot d  
%         = d \cdot (\sum_i e_i \cdot c_i) $
%
%where $A$ is the attenuation measured either as optical density
%or as absorbance -see function icnna.op.intensity2OD-,
%$I_0$ is the light intensity incident on the medium, $I_d$ is the
%light intensity transmitted through the medium, $\mu_a$ is the
%macroscopic absorption coefficient, $e_i$ is the
%specific extinction coefficient of the $i$-th absorbing compound
%measured in micromolar per cm, $c_i$ is the concentration of the
%$i$-th absorbing compound in the solution measured in micromolar,
%and $d$ is the distance travelled by the photons between the
%points where the light enters and leaves the medium. 
%
%    $ OD  = ln \frac{I_0}{I}
%          = \mu_a \cdot d  
%          = d \cdot (\sum_i e_i \cdot c_i) $
%
%The $\mu_a$ is the (macroscopic) absorption coefficient of the
% medium, and under the assumption of linearity;
%
%   $ \mu_a = (\sum_i e_i \cdot c_i) $
%
%   $A = \mu_a \cdot d \iff \frac{A}{\mu_a} = d$
%   [Okada2003b, pg. 2916]
%   [Sassaroli2004, pg. N256]
%
%% The modified Beer-Lambert law
%
%When a highly scattering medium is considered, the
%Beer-Lambert relationship must be modified to include
%   (i) an additive term, $G$, due to scattering losses and
%   (ii) a multiplier, to account for the increased optical
%   pathlength due to scattering. The true optical distance
%   is known as the differential pathlength (DP) and the
%   scaling factor as the differential pathlength factor (DPF):
%
%    $$ DP  = DPF \cdot d $$
%
%where $d$ is the geometrical distance. 
%
%The modified Beer-Lambert law which incorporates these two
%additions is then expressed as:
%
%   $$ OD  = d \cdot DPF \cdot \mu_a + G 
%          = d \cdot DPF \cdot (\sum_i e_i \cdot c) + G $$
%
% Since $G$ is unknown, but can be considered constant during
%temporally close measurements, taking differences in the above
%equation:
%
%   $$ t = 2: OD_2  = d \cdot DPF \cdot \mu_{a,2} + G $$  -
%   $$ t = 1: OD_1  = d \cdot DPF \cdot \mu_{a,1} + G $$  
%   ---------------------------------------------------------
%   $$ (OD_2-OD_1)  = d \cdot DPF \cdot (\mu_{a,2}-\mu_{a,1}) $$
%
%  or using the differential notation:
%
%   $$ \Delta OD  = d \cdot DPF \cdot \Delta \mu_{a} $$
%
% At this point, we have lose the capacity to recover absolute
%concentrations, and while we have get rid of unknown $G$, in the
%presence of several chromophore compounds, we shall have as
%many unknowns as chromophores are considered i.e. $i$.
%
%Replicating this equation at $n>=i$ different measured wavelengths
%results in a system of equation in Eq. 1.
%
%   $$ \lambda = 1: \Delta OD(\lambda_1)  = d \cdot DPF(\lambda_1) \cdot (\sum_i e_i(\lambda_1) \cdot \Delta c_i ) $$
%   $$ \lambda = 2: \Delta OD(\lambda_2)  = d \cdot DPF(\lambda_2) \cdot (\sum_i e_i(\lambda_2) \cdot \Delta c_i )  $$
%   ...
%   $$ \lambda = n: \Delta OD(\lambda_n)  = d \cdot DPF(\lambda_3) \cdot (\sum_i e_i(\lambda_n) \cdot \Delta c_i )  $$
%
%
%% DPF value and Wavelength dependency of the DPF
%
%
% The $DP$ can be approximated by the mean distance $L$ 
% [Hiraoka, 1993, pg 1860].
%
% $L$ is the path in the DPF sense or mean path length and
%is calculated as the product of the separation distance
%of probes (e.g. $d=3cm$) (i.e. the distance between the optodes,
%or similarly the distance from the light entering point
%to the tissue to the exiting point) multiplied by
%some accepted DPF e.g. in normal adult head 6.26 at 807m (Duncan,1995).
%
% $$ DPF=\frac{L}{d} \iff  L=DPF \cdot d $$
%   [Sassaroli, 2004]
%   [Hiraoka, 1993]
%
%$L$ is an approximation to the real DP (differential pathlength) 
%[Hiraoka, 1993, pg 1860]. This approximation has been criticised. 
%According to [Okada2003b, pg. 2921] it is innappropiate to use the 
%mean path length L as an alternative to the effective path length 
%$DPF\cdot d$ in the activation region.
%
% Further, the DPF is adimensional but depends on the wavelength. See
%[Essenpreis, 1993] for the wavelength dependency of the DPF.
% Using the wrong $DPF(\lambda)$ has the same effect as calculating
%with the wrong chromophore extinction spectra [Kohl,1998, pg. 1772]
%However, for optode distances larger than 2.5cm, the DPF
%is almost wavelength independent [[van der Zee, 1990]
%in Hiraoka, 1993], [[van der Zee, 1990] in Duncan, 1995],
%which makes the above approximation by $L$ reasonable for CW-fNIRS.
%
%Hence, the DPF is usually summarised as a simple value.
%However, it has been argued that comparing MBLL based NIRS 
%signal amplitudes across different measurements is not valid
%unless the partial path length (PPL) is determined [Hoshi, 2005]
%  
%In this function, by default a value 6.26 at 807m
%[Duncan, 1995] will be used, but the user can provide
%a different one. For instance, for newborn babies an accepted
%value is $DPF=4.99$ at 807m [Duncan, 1995], for males it might
%be more correct to use 6.09 or for females 6.42.
%[Essenpreis, 1993, pg 421] gets an average $DPF=6.32\pm 0.46$
%at 800 nm for adults.
%
%As said, the DPF is not really a constant value, but rather
%it depends on the wavelength lambda. In the original fOSA code
%this wavelength dependency was achieved by fixing
%the DPF value to a standard value (e.g. 6.26) and then
%using a wavelength dependent factor, the so called kDPF.
%
% $kDPF(\lambda)$ is the correction for the differential pathlength 
%factor, a wavelength dependent factor to correct the accepted
%general $DPF$ value (which comes as wavelength independent).
%
%In this sense, you can think of kDPF as:
%
%  $$ DPF(\lambda)=kDPF(\lambda) \cdot DPF_{accepted} $$
%
%fOSA 1 read the $kDPF(\lambda)$ from a file called abscoeff.
%and originally copied to ICNNA as well. In fOSA 2.1 this was replaced
%by a function called table_coeff.
%
%To be precise, kDPF does multiply the extinction coefficient
%rather than the DPF in fOSA code, i.e. rather than adapting
%DPF_accepted to a wavelength dependent version, fOSA actually
%leave that as it is, and apply the correction factor to
%something which is already wavelength dependent. 
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
%
%  
%% Input parameters
%
% OD | A - double[nSamples,nChannels,nSignals]
%   Attenuation. 3D tensor of absorbances (A) or optical density (OD).
%    * By default OD is assumed. If A is provided, then set option
%   .input to 'a'.
%
% montage - icnna.data.core.nirsMontage
%   The montage. Channel configurations including pairings
%   and interoptode distances will be retrived from here.
%
% inSD - icnna.data.core.signalDescriptor[nSignals].
%   List of signal descriptors for the input attenuations.
%   Nominal and actual acquisition wavelengths will be retrieved
%   from here.
%
% options - Optional. struct.
%   A struct of options with the following fields.
%    .input - char[]. Enum. Default is 'od'.
%       Indicates whether input parameter attenuation is expressed
%       as OD or A. Options are:
%       * 'od' - Optical density (uses natural logarithm)
%       * 'a'  - Absorbance (uses base 10 logarithm)
%
%       NOTE: Old versions of ICNNA using function miscellaneous/mbll
%       default to absorbance ('a').
%   .coeffs - icnna.data.core.opticalCoefficient[]. Default is empty
%      Optical coefficients to be used during the reconstruction.
%      If not provided, ICNNA will make an educated guess and shall
%      try to use the optical coefficient included by default
%      with ICNNA.
%
%
%% Output
%
% Cnimg - icnna.data.core.cwNirsNeuroimage
%   A reconstructed CW-fNIRS neuroimage
%
% C - double[nSamples,nChannels,nSignals]
%   Changes in concentrations for the different chromophores.
%   Each signal is a different chromophore.
%
% outSD - icnna.data.core.signalDescriptor[nSignals].
%   List of signal descriptors for the output changes in chromophore
%   concentrations. It dictates the order in which the third dimension
%   of output paramer C is arranged
%
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also icnna.op.intensity2OD, icnna.op.snirf.invertMBLL
%


%% Log
%
% -- ICNNA v1.4.0
%
% 11-Feb-2026: FOE 
%   + File created. UNFINISHED
%
%
%

%% Deal with options


error('NOT YET WORKING. Please use function mbll in the meantime.')


