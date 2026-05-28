function sys = m4_build_tf()

% MEMBER 4
% Hospital Temperature Control System
% Transfer Function + PI Controller

% -----------------------------------------
% Plant:
% G(s) = 1 / (10s + 1)
% -----------------------------------------

num_plant = [1];

den_plant = [10 1];

G = tf(num_plant, den_plant);

% -----------------------------------------
% PI Controller:
% C(s) = (s + 0.5) / s
% -----------------------------------------

num_ctrl = [1 0.5];

den_ctrl = [1 0];

C = tf(num_ctrl, den_ctrl);

% -----------------------------------------
% Closed-loop system
% T(s) = feedback(C*G,1)
% -----------------------------------------

sys = feedback(C * G, 1);

fprintf('Transfer function built successfully\n');

disp('Closed-loop transfer function:');

sys

end