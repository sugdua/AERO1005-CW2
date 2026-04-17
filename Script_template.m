% Liyu MA
% ssylm3@nottingham.edu.cn


%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [5 MARKS]
clear a
a = arduino('/dev/tty.usbserial-1110', 'Uno');

% Test single LED on digital pin D10
writeDigitalPin(a, 'D10', 1);

% LED Blink Test - Blink LED at 0.5s intervals (0.5s ON, 0.5s OFF)
for i = 1:10
    writeDigitalPin(a, 'D10', 1);  % Turn LED ON
    pause(0.5);                      % Wait 0.5 seconds
    writeDigitalPin(a, 'D10', 0);  % Turn LED OFF
    pause(0.5);                      % Wait 0.5 seconds
end


%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]

% Task 1a) Temperature sensor connected to analog pin A0
% MCP 9700A sensor specifications:
%   V0 = 0.5V (zero-degree voltage)
%   TC = 0.01 V/°C (temperature coefficient)
%   Temperature formula: T = (V - V0) / TC

% Task 1b) Data acquisition for 600 seconds (10 minutes)
duration = 600;  % Acquisition time in seconds
V0 = 0.5;        % Zero-degree voltage for MCP 9700A (V)
TC = 0.01;        % Temperature coefficient for MCP 9700A (V/°C)

% Pre-allocate arrays for storing acquired data
time_data = zeros(1, duration);          % Time array in seconds
voltage_data = zeros(1, duration);       % Raw voltage readings from sensor
temperature_data = zeros(1, duration);   % Converted temperature values in °C

% Data acquisition loop - read sensor approximately every 1 second
for i = 1:duration
    voltage_data(i) = readVoltage(a, 'A0');                % Read voltage from A0
    temperature_data(i) = (voltage_data(i) - V0) / TC;    % Convert voltage to temperature
    time_data(i) = i - 1;                                   % Time in seconds (0 to 599)
    pause(1);                                                % Wait approximately 1 second
end

% Calculate statistical quantities over the full dataset
min_temp = min(temperature_data);    % Minimum temperature recorded
max_temp = max(temperature_data);    % Maximum temperature recorded
avg_temp = mean(temperature_data);   % Average temperature over 10 minutes

% Task 1c) Create temperature vs time plot with labelled axes
figure('Name', 'Capsule Temperature Log');
plot(time_data, temperature_data, 'b-', 'LineWidth', 1.2);
xlabel('Time (s)');
ylabel('Temperature (\circC)');
title('Capsule Temperature Over 10-Minute Journey');
grid on;
saveas(gcf, 'temperature_plot.png');  % Save plot as image file

% Task 1d) Print formatted data to screen using sprintf/fprintf
% Output follows the format specified in Table 1 of the coursework brief
fprintf('\n');
fprintf('Data logging initiated - %s\n', datestr(now, 'dd/mm/yyyy'));
fprintf('Location - Nottingham\n\n');

% Print temperature at each minute (at 0s, 60s, 120s, ..., 600s)
for min_idx = 0:10
    sample_idx = min_idx * 60 + 1;  % Calculate index in data array
    if sample_idx > length(temperature_data)
        sample_idx = length(temperature_data);  % Prevent out-of-bounds
    end
    fprintf('Minute \t%d\tTemperature \t%.2f \circC\n\n', min_idx, temperature_data(sample_idx));
end

% Print summary statistics
fprintf('Max temp\t%.2f \circC\n', max_temp);
fprintf('Min temp\t%.2f \circC\n', min_temp);
fprintf('Average temp\t%.2f \circC\n\n', avg_temp);
fprintf('Data logging terminated\n');

% Task 1e) Write formatted data to a log file
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

fclose(fid);  % Close the log file

% Verify log file was written correctly by reading it back
fid_check = fopen('capsule_temperature.txt', 'r');
file_content = fread(fid_check, '*char')';  % Read entire file as string
disp('--- Verifying log file content ---');
disp(file_content);
fclose(fid_check);


%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]

% LED connections on breadboard:
%   Green LED  -> Digital pin D9  (comfort range indicator)
%   Yellow LED -> Digital pin D10 (below range indicator)
%   Red LED    -> Digital pin D11 (above range indicator)
% Each LED has a 220 Ohm resistor in series to limit current

% Call the temp_monitor function, passing the Arduino object
% The function runs indefinitely - press Ctrl+C to stop
temp_monitor(a);


%% TASK 3 - ALGORITHMS - TEMPERATURE PREDICTION [30 MARKS]

% Call the temp_prediction function, passing the Arduino object
% The function continuously calculates temperature rate and predicts
% the temperature expected in 5 minutes
% Press Ctrl+C to stop
temp_prediction(a);


%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

% See Word document submission template (AERO1005_CW2_Submission.docx)
% The reflective statement discusses challenges, strengths, limitations,
% and suggested future improvements of the project.

%% AI USAGE DISCLOSURE
% The Matlab copilot tool was used for debugging syntax errors during
% development, specifically for fprintf formatting issues.
% No AI was used to generate the core logic or algorithms.
