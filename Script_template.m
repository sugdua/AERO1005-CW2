% Liyu MA
% ssylm3@nottingham.edu.cn
% AERO1005 Coursework 2

%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [5 MARKS]
clear a
% Auto-detect Arduino port (works on both Mac and Windows)
ports = serialportlist("available");
% Filter: on Mac look for usbserial, on Windows look for COM
arduino_port = "";
for p = ports
    if contains(p, "usbserial") || contains(p, "COM")
        arduino_port = p;
        break;
    end
end
if arduino_port == ""
    error('No Arduino found. Check USB connection.');
end
a = arduino(arduino_port, 'Uno');

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

% Task 1b) Data acquisition for 600 seconds
duration = 600;  % Acquisition time in seconds
V0 = 0.5;        % Zero-degree voltage for temperature sensor MCP 9700A (V)
TC = 0.01;        % Temperature coefficient for temperature sensor MCP 9700A (V/°C)

% Pre-allocate the array to store data
time_data = zeros(1, duration);          % Time array in seconds
voltage_data = zeros(1, duration);       % Raw voltage getting from sensor
temperature_data = zeros(1, duration);   % Converted temperature values in °C

% The data acquisition loop reads the sensor once every second
for i = 1:duration
    voltage_data(i) = readVoltage(a, 'A0');                % Read voltage from A0
    temperature_data(i) = (voltage_data(i) - V0) / TC;    % Convert voltage to temperature
    time_data(i) = i - 1;                                   % Time in seconds (0 to 599)
    pause(1);                                                % Wait 1 second
end

% Calculate statistical quantities over the full dataset
min_temp = min(temperature_data);    % Minimum temperature recorded
max_temp = max(temperature_data);    % Maximum temperature recorded
avg_temp = mean(temperature_data);   % Average temperature over 10 minutes

% Task 1c) Create and save the temperature vs time chart
figure('Name', 'Temperature record of the space capsule');
plot(time_data, temperature_data, 'b-', 'LineWidth', 1.0);
xlabel('Time (s)');
ylabel('Temperature (\circC)');
title('Temperature inside the space capsule during the ten-minute journey');
grid on;
saveas(gcf, 'temperature_plot.png');  % Save plot as image file

% Task 1d) Print formatted data to screen using sprintf/fprintf
fprintf('\n');
msg1=sprintf('Data logging initiated - %s\n', datestr(now, 'dd/mm/yyyy'));
disp(msg1)
msg2=sprintf('Location - Nottingham\n\n');
disp(msg2)
fprintf('\n');
% Print temperature at each minute (at 0s, 60s, 120s, ..., 600s)
for min_idx = 0:10
    sample_idx = min_idx * 60 + 1;  % Calculate index in data array
    if sample_idx > length(temperature_data)
        sample_idx = length(temperature_data);  % Prevent out-of-bounds
    end
    msg3=sprintf('Minute \t%d\tTemperature \t%.2f °C\n\n', min_idx, temperature_data(sample_idx));
    disp(msg3)
    fprintf('\n');
end

% Print summary statistics
msg4=sprintf('Max temp\t%.2f °C\n', max_temp);
disp(msg4)
msg5=sprintf('Min temp\t%.2f °C\n', min_temp);
disp(msg5)
msg6=sprintf('Average temp\t%.2f °C\n\n', avg_temp);
disp(msg6)
msg7=sprintf('Data logging terminated\n');
disp(msg7)

% Task 1e) Write formatted data to a log file
fid = fopen('capsule_temperature.txt', 'w');  % Open file with write permission

fprintf(fid, 'Data logging initiated - %s\n', datestr(now, 'dd/mm/yyyy'));
fprintf(fid, 'Location - Nottingham\n\n');

for min_idx = 0:10
    sample_idx = min_idx * 60 + 1;
    if sample_idx > length(temperature_data)
        sample_idx = length(temperature_data);
    end
    fprintf(fid, 'Minute \t%d\tTemperature \t%.2f °C\n\n', min_idx, temperature_data(sample_idx));
end

fprintf(fid, 'Max temp\t%.2f °C\n', max_temp);
fprintf(fid, 'Min temp\t%.2f °C\n', min_temp);
fprintf(fid, 'Average temp\t%.2f °C\n\n', avg_temp);
fprintf(fid, 'Data logging terminated\n');

fclose(fid);  % Close the log file

% Verify log file was written correctly by reading it back
fid_check = fopen('capsule_temperature.txt', 'r');
file_content = fread(fid_check, '*char')';  % Read entire file as string
disp('--- Verifying log file content ---');
disp(file_content);
fclose(fid_check);
%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]

% Insert answers here


%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [30 MARKS]

% Insert answers here


%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

% Insert answers here
