% For MATLAB > 2017a

%% Fuzzy Systems 2019 - Group 4
% Manousaridis Ioannis 8855
% Classification with TSK models 
% Grid Search - Isolet dataset from UCI repository
% TSK model Ser07 
%% Clear all 

close all; clc;
fprintf('Cleared everything\n\n');

%% Initializations

NF = [5 10 15 20]; % Number of Features
NR = [4 8 12 16 20]; % Number of Rules
mean_model_err = zeros(length(NF), length(NR));
count = 1; error_matrix = cell(length(NF), length(NR));
overall_accuracy = zeros(length(NF),length(NR));
producers_accuracy = cell(length(NF), length(NR));
users_accuracy = cell(length(NF), length(NR));
k_hat = zeros(length(NF),length(NR));

%% Create Folder for Plots and start counting

% Make a directory to save the plots if it doesn't exist
if ~exist('Plots', 'dir') 
    mkdir('Plots')  
end
tic
%% Dataset preparation

% Read Data
load isolet.csv
fprintf('Read Data\n\n');

sorted_isolet = sort_dataset(isolet);% Sort the dataset based on the diferrent output values
tbl = tabulate(sorted_isolet(:,end)); % Count the different output values

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


%% Features selection with Relief algorithm

fprintf('Relief Algorithm started\n\n');
[ranks, ~] = relieff(isolet(:, 1:end - 1), isolet(:, end), 50, 'method', 'classification');

%% Grid Search Algorithm

