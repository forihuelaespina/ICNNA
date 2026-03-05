function [M] = mbll(T,options)
%DEPRECATED. Reconstruction using the Modified Beer-Lambert law (MBLL).
%
%   This function is now deprecated. Use icnna.op.intensity2deltaOD
% and icnna.op.deltaOD2deltaConcentrations instead.
%
%
% M=mbll(T) - Reconstructs 3D tensor of raw light intensities to a 3D 
%   neuroimage tensor, using the modified Beer-Lambert law (MBLL).
%
% M=mbll(T,options) - Reconstructs 3D tensor of raw light intensities 
%   to a 3D  neuroimage tensor, using the modified Beer-Lambert law
%   (MBLL) with the chosen options.
%
% M=mbll(T,...,'-v1.2') - Provides backward compatibility for older ICNNA
%   versions.
%       When no DPF was being used the optical path was normalize to 1 
%   as the values would be relative anyway. Now with a better support for
%   varying IOD since version 1.3.0, this has to be changed to the
%   value of the IOD. Use the flag to enforce backward compatibility.
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
%attenuation, expressed whether as absorbance ($A$) or the optical
%density ($OD$), is proportional to the concentration of the
%compound in the solution ($c$) and the optical pathlength ($d$):
%
%    $ OD = ln \frac{I_0}{I}  = e \cdot c \cdot d $$
%    $ A  = 2.303 log_10 \frac{I_0}{I}  = e \cdot c \cdot d $$
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
%    $ A  = 2.303 log_10 \frac{I_0}{I}  = e \cdot c \cdot d $$
%
%The product e.c is known as the (macroscopic) absorption
%coefficient of the medium $\mu_a$.
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
% For a much better explanation see function icnna.op.intensity2OD
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
% T - 3D tensor of raw light intensities. Transmittance.
%   The first dimension indexes time samples, 
%   the second dimensions indexes channels and the third
%   dimension indexes nominal acquisition wavelengths (or optical filters).
%   Nominal wavelengths can be configured using the 'wavelengths'
%   option.
%
% M - 3D neuroimage tensor. The first dimension indexes time
%   samples, the second dimensions indexes channels and the third
%   dimension indexes reconstructed chromophores (1 - Oxy and 2- Deoxy).
%
% Options - optionName, optionValue pair arguments
%    .attenuationType - char[]. Enum. Default is 'od'.
%       v1.4.0 or above
%       Options are:
%       * 'od' - Optical density (uses natural logarithm)
%       * 'a'  - Absorbance (uses base 10 logarithm)
%
%       NOTE: The use of 'od' is the default behaviour since v1.4.0.
%       Use option 'a' for legacy behaviour.
%
%   .dpf - Int. 
%       Differential pathlength factor (DPF) used for reconstruction.
%       By default is set to 6.26 (Average DPF accepted value for normal
%       adult head). Set it to [] if you want to reconstruct without DPF.
%   .invert - Char[]. Enum. Default is 'moorepenrose'
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
%   .iod - Int (scalar or vector). By default is set to 30mm.
%       Interoptode distance in [mm]. If scalar, the same IOD will be
%       used for all channels. If vector, there will be
%       one IOD per channel. It can either be a column or row vector.
%
%    .Ineg - char[]. Default is 'shift'
%       Determines behaviour if negative (or zero) intensity values are found.
%       Options are;
%       'shift' - Shift all values to be positive. Default's ICNNA choice.
%       'abs'   - Use the absolute value of I. This is HomEr 2/3 choice.
%       'real'  - Allows for complex number outcomes from the
%           computation of logarithms, and later use the real part of
%           the complex number of the solution.
%       'magnitude' - Allows for complex number outcomes from the
%           computation of logarithms, and later compute the magnitude
%           of the polar representation of the complex number of the
%           solution.
%       'none'  - Do not correct. Beware! This will lead to negative
%           logarithms and hence to complex number outputs.
%           
%   .I0ref - DEPRECATED. See option .Iref instead.
%   .Iref - char[].
%       Determines how to establish the reference intensity I(t=0)
%       (note that this is different from the irradiated intensity I_0
%       which is assume invariant over time).
%       Options are;
%       'first' - Use only the first sample. Used by classical fOSA
%       'first50' - Default. Use the first 50 samples (or all if the
%           timeseries is less than 50). Used by fOSA v2.2 and onwards
%           and the ICNNA option.
%       'mean' - Use the mean of the timeseries. Used by Homer. Although
%           in principle this provides more stability, BUT in the
%           presence of optode movements, this mean can be severely
%           distorted.
%
%   .regularization - Char[]. Enum. Default is 'tikhonov'
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
%       NOTE: The use of the Tikhonov's regularization is the default
%       behaviour since v1.4.0.
%       Use option 'none' for legacy behaviour.
%
%   .regularizationParams - Depends on option .regularization
%       v1.4.0 or above
%       Regularization parameters.
%       * .regularization == 'none' => Not used.
%       * .regularization == 'ridge'
%           .regularizationParams - double. Default is 0.01.
%               Value of Ridge's lambda or L.
%       * .regularization == 'tikhonov' (Default)
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
%   .wavelengths - A row vector of nominal wavelengths set in [nm]. By 
%       default is set to [695 830] nm (corresponding to those of the
%       HITACHI ETG-4000 for historical reasons of ICNNA). The number of
%       wavelengths must match size(T,3) and size(M,3).
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
% Copyright 2018-26
% Copyright over some comments belong to their authors.
% @author: Felipe Orihuela-Espina
% 
%
% See also import, neuroimage, NIRS_neuroimage, rawData_ETG4000,
%   rawData_NIRScout, icnna.op.intensity2deltaOD,
%   icnna.op.deltaOD2deltaConcentrations, 
%   icnna.data.core.opticalCoefficients
%





