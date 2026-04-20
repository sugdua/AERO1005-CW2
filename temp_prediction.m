function temp_prediction(a)
% TEMP_PREDICTION Temperature rate monitoring and 5-minute prediction
%   Reads MCP 9700A sensor on A0, calculates rate of change using
%   30-sample moving average (linear regression), predicts temp in 5 min.
%   Green (D10): stable rate within +/-4 C/min
%   Red (D4): rate > +4 C/min (heating too fast)
%   Yellow (D7): rate < -4 C/min (cooling too fast)
%   Stop with Ctrl+C

V0 = 0.5;
TC = 0.01;
window_size = 30;

greenPin = 'D10';
yellowPin = 'D7';
redPin = 'D4';

% Turn off all LEDs
writeDigitalPin(a, greenPin, 0);
writeDigitalPin(a, yellowPin, 0);
writeDigitalPin(a, redPin, 0);

time_data = [];
temp_data = [];

tic;

while true
    % Read temperature
    voltage = readVoltage(a, 'A0');
    current_temp = (voltage - V0) / TC;
    elapsed = toc;
    
    time_data(end+1) = elapsed;
    temp_data(end+1) = current_temp;
    n = length(temp_data);
    
    % Calculate rate of change
    if n >= window_size
        % Linear regression over last 30 samples
        recent_t = time_data(end-window_size+1:end);
        recent_T = temp_data(end-window_size+1:end);
        p = polyfit(recent_t, recent_T, 1);
        rate_per_sec = p(1);
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
    
    rate_per_min = rate_per_sec * 60;
    predicted_temp = current_temp + rate_per_sec * 300;  % 5 min ahead
    
    fprintf('Time: %.0fs | Temp: %.2f C | Rate: %.3f C/min | Predicted: %.2f C\n', ...
        elapsed, current_temp, rate_per_min, predicted_temp);
    
    % LED control based on rate
    if rate_per_min > 4
        % Heating too fast - red
        writeDigitalPin(a, greenPin, 0);
        writeDigitalPin(a, yellowPin, 0);
        writeDigitalPin(a, redPin, 1);
    elseif rate_per_min < -4
        % Cooling too fast - yellow
        writeDigitalPin(a, greenPin, 0);
        writeDigitalPin(a, yellowPin, 1);
        writeDigitalPin(a, redPin, 0);
    else
        % Stable - green
        writeDigitalPin(a, greenPin, 1);
        writeDigitalPin(a, yellowPin, 0);
        writeDigitalPin(a, redPin, 0);
    end
    
    pause(1);
end

end
