function [dC] = deltaOD2deltaConcentrations(dOD,options)
%Reconstruct (delta) concentrations from (delta) optical densities using the MBLL.
%
% [dC] = deltaOD2deltaConcentrations(dOD)
% [dC] = deltaOD2deltaConcentrations(dOD,options)
% 
% 
% Reconstructs 3D tensor of (delta) optical densities (or absorbances)
% to a 3D  neuroimage tensor of chromophore concentrations, using
% the modified Beer-Lambert law (MBLL).
%
%
%% Absorption and concentration:
%
% The number of molecules of a certain pured substance (called solute)
% within a given volume of a mixture substance (called solution) is
% called the *concentration* $c$:
%
%   $c [molar] = \frac{moles of solute}{liters of solution} [m^{-3}]$ (Eq.1)
%
% Absorption in matter happens as the energy is transferred from
%the traversing radiation to the matter. How much does some matter
%absorbs depends (mostly) on the presence of chromophores, the part
%of molecules that interact with the light. The rule of thumb is simple;
%the more molecules with these chromophores there are within a given
%volume, the more the matter absorbs light.
%
% In this sense, physicists characterise how much does some matter
%absorbs using the so called *absorption coefficient* $\mu_a$ which
%under some assumptions, valid for biological tissues, can be
%approximated as a linear summation of the absorption due to each
%choromophore;
%
%       $ \mu_a^{tissue} \propto \sum_j \mu_{a,j}^{chromophore} $ (Eq.2)
%
% Not all choromophores (and hence molecules containing them) absorb
% equally. Even though a chromophore may be only a certain part of
% a molecule, in practice, it is common to use these terms
% interchangeably in the context of radiation transport.
% 
% The specific spectral signature of the absorption by a
% single chromophore is referred to as the *specific absorption
% coefficient* of the chromophore, $e(\lambda)$. So the contribution
% of a given chromophore (solute) to the absorption in the mixture
% (solution), is simply proportional to the number of chromophores
% present:
%
%       $ \mu_{a}^{chromophore} = e(\lambda) * c $              (Eq.3)
%
% Substituting, Eq. 3 in Eq. 2;
%
%       $ \mu_a^{tissue} \propto \sum_j \mu_{a,j}^{chromophore} 
%                       = \sum_j e_j(\lambda) * c_j$            (Eq.4)
%
%
%
%% The Beer-Lambert law:
%
%The absorption of light intensity in a non-scattering medium
%is described by the Beer-Lambert Law. This law states that for
%an absorbing compound dissolved in a non-absorbing medium, the
%attenuation, expressed whether as absorbance ($A$) or the optical
%density ($OD$), is proportional to the concentration of the
%compound in the solution ($c$) and the optical pathlength ($d$):
%
%    $ OD = ln \frac{I_0}{I}  = e \cdot c \cdot d $$
%    $ A  = 2.303 log_10 \frac{I_0}{I}  = e \cdot c \cdot d $$
%
%where the attenuation is measured either as optical densities $OD$
%(using natural logarithms) or as absorbance $A$ (using base 10
%logarithm), $I_0$ is the light intensity incident on the medium,
%$I$ is the light intensity transmitted through the medium, $e$ is the
%specific extinction coefficient of the absorbing compound
%measured in micromolar per cm, $c$ is the concentration of the
%absorbing compound in the solution measured in micromolar,
%and d is the distance travelled by the photons between the
%points where the light enters and leaves the medium. 
%
%    $ A  = 2.303 log_10 \frac{I_0}{I}  = e \cdot c \cdot d $$
%
%The product e.c is the (macroscopic) absorption coefficient of
% the medium $\mu_a$ as explained above.
%
%       $$A = \mu_a \cdot d \iff \frac{A}{\mu_a} = d$$
%   [Okada2003b, pg. 2916]
%   [Sassaroli2004, pg. N256]
%
%% The modified Beer-Lambert law (MBLL)
%
% When a highly scattering medium is considered, the
%Beer-Lambert relationship must be modified to include
%   (i) an additive term, G, due to scattering losses and
%   (ii) a multiplier, DPF, to account for the increased optical
%   pathlength due to scattering.
%
% The modified Beer-Lambert law which incorporates these two
%additions is then expressed as:
%
%   $$ OD = ln \frac{I_0}{I}  = d \cdot DPF \cdot \mu_a + G $$
%
% Since $G$ is unknown, but can be considered constant during
%measurement, taking differences in the above equation against
%a fixed reference I_ref:
%
%  $$ (OD(\tau)-OD(ref))  = d \cdot DPF \cdot [\sum_j e_j \cdot (c_(\tau)-c_(ref))] $$
%  $$ D(OD)  = d \cdot DPF \cdot [\sum_j e_j \cdot D(c_j)] $$  (Eq. 5)
%
% where D() represents variations at a certain time $t=\tau$ with
% respect to the fixed refered $t=ref$.
%
%% Reconstruction of (changes in) chromophore concentrations from (changes in) optical density
%
% From the modified Beer-Lambert law (MBLL), the changes
% in \mu_a are proportional to the changes in optical densities
% scaled byt the optical path:
%
%                         D(OD(\lambda))
%   D(\mu_a(\lambda)) = -----------------
%                         DPF(\lambda)*d
%
% where D() represents variations, DPF is the differential pathlength
% factor, and d is the inter-optode separation. 
%
%Replicating Equation 5 at each different measured wavelength
%results in the system of equation in Eq. 6.
% The reconstruction of changes in chromophore concentrations
%from changes in optical densities using the MBLL conversion
%corresponds to solving the equation system:
%
%   / D\mu_a(\lamda_1) \   / e_1(\lamda_1)    e_j(\lamda_1) \/ D(c_1) \
%   |       ...        | = |    ...       ...         ...   ||  ...   |  (Eq. 6)
%   \ D\mu_a(\lamda_i) /   \ e_1(\lamda_i)    e_j(\lamda_i) /\ D(c_1) /
%
%   where D() represents variations, \mu_a(\lamda_i) is the macroscopic
% absorption coefficient of the tissue in [mm^-1] measured at wavelength
% $\lambda_i [nm]$, and e_j(\lamda_i) represents the specific absorption
% coeffients for the j-th choromophore at wavelength \lamda_i.
% 
% Our chromophores of interest are mainly oxy- and deoxy- haemoglobin
% but in principle it is possible to reconstruct other chromophores
% if more wavelengths were available.
%
%
%% DPF value and Wavelength dependency of the DPF
%
% The true optical distance walked by light in the matter
% is known as the differential pathlength (DP) and the
% scaling factor as the differential pathlength factor (DPF):
%
%    $$ DP  = DPF \cdot d $$
%
%where $d$ is the geometrical distance. The $DP$ can be approximated
%by the mean distance $L$ [Hiraoka, 1993, pg 1860].
% The DPF is adimensional but depends on the wavelength...
%
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
%% Accounting for water, lipids and other background contributions.
%
% Eq. 6 above show the direct reconstruction assuming that the
%whole tissue macroscopic \mu_a follows Eq. 4. However, in practice
%if we are only interested in recovering the concentrations of
%a subset of the chromophores the approximation in Eq. 4 may not
%suffice. We want to express the tissue macroscopic \mu_a as a
%combination of both, some contributions to be recovered and some
%additional assumed contributions, e.g. perhaps from water and lipids.
%
% [Correia, 2010] in their (Eq. 10) proposes the following model:
%
% $\mu_{a,\text{brain}}(\lambda) = ...
%         \varepsilon_{\text{HbO}_2}[\text{HbT}]\,\text{SO}_2 ...
%       + \varepsilon_{\text{HHb}}[\text{HbT}](1 - \text{SO}_2) ...
%       + \mu_{a,\text{H}_2\text{O}}\,W 
%       + \mu_{a,\text{Lipid}}\,L 
%       + \sum_{x \in \{\text{aa3}, b, c\}} \Bigl( \varepsilon_{\text{oxCyt }x}[\text{oxCyt }x]\,\text{Ox}
%       + \varepsilon_{\text{rCyt }x}[\text{rCyt }x](1 - \text{Ox}) \Bigr)
%       + B$                                    (Eq. 7)
%
% With L, W, and B some assumed contributions of lipids, water
% and the rest of the background.
%
% If we are not interested in cytochrome, we can slightly simplify
% this model here adding all the contribution from cytochrome to the
% background, as:
%
% $\mu_{a,\text{brain}}(\lambda) = ...
%         \varepsilon_{\text{HbO}_2}[\text{HbT}]\,\text{SO}_2 ...
%       + \varepsilon_{\text{HHb}}[\text{HbT}](1 - \text{SO}_2) ...
%       + \mu_{a,\text{H}_2\text{O}}\,W 
%       + \mu_{a,\text{Lipid}}\,L 
%       + B$                                    (Eq. 8)
%
% The next step is how to incoporate this into the reconstruction
% in order to still land on a system of equations alike Eq. 6 for
% reconstruction of our chromophores of interest.
%
% In principle, we can model D(OD) as the sum of 2 terms:
%
%   $ D(OD)_{measured} = D(OD)_{fixed contribution} + D(OD)_{chromophore contribution} $
% 
%   where;
%   * $D(OD)_{fixed contribution}$ accounts for all fixed assumed
% contributions; e.g. lipids, water and background (perhaps including
% the changes due to cytochrome distinct redox states), and
%   * $D(OD)_{chromophore contribution}$ accounts for the part of
% the optical density that it is of our interest.
%
% We can compute:
%
%   $D(OD)_{fixed contribution} = e_H2O*[H2O] + e_Lip*[Lip] + B$
%
% and then substract this contribution from the measured OD;
%
%   $D(OD)_{chromophore contribution} = ...
%           D(OD)_{measured} - D(OD)_{fixed contribution} $
%
% From, here we proceed as usual with Eq. 6.
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
%absorbance i.e. $OD=2.303*A$. This is similar to simply considering $l=1$.
%
%
% For a better explanation see function icnna.op.intensity2OD
%
%
%% Remarks
%
% Reconstruction is made channel-wise. Currently, overdetermines systems
% are not supported (e.g. 8 wavelengths and 3 parameters, or broadband).
% Currently only topological reconstruction is permited, i.e. interoptode
% distance is unique (although configurable).
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
% The coefficients are inherited from those of fOSA, but since v1.4.0
% (12-Feb-2026) these were refactored from a single function
% table_abscoeffs to a collection .json files and the use of ICNNA's
% new @iccna.data.core.opticalCoefficient objects.
%
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
%% Known bugs or limitations
%
% 1) Limited to 2 wavelengths: At the moment the code is assuming that light intensities
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
% 2) Nominal vs Actual wavelengths: Please note that the
% optode "effective" wavelengths at
% the different channels at which the optode is working might
% slightly differ from the "nominal" wavelengths.
% These effective wavelengths are also available at the
% Hitachi file, for each of the channels.
% However I'm not taking that into account at the moment,
% and I consider the nominal waveleghts to be the effective
% wavelengths.
%
%
% 3) Use of constants: The use of the nirs_neuroimage constants
% .OXY and .DEOXY needs changing to use the new
% @icnna.data.core.signalDescriptors instead.
%
% 4) Currently the units are assumed rather then checked.
%
%
%% References
%
% [Correia, 2010] Correia, T., Gibson, A., Hebden, J. (2010) "Identification
% of the optimal wavelengths for optical topography: a photon
% measurement density function analysis". Journal of biomedical
% optics, 15(5), 056002-056002
%
% [Duncan, 1995] Duncan, A. et al (1995) "Optical pathlength measurements
% on adult head and the head of the newborn infant using phase
% resolved optical spectroscopy" Physics in Medicine and Biology 40:295-304
%
% [Essenpreis, 1993] Essenpreis, M. et al (1993) "Spectral dependence
%of temporal point spread functions in human tissues" APPLIED OPTICS
%32(4):418-425
%
% [Herrera-Vega, 2018] Herrera-Vega, J (2018) "Image Reconstruction
%in Functional Optical Neuroimaging: The modelling and separation of
%the scalp blood flow", Instituto Nacional de Astrofisica, Optica y
%Electronica, PhD Thesis.
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
%% Input Parameters
%
% dOD - double[nSamples,nChannels,nWavelengths]
%   3D tensor of optical densities (see function icnna.op.intensity2deltaOD).
%   The first dimension indexes time samples, 
%   the second dimensions indexes channels and the third
%   dimension indexes nominal acquisition wavelengths (or optical filters).
%   Nominal wavelengths can be configured using the .wavelengths
%   option.
%
%   NOTE: In principle, you can also feed a matrix of absorbances $dA$,
%       but this function does NOT correct for the scaling factor
%       $OD = 2.303 A$, hence introducing a further scaling error
%       although this may be irrelevant since we are not recovering
%       absolute values anyways.
%
% Options - optionName, optionValue pair arguments
%   .bgMua - double. Default is 0.12 [cm^{−1}]
%        Background absorption coefficient.
%        Default value from [Correia, 2010]. Although this value was
%        originally considered in the context of recovering the
%        cytochrome-c-oxidase it is used here as is.
%        Watch out! The original value is reported in [mm^{−1}],
%        whereas here is used in [cm^{−1}].
%        Set to 0 if you do not want to correct for it.
%
%   .dpf - int. 
%       Differential pathlength factor (DPF) used for reconstruction.
%       By default is set to 6.26 (Average DPF accepted value for normal
%       adult head). This value will then be multiplied by the
%       kDPF(\lambda).
%       Set it to [] if you want to reconstruct without DPF
%       correction.
%
%   .invert - char[]. Enum. Default is 'moorepenrose'
%       v1.4.0 or above
%       Type of matrix inversion. Options are:
%           * 'direct' - Uses direct inversion. Use this option
%                       for legacy behaviour. It does not use
%                       regularization of any kind.
%           * 'moorepenrose' - Uses Moore-Penrose pseudo inverse.
%
%       NOTE: The use of the pseudo-inverse is the default behaviour
%       since v1.4.0.
%       Use option 'direct' for legacy behaviour.
%       
%   .iod - int (scalar or vector). By default is set to 30mm.
%       Interoptode distance in [mm]. If scalar, the same IOD
%       will be used for all channels. If vector, there will be
%       one IOD per channel. It can either be a column or row
%       vector.
%       If units are likely not in [mm], ICNNA will try to
%       autoscale and yield a warning.
%
%       +===========================================+
%       | Watch out! @channelLocationMap does not   |
%       | store the spatial units. When extracting  |
%       | IODs from a @channelLocationMap you may   |
%       | need to adjust the units.                 |
%       +===========================================+
%
%   .lipidFraction - double. Default is 0.116 (i.e. 11.6%)
%        Fraction of lipid content.
%        Default value from [Herrera-Vega, 2018, pg 60]
%        Set to 0 if you do not want to correct for it.
%
%   .regularization - char[]. Enum. Default is 'tikhonov'
%       v1.4.0 or above
%       Only used if option .inverse is NOT 'direct'.
%       Type of matrix inversion. Options are:
%           * 'none' - Do not use regularization.
%           * 'ridge' - Use Ridge regularization.
%               Ridge regularization is the special case of Tikhonov 
%               regularization where Tikhonov \Gamma matrix is
%               the identity matrix, i.e, \Gamma = I.
%               Ridge corresponds to the simplest Tikhonov's penalty:
%               \norm{Gamma \cdot x}_2^2 = \norm{x}_2^2
%           * 'tikhonov' - Use full Tikhonov's regularization (i.e.
%               permits controlling \Gamma).
%
%       NOTE: The use of the Tikhonov's regularization is the
%       default behaviour since v1.4.0.
%       Use option 'none' for legacy behaviour.
%
%   .regularizationParams - Type depends on option .regularization
%       v1.4.0 or above
%       Regularization parameters.
%       * .regularization == 'none' => Not used.
%       * .regularization == 'ridge'
%           .regularizationParams - double. Default is 0.01.
%               Value of Ridge's lambda or L.
%       * .regularization == 'tikhonov'
%           .regularizationParams - struct with the following
%               fields;
%               .lambda - double. Default is 0.01.
%                   Value of Tikhonov's lambda or L.
%               .Gamma - double[]. Default is I (i.e. coincides with Ridge).
%                   Value of Tikhonov's \Gamma.
%                   Tikhonov's \Gamma can encode a lot of stuff, e.g.;
%                       + identity smoothing,
%                       + derivative penalties,
%                       + spatial smootings e.g. Laplacians, differentials, etc
%                       + depth weighting,
%                       + structural constraints,
%                       + any other linear constraint.
%
%   .waterFraction - double. Default is 0.8 (i.e. 80%)
%        Fraction of water content.
%        Default value from [Herrera-Vega, 2018, pg 60]
%        Set to 0 if you do not want to correct for it.
%
%   .wavelengths - double[nWavelengthsx1]. Default is set to [695; 830] nm (corresponding
%       to those of the HITACHI ETG-4000 for historical reasons of ICNNA).
%       A column vector of nominal wavelengths set in [nm].
%       The number of wavelengths must match size(dOD,3).
%
%
%% Output
%
% dC - double[nSamples,nChannels,nSignals]
%   3D neuroimage tensor of chromophore concentrations.
%   The first dimension indexes time samples,
%   the second dimensions indexes channels and the third
%   dimension indexes reconstructed chromophores (1- Oxy and 2- Deoxy).
%
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also icnna.op.intensity2deltaOD
%


