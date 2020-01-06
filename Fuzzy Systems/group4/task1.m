% For MATLAB > 2017a

%% Fuzzy Systems 2019 - Group 4
% Manousaridis Ioannis 8855
% Classification with TSK models 
% Avilla dataset from UCI repository
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
% Read Data
fprintf('Dataset Preparation\n\n');
load avila.dat
fprintf('Finished reading\n\n');

sorted_avila = sort_dataset(avila); % Sort the dataset based on output values
tbl = tabulate(sorted_avila(:,end)); % Count the different output values


%% Split the Dataset

ind = split_indices(tbl); % Prepare Indices to split the Dataset uniformly

% First 60% will be used for Training, next 20% for Validation and last 20% for testing
training_set = [] ; 
validation_set = [] ;
check_set = [] ; 

for i = 1 : size(tbl,1)
    training_set = [ training_set ; sorted_avila( ind(i,1) : ind(i,2) - 1 , :) ];
    validation_set = [ validation_set ; sorted_avila( ind(i,2) : ind(i,3) - 1 , :)];
    check_set = [ check_set ; sorted_avila( ind(i,3) : ind(i,1)+tbl(i,2) - 1 , :)];
end
% Check if the sets were correctly splitted
fprintf("Checking the splitting of sets:\n\n");
balanced_split_checker(tbl,training_set,validation_set,check_set);

%% Shuffle Data in each set

fprintf("Shuffling data\n\n");
training_set = shuffle_set(training_set);
validation_set = shuffle_set(validation_set);
check_set = shuffle_set(check_set);

%% Initializations

% Evaluation metrics arrays
error_matrix = cell(1, 5);
overall_accuracy = zeros(5,1);
producers_accuracy = cell(1, 5);
users_accuracy = cell(1, 5);
k_hat = zeros(5,1);

radius = [0.8 0.8 0.3 0.6 0.4]'; % radius parameter - SC Algorithm
squash_factor=[0.5 0.5 0.5 0.5 0.5]'; % Squash Factor - genfis option
NR = zeros(5,1); % Number of Rules produced by SC Algorithm

%% Training

for k = 1:5
    
    % Set Subtractive Clustering Options
    genfis_opt = genfisOptions('SubtractiveClustering','ClusterInfluenceRange',radius(k),'SquashFactor',squash_factor(k),'Verbose',0);
    
    % FIS generation
    InitialFIS = genfis(training_set(:,1:end-1), training_set(:,end), genfis_opt);
    NR(k) = length(InitialFIS.Rule);     % Number of Rules
    
    for i = 1 : length(InitialFIS.Output.MF)
        InitialFIS.Output.MF(i).Type = 'constant';
    end
    
    plot_input_MF(InitialFIS); % Plot Inital Membership Functions
    title(['TSK model ', num2str(k), ': Input MFs before training']);
    plot_save(['TSK', num2str(k), 'InputMFsbeforeTraining']); pause(0.01);
    
    %Train TSK Model - Inform the User about the current status
    disp(['Current model training ', num2str(k), ' / ', num2str(length(NR))]);
    fprintf('Ongoing training..\n\n');
    
    % Set Training Options and train the generated FIS
    anfis_opt = anfisOptions('InitialFIS', InitialFIS, 'EpochNumber', 200, 'DisplayANFISInformation', 0, 'DisplayErrorValues', 0, 'ValidationData', validation_set);
    [trnFIS, trnError, stepSize, chkFIS, chkError] = anfis(training_set, anfis_opt);
    
    y_pred = evalfis(check_set(:,1:end-1),chkFIS); % Evaluate the trained FIS
    y = check_set(:,end);
    y_pred = round(y_pred); % round output to an integer for classifying
    
    % Cases in which the output is 1 or 12 and round leads to 0 or 13
    limit_0 = tbl(1,1); 
    limit_1 = tbl(end,1);
    y_pred(y_pred < limit_0) = limit_0;
    y_pred(y_pred > limit_1) = limit_1;
    
    %% Calculate Metrics 
 
    N = length(check_set); % Total Number of classified 
    error_matrix = confusionmat(y, y_pred);
    
    % Plot Error Matrix
    figure()
    confusionchart(y, y_pred)
    title(['Confusion Matrix of Model ' num2str(k)]);
    plot_save(['Confusion_Matrix' num2str(k)]);
    pause(0.01);
    
    figure()
    confusionchart(y, y_pred,'Normalization','row-normalized','RowSummary','row-normalized')
    title(['Confusion Matrix of Model ' num2str(k) ' - Frequencies']);
    plot_save(['Confusion_Matrix_Frequencies' num2str(k)]);
    pause(0.01);
    
    overall_accuracy(k) = sum(diag(error_matrix)) / N;
    % Producer's Accuracy Initialization
    PA = zeros(limit_1 , 1);
    % User's Accuracy Initialization
    UA= zeros(limit_1 , 1);
    
    for i = 1 : limit_1
        PA(i) = error_matrix(i, i) / sum(error_matrix(:, i));
        UA(i) = error_matrix(i, i) / sum(error_matrix(i, :));
    end
    
    % Producer's Accuracy
    producers_accuracy{1,k} = PA;
    % User's Accuracy
    users_accuracy{1,k} = UA;

    % k_hat parameters
    x_ir_x_ic = zeros( limit_1 , 1 );
    for i = 1 : limit_1
        x_ir_x_ic(i) = ( sum(error_matrix(i,:)) * sum(error_matrix(:,i)) ) / N^2 ;
    end
    k_hat(k) = (overall_accuracy(k) - sum(x_ir_x_ic)) / (1 - sum(x_ir_x_ic));
    
    
    % Plot Final Membership Functions
    plot_input_MF(chkFIS);
    title(['TSK model ', num2str(k), ': Input MF after training']);
    plot_save(['TSK', num2str(k), 'InputMFafterTraining']);
    
    figure;
    plot(1:length(trnError), trnError, 1:length(trnError), chkError);
    title(['TSK model ', num2str(k), ': Learning Curve']);
    xlabel('Iterations');
    ylabel('Error');
    legend('Training Set', 'Check Set');
    plot_save(['learning_curve_', num2str(k)]);
    
