function temp_prediction(a)
% TEMP_PREDICTION Temperature rate monitoring and 5-minute prediction
%   TEMP_PREDICTION(a) continuously reads temperature from an MCP 9700A
%   sensor on Arduino analog pin A0. It calculates the rate of temperature
%   change using a moving average over the last 30 samples to reduce noise.
%   The function predicts the temperature expected in 5 minutes assuming a
%   constant rate. LED indicators show: green (D9) for stable comfort range,
%   red (D11) for rate > +4°C/min, yellow (D10) for rate < -4°C/min.
%   Input: a - Arduino object created with arduino() function.

% Sensor parameters (MCP 9700A)
V0 = 0.5;     % Zero-degree voltage (V)
TC = 0.01;     % Temperature coefficient (V/°C)

% Rate threshold: 4°C/min converted to °C/s
rate_threshold = 4 / 60;  % = 0.0667 °C/s

% LED pin assignments
greenPin = 'D9';
yellowPin = 'D10';
redPin = 'D11';

% Ensure all LEDs are OFF initially
writeDigitalPin(a, greenPin, 0);
writeDigitalPin(a, yellowPin, 0);
writeDigitalPin(a, redPin, 0);

% Parameters for moving average smoothing
window_size = 30;  % Number of samples for moving average (30 seconds window)

% Initialise data storage
time_data = [];
temp_data = [];

% Main prediction loop - runs indefinitely
tic;  % Start timer

while true
    % Read current temperature
    voltage = readVoltage(a, 'A0');
    current_temp = (voltage - V0) / TC;
    elapsed_time = toc;
    
    % Store data
    time_data(end+1) = elapsed_time;
    temp_data(end+1) = current_temp;
    n = length(temp_data);
    
    % Calculate rate of temperature change using moving average
    if n >= 2
        if n >= window_size
            % Use moving average over the last 'window_size' samples
            % to smooth out short-term noise spikes
            recent_temps = temp_data(end-window_size+1:end);
            recent_times = time_data(end-window_size+1:end);
            
            % Linear regression over the window for robust rate estimation
            % rate = slope of best-fit line through recent data
            p = polyfit(recent_times, recent_temps, 1);
            rate_per_sec = p(1);  % Temperature change rate in °C/s
        else
            % Not enough data yet - use simple difference
            dt = time_data(end) - time_data(1);
            dT = temp_data(end) - temp_data(1);
            if dt > 0
                rate_per_sec = dT / dt;
            else
                rate_per_sec = 0;
            end
        end
    else
        rate_per_sec = 0;  % First sample - no rate available
    end
    
    % Convert rate to °C/min for display and threshold comparison
    rate_per_min = rate_per_sec * 60;
    
    % Predict temperature in 5 minutes (300 seconds)
    predicted_temp = current_temp + rate_per_sec * 300;
    
    % Display current status to screen
    fprintf('Time: %.0fs | Current Temp: %.2f°C | Rate: %.3f°C/min | Predicted (5min): %.2f°C\n', ...
        elapsed_time, current_temp, rate_per_min, predicted_temp);
    
    % LED control based on rate of change
    if rate_per_min > 4
        % Temperature increasing too fast - constant red LED
        writeDigitalPin(a, greenPin, 0);
        writeDigitalPin(a, yellowPin, 0);
        writeDigitalPin(a, redPin, 1);
        
    elseif rate_per_min < -4
        % Temperature decreasing too fast - constant yellow LED
        writeDigitalPin(a, greenPin, 0);
        writeDigitalPin(a, yellowPin, 1);
        writeDigitalPin(a, redPin, 0);
        
    else
        % Temperature stable within comfort range - constant green LED
        writeDigitalPin(a, greenPin, 1);
        writeDigitalPin(a, yellowPin, 0);
        writeDigitalPin(a, redPin, 0);
    end
    
    pause(1);  % Wait approximately 1 second before next reading
end

end