%% Log
%
% -- ICNNA v1.4.0
%
% 13-Feb-2026: FOE 
%   + File created from code in old function miscellaneous/mbll. Unfinished
%
% 16-Feb-2026: FOE 
%   + Continued working on this function.
%
% 18-Feb-2026: FOE 
%   + Made iod to accept values in mm rather than cm and
%   allowed for autoscale.
%   + Added warning when iod may NOT be in expected units.
%   + Polished comments
%   + Explicitly distinguish Ridge from Tikhonov's regularization.
%   Tikhonov's implementation no longer forces \Gamma = I although
%   it defaults to \Gamma = I.
%
%


%% Deal with options
opt.bgMua = 0.12; %In [cm^{-1}]
opt.dpf = 6.26; %Average DPF accepted value for normal adult head.
                %Set to [] to reconstruct without dpf correction.
opt.invert = 'moorepenrose'; %Matrix inversion
opt.iod = 30; %Interoptode distance in [mm]
opt.lipidFraction = 0.116;
opt.regularization = 'tikhonov'; %Regularization
opt.regularizationParams.lambda = 0.01; %Default: Tikhonov's lambda or L
opt.regularizationParams.Gamma  = eye(2); %Default: Tikhonov's Gamma
opt.waterFraction = 0.8;
opt.wavelengths = [695 830]; %In [nm]
if (exist('options','var') && isstruct(options))
    if isfield(options,'bgMua')
        opt.bgMua = options.bgMua;
    end
    if isfield(options,'dpf')
        opt.dpf = options.dpf;
    end
    if isfield(options,'invert')
        opt.invert = lower(options.invert);
    end
    if isfield(options,'iod')
        opt.iod = options.iod;
    end
    if isfield(options,'lipidFraction')
        opt.lipidFraction = options.lipidFraction;
    end
    if isfield(options,'regularization')
        opt.regularization = lower(options.regularization);
    end
    if isfield(options,'regularizationParams')
        opt.regularizationParams = options.regularizationParams;
    end
    if isfield(options,'waterFraction')
        opt.waterFraction = options.waterFraction;
    end
    if isfield(options,'wavelengths')
        opt.wavelengths = options.wavelengths;
    end
