function [dA] = intensity2DeltaOD(I,options)
% Calculates the (\Delta) optical density (and/or absorbance) from intensities.
%
% [dOD] = icnna.op.intensity2DeltaOD(I,options)
% [dA]  = icnna.op.intensity2DeltaOD(I,options)
%
%
%% Optical density, absorbance and attenuation
%
% Absorbance and optical density are two tightly related concepts in
%optics. They both refer to the ratio between the incoming and outgoing
%intensities, although there is one operational difference; one use
%natural logarithms (optical density) whereas the other (absorbance)
%uses base 10 logarithms
%
%   A  = -log_{10}(I_d/I_0) = \mu_e d
%
%   OD = -ln(I_d/I_0) = \mu_e d
%
% and of course they are related by a constant;
%
%   OD = ln(10) * A \approx 2.303 A
%
%   Sometimes you may see that the optical density is defined as
% the absorbance of an optical element per unit distance l:
%
%  OD = \frac{A}{l}
%
% Finally, attenuation is the construct that refers to the reduction
% in the intensity of light as it travels through a medium. In constrast,
% OD and absorbance are estimators of attenuation, i.e. a specific way
% to quantify attenuation, but not the only estimators. For instance,
% another popular estimator of attenuation is optical depth (the integral
% of the attenuation coefficient over the path length). Note for instance
% that for a homogenous medium optical depth is equivalent to optical
% density.
%
%
%% About \Delta OD
%
% The \Delta OD in the MBLL is not a traditional differental
% expression, e.g.:
%
%       \Delta OD(t) = OD[t=\tau] - OD[t=\tau-1]
%
% Instead, the \Delta OD(t) in the MBLL is actually a difference against
% a FIXED reference -this is the step that forces G to vanish!-. That is:
%
%        \Delta OD(t) = OD[t=\tau] - OD[t=0]
%                     = -ln(I(t)/I_0) - (-ln(I(t=0)/I_0))
%                     =  ln(I_0/I(t)) - ln(I_0/I(t=0))
%
% Note that I_0 (the irradiated light is assumed constant over time),
% and that I_0 is different from the fixed reference I(t=0).
%
% Using the logarithm property: ln(a) − ln(b) = ln(a / b)
%
%        \Delta OD(t) = OD[t=\tau] - OD[t=0]
%                     = ln(I_0/I(t)) - ln(I_0/I(t=0))
%                     = ln(I_0/I(t) / I_0/I(t=0))
%                     = ln(I(t=0)/I(t))  
%
%   +==========================================================+
%   | IMPORTANT: Note that there is no need for an explicit    |
%   | substraction to get \Delta OD(t)!                        |
%   +==========================================================+
%
% I(t=0) -our reference- is constant throughout \Delta OD(t). Later,
% when the MBLL uses \Delta OD(t), that represents a bias
% in the estimation of the changes in the concentrations \Delta c_i,
% but it is a constant bias, and hence \Delta c_i remain proportional
% to \Delta OD(t) up to a constant:
%
%       \Delta c_i \propto \Delta OD(t)
%
% Finally, the question is how to choose our reference I(t=0). Different
% software tools out there use different choices with different pros and
% cons.
%
%   * fOSA originally used the first 50 samples, i.e. mean(I(t=1...50))
%   * Both HomER 2 and HomER 3, use the mean(I(t))
%   * ICNNA started using I(t=1) and many years ago -I was not yet
%   documenting this properly at the time-, started offering the
%   possibility of using either of these three options -leaving fOSA's
%   choice as the default- (See option .Iref).
%
% Using I(t=1) has the advantage of being closer to the ideal of an
%instantaneous reference but can be very noisy in practice. HomEr choice
%centers the \Delta OD(t) around a zero mean, but it may be more strongly
%affected by large optode movements. fOSA solution offers a reasonable
%trade off but cannot guarantee zero mean.
%
%
%% Remark
%
% In truth, the hardware will encode voltages rather than intensity, but
% these are proportional. In fNIRS, the recorded voltages are taken as
% a direct proxy of radiation intensity incoming to the photodetector.
%
%
%
%% Input Parameters
%
% I - double[nSamples,nChannels,nSignals] | double[nSamples,nMeasurements]
%   Transmittance. 3D tensor of raw light intensities.
%   The first dimension indexes time samples, the second 
%   dimensions indexes channels and the third dimension indexes nominal 
%   acquisition wavelengths (or optical filters). The second and third
%   dimensions may be collapsed into one.
%
% options - Optional. struct.
%   A struct of options with the following fields.
%    .Ineg - char[]. Default is 'shift'
%       Determines behaviour if negative (or zero) intensity values are found.
%       Options are;
%       'shift' - Shift all values to be positive. Default's ICNNA choice.
%       'abs'   - Use the absolute value of I. This is HomEr 2/3 choice.
%       'real' - Allows for complex number outcomes from the
%           computation of logarithms, and later use the real part of
%           the complex number of the solution.
%       'magnitude' - Allows for complex number outcomes from the
%           computation of logarithms, and later compute the magnitude
%           of the polar representation of the complex number of the
%           solution.
%       'none'  - Do not correct. Beware! This will lead to negative
%           logarithms and hence to complex number outputs.
%
%
%       NOTE: It is not clear to me (FOE) how or why one can get negative
%           I recordings. The only thing I can think is that the output
%           of an fNIRS device may not be yielding the physical
%           intensity, but instead yielding some differential proxy
%           (at the end of the day, strictly speaking, we use voltages
%           -difference in potentials-, rather than intensities, or
%           perhaps the electronics yield some log-transformed version
%           of the intensity). 
%           So whilst light intensity (power per unit area) will not be
%           negative, but its proxy may be. Anyhow, the point is
%           that different software tools make different efforts to
%           attend to this issue. I'm not certain about the physical
%           validity of each choice, but at least, from a mathematical
%           point of view, the 'abs' option above is a crude patch
%           that does not seem safe as it will not preserve the
%           relative structure of the values. I understand HomEr(s) do
%           this because it assumes that these negative values are pure
%           noise and hence lack any structure. But IMHO, the signal
%           shifting ('shift') is mathematically a more logical choice
%           preserving both the value structure and the linearity
%           assumed by MBLL.
%
%
%
%    .Iref - char[]. Default is 'first50'
%       Determines how to establish the reference intensity I(t=0).
%       Options are;
%       'first' - Use only the first sample. Used by classical fOSA
%       'first50' - Default. Use the first 50 samples (or all if the
%           timeseries is less than 50). Used by fOSA v2.2 and onwards
%           and the default ICNNA option.
%       'mean' - Use the mean of the timeseries. Used by Homer. Although
%           in principle this provides zero mean OD and more stability,
%           BUT in the presence of optode movements, this mean can be
%           severely distorted.
%
%           See note above about the pros and cons of each option.
%
%
%    .output - char[]. Enum. Default is 'od'.
%       Options are:
%       * 'od' - Optical density (uses natural logarithm) - Used by HomEr
%       * 'a'  - Absorbance (uses base 10 logarithm) - Used by fOSA
%
%       NOTE: Old versions of ICNNA using function miscellaneous/mbll
%       default to absorbance ('a') for historical reasons, but here
%       the default is 'od'.
%
%  
%% Output
%
% dOD | dA - double[nSamples,nChannels,nSignals] | double[nSamples,nMeasurements]
%   (\Delta) Attenuation. 3D/2D tensor of (\Delta) absorbances or optical
%   density. See option .output
%
%
%
% Copyright 2026
% @author Felipe Orihuela-Espina
%
% See also
%


