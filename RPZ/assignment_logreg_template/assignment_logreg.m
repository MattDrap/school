% RPZ assigment: Logistic regression


%% Init
run('../stprtool/stprpath.m');

%% Classification of letters A and C
%--------------------------------------------------------------------------
% Load training data and compute features
load ('data_33rpz_logreg.mat');

% Prepare the training data
trainX = compute_measurements(trn.images);
trainX = [ones(1, size(trainX, 2)); trainX];

% Training - gradient descent of the logistic loss function
% Start at a fixed point:
w_init = [-7; -8];
% or start at a random point:
%w_init = 20 * (rand(size(trainX, 1), 1) - 0.5);
epsilon = 1e-2;
[w, wt, Et] = logistic_loss_gradient_descent(trainX, trn.labels, w_init, epsilon);

% Plot the progress of the gradient descent
% plotEt
plot(Et);
print('E_progress_AC.png', '-dpng');
    
%
plot_gradient_descent(trainX, trn.labels, @logistic_loss, w, wt, Et);
print('w_progress_2d_AC.png', '-dpng');
% plot aposteriori probabilities
thr = get_threshold(w);
plotX = -4:0.01:4;
train1 = trainX(:, trn.labels == -1);
train2 = trainX(:, trn.labels == 1);
plotXp1 = [ones(1, size(plotX, 2)); plotX];
p1x = 1./(1+exp(w'*plotXp1));
p2x = 1./(1+exp(-w'*plotXp1));
figure
hold on;
scatter(train1(2,:), ones(1, length(train1)), 'r');
scatter(train2(2, :), zeros(1,length(train2)), 'b');
plot(plotX, p1x, 'r');
plot(plotX, p2x, 'b');
line([thr thr],[0 1],'Color','g');
hold off;
print('aposteriori.png', '-dpng');

% Prepare the test data
testX = compute_measurements(tst.images);
testX = [ones(1, size(testX, 2)); testX];
    
% Classify letter test data and calculate classification error
classifiedLabels = classify_images(testX, w);

testError = sum(classifiedLabels ~= tst.labels) / length(tst.labels);
fprintf('Letter classification error: %.2f%%\n', testError * 100);

% Visualize classification results
show_classification(tst.images, classifiedLabels, 'AC');
print('classif_AC.png', '-dpng');


%% Classification of MNIST digits
%--------------------------------------------------------------------------
% Load training data
load('mnist_01_trn');

% prepare the training data
Xtrain = X;
Xtrain = [ones(1, size(Xtrain, 2)); Xtrain];

% Training - gradient descent of the logistic loss function
w_init = rand(size(Xtrain, 1), 1);
epsilon = 1e-2;
[w, ~, Et] = logistic_loss_gradient_descent(Xtrain, y, w_init, epsilon);

% Plot the progress of the gradient descent
% plotEt
figure();
plot(Et);
print('E_progress_MNIST.png','-dpng');
% Load test data
load('mnist_01_tst');
Xtest = X;
Xtest = [ones(1, size(Xtest, 2)); Xtest];
% prepare the training data

% Classify MNIST test data and calculate classification error
classifiedLabels = classify_images(Xtest, w);
testError = sum(classifiedLabels ~= y)/length(y);%
fprintf('MNIST digit classification error: %.2f%%\n', testError * 100);

% Visualize classification results
show_mnist_classification(Xtest(2:end,:), classifiedLabels);
print('classif_MNIST.png', '-dpng');
