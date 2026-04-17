% Liyu MA
% liyu.ma@nottingham.edu.cn
% AERO1005 Coursework 2 - Solving Engineering Problems with a Programming Language
% Student ID: 20721363

%% PRELIMINARY TASK - Arduino and Git Installation
% Establish communication with Arduino
% NOTE: Change 'COM3' to your actual port (check Device Manager on Windows or ls /dev/tty.* on Mac)
a = arduino('COM3', 'Uno');

% LED Blink Test - Blink an LED on digital pin D13 at 0.5s intervals
for i = 1:10
    writeDigitalPin(a, 'D13', 1);  % Turn LED ON
    pause(0.5);                      % Wait 0.5 seconds
    writeDigitalPin(a, 'D13', 0);  % Turn LED OFF
    pause(0.5);                      % Wait 0.5 seconds
end

%% TASK 1 - Read Temperature Data, Plot, and Write to a Log File

% Task 1a) Temperature sensor connected to analog pin A0
% MCP 9700A sensor: V0 = 0.5V, TC = 0.01 V/°C
% Temperature = (Voltage - V0) / TC

% Task 1b) Data acquisition for 600 seconds (10 minutes)
duration = 600;  % Acquisition time in seconds
V0 = 0.5;        % Zero-degree voltage for MCP 9700A (V)
TC = 0.01;        % Temperature coefficient for MCP 9700A (V/°C)

% Pre-allocate arrays for efficiency
time_data = zeros(1, duration);          % Time array (seconds)
voltage_data = zeros(1, duration);       % Raw voltage readings
temperature_data = zeros(1, duration);   % Converted temperature values

% Data acquisition loop - read once per second for 10 minutes
for i = 1:duration
    voltage_data(i) = readVoltage(a, 'A0');                % Read voltage from sensor
    temperature_data(i) = (voltage_data(i) - V0) / TC;    % Convert to temperature (°C)
    time_data(i) = i - 1;                                   % Time in seconds (0 to 599)
    pause(1);                                                % Wait approximately 1 second
end

% Calculate statistical quantities
min_temp = min(temperature_data);    % Minimum temperature
max_temp = max(temperature_data);    % Maximum temperature
avg_temp = mean(temperature_data);   % Average temperature

% Task 1c) Plot temperature vs time
figure('Name', 'Capsule Temperature Log');
plot(time_data, temperature_data, 'b-', 'LineWidth', 1.2);
xlabel('Time (s)');
ylabel('Temperature (\circC)');
title('Capsule Temperature Over 10-Minute Journey');
grid on;
saveas(gcf, 'temperature_plot.png');  % Save plot as image

% Task 1d) Print formatted data to screen using sprintf
fprintf('\n');
fprintf('Data logging initiated - %s\n', datestr(now, 'dd/mm/yyyy'));
fprintf('Location - Nottingham\n\n');

% Print temperature at each minute (0, 60, 120, ..., 600 seconds)
for min_idx = 0:10
    sample_idx = min_idx * 60 + 1;  % Index in data array
    if sample_idx > length(temperature_data)
        sample_idx = length(temperature_data);
    end
    if min_idx < 10
        fprintf('Minute \t%d\tTemperature \t%.2f \circC\n\n', min_idx, temperature_data(sample_idx));
    else
        fprintf('Minute \t%d\tTemperature \t%.2f \circC\n\n', min_idx, temperature_data(sample_idx));
    end
end

fprintf('Max temp\t%.2f \circC\n', max_temp);
fprintf('Min temp\t%.2f \circC\n', min_temp);
fprintf('Average temp\t%.2f \circC\n\n', avg_temp);
fprintf('Data logging terminated\n');

% Task 1e) Write the same data to a log file
fid = fopen('capsule_temperature.txt', 'w');  % Open file with write permission

fprintf(fid, 'Data logging initiated - %s\n', datestr(now, 'dd/mm/yyyy'));
fprintf(fid, 'Location - Nottingham\n\n');

for min_idx = 0:10
    sample_idx = min_idx * 60 + 1;
    if sample_idx > length(temperature_data)
        sample_idx = length(temperature_data);
    end
    fprintf(fid, 'Minute \t%d\tTemperature \t%.2f \circC\n\n', min_idx, temperature_data(sample_idx));
end

fprintf(fid, 'Max temp\t%.2f \circC\n', max_temp);
fprintf(fid, 'Min temp\t%.2f \circC\n', min_temp);
fprintf(fid, 'Average temp\t%.2f \circC\n\n', avg_temp);
fprintf(fid, 'Data logging terminated\n');

fclose(fid);  % Close the file

% Verify the file was written correctly by reading it back
fid_check = fopen('capsule_temperature.txt', 'r');
file_content = fread(fid_check, '*char')';
disp('--- Verifying log file content ---');
disp(file_content);
fclose(fid_check);

%% TASK 2 - LED Temperature Monitoring Device
% LED connections:
%   Green LED  -> Digital pin D9
%   Yellow LED -> Digital pin D10
%   Red LED    -> Digital pin D11
% Call the temp_monitor function, passing the Arduino object
temp_monitor(a);

%% TASK 3 - Temperature Prediction
% Call the temp_prediction function, passing the Arduino object
temp_prediction(a);

%% TASK 4 - Reflective Statement
% See Word document submission template

%% AI USAGE DISCLOSURE
% The Matlab copilot tool was used for debugging syntax errors during development.
% No AI was used to generate the core logic or algorithms.