%% Log
%
% -- ICNNA v1.4.0
%
% 11/12-Feb-2026: FOE 
%   + File created.
%
%
%

%% Deal with options
opt.Ineg   = 'shift';   %Behaviour in case of negative intensities.
opt.Iref   = 'first50'; %From v1.3.0. Method to calculate I_{reference}.
                        %Watch out! This is I(t=0), not I_0!
opt.output = 'od';
if (exist('options','var') && isstruct(options))
    if isfield(options,'Ineg')
        opt.Ineg = lower(options.Ineg);
    end
    if isfield(options,'Iref')
        opt.Iref = lower(options.Iref);
    end
    if isfield(options,'output')
        opt.output = lower(options.output);
    end
end

if ~ismember(opt.output,{'od','a'})
    error('icnna:op:intensity2OD:InvalidParameterValue',...
          'Option .output must be either ''od'' or ''a''.');
end


%% Main body

%Work in matrix form is faster than doing so in tensor form,
%so transiently change to matrix form by "concatenating" the
%third axis.
[i,j,k] = size(I);
I = reshape(I,i,j*k);

% Check that absolute intensity does not reach zero or below zero
flagNegative = any(any(I <= 0));
if (flagNegative)
    warning('icnna:op:intensity2OD:NegativeIntensities',...
        ['Negative or zero intensities found. ' ...
         'Intensity corrected according to option .Ineg.'])
    switch (opt.Ineg)
        case 'shift' %ICNNA default behaviour
            tmpMin = min(min(I));
            I=I-tmpMin;
    
        case 'abs' %Homer 2/3 choice
            I=abs(I);
    
        case {'magnitude','real'}
            %Do nothing here.
            % This is to be corrected AFTER computing the logarithms

        case 'none'
            %Do nothing. Do NOT correct!

        otherwise
            error('icnna:op:intensity2OD:InvalidParameterValue',...
                'Invalid parameter value for option .Ineg.')
    end
end

% Decide on the reference Iref
k=min(50,size(I,1)); %By default, use the first 50 samples
      %as fOSA v2.2 to match previous behaviour
switch opt.Iref
    case 'first'
        k = 1;
    case 'first50' %Default.
        %Do nothing
    case 'mean' %This one matches Homer 2/3
        k = size(I,1);
    otherwise
        error('icnna:op:intensity2OD:InvalidParameterValue',...
            'Invalid parameter value for option .Iref.')
end
if ~isempty(I)
    Iref = mean(I(1:k,:),"omitnan");
else
    Iref = ones(1,nChannels);
end

% Calculate (\Delta) attenuations/optical densities
% \Delta A  =-log10 [I/Iref] = log10 [Iref/I]
% \Delta OD =-ln    [I/Iref] = ln    [Iref/I]
% \Delta OD = ln(10)\Delta A  <=> \Delta A = \Delta OD / ln(10)
Iref = repmat(Iref,nSamples,1);
if strcmp(opt.output,'od')
    dA = log(Iref./I);
else %'a'
    dA = log10(Iref./I);
end




if (flagNegative)
    switch (opt.Ineg)
        case {'shift','abs'}
            %Do nothing. Already corrected
    
        case 'magnitude' %Take the magnitude of the polar representation
            dA = abs(dA); %Note that abs of complex numbers is the magnitude.
    
        case 'real' %Take the real part of the Argand representation
            dA = real(dA);
    
        case 'none'
            %Do nothing. Do NOT correct!
    
        otherwise
            error('icnna:op:intensity2OD:InvalidParameterValue',...
                'Invalid parameter value for option .Ineg.')
    end
end




dA = reshape(dA,i,j,k); %Return to original shape


end