function m4_stability_analysis(sys)

% MEMBER 4
% Stability + Frequency Analysis

% -----------------------------------------
% Pole Calculation
% -----------------------------------------

p = pole(sys);

fprintf('\nSystem poles:\n');

disp(p);

% -----------------------------------------
% Stability Check
% -----------------------------------------

if all(real(p) < 0)

    fprintf('System is STABLE\n');

else

    fprintf('System is UNSTABLE\n');

end

% -----------------------------------------
% Plotting
% -----------------------------------------

figure('Name', 'M4: Laplace Stability Analysis');

% -------- Bode Plot --------
subplot(2,2,[1 2]);

bode(sys);

grid on;

title('Bode Plot');

% -------- Pole-Zero Map --------
subplot(2,2,3);

pzmap(sys);

grid on;

title('Pole-Zero Map');

% -------- Step Response --------
subplot(2,2,4);

step(sys);

grid on;

title('Step Response');

end