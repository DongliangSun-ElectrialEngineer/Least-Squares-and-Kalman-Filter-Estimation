close all;
clear;
clc;

data = load ('data_LS.txt');
t = data(:,1);
y = data(:,2);

% Initialization
x(:,1) =[0 0 0]';
F = [0 0 0;0 0 0;0 0 0];
G = diag([10 10 10]);
Q = diag([0.001 0.001 0.001]);
R = 10;
P(:,:,1) = diag([50 50 50]);
dT = mean(diff(t));

for i = 1:length(t)-1
%--> KF Prediction
% Calculate H matrix
H = [1 dT*i 0.5*(dT*i)^2];
% Calculate Transition Matrix
Phi = eye(3,3) + F*dT;
% Calculate System Noise Matrix
Qd = dT^2*G*Q*G';
% Predict States
x(:,i+1) = Phi*x(:,i);
% Predict State Error Covariance
P(:,:,i+1) = Phi*P(:,:,i)*Phi' + Qd;
%--> KF Update
% Calculate Kalman Gain
K = P(:,:,i+1)*H'/(H*P(:,:,i+1)*H'+R);
% Update error covariance matrix P
P(:,:,i+1) = P(:,:,i+1) - K*H*P(:,:,i+1);
% Calculate error state
error_states = K*(y(i+1) - H*x(:,i+1));
% Correct states
x(:,i+1) = x(:,i+1) + error_states;
%Smoothed measurements
y_estimation(i+1,1) = H*x(:,i+1);
end

% Plotting KF estimates vs ground truth
x_true = [7.4507, 39.1441, -9.7340]';
figure;
state_names = {'Initial Position y(0)', 'Initial Velocity v(0)', 'Acceleration a'};
for i = 1:3
    subplot(3,1,i);
    plot(t, x(i,:), 'b-', 'LineWidth', 1.5); hold on;
    yline(x_true(i), 'r--', 'LineWidth', 1.5);  % ground truth is constant
    grid on;
    xlabel('Time (s)');
    ylabel(state_names{i});
    legend('KF Estimate', 'Ground Truth', 'Location','best');
    title(['Kalman Filter estimate of ', state_names{i}]);
end

x_hat = x(:,end);
%Calculate the root mean squared error
x_true = [7.4507, 39.1441, -9.7340]';
rmse = sqrt(mean((x_hat-x_true).^2));
fprintf('Root mean squared error = %.6f \n', rmse);

%Plot the noisy position measurements vs. the smoothed measurement.
figure;
plot(t, y, 'r', 'MarkerSize', 2, 'DisplayName', 'Noisy Measurements'); hold on;
plot(t, y_estimation, 'b', 'LineWidth', 2, 'DisplayName', 'Smoothed Measurements');
xlabel('Time t');
ylabel('Position y');
legend('show');
grid on;
title('Noisy vs Smoothed Measurements');