%% Log
%
% File created: 12-Apr-2018 (but some code goes back to 2008)
% File last modified (before creation of this log): 12-Apr-2025
%
% 12-Apr-2018: FOE. Extraction from rawData_ETG-4000.convert method
%   and improved.
%
% 25-Apr-2018: FOE. Bug fix. Oxy and deoxy were returned swapped.
%
% 12-Apr-2025: FOE
%   + Got rid of old labels @date and @modified.
%   + Allow IOD to be different for each channel for a better support
%   of the short channels and HD models. Correct reconstructions was
%   possible before but required to call this function several times
%   separetely for each different IOD. Now this can be done in 1 shot.
%   + Allow the reference I0 to calculate the OD to be different from the
%   first samples. This is a trick use by other software tools e.g. Homer
%   uses the mean of the whole signal (rather than only the first 50
%   samples as fOSA -and ICNNA by inheritance- did), that can enhance
%   stability of the signal. For this a new option I0ref is provided.
%   + When no DPF was being used the path was normalize to 1 as the
%   values would be relative anyway. Now with a better support for
%   varying IOD, this has to be changed to the value of the IOD.
%   However, to afford backward compatibility I will provide a version
%   flag.
%   + I have also took advantage of revisiting this function to make
%   it a bit more efficient.
%
%
% 26-Oct-2025: FOE
%   + Some minor comment improvements.
%
% -- ICNNA v1.4.0
%
% 12-Feb-2026: FOE
%   + Calculation of optical density / absorbance now relies
%   on function icnna.op.intensity2deltaOD hence simplifying the code here.
%   + Added option attenuationType to choose between optical density and
%   absorbance.
%   + Added option .invert to invert using pseudo-inverse. 
%   + Added option .regularization to use regularization. 
%   + Added option .regularizationParams to support regularization parameters.
%   + Deprecated option .I0ref and replaced by option Iref to avoid
%   confusion between I_0 (the irradiated light) and I(t=ref), the
%   differential reference of the MBLL.
%   + Added option .Ineg to deal with negative or zero intensities.
%       This is now more flexible that the fixed shifting that ICNNA
%       does by default and allows to better replicate HomEr 2/3 choice.
%       See comments above.
%   + Coefficients are no longer read from function table_abscoeffs
%   but instead they use icnna.data.core.opticalCoefficient objects.
%   + Comment improvements.
%   + Code polishing
%       * Matrix 'absorb' rebranded E for extinction
%       * Matrix 'A' rebranded dA for (\Delta A)
%       * Matrix 'conc' rebranded dC for (\Delta C)
%
%
% 16-Feb-2026: FOE
%   + Calculation of concentrations now relies
%   on function icnna.op.deltaOD2deltaConcentrations hence
%   simplifying the code here.
%   + Deprecated. Use icnna.op.intensity2deltaOD and
%   icnna.op.deltaOD2deltaConcentrations instead.
%   + Option iod now operates in [mm] instead of [cm]
%   for coherence with icnna.op.deltaOD2deltaConcentrations
%

