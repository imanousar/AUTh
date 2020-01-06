% For MATLAB > 2017a

%% Fuzzy Systems 2019 - Group 4
% Manousaridis Ioannis 8855
% Classification with TSK models 
% Final TSK - Isolet dataset from UCI repository
% TSK model Ser07 

%% Clear all 

close all; clc;
fprintf('Cleared everything\n\n');

%% Create Folder for Plots and start counting

% Make a directory to save the plots if it doesn't exist
if ~exist('Plots', 'dir') 
    mkdir('Plots')  
end
tic    

%% Dataset preparation

load isolet.csv
load('optimum_model_1.mat')
isolet = isolet(:,[features_indices ,end]);

sorted_isolet = sort_dataset(isolet); % Sort the dataset based on the diferrent output values
tbl = tabulate(sorted_isolet(:,end));  % Count the different output values

%% Split the Dataset

ind = split_indices(tbl); % Prepare Indices to split the Dataset uniformly

% First 60% will be used for Training, next 20% for Validation and last 20% for testing
training_set = [] ; validation_set = [] ; check_set = [] ; 

for i = 1 : size(tbl,1)
    training_set = [ training_set ; sorted_isolet( ind(i,1) : ind(i,2) - 1 , :) ];
    validation_set = [ validation_set ; sorted_isolet( ind(i,2) : ind(i,3) - 1 , :)];
    check_set = [ check_set ; sorted_isolet( ind(i,3) : ind(i,1)+tbl(i,2) - 1 , :)];
end

% Check if the sets were correctly splitted
fprintf("Checking the splitting of sets:\n\n");
balanced_split_checker(tbl,training_set,validation_set,check_set);

%% Shuffle Data in each set

fprintf("Shuffling data\n\n");
training_set = shuffle_set(training_set);
validation_set = shuffle_set(validation_set);
check_set = shuffle_set(check_set);

%% FIS 

fprintf("FIS Generation\n\n");

% Set Fuzzy C-Means Clustering Option and generate the FIS
genfis_opt = genfisOptions('FCMClustering','NumClusters',rules_number,'Verbose',0);
InitialFIS = genfis(training_set(:, 1:end-1), training_set(:, end), genfis_opt);
for i = 1 : length(InitialFIS.Output.MF)
    InitialFIS.Output.MF(i).Type = 'constant';
end

%% Plot some input Membership Functions

numberOfPlots = 4;
plot_input_MFs(InitialFIS,numberOfPlots);
sgtitle('Optimum Model - Membership Functions before training');
plot_save('Optimum_Model_MF_before_training');
pause(0.01);
%% Train TSK Model

fprintf("TSK Training\n\n");
% Set Training Options and train generated FIS
anfis_opt = anfisOptions('InitialFIS', InitialFIS, 'EpochNumber', 5, 'DisplayANFISInformation', 0, 'DisplayErrorValues', 0, 'ValidationData', validation_set);
[trnFIS, trnError, stepSize, chkFIS, chkError] = anfis(training_set, anfis_opt);

% Evaluate the trained FIS
y_pred = evalfis(check_set(:,1:end-1),chkFIS);
y = check_set(:,end);
y_pred = round(y_pred); % Output must be integer (Classification)

% Cases in which the output is 1 or 26 and round leads to 0 or 27
limit_0 = tbl(1,1);
limit_1 = tbl(end,1);
y_pred(y_pred < limit_0) = limit_0;
y_pred(y_pred > limit_1) = limit_1;

%% Calculate Metrics 

N = length(check_set); % Total Number of classified values
error_matrix = confusionmat(y, y_pred);

% Plot Error Matrix
figure()
confusionchart(y, y_pred)
title('Confusion Matrix of Optimum Model');
plot_save('Confusion_Matrix');
pause(0.01);

figure()
confusionchart(y, y_pred,'Normalization','row-normalized','RowSummary','row-normalized')
title('Confusion Matrix of Optimum Model - Frequencies');
plot_save('Confusion_Matrix_Frequencies');
pause(0.01);

