% For MATLAB > 2017a

%% Fuzzy Systems 2019 - Group 3
% Manousaridis Ioannis 8855
% Regression with TSK models 
% Cobined Cycle Power Plant (CCPP) dataset from UCI repository
% TSK Model Ser07 
%% Clear

clear;
close all;

%% Begin

% constant: Singleton , linear: Polynomial
mfNumber = [2 3 2 3];
outputForm = ["constant" "constant" "linear" "linear"];

% Make a directory to save the plots if it doesn't exist
if ~exist('Plots', 'dir') 
    mkdir('Plots')  
end


%% TSK Models
% k = 1 %for training one specific model uncomment this and comment the for
% loop 
for k=1:4
%% Initializations

% Start counting time 
tic

% Read Dataset
load CCPP.dat

% Split Dataset
training_set = CCPP(1 : round(0.6*size(CCPP,1)), :);  % 60% is for training
validation_set = CCPP(round(0.6*size(CCPP,1))+1 : round(0.8 * size(CCPP,1)), :); % 20% is for validation
check_set = CCPP(round(0.8*size(CCPP,1))+1 : end, :); % 20% is for testing


%% FIS 

% Set FIS Options
opt = genfisOptions('GridPartition');
opt.NumMembershipFunctions = mfNumber(k) * ones(size(CCPP,2) - 1 , 1);
opt.InputMembershipFunctionType = ["gbellmf" "gbellmf" "gbellmf" "gbellmf"]% Bell-Shaped
opt.OutputMembershipFunctionType = outputForm(k); % Constant or Linear

% FIS Generation 
% syntax: genfis(inputData,outputData,options)
InitialFIS = genfis(training_set(:, 1:end-1), training_set(:, end), opt);

% Plot input Membership Functions
plotInputMembershipFunc(InitialFIS);
sgtitle(['TSK Model ', num2str(k) ,': Membership Functions before training']);
plot_save(join(['TSK_' num2str(k) '_MF_before_Training']));
pause(0.01);

%% Train TSK Model
 
% Tune the fis. Set Training Options.
% The fis structure already exists.
% Set the Validation Data to avoid Overfitting.
anfis_opt = anfisOptions('InitialFIS', InitialFIS, 'EpochNumber', 200, 'DisplayANFISInformation', 0, 'DisplayErrorValues', 0, 'ValidationData', validation_set);

% Train generated FIS
[trnFIS, trnError, stepSize, chkFIS, chkError] = anfis(training_set, anfis_opt);

% Evaluate the trained FIS
y_hat = evalfis(check_set(:,1:end-1),trnFIS);
y = check_set(:,end);

%% Metrics

% Calculate MSE - RMSE
MSE = mean((y - y_hat).^2);
RMSE = sqrt(MSE);

% Calculate R^2 coefficient
SSres = sum( (y - y_hat).^2 );
SStot = sum( (y - mean(y)).^2 );
R_sqr = 1 - SSres / SStot;

% Calculate NMSE - NDEI
NMSE = (sum( (y - y_hat).^2 )/length(y)) / var(y);
NDEI = sqrt(NMSE);

%% Plots

% Metrics
plotMetrics(y,y_hat,trnError,chkError,k);

% Trained input Membership Functions
plotInputMembershipFunc(chkFIS)
sgtitle(['TSK Model ', num2str(k) ,': Membership Functions after training']);
plot_save(join(['TSK_' num2str(k) '_MF_after_Training']));


% Display Metrics
fprintf('MSE = %f RMSE = %f R^2 = %f NMSE = %f NDEI = %f\n', MSE, RMSE, R_sqr, NMSE, NDEI)

% Display Elasped Time
toc

end

%% Function to Plot the Metrics
function plotMetrics(y,y_hat,trnError,chkError,k)

% Plot the Metrics
figure;
plot(1:length(y),y,'*r',1:length(y),y_hat, '.b');
title('Output: Net Hourly Electrical Energy Output');
legend('Reference Outputs','Model Outputs');
plot_save(join(['TSK_' num2str(k) '_Output']));

figure;
plot(y - y_hat);
title('Prediction Errors');
plot_save(join(['TSK_' num2str(k) '_Prediction_Errors']));

figure;
plot(1:length(trnError),trnError,1:length(trnError),chkError);
title('Learning Curve');
legend('Traning Set', 'Check Set');
plot_save(join(['TSK_' num2str(k) '_Learning_Curve']));

end

%% Function to Plot input Membership Functions of the given FIS
function plotInputMembershipFunc(FIS)

% The features of CCCP-dataset
features = ["Temperature" "Ambient Pressure" "Relative Humidity" "Exhaust Vacuum"];

% Subplot with Membership Functions
figure;
for i=1:length(features)
    
    [x,mf] = plotmf(FIS,'input',i);
    subplot(2,2,i);
    plot(x,mf);
    xlabel(join(['Feature' num2str(i) ': ' features(i)]));

end

end

%% Function to automatically save the plots 
function plot_save(name)

set(gcf, 'Position', get(0, 'Screensize')); % Resize to fullscreen for higher resolution 
saveas(gcf, join(['Plots/',name,'.jpg'])); % Save figure 
set(gcf,'position',get(0,'defaultfigureposition')); % Resize figure back to normal

end