warning('icnna:miscellaneous:mbll:Deprecated',...
    ['This function is now deprecated. Please use ' ...
     'functions icnna.op.intensity2deltaOD and ' ...
     'icnna.op.deltaOD2deltaConcentrations instead.']);






%Check if backward compatibility flag has been provided.
compatibilityFlag = '';
switch (nargin)
    case 1 %Just T is provided. No options or compatibility flag
        %Do nothing
    case 2 %Either T and Options or T and flag
        if ischar(options)
            compatibilityFlag = options;
            if ~strcmpi(compatibilityFlag,'-v1.2')
                error('ICNNA:misc:mbll:InvalidParameterValue',...
                        'Invalid compatibility version flag.');
            end
            options = [];
        end
   
    case 3 %T, options and flag
        %Do nothing
    otherwise
        error('ICNNA:misc:mbll:UnexpectedNumberOfParameters',...
                'Unexpected number of parameters.');
end



opt.attenuationType = 'od'; %From v1.4.0. 
opt.dpf = 6.26; %Average DPF accepted value for normal adult head.
                %Set to [] to reconstruct without dpf correction.
opt.invert = 'moorepenrose'; %From v1.4.0. Matrix inversion
opt.Ineg   = 'shift';   %From v1.4.0. Behaviour in case of negative
                        %intensities.
opt.iod = 30; %Interoptode distance in [mm]
                %Since 18-Feb-2026 (v1.4.0) this operates in [mm] 
                %Since 12-Apr-2025 (v1.3.0) this changed from a simple
                %scalar to either a scalar (same iod for ALL channels)
                %or a column or row vector, with 1 iod per channel.
                %This provides correct support to short channels and
                %HD arrays.
opt.Iref = 'first50'; %From v1.4.0. Replaced I0ref (v1.3.0). Method to calculate I0.
opt.regularization = 'tikhonov'; %From v1.4.0. Regularization
opt.regularizationParams.lambda = 0.01; %From v1.4.0. Tikhonov's lambda or L
opt.regularizationParams.Gamma  = eye(2); %From v1.4.0. Tikhonov's Gamma
opt.wavelengths = [695 830]; %In [nm]
if (exist('options','var') && isstruct(options))
    if isfield(options,'attenuationType')
        opt.attenuationType = lower(options.attenuationType);
    end
    if isfield(options,'dpf')
        opt.dpf = options.dpf;
    end
    if isfield(options,'invert')
        opt.invert = lower(options.invert);
    end
    if isfield(options,'Ineg')
        opt.Ineg = lower(options.Ineg);
    end
    if isfield(options,'iod')
        opt.iod = options.iod;
    end
    if isfield(options,'Iref')
        opt.Iref = lower(options.Iref);
    end
    if isfield(options,'I0ref') && ~isfield(options,'Iref')
        warning('icnna:miscellaneous:mbll:DeprecatedOption',...
                'Option .I0ref is deprecated. Use option .Iref instead.');
        opt.Iref = lower(options.I0ref);
    end
    if isfield(options,'regularization')
        opt.regularization = lower(options.regularization);
    end
    if isfield(options,'regularizationParams')
        opt.regularizationParams = options.regularizationParams;
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
nSamples  = size(M,1);
nChannels = size(M,2);
nSignals  = size(M,3); %Number of reconstructed parameters in principle
            %should match the number of wavelengths (this won't
            %be the case for overdetermined systems).

%%FOE: Code deprecated on 12-Feb-2026
% coefficients=table_abscoeff();
% mua_HHb= coefficients(:,2); % de-oxy
% mua_HbO2= coefficients(:,3); % oxy
% kDPF = coefficients(:, 8); %8 is the column holding the DPF

coeffsPath = ['+icnna' filesep '+data' filesep '+coeffs' filesep];
mua_HHb    = icnna.data.core.opticalCoefficient.create([coeffsPath ...
                            'HbR_extinction_specific_fOSA_CopeM.json']);
mua_HbO2   = icnna.data.core.opticalCoefficient.create([coeffsPath ...
                            'HbO2_extinction_specific_fOSA_CopeM.json']);
kDPF       = icnna.data.core.opticalCoefficient.create([coeffsPath ...
                            'HeadAdult_kDPF_macroscopic_fOSA_CopeM']);


