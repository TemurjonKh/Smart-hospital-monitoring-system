function sys = m4_build_tf()
    % Build a transfer function for hospital temperature control loop
    % Model: room heating system with sensor lag and PI controller
    %
    % Plant (room thermal dynamics): G(s) = 1 / (10s + 1)
    %   — first-order system, time constant = 10 seconds
    %
    % PI Controller: C(s) = (s + 0.5) / s
    %   — adds integral action for zero steady-state error
    %
    % Closed-loop: T(s) = C(s)*G(s) / (1 + C(s)*G(s))

    num_plant = [1];                         % numerator of G(s)
    den_plant = [10 1];                      % denominator: 10s + 1
    G = tf(num_plant, den_plant);            % plant transfer function

    num_ctrl = [1 0.5];                      % numerator of C(s): s + 0.5
    den_ctrl = [1 0];                        % denominator: s (integrator)
    C = tf(num_ctrl, den_ctrl);              % PI controller

    % Closed-loop system using negative feedback
    sys = feedback(C * G, 1);

    fprintf('Transfer function built: Hospital temp control loop\n');
    sys                                      % display tf in command window
end

function m4_stability_analysis(sys)
    % Perform full stability and frequency-domain analysis
    % Plots: Bode plot, pole-zero map, step response

    p = pole(sys);                           % get poles of closed-loop system
    is_stable = all(real(p) < 0);           % stable if all poles in left half-plane

    if is_stable
        fprintf('System is STABLE — all poles in left half-plane\n');
    else
        fprintf('System is UNSTABLE — pole(s) in right half-plane\n');
    end

    figure('Name', 'M4: Laplace Stability Analysis');

    % --- Bode Plot ---
    subplot(2,2,[1 2]);
    bode(sys); grid on;
    title('Bode Plot — Temperature Control Loop');

    % --- Pole-Zero Map ---
    subplot(2,2,3);
    pzmap(sys); grid on;
    title('Pole-Zero Map');

    % --- Step Response ---
    subplot(2,2,4);
    step(sys); grid on;
    title('Step Response (Set-Point Change)');
end
