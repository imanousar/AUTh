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

%% Read and shuffle Data 

load superconduct.csv
fprintf('Read Data\n\n');


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

%% Features selection with Relief algorithm
fprintf('Relief Algorithm started\n\n');

[ranks, ~] = relieff(shuffledData(:, 1:end - 1), shuffledData(:, end), 100, 'method','regression');

%% Initializations

NF = [3 9 15 21]; % number of features
NR = [4 6 8 10 12]; % number of Rules

mean_model_error = zeros(length(NF), length(NR));
count = 1;

%% Grid Search Algorithm
fprintf('Grid Search Algorithm started\n\n');
for f = 1 : length(NF)
    for r = 1 : length(NR)
        
        %% Cross Validation with 5-Folds
        
        c = cvpartition(training_set(:, end), 'KFold', 5); % 5 Folds
        err = zeros(c.NumTestSets, 1); % error 
        
        % 5 Folds
        for i = 1 : c.NumTestSets
            
            trainID = c.training(i);
            testID = c.test(i);
            
            % 80% training data
            trainingSet_x = training_set(trainID, ranks(1:NF(f)));
            trainingSet_y = training_set(trainID, end);
            
            % 20% validation data
            validationData_x = training_set(testID, ranks(1:NF(f)));
            validationData_y = training_set(testID, end);
           
            %% FIS 
            
            % set fuzzy C-means clustering options. Generate FIS. Use validation data option to avoid overfitting

            genfis_opt = genfisOptions('FCMClustering','NumClusters',NR(r),'Verbose',0);
            InitialFIS = genfis(trainingSet_x, trainingSet_y, genfis_opt);
            anfis_opt = anfisOptions('InitialFIS', InitialFIS, 'EpochNumber', 150, 'DisplayANFISInformation', 0, 'DisplayErrorValues', 0, 'DisplayStepSize', 0, 'DisplayFinalResults', 0, 'ValidationData', [validationData_x validationData_y]);
            
            % Inform the User about the current status
            disp(['TSK Model ', num2str(count), ' of ', num2str(length(NF)*length(NR))]);
            disp(['Features used: ',num2str(NF(f))]);
            disp(['Rules used : ',num2str(NR(r))]) ;
            disp(['K (Fold Number): ',num2str(i)]); 
            fprintf('Ongoing training.... \n\n');
            
            % Train and evaluate the FIS             
            [trnFIS, trainError, ~, InitialFIS, chkError] = anfis([trainingSet_x trainingSet_y], anfis_opt);
            y_pred = evalfis(validation_set(:, ranks(1:NF(f))), InitialFIS);
            y_tr = validation_set(:, end);
         
            % Calculate Euclidian-Norm Error
            err(i) = (norm(y_tr-y_pred))^2/length(y_tr);
        end
        
        % For every model calculate Mean Error of the 5 folds 
        mean_model_error(f, r) = mean(err);
        
        % Count Total Models
        count = count + 1;
    end
end
fprintf('Grid Search Algorithm finished\n\n');


%% Model Errors
fprintf('The Mean Error for all Models: \n');
disp(mean_model_error)

% Plot errors. 2D Plots of All Mean Errors
figure;
sgtitle('Mean Error for each number of Features and Rules');

for i=1:length(NF)
    
    subplot(2,2,i); bar(mean_model_error(i,:))
    xlabel('Number of Rules'); ylabel('Mean Square Error');
    xticklabels(string(NR)); legend([num2str(NF(i)),' features'])
    
end

save_plot('Subplots_Mean_Errors');


% 3D Plot of All Model Errors
figure;
bar3(mean_model_error); ylabel('Number of Features');
yticklabels(string(NF)); xlabel('Number of Rules');
xticklabels(string(NR)); zlabel('Mean square error');
title('3D Plot of All Model Errors for different Features and Rules');
save_plot('3Dplot_Mean_Error');

%% Optimum Model Selection

% Select the model with the minimum mean error
minMatrix = min(mean_model_error(:));
[min_row,min_col] = find(mean_model_error==minMatrix);
[~,ModelNum]=min(reshape(mean_model_error',[],1));
features_number = NF(min_row); rules_number = NR(min_col);

% Print the optimum model
disp(['The Optimum Model is ',num2str(ModelNum)]);
disp(['Number of Features : ',num2str(features_number)]);
disp(['Number of Rules : ',num2str(rules_number)]) ;

features_indices = sort(ranks(1:features_number));

% Save Optimum Model Specs
save('optimum_model.mat','features_number','rules_number','features_indices')
toc % Display Elasped Time


%% Functions

% Save plots in higher resolution
function save_plot(name)

set(gcf, 'Position', get(0, 'Screensize')); % Resize to fullscreen for higher resolution 
saveas(gcf, join(['Plots/',name,'.jpg'])); % Save figure 
set(gcf,'position',get(0,'defaultfigureposition')); % Resize figure back to normal

end


