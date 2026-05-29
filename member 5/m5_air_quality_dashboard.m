function m5_air_quality_dashboard(t)

% =========================================
% Simulated CO2 + Temperature
% =========================================

% CO2 signal
co2 = 600 ...
    + 100*sin(2*pi*0.002*t) ...
    + 20*randn(size(t));

% Room temperature
room_temp = 22 ...
    + 0.5*sin(2*pi*0.001*t) ...
    + 0.1*randn(size(t));

% =========================================
% Alert Checks
% =========================================

co2_alert = any(co2 > 1000);

temp_alert = any(room_temp > 24 | room_temp < 20);

% =========================================
% GRAPH
% =========================================

figure('Name', 'M5: Air Quality Dashboard');

% -------- CO2 --------

subplot(2,1,1);

plot(t, co2, 'b');

hold on;

yline(1000, 'r--', 'CO2 Limit');

hold off;

xlabel('Time (s)');

ylabel('ppm');

title('Room CO2 Level');

grid on;

if co2_alert

    title('CO2 ALERT: HIGH CO2 LEVEL');

end

% -------- Temperature --------

subplot(2,1,2);

plot(t, room_temp, 'm');

hold on;

yline(24, 'r--', 'Upper Limit');

yline(20, 'b--', 'Lower Limit');

hold off;

xlabel('Time (s)');

ylabel('Degrees C');

title('Room Temperature');

grid on;

if temp_alert

    title('TEMPERATURE ALERT');

end

end