%Now iod will always be used as vector.
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









%% Prepare the extinction matrix and pathlength
% Pathlength fixed at a separation distance and DPF in mm
% Coefficient units in /mM/cm
E=zeros(2);
if ~isempty(opt.dpf)
    path = opt.iod * opt.dpf;
    % To calculate the concentation changes for 2 wavelengths (wl) using the table (abscoeff)
    for wl = 1:nWlengths
        %%FOE: Code deprecated on 12-Feb-2026
        % index = find (coefficients(:,1) == opt.wavelengths(wl));%1 is the column holding the wavelength
        % %%%Watch out! See remarks
        % %wavelength dependent value.
        % absorb(wl,1) = mua_HHb(index) * kDPF(index);     % de-oxy-corrected
        % absorb(wl,2) = mua_HbO2(index) * kDPF(index);    % oxy-corrected
        E(wl,1) = mua_HHb.getResponseAt(opt.wavelengths(wl)) ...
                        * kDPF.getResponseAt(opt.wavelengths(wl)); % de-oxy-corrected
        E(wl,2) = mua_HbO2.getResponseAt(opt.wavelengths(wl)) ...
                        * kDPF.getResponseAt(opt.wavelengths(wl)); % oxy-corrected


    end
    
else %Reconstruct without DPF
    if strcmpi(compatibilityFlag,'-v1.2')
        path = ones(nChannels,1);
    else
        path = opt.iod;
    end
    % To calculate the concentation changes for 2 wavelengths (wl) using the table (abscoeff)
    for wl = 1:nWlengths
        %%FOE: Code deprecated on 12-Feb-2026
        % index = find (coefficients(:,1) == opt.wavelengths(wl));
        % absorb(wl,1) = mua_HHb(index);     % de-oxy
        % absorb(wl,2) = mua_HbO2(index);    % oxy
        E(wl,1) = mua_HHb.getResponseAt(opt.wavelengths(wl)); % de-oxy
        E(wl,2) = mua_HbO2.getResponseAt(opt.wavelengths(wl)); % oxy
    end
    
    
end

%% Convert intensities


if strcmpi(compatibilityFlag,'-v1.2')
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
        od=A/path(ch); %Optical Density: OD = A/d
    
        for num = 1:nSamples
            %%%LAMBERT LAW: A=log10 [Io/I]=e.c.d.DPF   =>   c=A/(e.d.DPF)= OD/(e.DPF)
            %%%where DPF depends on the path defined by the optode separation
            %%%and the avgDPF
            conc(num,:) = od(num,:)* inv(E)'; 
        end % for each sample
        
        
        %Watch out! See absorb matrix! Oxy is in conc(:,2) and deoxy in conc(:,1)
        M(:,ch,1)=conc(:,2);
        M(:,ch,2)=conc(:,1);
        
    end     % for each channel pair


    M = 1000 * M; % uM /*To convert from mM->uM*/


