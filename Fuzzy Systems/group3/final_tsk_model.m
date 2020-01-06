% For MATLAB > 2017a

%% Fuzzy Systems 2019 - Group 3
% Manousaridis Ioannis 8855
% Regression with TSK models 
% Superconductivity dataset from UCI repository
% TSK Model Ser07 
%% Clear all 

close all; clc;
fprintf('Cleared everything\n\n');

%% Create Folder for Plots and start counting

% Make a directory to save the plots if it doesn't exist
if ~exist('Plots', 'dir') 
    mkdir('Plots')  
end

tic        

%% Read and shuffle the Data 

fprintf('Read Data\n\n');
load superconduct.csv
load('optimum_model_1.mat')
superconduct = superconduct(:,[features_indices , end]);

shuffledData = zeros(size(superconduct)); % Array with Shuffled Data
rand_pos = randperm(length(superconduct)); % Array of random Positions 

% new array with original data randomly distributed
for k = 1:length(superconduct)
    shuffledData(k, :) = superconduct(rand_pos(k), :);
end

%% Split the Dataset

% First 60% will be used for Training, next 20% for Validation and last 20% for testing
training_set = shuffledData(1 : round(0.6*size(shuffledData,1)), :);
validation_set = shuffledData(round(0.6*size(shuffledData,1))+1 : round(0.8 * size(shuffledData,1)), :);
check_set = shuffledData(round(0.8*size(shuffledData,1))+1 : end, :); 

%% FIS 

% set fuzzy C-means clustering options. Generate FIS. 
genfis_opt = genfisOptions('FCMClustering','NumClusters',rules_number,'Verbose',0);
InitialFIS = genfis(training_set(:, 1:end-1), training_set(:, end), genfis_opt);

%% Plot some input Membership Functions

numberOfPlots = 4;
plot_input_MFs(InitialFIS,numberOfPlots);
sgtitle('Optimum Model - Membership Functions before training');
save_plot('Optimum_Model_MF_before_training');
pause(0.01);

%% Train TSK Model

% Set training options and train generated FIS
anfis_opt = anfisOptions('InitialFIS', InitialFIS, 'EpochNumber', 50, 'DisplayANFISInformation', 0, 'DisplayErrorValues', 0, 'ValidationData', validation_set);
[trnFIS, trnError, stepSize, chkFIS, chkError] = anfis(training_set, anfis_opt);

% Evaluate the trained FIS
y_pred = evalfis(check_set(:,1:end-1),chkFIS);
y = check_set(:,end);

%% Metrics Calculation

MSE = mean((y - y_pred).^2);
RMSE = sqrt(MSE);
NMSE = (sum( (y - y_pred).^2 )/length(y)) / var(y);
NDEI = sqrt(NMSE);

% R^2 coefficient
SSres = sum( (y - y_pred).^2 );
SStot = sum( (y - mean(y)).^2 );
R_sqr = 1 - SSres / SStot;


%% Plot Results

% Plot Metrics and some trained MFs
plot_metrics(y,y_pred,trnError,chkError);
plot_input_MFs(chkFIS,numberOfPlots)

sgtitle('Optimum Model - Some Membership Functions after training');
save_plot(join('Optimum'));

% Display Metrics and Elapsed Time
fprintf('MSE = %f RMSE = %f R^2 = %f NMSE = %f NDEI = %f\n', MSE, RMSE, R_sqr, NMSE, NDEI)
toc

%% Functions

% Plot the Metrics
function plot_metrics(y,y_pred,trnError,chkError)

figure;
plot(1:length(y),y,'*r',1:length(y),y_pred, '.b');
title('Output');
legend('Reference Outputs','Model Outputs');
save_plot('Best_Model_Output');

figure;
plot(y - y_pred);
title('Prediction Errors');
save_plot('Best_Model_Prediction_Errors');

figure;
plot(1:length(trnError),trnError,1:length(trnError),chkError);
title('Learning Curve');
legend('Traning Set', 'Check Set');
save_plot('Best_Model_Learning_Curve');
figure;


end

%Plot the input Membership Functions of the given FIS
function plot_input_MFs(FIS,numberOfPlots)

figure;
for i=1:numberOfPlots
    
    [x,mf] = plotmf(FIS,'input',i);
    subplot(2,2,i);
    plot(x,mf);
    xlabel(['Input' num2str(i)]);

end

end

% Save plots in higher resolution
function save_plot(name)

set(gcf, 'Position', get(0, 'Screensize')); % Resize to fullscreen for higher resolution 
saveas(gcf, join(['Plots/',name,'.jpg'])); % Save figure 
set(gcf,'position',get(0,'defaultfigureposition')); % Resize figure back to normal

end