end

%% Plot Metrics and  Save Metrics Information

save('metrics', 'error_matrix','overall_accuracy','k_hat','producers_accuracy','users_accuracy');

toc % Display Elasped Time


%% Functions 

% Sort the dataset based on output
function sorted = sort_dataset(dataset)
[~,idx] = sort(dataset(:,end));
sorted = unique( dataset(idx,:) ,'rows','stable');
end

% Check if the splitting of sets is balanced
function balanced_split_checker(tbl,training_set,validation_set,check_set)
tbl_1 = tabulate(training_set(:,end));
tbl_2 = tabulate(validation_set(:,end));
tbl_3 = tabulate(check_set(:,end));
frequencyTable = table(tbl(:,1),strcat(num2str(tbl(:,3)),'%'),strcat(num2str(tbl_1(:,3)),'%'),...
strcat(num2str(tbl_2(:,3)),'%'),strcat(num2str(tbl_3(:,3)),'%'));
frequencyTable.Properties.VariableNames = {'classes_values' 'avila_set' 'training_set' 'validation_set' 'check_set'};
disp(frequencyTable)
end

% Make indices ready for splitting the dataset correctly
function ind = split_indices(tbl)
ind = zeros(length(tbl),3); ind(1,1) = 1;
ind(1,2) = ind(1,1) + round(0.6*tbl(1,2));
ind(1,3) = ind(1,2) + round(0.2*tbl(1,2));

for i=2:length(tbl)
    ind(i,1) = ind(i-1,1) + tbl(i-1,2);
    ind(i,2) = ind(i,1) + round(0.6*tbl(i,2));
    ind(i,3) = ind(i,2) + round(0.2*tbl(i,2));
end
end

% Shuffle a set
function shuffled_data = shuffle_set(set)
shuffled_data = zeros(size(set)); % Initialize an array 
rand_pos = randperm(length(set)); % Array of random positions

for i = 1:length(set)
    shuffled_data(i, :) = set(rand_pos(i), :); % Array with randomly distributed data
end
end

%Plot input Membership Functions of a FIS
function plot_input_MF(FIS)

figure;
for i = 1 : length(FIS.Input)
    [x,mf] = plotmf(FIS,'input',i);
    plot(x,mf); hold on;
end
xlabel('Inputs');
end

% Save plots in high resolution
function plot_save(name)

set(gcf, 'Position', get(0, 'Screensize')); % Resize to fullscreen for higher resolution 
saveas(gcf, join(['Plots/',name,'.jpg'])); % Save figure 
set(gcf,'position',get(0,'defaultfigureposition')); % Resize figure back to normal

end