overall_accuracy = sum(diag(error_matrix)) / N;
PA = zeros(limit_1 , 1); % Producer's Accuracy Initialization
UA = zeros(limit_1 , 1); % User's Accuracy Initialization

for i = 1 : limit_1
    PA(i) = error_matrix(i, i) / sum(error_matrix(:, i));
    UA(i) = error_matrix(i, i) / sum(error_matrix(i, :));
end

producers_accuracy = PA;
users_accuracy = UA;

% k_hat parameters
x_ir_x_ic = zeros( limit_1 , 1 );
for i = 1 : limit_1
    x_ir_x_ic(i) = ( sum(error_matrix(i,:)) * sum(error_matrix(:,i)) ) / N^2 ;
end

k_hat = (overall_accuracy - sum(x_ir_x_ic)) / (1 - sum(x_ir_x_ic));
%% Plot Results

% Plot the Metrics
plot_metrics(y,y_pred,trnError,chkError);

% Plot some trained input Membership Functions
plot_input_MFs(chkFIS,numberOfPlots)
sgtitle('Best Model - Some Membership Functions after training');
plot_save(join(['Best_Model_MF_after_Training']));

toc % Display Elasped Time


%% Functions

function plot_metrics(y,y_pred,trnError,chkError)
figure;
plot(1:length(y),y,'*r',1:length(y),y_pred, '.b');
title('Output'); legend('Reference Outputs','Model Outputs');
plot_save('Best_Model_Output');

figure;
plot(y - y_pred); title('Prediction Errors');
plot_save('Best_Model_Prediction_Errors');

figure;
plot(1:length(trnError),trnError,1:length(trnError),chkError);
title('Learning Curve');
legend('Traning Set', 'Check Set');
plot_save('Final_Model_Learning_Curve');
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

% Sort the dataset based on output
function sorted = sort_dataset(dataset)
[~,idx] = sort(dataset(:,end));
sorted = unique( dataset(idx,:) ,'rows','stable');
end

% Make indices ready for splitting the dataset correctly
function ind = split_indices(tbl)

% Prepare indices of sets
ind = zeros(length(tbl),3);
ind(1,1) = 1;
ind(1,2) = ind(1,1) + round(0.6*tbl(1,2));
ind(1,3) = ind(1,2) + round(0.2*tbl(1,2));

for i=2:length(tbl)
    ind(i,1) = ind(i-1,1) + tbl(i-1,2);
    ind(i,2) = ind(i,1) + round(0.6*tbl(i,2));
    ind(i,3) = ind(i,2) + round(0.2*tbl(i,2));
end
end


% Shuffle a set
function shuffledData = shuffle_set(set) 

shuffledData = zeros(size(set));  % Initialize an array 
rand_pos = randperm(length(set)); % Array of random positions
for i = 1:length(set)
    shuffledData(i, :) = set(rand_pos(i), :); % Array with randomly distributed data
end
end

% Check if the splitting of sets is balanced
function balanced_split_checker(tbl,training_set,validation_set,check_set)

tbl1 = tabulate(training_set(:,end));
tbl2 = tabulate(validation_set(:,end));
tbl3 = tabulate(check_set(:,end));
frequencyTable = table(tbl(:,1),strcat(num2str(tbl(:,3)),'%'),strcat(num2str(tbl1(:,3)),'%'),...
strcat(num2str(tbl2(:,3)),'%'),strcat(num2str(tbl3(:,3)),'%'));
frequencyTable.Properties.VariableNames = {'Output_Values' 'Isolet_Set' 'Training_Set' 'Validation_Set' 'Check_Set'};
disp(frequencyTable)
end

% Save plots in high resolution
function plot_save(name)
set(gcf, 'Position', get(0, 'Screensize')); % Resize to fullscreen for higher resolution 
saveas(gcf, join(['Plots/',name,'.jpg'])); % Save figure 
set(gcf,'position',get(0,'defaultfigureposition')); % Resize figure back to normal
end