else %Since v1.3

    %%FOE: Code deprecated on 12-Feb-2026
    % %Work in matrix form is faster than doing so in tensor form,
    % %so transiently change to matrix form by "concatenating" the
    % %third axis.
    % T = reshape(T,size(T,1),size(T,2)*size(T,3));
    % 
    % % Check that absolute intensity does not reach below zero
    % tmpMin = min(min(T));
    % if tmpMin < 0
	%     T=T-tmpMin;
    % end
    % 
    % 
    % % Decide on the reference I0 (beware! this is not I_0 but I(t=reference))
    % k=min(50,size(T,1)); %By default, use the first 50 samples 
    %        %as fOSA v2.2 to match previous behaviour
    % switch opt.I0ref
    %     case 'first'
    %         k = 1;
    %     case 'first50'
    %         %Do nothing. Default
    %     case 'mean' %This one matches Homer3
    %         k=size(T,1);
    %     otherwise
    %         error('ICNNA:misc:mbll:InvalidParameterValue',...
    %               'Invalid parameter value opt.I0ref.')
    % end
    % if ~isempty(T)
    %     I0 = mean(T(1:k,:),"omitnan");
    % else
    %     I0 = ones(1,nChannels);
    % end
    % 
    % % Calculate attenuations/optical densities
    % % A  =-log10 [I/I0] = log10 [I0/I]
    % % OD =-ln    [I/I0] = ln    [I0/I]
    % I0 = repmat(I0,nSamples,1);
    % if strcmp(opt.attenuationType,'od')
    %     A = log(I0./I);
    % else %'a'
    %     A = log10(I0./I);
    % end
    %
    % dA = A; %This line was NOT needed originally as all code below
    %         %was using A directly, but the variable name was a bit
    %         %confusing, so I updated to dA below

    % Calculate (\Delta) absorbances/optical densities
    opt2.Iref   = opt.I0ref;
    opt2.Ineg   = opt.Ineg;
    opt2.output = opt.attenuationType;
    dOD = icnna.op.intensity2deltaOD(T,opt2); %Note that this is already
                                        %\Delta A ~ \Delta OD
                                        %See documentation in icnna.op.intensity2OD


   %  dA = reshape(dA,size(dA,1),size(dA,2)*size(dA,3));
   %      %Work in matrix form is faster than doing so in tensor form,
   %      %so transiently change to matrix form by "concatenating" the
   %      %third axis.
   % 
   % 
   % 
   %  %Attenuation to concentrations
   %      %%%Modified LAMBERT LAW:
   %      %%%     deltaA=d.DPF.E.deltaC
   %      %%%  => E.deltaC = deltaA/(d.DPF)
   %      %%%
   %      %%%== If using direct inverse:
   %      %%%  => deltaC=E^{-1}*deltaA/(d.DPF)
   %      %%%
   %      %%%== If using Moore-Perose psedo-inverse:
   %      %%%  => deltaC=(E^T*E)^{-1}*E^T*deltaA/(d.DPF)
   %      %%%
   %      %%%== If using Moore-Perose psedo-inverse and Tikhonov's regularization:
   %      %%%  => deltaC=(E^T*E-L*I)^{-1}*E^T*deltaA/(d.DPF)
   %      %%%
   % 
   %  %Differential Pathlength correction
   %  path = repmat(path',nSamples,2);
   %  dA   = dA./path; %path = iod*dpf (see above)
   % 
   %  %Reconstruction: OD to concentrations - Solve the inverse system
   %  switch (opt.invert)
   %      case 'direct' %Legacy
   %          tmpInv = inv(E)';
   %      case 'moorepenrose' %Default since v1.4.0
   %          switch (opt.regularization)
   %              case 'none'
   %                  tmpInv = pinv(E)';
   %                      %As far as I can tell, this is the one being used
   %                      %by HomEr 2 (see function hmrOD2Conc.m, ln 46)
   %                      % as well as by HomEr 3 (see function hmrR_OD2Conc.m, ln 64).
   %              case 'tikhonov'
   %                  L = opt.regularizationParams;
   %                  tmpInv = ((E'*E-L*eye(2))*E')';
   %              otherwise
   %                  error('icnna:miscellaneous:mbll:InvalidParameterValue',...
   %                    'Invalid option .regularization value.');
   %          end
   %      otherwise
   %          error('icnna:miscellaneous:mbll:InvalidParameterValue',...
   %                'Invalid option .invert value.');
   %  end
   %  for iCh = 1:nChannels
   %      dC = nan(nSamples,2); % 2 signals
   %      for num = 1:nSamples
   %          dC(num,:) = dA(num,[iCh iCh+nChannels])* tmpInv;
   %              %Watch out! This line won't generalize well if
   %              %there are more than 2 signals e.g. in the presence
   %              %of HbT or CCO!
   %      end % for each sample
   % 
   %      %Watch out! See extinction matrix E!
   %      % Oxy is in dC(:,2) and deoxy in dC(:,1)
   %      M(:,iCh,1)=dC(:,2);
   %      M(:,iCh,2)=dC(:,1);
   % end % for each channel


    opt3.bgMua  = 0; %In [mm^{-1}]
    opt3.lipidFraction  = 0;
    opt3.waterFraction = 0;
    opt3.iod    = opt.iod; %Interoptode distance in [mm]
    opt3.dpf    = opt.dpf; %Average DPF accepted value for normal adult head.
                    %Set to [] to reconstruct without dpf correction.
    opt3.invert = 'moorepenrose'; %Matrix inversion
    opt3.regularization = 'tikhonov'; %Regularization
    opt3.regularizationParams = opt.regularizationParams;
                           %Default: Tikhonov's lambda or L
    opt3.wavelengths   = opt.wavelengths; %In [nm]
    M = icnna.op.deltaOD2deltaConcentrations(dOD,opt3);

end





end






