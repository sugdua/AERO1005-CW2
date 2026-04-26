function temp_prediction(a, pred_duration)
% TEMP_PREDICTION Temperature rate monitoring and 5-minute prediction
%   Reads MCP 9700A sensor on A0, calculates rate of change using
%   30-sample moving average (linear regression), predicts temp in 5 min.
%   Green (D10): stable rate within +/-4 C/min
%   Red (D4): rate > +4 C/min (heating too fast)
%   Yellow (D7): rate < -4 C/min (cooling too fast)
%   Stops automatically after pred_duration seconds (default 300 s)
%   Usage: temp_prediction(a)        -> runs for 300 s
%          temp_prediction(a, 180)   -> runs for 180 s

% Set default duration
    if nargin < 2
        pred_duration = 300;   %Can change the duration here
    end
V0 = 0.5;
TC = 0.01;
window_size = 30;  %Sliding window size(30 points)

greenPin = 'D10';
yellowPin = 'D7';
redPin = 'D4'; %The name replaces the port number, making it easier to modify

% Turn off all LEDs
writeDigitalPin(a, greenPin, 0);
writeDigitalPin(a, yellowPin, 0);
writeDigitalPin(a, redPin, 0);

time_data = [];   %Array for storage of time data
temp_data = [];   %Array for storage of temperature data

tic;

while true <= pred_duration  %The while cycle of time limits
    % Read temperature
    voltage = readVoltage(a, 'A0');
    current_temp = (voltage - V0) / TC;
    elapsed = toc;
    
    time_data(end+1) = elapsed;
    temp_data(end+1) = current_temp;
    n = length(temp_data); %Data length
    
    % Calculate rate of change
    if n >= window_size
        % Linear regression over last 30 samples
        recent_t = time_data(end-window_size+1:end);
        recent_T = temp_data(end-window_size+1:end);
        p = polyfit(recent_t, recent_T, 1);
        rate_per_sec = p(1);  %Slope temp/second
    elseif n >= 2
        % Simple difference for early samples
        dt = time_data(end) - time_data(1);
        dT = temp_data(end) - temp_data(1);
        if dt > 0
            rate_per_sec = dT / dt;
        else
            rate_per_sec = 0;
        end
    else
        rate_per_sec = 0;
    end
    
    rate_per_min = rate_per_sec * 60; %Convert to min
    predicted_temp = current_temp + rate_per_sec * 300;  % 5 min ahead
    
    fprintf('Time: %5.0f s | Temp: %7.2f C | Rate: %8.3f C/min | Predicted: %7.2f C\n', ...
    elapsed, current_temp, rate_per_min, predicted_temp);
   
    % LED control based on rate
    if rate_per_min > 4
        writeDigitalPin(a, greenPin, 0);
        writeDigitalPin(a, yellowPin, 0);
        writeDigitalPin(a, redPin, 1);     % Heating too fast - LED red on
    elseif rate_per_min < -4
        writeDigitalPin(a, greenPin, 0);
        writeDigitalPin(a, yellowPin, 1);
        writeDigitalPin(a, redPin, 0);     % Cooling too fast - LED yellow on
    else
        writeDigitalPin(a, greenPin, 1);
        writeDigitalPin(a, yellowPin, 0);
        writeDigitalPin(a, redPin, 0);     % Stable - LED green on
    end
    
    pause(1);
end
%Turn off all the LED lights
    writeDigitalPin(a, greenPin, 0);
    writeDigitalPin(a, yellowPin, 0);
    writeDigitalPin(a, redPin, 0);
    disp('Task 3 prediction finished.');
end
