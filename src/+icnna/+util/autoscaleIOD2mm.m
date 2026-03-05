function [best_scaled, best_factor] = autoscaleIOD2mm(iod)
%Make an educated guess to convert IOD distances to millimeters
%
%   [best_scaled, best_factor] = icnna.util.autoscaleIOD2mm(iod)
%
%@channelLocationMap does NOT store the spatial units
%so I need to make an educated guess. Assume:
% 1) The expected correct scale in cm to be somewhere
% between a few millimeters e.g. 2mm, and several centimeters
% e.g., 60mm
% 2) There are more or equal number of long channels than there
%are short channels, and 
% 3) Distances in whatever units but will be in some metric units
%between nanometers and kilometers.
%
% Using the above, I can adjust the distances until the 
%majority of channels only has one figure is before the
%decimal point.
%
%% Input parameters
%
% iod - double[nChannels]
%       Inter optode distances in some unknown spatial units.
%
%% Output
%
% best_scaled - double[nChannels]
%       Best fit of inter optode distances in [mm] (given the
%       assumptions above)
% best_factor - Int
%       The best conversion factor.
%
%
% Copyright 2026
% @author: Felipe Orihuela-Espina
%
% See also 
%



%% Log
%
% 18-Feb-2026: FOE
%   + File created.
%

target_range = [2, 60]; % expected correct scale in mm

% Possible metric scale factors to convert unknown unit into cm
%
% Note that below ONLY a few plausible conversion factors (those in
% the SI units) are used rather than ALL possible factors between
% nanometers and kilometers. The rationale for restricting
% scale inference to discrete SI units is because it improves
% robustness and alleviate the risk of getting misleading
% results for several reasons:
%
%   1) Physical units are discrete:
%      Real-world measurements use specific SI units rather than arbitrary
%      powers of ten. Restricting the hypothesis space to nm, µm, mm, cm, m
%      and km ensures the inferred unit is interpretable and realistic.
%
%   2) Avoids false optima due to noise or outliers:
%      Testing for all exponents (e.g., 10^-12 to 10^+12) means that
%      random data fluctuations or outlier clusters could mistakenly
%      make an arbitrary exponent appear "optimal". Limiting the
%      estimations to valid SI units avoids selecting meaningless
%      or unstable scaling factors.
%
%   3) Ensures interpretability:
%      A chosen factor like "10^-2" is not meaningful as a standalone unit,
%      but "mm" or "m" is. Restricting the search ensures outputs correspond
%      to actual, understandable measurement units.
%
% The feasible units and their conversion factors to centimetres are:
%
%     Unit    |  Multiply by (to convert to cm)
%     --------+---------------------------------
%     nm      |  1e-6
%     µm      |  1e-3
%     mm      |  1
%     cm      |  10
%     m       |  1e3
%     km      |  1e6
%
% By evaluating only these scale factors and selecting the one that best
% aligns the distribution with the expected range (typically 0.2–6 cm),
% we obtain a stable, interpretable, and domain‑consistent scaling.
%
factors = [1e-6, 1e-3, 1, 10, 1e3, 1e6];
% Corresponding string labels (optional)
%units   = {'nm','um','mm','cm','m','km'};

best_score = -Inf;
best_factor = NaN;

for i = 1:length(factors)
    scaled = iod * factors(i);

    % Compute percentage in target range
    in_range = mean(scaled >= target_range(1) ...
                  & scaled <= target_range(2));

    % Reward: being > 10 mm
    above_one = mean(scaled > 10);

    % Combined score (tweakable)
    score = in_range + 0.2 * above_one;

    if score > best_score
        best_score = score;
        best_factor = factors(i);
    end
end

% Return the scaled version
best_scaled = iod * best_factor;

%fprintf('Chosen scaling factor = %g (assuming units were %s)\n', ...
%    best_factor, units{factors == best_factor});
end
