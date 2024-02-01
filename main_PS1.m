clear all; %clears the workspace

%% Load the data
data = xlsread("GDPC1.xls"); %imports the excel data
dates = data(2:end,1); %since we lose the first row after log difference, 
% collect the dates from second row
formatted_date = datetime(dates, 'ConvertFrom', 'excel', 'Format', 'yyyy-MM-dd'); %converting to proper format

%% Plot the series
y = diff(log(data(:,2))); %compute percentage change from the previous quarter

figure(1); %name the figure
plot(formatted_date, y, 'LineWidth', 1.5);
title('US Real GDP Growth','FontSize', 16);
xlabel('Quarter', 'FontSize', 14);
ylabel('Change from a quarter ago', 'FontSize', 14);
line([min(formatted_date),max(formatted_date)], [0, 0], 'LineStyle', '--','Color', 'r', 'LineWidth', 1.5);

%% AR(1) estimation
b1 = AREstimation(y,1); %p value is set to 1 and the AREstimation function is called here

%% SIGMA calc
p1 = 1;
Y1 = y(p1+1:end); % (T-1)*1 matrix
T1 = size(Y1,1); 
X1 = [ones(T1,1) y(p1:end-1,:)]; % (T-p)*(p+1) matrix
K1 = size(X1,2); %number of parameters

y_hat_1 = X1 * b1; %fitted values
eps_1 = Y1 - y_hat_1; % Compute regression residuals
RSS_1 = eps_1' * eps_1; %compute square of residuals
sigma2_1 = RSS_1 / (T1-K1); %variance of the residuals

%% Autocorrelations upto 10 lags
lags = 10;
autocorrelation_values = autocorr(y,lags); %this function computes the acf values for 10 lags

figure(2);
bar(0:lags, autocorrelation_values,'DisplayName', 'Autocorrelation');
title('ACF upto 10 lags','FontSize', 16);
xlabel('lags', 'FontSize', 14);
ylabel('ACF', 'FontSize', 14);

%% Wold representation - MA(1)
F1 = [b1(2:end)'; eye(p1-1) zeros(p1-1,1)]; %p * p matrix

K1 = 100

for j = 1:K1
    MATemp_1 = F1^(j-1); 
    MACoeff_1(j) = MATemp_1 (1,1);
end

figure(3);
plot(MACoeff_1, '*-', 'LineWidth', 1.5)
title('MA(1) Coeff','FontSize', 16);


%% AR(2) Estimation
b2 = AREstimation(y,2);

% SIGMA calc
p2 = 2;
Y2 = y(p2+1:end); %(T-p) matrix
T2 = size(Y2,1);
X2 = [ones(T2,1) y(p2:end-1,:) y(p2-1:end-2,:)]; % (T-p)*(p+1) matrix
K2 = size(X2,2);

y_hat_2 = X2 * b2; %fitted values
eps_2 = Y2 - y_hat_2; % Compute regression residuals
RSS_2 = eps_2' * eps_2; %compute RSS
sigma2_2 = RSS_2 / (T2-K2); %variance of the residuals

%% Roots of the AR(2)
c = b2(1);
phi1 = b2(2);
phi2 = b2(3);
root = roots([-phi2, -phi1, 1]);

%% causality & stationarity check
% Check for causality
if all(abs(root) > 1)
    disp('The process is causal.');
else
    disp('The process is not causal.');
end

% Check for stationarity
if all(abs(root) > 1)
    disp('The process is stationary.');
else
    disp('The process is not stationary.');
end

%% Wold representation - MA(2)
F2 = [b2(2:end)'; eye(p2-1) zeros(p2-1,1)];

K2 = 100

for j = 1:K2
    MATemp_2 = F2^(j-1); 
    MACoeff_2(j) = MATemp_2 (1,1);
end

figure(4);
plot(MACoeff_2, '*-', 'LineWidth', 1.5)
title('MA(2) Coeff','FontSize', 16);

%% yt =c+εt +1.2εt−1 +2εt−2

%This is MA(2) process, so it is inherently stationary under the assumption
%of white noise terms. It has a constant mean & variance. Autocovariance
%function depends only on h.

root_2 = roots([2, 1.2, 1]);

%inveritibility check 
if all(abs(root_2) > 1)
    disp('The process is invertible.');
else
    disp('The process is not invertible.');
end
