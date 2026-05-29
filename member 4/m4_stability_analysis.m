function m4_stability_analysis(sys)
% M4_STABILITY_ANALYSIS  Full stability analysis of drug infusion control loop
% No toolbox required.
%
% Computes and displays:
%   - Poles (stability check)
%   - DC gain (steady-state drug concentration)
%   - Steady-state error
%   - Gain margin and phase margin (from Bode plot)
%   - Step response (blood concentration tracking a target dose)
%   - Bode magnitude and phase plots
%   - Pole-zero map

%% ── Poles ────────────────────────────────────────────────────────────────
p = roots(sys.den);
fprintf('\n--- Laplace Stability Analysis: Drug Infusion Pump ---\n');
fprintf('Closed-loop poles:\n');
for k = 1:length(p)
    if imag(p(k)) ~= 0
        fprintf('  p%d = %.4f + %.4fj\n', k, real(p(k)), imag(p(k)));
    else
        fprintf('  p%d = %.4f\n', k, real(p(k)));
    end
end

if all(real(p) < 0)
    fprintf('System is STABLE — all poles in left half-plane\n');
    fprintf('  Clinical meaning: drug concentration converges to target\n');
else
    fprintf('System is UNSTABLE — concentration will oscillate or diverge (DANGEROUS)\n');
end

%% ── Steady-state analysis ────────────────────────────────────────────────
% DC gain = T(0) = num(0)/den(0)  [Final Value Theorem: lim s→0 of s*T(s)/s]
dc_gain = polyval(sys.num, 0) / polyval(sys.den, 0);
sse     = 1 - dc_gain;   % steady-state error for unit step input
fprintf('\nDC gain (steady-state concentration): %.4f\n', dc_gain);
fprintf('Steady-state error: %.4f  (%.1f%%)\n', sse, sse*100);
if abs(sse) < 0.01
    fprintf('  Clinical meaning: PI controller eliminates dosing error\n');
end

%% ── Frequency response ───────────────────────────────────────────────────
w_hz  = logspace(-4, 1, 2000);
w_rad = 2 * pi * w_hz;
H       = polyval(sys.num, 1j*w_rad) ./ polyval(sys.den, 1j*w_rad);
mag     = abs(H);
mag_db  = 20 * log10(mag + 1e-12);
phase_d = angle(H) * 180 / pi;

%% ── Gain margin ──────────────────────────────────────────────────────────
% Gain margin: how much gain can increase before instability
% Find frequency where phase = -180 deg
phase_cross_idx = find(diff(sign(phase_d + 180)));
if ~isempty(phase_cross_idx)
    idx_pc  = phase_cross_idx(1);
    gm_db   = -mag_db(idx_pc);
    w_pc_hz = w_hz(idx_pc);
    fprintf('\nGain margin  : %.2f dB  (at %.4f Hz)\n', gm_db, w_pc_hz);
else
    gm_db = Inf;
    fprintf('\nGain margin  : Inf (phase never crosses -180 deg)\n');
end

%% ── Phase margin ─────────────────────────────────────────────────────────
% Phase margin: how much phase lag before instability
% Find frequency where |H| = 1 (0 dB)
gain_cross_idx = find(diff(sign(mag_db)));
if ~isempty(gain_cross_idx)
    idx_gc  = gain_cross_idx(end);
    pm      = 180 + phase_d(idx_gc);
    w_gc_hz = w_hz(idx_gc);
    fprintf('Phase margin : %.2f deg  (at %.4f Hz)\n', pm, w_gc_hz);
    if pm > 45
        fprintf('  Good stability margin — safe for clinical use\n');
    elseif pm > 0
        fprintf('  WARNING: Low phase margin — system may oscillate\n');
    else
        fprintf('  DANGER: Negative phase margin — system is unstable\n');
    end
else
    pm = NaN;
    fprintf('Phase margin : N/A (gain never crosses 0 dB)\n');
