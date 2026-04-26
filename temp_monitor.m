function temp_monitor(a, monitor_duration)
% TEMP_MONITOR Real-time temperature monitoring with LED indicators
%   Reads MCP 9700A sensor on A0, displays live plot, controls LEDs:
%   Green (D10): constant ON when 18-24 °C (comfort range)
%   Yellow (D7): blinks 0.5s when below 18 °C
%   Red (D4): blinks 0.25s when above 24 °C
%   Stop automatically after motor_duration seconds (default 600 s)
%   Usage: temp_monitor(a)        -> runs for 600 s
%          temp_monitor(a, 300)   -> runs for 300 s

% Set default duration
    if nargin < 2
        monitor_duration = 30;   %Can change the duration here
    end

V0 = 0.5;
TC = 0.01;
T_low = 18;
T_high = 24;

greenPin = 'D10'; 
yellowPin = 'D7';
redPin = 'D4';  %The name replaces the port number, making it easier to modify

% Turn off all LEDs first
writeDigitalPin(a, greenPin, 0);
writeDigitalPin(a, yellowPin, 0);
writeDigitalPin(a, redPin, 0);

% Set up live plot
time_data = []; %Array for storage of time data
temp_data = []; %Array for storage of temperature data
figure('Name', 'Live Temperature Monitor');
h = plot(0, 0, 'b-', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Temperature (\circC)');
title('Real-Time Capsule Temperature');
grid on; %Display grid lines

tic

while toc<= monitor_duration
    % Read temperature
    voltage = readVoltage(a, 'A0');
    current_temp = (voltage - V0) / TC; %Transfer voltage to temperature
    elapsed = toc; %Obtain the running time
    
    % Store data
    time_data(end+1) = elapsed;
    temp_data(end+1) = current_temp;
    
    % Update plot
    set(h, 'XData', time_data, 'YData', temp_data);
    xlim([0, max(elapsed + 10, 60)]); %X-axis dynamic range
    ylim([min(temp_data) - 2, max(temp_data) + 2]); %Y-axis dynamic range
    drawnow; %Force refresh
    
    % LED control
    if current_temp >= T_low && current_temp <= T_high
        % Comfort range - green constant
        writeDigitalPin(a, greenPin, 1); 
        writeDigitalPin(a, yellowPin, 0);
        writeDigitalPin(a, redPin, 0);
        pause(1);
        
    elseif current_temp < T_low
        % Too cold - yellow blink 0.5s
        writeDigitalPin(a, greenPin, 0);
        writeDigitalPin(a, redPin, 0);
        writeDigitalPin(a, yellowPin, 1); %The yellow light flashes once for a total of 1 second
        pause(0.5);
        writeDigitalPin(a, yellowPin, 0);
        pause(0.5);
        
    else
        % Too hot - red blink 0.25s
        writeDigitalPin(a, greenPin, 0);
        writeDigitalPin(a, yellowPin, 0);
        writeDigitalPin(a, redPin, 1); %The red light flashes twice for a total of 1 second
        pause(0.25);
        writeDigitalPin(a, redPin, 0);
        pause(0.25);
        writeDigitalPin(a, redPin, 1);
        pause(0.25);
        writeDigitalPin(a, redPin, 0);
        pause(0.25);
    end
end
% Turn off all the LED lights to facilitate the start of task 3.
    writeDigitalPin(a, greenPin, 0);
    writeDigitalPin(a, yellowPin, 0);
    writeDigitalPin(a, redPin, 0);
    disp('Task 2 monitoring finished.');
end