end






%% Some basic initialization
nWlengths=length(opt.wavelengths);
assert(nWlengths == size(dOD,3), ...
    'Unexpected number of nominal wavelengths.');


dC=nan(size(dOD));
[nSamples,nChannels,~] = size(dC);


%These are necessary coefficients, so worth reading them straight away.
%Those that only are needed depending on the options, will only
%be read on demand.
coeffsPath = [icnna_rootDirectory filesep ...
                '+icnna' filesep '+data' filesep '+coeffs' filesep];
mua_HHb    = icnna.data.core.opticalCoefficient.create([coeffsPath ...
                            'HbR_extinction_specific_fOSA_CopeM.json']);
mua_HbO2   = icnna.data.core.opticalCoefficient.create([coeffsPath ...
                            'HbO2_extinction_specific_fOSA_CopeM.json']);
kDPF       = icnna.data.core.opticalCoefficient.create([coeffsPath ...
                            'HeadAdult_kDPF_macroscopic_fOSA_CopeM.json']);


%Now IOD will always be used as vector.
%If it is scalar convert to column vector by simply replicating the value.
%If it is a vector make sure it is a column vector.
if isscalar(opt.iod)
    opt.iod = repmat(opt.iod,nChannels,1);
else
    assert(numel(opt.iod) == nChannels, ...
        ['Unexpected number of inter-optode distances. These ought to' ...
        'match the number of channels in T.']);
    opt.iod = reshape(opt.iod,nChannels,1); %make it column vector
