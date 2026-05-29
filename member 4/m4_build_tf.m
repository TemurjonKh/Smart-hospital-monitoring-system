function sys = m4_build_tf()
% M4_BUILD_TF  Drug infusion pump control loop — Laplace domain model
% No toolbox required.
%
% -----------------------------------------------------------------------
% HOSPITAL SCENARIO:
%   An IV drug infusion pump delivers medication at a controlled rate.
%   The patient's blood concentration C(t) must reach a target level
%   quickly and stay there without overshoot (overdose risk).
%
% LAPLACE TRANSFORM CONNECTION:
%   In the time domain, the drug concentration dynamics obey:
%       tau * dC/dt + C(t) = K * u(t)
%   where u(t) is the pump flow rate (input) and C(t) is concentration.
%
%   Taking the Laplace Transform (L{ dC/dt } = s*C(s)):
%       tau*s*C(s) + C(s) = K*U(s)
%       C(s)/U(s) = K / (tau*s + 1)       ← Plant G(s)
%
%   Parameters:
%       K   = 1   (steady-state concentration gain, normalised)
%       tau = 8   (pharmacokinetic time constant, seconds)
%
%   Plant:  G(s) = 1 / (8s + 1)
%
% PI CONTROLLER (eliminates steady-state error for step dose changes):
%   C(s) = Kp * (1 + 1/(Ti*s)) = (Kp*Ti*s + Kp) / (Ti*s)
%   With Kp=1, Ti=4:
%   C(s) = (s + 0.25) / s
%
% CLOSED-LOOP (negative feedback — sensor measures actual concentration):
%   T(s) = C(s)*G(s) / (1 + C(s)*G(s))
%        = num_ol / (den_ol + num_ol)    [polynomial addition]
% -----------------------------------------------------------------------

% Open-loop C(s)*G(s) = (s + 0.25) / (8s^2 + s)
num_ol = [1, 0.25];      % numerator
den_ol = [8, 1, 0];      % denominator

% Pad to equal length and compute closed-loop denominator
n      = max(length(num_ol), length(den_ol));
num_p  = [zeros(1, n - length(num_ol)), num_ol];
den_p  = [zeros(1, n - length(den_ol)), den_ol];

sys.num = num_p;
sys.den = den_p + num_p;   % T(s) denominator = den_ol + num_ol

fprintf('Drug infusion pump control TF built\n');
fprintf('  Plant G(s)      = 1 / (8s + 1)   [pharmacokinetic model]\n');
fprintf('  Controller C(s) = (s + 0.25) / s [PI, Kp=1 Ti=4]\n');
fprintf('  Closed-loop num : %s\n', mat2str(sys.num));
fprintf('  Closed-loop den : %s\n', mat2str(sys.den));

end