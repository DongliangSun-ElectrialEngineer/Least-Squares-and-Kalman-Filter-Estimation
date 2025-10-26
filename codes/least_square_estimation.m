close all;
clear;
clc;

data = load ('data_LS.txt');
t = data(:,1);
y = data(:,2);

%Build H matrix
H = [ones(length(t),1), t, 0.5*t.^2];

%least squares solution
x_hat = (H'*H)\(H'*y);
disp(x_hat)
fprintf('x_hat:\n');
fprintf('%.4f\n', x_hat); 

%Smoothed position measurement
y_estimation = H * x_hat;

%Calculate the root mean squared error
x_true = [7.4507, 39.1441, -9.7340]';
rmse = sqrt(mean((x_hat-x_true).^2));
fprintf('Root mean squared error = %.6f \n', rmse);

%Plot the noisy position measurements vs. the smoothed measurement.
figure;
plot(t, y, 'r', 'MarkerSize', 6, 'DisplayName', 'Noisy Measurements'); hold on;
plot(t, y_estimation, 'b-', 'LineWidth', 2, 'DisplayName', 'Smoothed Measurements');
xlabel('Time t');
ylabel('Position y');
legend('show');
grid on;
title('Noisy vs Smoothed Measurements');

%Calculate the average time required to run the LS estimation equation
num_runs = 100;   % repeat to get a stable average
times = zeros(num_runs,1);
for i = 1:num_runs
    tic;
    x_hat = (H'*H)\(H'*y);   
    times(i) = toc;
end
avg_time = mean(times);
fprintf('Average time for LS estimation = %.6f seconds\n', avg_time);

% Increase the random noise to the measurement vector y and calculate the
% root mean squared error between your estimate of 𝒙 and the ground truth
% value.

% Noise variance grid 
var_list = linspace(0, 10000, 100);  % 100 points from 0 to 10000

% Preallocate
rmse_vector = zeros(length(var_list),1);     % overall RMSE (across the 3 state entries)

% Monte Carlo runs to average RMSE at each variance level
num_trials = 200;

rng(0); % for reproducibility

for i = 1:length(var_list)
    sigma2 = var_list(i);
    sigma = sqrt(sigma2);
    
    rmse_trials = zeros(num_trials,1);
    
    for k = 1:num_trials
    % Add zero-mean Gaussian measurement noise with a standard
    % deviation of sigma
    y_noisy = y + sigma * randn(length(y),1);
    
    x_hat = (H'*H)\(H'*y_noisy);
    
    % Compute RMSE between x_hat and x_true for each trial
    rmse_trials(k,1) = sqrt(mean((x_hat - x_true).^2));
    end
    
    % average across trials
    rmse_vector(i) = mean(rmse_trials);
end

% Relationship between the measurementnoise variance 
% and the root mean squared error of the estimation of 𝒙
figure;
plot(var_list, rmse_vector, '-o', 'LineWidth', 1.4, 'MarkerSize',4);
grid on;
xlabel('Measurement noise variance');
ylabel('RMSE');
title('LS estimation: RMSE vs measurement noise variance');