end
[opt.iod, best_factor] = icnna.util.autoscaleIOD2mm(opt.iod);
if best_factor ~= 1
    warning('icnna:op:deltaOD2deltaConcentrations:InvalidParameterValue',...
            'Option .iod is expected in [mm]. Autoscaling applied.');
end
opt.iod = opt.iod/10; %From [mm] to [cm] to match coefficients units.


%% Prepare the extinction matrix and pathlength
% Pathlength fixed at a separation distance in cm and DPF 
% Coefficient units in /mM/cm
E=zeros(2);
if ~isempty(opt.dpf)
    path = opt.iod * opt.dpf;
    % To calculate the concentation changes for 2 wavelengths (wl) using the table (abscoeff)
    E(:,1) = mua_HHb.getResponseAt(opt.wavelengths) ...
        .* kDPF.getResponseAt(opt.wavelengths); % de-oxy-corrected
    E(:,2) = mua_HbO2.getResponseAt(opt.wavelengths) ...
        .* kDPF.getResponseAt(opt.wavelengths); % oxy-corrected
    
else %Reconstruct without DPF
    path = opt.iod;
    % To calculate the concentation changes for 2 wavelengths (wl) using the table (abscoeff)
    E(:,1) = mua_HHb.getResponseAt(opt.wavelengths); % de-oxy
    E(:,2) = mua_HbO2.getResponseAt(opt.wavelengths); % oxy
    