fprintf('Grid Search Algorithm started\n\n');
for f = 1 : length(NF)
    for r = 1 : length(NR)
        
        % Cross Validation with  5-Folds 
        train_fold = cell(1,5);
        test_fold = cell(1,5);
        testID = cell(1,5);
        
        for i = 1 : size(tbl,1)
            singleClass = training_set(training_set(:,end)==tbl(i,1),:);
            c = cvpartition(singleClass(:, end), 'KFold', 5);
            for w = 1 : c.NumTestSets
                train_fold{1,w} = [train_fold{1,w};c.training(w)];
                test_fold{1,w} = [test_fold{1,w};c.test(w)];
            end
        end
        
        err = zeros(c.NumTestSets, 1);
        
        % 5 Folds for each one
        for i = 1 : c.NumTestSets
            
            trainID = logical(train_fold{1,i});
            testID = logical(test_fold{1,i});
            
            % 80% training data
            trainingSet_x = training_set(trainID, ranks(1:NF(f)));
            trainingSet_y = training_set(trainID, end);
            
            % 20% validation data
            validation_data_x = training_set(testID, ranks(1:NF(f)));
            validation_data_y = training_set(testID, end);
            
            % Shuffle data in fold 
            trainingSet_x = shuffle_set(trainingSet_x);
            trainingSet_y = shuffle_set(trainingSet_y);
            validation_data_x = shuffle_set(validation_data_x);
            validation_data_y = shuffle_set(validation_data_y);
            
            %% FIS 
            
            % Set fuzzy C-means clustering options and generate FIS. U
            genfis_opt = genfisOptions('FCMClustering','NumClusters',NR(r),'Verbose',0,'FISType','sugeno');
            InitialFIS = genfis(trainingSet_x, trainingSet_y, genfis_opt);
            
            for j = 1 : length(InitialFIS.Output.MF)
                InitialFIS.Output.MF(j).Type = 'constant';
                InitialFIS.Output.MF(j).Params = (tbl(1,1)+tbl(end,1))/2;
            end
            
            % Use validation data option to avoid overfitting
            anfis_opt = anfisOptions('InitialFIS', InitialFIS, 'EpochNumber', 150, 'DisplayANFISInformation', 0, 'DisplayErrorValues', 0, 'DisplayStepSize', 0, 'DisplayFinalResults', 0, 'ValidationData', [validation_data_x validation_data_y]);
            
            % Inform User about the current status
            disp(['TSK Model ', num2str(count), ' / ', num2str(length(NF)*length(NR))]);
            disp(['Features used: ',num2str(NF(f))]);
            disp(['Rules used: ',num2str(NR(r))]) ;
            disp(['K (Fold Number): ',num2str(i)']);
            fprintf('Ongoing training... \n\n');
            
            % Train and evaluate the FIS             
            [trnFIS, trainError, ~, InitialFIS, chkError] = anfis([trainingSet_x trainingSet_y], anfis_opt);
            y_pred = evalfis(validation_set(:, ranks(1:NF(f))), InitialFIS);
            y = validation_set(:, end);
            y_pred = round(y_pred); % Output must be an integer (Classification)

            % Special cases if the output is out of the classification range
            limit_0 = tbl(1,1);
            limit_1 = tbl(end,1);
            y_pred(y_pred < limit_0) = limit_0;
            y_pred(y_pred > limit_1) = limit_1;
            
            % Calculate Euclidian-Norm Error
            err(i) = (norm(y-y_pred))^2/length(y);
        end
        
        %% Calculate Metrics 
        
        % For every model calculate Mean Error of the 5 folds
        mean_model_err(f, r) = mean(err);
        
        % Count Total Models
        count = count + 1;
    end
end

%% Model Errors
fprintf('The Mean Error for all Models: \n');
disp(mean_model_err)

%% Plot Errors

% 2D Plots of All Mean Errors
figure;
sgtitle('Mean Error for each number of Features and Rules');

for i=1:length(NF)
    subplot(2,2,i);
    bar(mean_model_err(i,:))
    xlabel('Number of Rules');
    xticklabels(string(NR));
    legend([num2str(NF(i)),' features'])
end
plot_save('Subplots_Mean_Errors');

% 3D Plot of All Model Errors
figure;
bar3(mean_model_err); ylabel('Number of Features');
yticklabels(string(NF)); xlabel('Number of Rules');
xticklabels(string(NR));
title('3D Plot of All Model Errors for different Features and Rules');
plot_save('3Dplot_Mean_Error');

%% Optimum Model Selection

% Select the model with the minimum mean error
minMatrix = min(mean_model_err(:));
[min_row,min_col] = find(mean_model_err==minMatrix);
[~,ModelNum]=min(reshape(mean_model_err',[],1));
features_number = NF(min_row);
rules_number = NR(min_col);

% Print the optimum model
disp(['The Optimum Model is ',num2str(ModelNum)]);
disp(['Number of Features : ',num2str(features_number)]);
disp(['Number of Rules : ',num2str(rules_number)]) ;
features_indices = sort(ranks(1:features_number));

% Save Optimum Model Specs
save('optimum_model.mat','features_number','rules_number','features_indices')
toc % Display Elasped Time

%% Functions

% Sort the dataset based on output
function sorted = sort_dataset(dataset)
[~,idx] = sort(dataset(:,end));
sorted = unique( dataset(idx,:) ,'rows','stable');
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

% Check if the splitting of sets is balanced
function balanced_split_checker(tbl,training_set,validation_set,check_set)
tbl_1 = tabulate(training_set(:,end));
tbl_2 = tabulate(validation_set(:,end));
tbl_3 = tabulate(check_set(:,end));
frequencyTable = table(tbl(:,1),strcat(num2str(tbl(:,3)),'%'),strcat(num2str(tbl_1(:,3)),'%'),...
strcat(num2str(tbl_2(:,3)),'%'),strcat(num2str(tbl_3(:,3)),'%'));
frequencyTable.Properties.VariableNames = {'classes_values' 'isolet_set' 'training_set' 'validation_set' 'check_set'};
disp(frequencyTable)
end

% Save plots in high resolution
function plot_save(name)
set(gcf, 'Position', get(0, 'Screensize')); % Resize to fullscreen for higher resolution 
saveas(gcf, join(['Plots/',name,'.jpg'])); % Save figure 
set(gcf,'position',get(0,'defaultfigureposition')); % Resize figure back to normal
end