end

%% ── Step response via Euler integration ──────────────────────────────────
a  = sys.den / sys.den(1);
b  = sys.num / sys.den(1);
b  = [zeros(1, length(a) - length(b)), b];

dt     = 0.01;
t_sim  = 0 : dt : 120;   % 2-minute window for drug concentration
order  = length(a) - 1;
w_st   = zeros(order, 1);
y_sim  = zeros(size(t_sim));

for k = 1:length(t_sim)
    w_new    = 1.0 - a(2:end) * w_st;
    y_sim(k) = b(2:end) * w_st + b(1) * w_new;
    w_st     = [w_new; w_st(1:end-1)];
end

% Find settling time (within 2% of final value)
final_val   = y_sim(end);
settled_idx = find(abs(y_sim - final_val) > 0.02 * final_val, 1, 'last');
if ~isempty(settled_idx) && settled_idx < length(t_sim)
    t_settle = t_sim(settled_idx);
    fprintf('\nSettling time (2%%): %.1f s\n', t_settle);
    fprintf('  Clinical meaning: drug reaches target concentration in %.0f seconds\n', t_settle);
end

%% ── Plots ─────────────────────────────────────────────────────────────────
figure('Name', 'M4: Drug Infusion Pump — Laplace Analysis');

% Bode magnitude
subplot(3,2,1);
semilogx(w_hz, mag_db, 'b', 'LineWidth', 1.2); grid on;
title('Bode Plot — Magnitude');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
yline(0, 'k--', '0 dB');

% Bode phase
subplot(3,2,2);
semilogx(w_hz, phase_d, 'r', 'LineWidth', 1.2); grid on;
title('Bode Plot — Phase');
xlabel('Frequency (Hz)'); ylabel('Phase (deg)');
yline(-180, 'k--', '-180 deg');

% Pole-zero map
subplot(3,2,3);
plot(real(p), imag(p), 'rx', 'MarkerSize', 12, 'LineWidth', 2.5);
hold on; xline(0,'k--'); yline(0,'k--'); hold off; grid on;
title('Pole-Zero Map');
xlabel('Real axis'); ylabel('Imaginary axis');

% Step response
subplot(3,2,[4 6]);
plot(t_sim, y_sim, 'b', 'LineWidth', 1.5); hold on;
yline(1.0,  'r--', 'Target concentration');
yline(0.98, 'g:',  '2% settling band');
yline(1.02, 'g:');
hold off; grid on;
title('Step Response — Drug Concentration Tracking');
xlabel('Time (s)'); ylabel('Concentration (normalised)');
xlim([0 120]);

% Summary text panel
subplot(3,2,5);
axis off;
text(0.05, 0.95, 'Stability Summary',   'FontWeight','bold','FontSize',11,'Units','normalized');
text(0.05, 0.80, sprintf('DC gain       : %.4f', dc_gain),   'FontSize',10,'Units','normalized');
text(0.05, 0.65, sprintf('SS error      : %.2f%%', sse*100), 'FontSize',10,'Units','normalized');
if ~isinf(gm_db)
    text(0.05, 0.50, sprintf('Gain margin   : %.1f dB', gm_db),  'FontSize',10,'Units','normalized');
else
    text(0.05, 0.50, 'Gain margin   : Inf',                       'FontSize',10,'Units','normalized');
end
if ~isnan(pm)
    text(0.05, 0.35, sprintf('Phase margin  : %.1f deg', pm),     'FontSize',10,'Units','normalized');
end
if exist('t_settle','var')
    text(0.05, 0.20, sprintf('Settling time : %.1f s', t_settle), 'FontSize',10,'Units','normalized');
end
stable_str = 'STABLE';
if ~all(real(p) < 0); stable_str = 'UNSTABLE'; end
text(0.05, 0.05, sprintf('Status        : %s', stable_str), ...
    'FontSize',10,'Units','normalized','FontWeight','bold');

end