end
path = path; %From [mm] to [cm] to match coefficients units.

%% Convert intensities

dOD = reshape(dOD,size(dOD,1),size(dOD,2)*size(dOD,3));
%Work in matrix form is faster than doing so in tensor form,
%so transiently change to matrix form by "concatenating" the
%third axis.


%Adjust for water, lipid and background if required.
%   $D(OD)_{fixed contribution} = e_H2O*[H2O] + e_Lip*[Lip] + B$
%
% and then substract this contribution from the measured OD;
%
%   $D(OD)_{chromophore contribution} = ...
%           D(OD)_{measured} - D(OD)_{fixed contribution} $

if opt.waterFraction ~= 0 %Only read file if needed.
    mua_Water = icnna.data.core.opticalCoefficient.create([coeffsPath ...
                            'Water_extinction_specific_fOSA_CopeM.json']);
    e_Water   = mua_Water.getResponseAt(opt.wavelengths);
else
    e_Water = zeros(nWlengths,1);
end
if opt.lipidFraction ~= 0
    mua_Lipid = icnna.data.core.opticalCoefficient.create([coeffsPath ...
                            'Lipid_absorption_specific_OMLC_PrahlS2004.json']);
    e_Lipid   = mua_Lipid.getResponseAt(opt.wavelengths);
    %This is in [m^{-1}], Convert to [cm^{-1}]
    e_Lipid   = e_Lipid/100;
