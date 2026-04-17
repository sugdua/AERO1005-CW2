function temp_monitor(a)
% TEMP_MONITOR Real-time temperature monitoring with LED indicators
%   TEMP_MONITOR(a) continuously monitors temperature using an MCP 9700A
%   sensor connected to Arduino analog pin A0. It displays a live-updating
%   temperature plot and controls three LEDs based on the comfort range
%   of 18-24°C. Green LED (D9) shows constant light when temperature is
%   in range. Yellow LED (D10) blinks at 0.5s intervals when below range.
%   Red LED (D11) blinks at 0.25s intervals when above range. The function
%   runs indefinitely until manually stopped with Ctrl+C.
%   Input: a - Arduino object created with arduino() function.

% Sensor parameters (MCP 9700A)
V0 = 0.5;     % Zero-degree voltage (V)
TC = 0.01;     % Temperature coefficient (V/°C)

% Comfort temperature range
T_low = 18;    % Lower bound (°C)
T_high = 24;   % Upper bound (°C)

% LED pin assignments
greenPin = 'D9';
yellowPin = 'D10';
redPin = 'D11';

% Ensure all LEDs are OFF initially
writeDigitalPin(a, greenPin, 0);
writeDigitalPin(a, yellowPin, 0);
writeDigitalPin(a, redPin, 0);

% Initialise data arrays and figure for live plotting
time_data = [];
temp_data = [];
figure('Name', 'Live Temperature Monitor');
h = plot(0, 0, 'b-', 'LineWidth', 1.5);  % Create plot handle for updating
xlabel('Time (s)');
ylabel('Temperature (\circC)');
title('Real-Time Capsule Temperature');
grid on;

% Add comfort range reference lines
hold on;
yline(T_low, '--g', '18\circC', 'LineWidth', 1);
yline(T_high, '--r', '24\circC', 'LineWidth', 1);
hold off;

% Main monitoring loop - runs indefinitely
cycle = 0;
tic;  % Start timer for accurate timing

while true
    cycle = cycle + 1;
    
    % Read temperature from sensor
    voltage = readVoltage(a, 'A0');
    current_temp = (voltage - V0) / TC;
    elapsed_time = toc;  % Get elapsed time since start
    
    % Append new data to arrays
    time_data(end+1) = elapsed_time;
    temp_data(end+1) = current_temp;
    
    % Update live plot
    set(h, 'XData', time_data, 'YData', temp_data);
    xlim([0, max(elapsed_time + 10, 60)]);  % Dynamic x-axis scaling
    ylim([min(temp_data) - 2, max(temp_data) + 2]);  % Dynamic y-axis scaling
    drawnow;  % Force graph update
    
    % LED control based on temperature
    if current_temp >= T_low && current_temp <= T_high
        % Temperature in comfort range - green LED constant ON
        writeDigitalPin(a, greenPin, 1);
        writeDigitalPin(a, yellowPin, 0);
        writeDigitalPin(a, redPin, 0);
        pause(1);  % Standard 1-second interval
        
    elseif current_temp < T_low
        % Temperature below range - yellow LED blinks at 0.5s intervals
        writeDigitalPin(a, greenPin, 0);
        writeDigitalPin(a, redPin, 0);
        writeDigitalPin(a, yellowPin, 1);   % Yellow ON
        pause(0.5);
        writeDigitalPin(a, yellowPin, 0);   % Yellow OFF
        pause(0.5);
        
    else
        % Temperature above range - red LED blinks at 0.25s intervals
        writeDigitalPin(a, greenPin, 0);
        writeDigitalPin(a, yellowPin, 0);
        writeDigitalPin(a, redPin, 1);      % Red ON
        pause(0.25);
        writeDigitalPin(a, redPin, 0);      % Red OFF
        pause(0.25);
        writeDigitalPin(a, redPin, 1);      % Red ON (second blink within 1s)
        pause(0.25);
        writeDigitalPin(a, redPin, 0);      % Red OFF
        pause(0.25);
    end
end

end