else
    e_Lipid = zeros(nWlengths,1);
end
B = 0.12; %In [cm^{-1}]

dOD_fixed = e_Water*opt.waterFraction ...
          + e_Lipid*opt.lipidFraction ...
          + B; %Column vector for each wavelength
dOD_fixed = reshape(repmat(dOD_fixed, 1, nChannels)', 1, []);
dOD = dOD - dOD_fixed;

%Attenuation to concentrations
%%%Modified LAMBERT LAW:
%%%     deltaA=d.DPF.E.deltaC
%%%  => E.deltaC = deltaA/(d.DPF)
%%%
%%%== If using direct inverse:
%%%  => deltaC=E^{-1}*deltaA/(d.DPF)
%%%
%%%== If using Moore-Perose psedo-inverse:
%%%  => deltaC=(E^T*E)^{-1}*E^T*deltaA/(d.DPF)
%%%
%%%== If using Moore-Perose psedo-inverse and Tikhonov's regularization:
%%%  => deltaC=(E^T*E-L*I)^{-1}*E^T*deltaA/(d.DPF)
%%%

%Differential Pathlength correction
path = repmat(path',nSamples,2);
dOD   = dOD./path; %path = iod*dpf (see above)

%Reconstruction: OD to concentrations - Solve the inverse system
switch (opt.invert)
    case 'direct' %Legacy
        tmpInv = inv(E);
    case 'moorepenrose' %Default since v1.4.0
        switch (opt.regularization)
            case 'none'
                tmpInv = pinv(E);
                %As far as I can tell, this is the one being used
                %by HomEr 2 (see function hmrOD2Conc.m, ln 46)
                % as well as by HomEr 3 (see function hmrR_OD2Conc.m, ln 64).
            case 'ridge'
                L = opt.regularizationParams;
                tmpInv = (inv(E'*E-L*eye(2))*E');
            case 'tikhonov'
                L = opt.regularizationParams.lambda;
                G = opt.regularizationParams.Gamma;
                tmpInv = (inv(E'*E-L^2*(G'*G))*E');
            otherwise
                error('icnna:miscellaneous:mbll:InvalidParameterValue',...
                    'Invalid option .regularization value.');
        end
    otherwise
        error('icnna:miscellaneous:mbll:InvalidParameterValue',...
            'Invalid option .invert value.');
end


for iCh = 1:nChannels
    %%% 16-Feb-2026 (FOE): Deprecated code
    % tmp_dC = nan(nSamples,2); % 2 signals
    % for num = 1:nSamples
    %     %Note that in the system of equations both dC and dOD
    %     %are column vectors, but here they come as row vectors
    %     %hence the need for the "two" transposes below.
    %     tmp_dC(num,:) = [tmpInv * dOD(num,[iCh iCh+nChannels])']';
    %     %Watch out! This line won't generalize well if
    %     %there are more than 2 signals e.g. in the presence
    %     %of HbT or CCO!
    % end % for each sample

    %Note that in the system of equations both dC and dOD
    %are column vectors, but here they come as row vectors
    %hence the need for the "two" transposes below.
    tmp_dC = (tmpInv * dOD(:,[iCh iCh+nChannels])')';

    %See extinction matrix E!
    % Oxy is in tmp_dC(:,2) and deoxy in tmp_dC(:,1)
    dC(:,iCh,nirs_neuroimage.OXY)   = tmp_dC(:,2);
    dC(:,iCh,nirs_neuroimage.DEOXY) = tmp_dC(:,1);
    %NOTE: The use of the nirs_neuroimage constant above needs
    %changing to use the new icnna.data.core.signalDescriptors
    %instead.
end % for each channel



dC = 1000 * dC; % uM /*To convert from mM->uM*/


end

