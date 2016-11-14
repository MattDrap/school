% Assigment 04 MAXIMUM LIKELIHOOD ESTIMATION

% initialize stpr toolbox 
run('../stprtool/stprpath.m')

%% Part 1 of the task

stepCardinality = 10;
maxCardinality = 500;
cardinalities = 10:stepCardinality:maxCardinality;
n = size(cardinalities,2);

var_mu_rec = zeros(1,n);
var_sigma_rec = zeros(1,n);

for i = 1:n    
    % Compute the variance of the estimations for a fix cardinality
    [var_mu_rec(i), var_sigma_rec(i)] = mle_variance(cardinalities(i));    
end

figure, plot(cardinalities',[var_mu_rec' var_sigma_rec'],'lineWidth',3), grid on;
legend('Mean','Standard deviation');
xlabel 'Cardinality of traning set'
ylabel 'Variance'
print('mle_variances.png', '-dpng');

%% Part 2 of the task
%% Load training and test data
load data_33rpz_cv04.mat
Distributions = {};
%% Select the training set
trnSet = trn_2000;

%% Computing features vectors (trainning)
x = compute_measurement_lr_cont(trnSet.images);

%% Estimate prior probabilities
prior_A = estimate_prior(1,trnSet.labels);
prior_C = estimate_prior(2,trnSet.labels);

%% Splitting the trainning data into into classes
x_A = x(trnSet.labels == 1);
x_C = x(trnSet.labels == 2);

%% Computing Gaussian models of Maximal Likelihood
[DA.Mean, DA.Sigma] = mle_normal(x_A);
[DC.Mean, DC.Sigma] = mle_normal(x_C);

DA.Prior = prior_A;
DC.Prior = prior_C;

Distributions(1) = {DA};
Distributions(2) = {DC};
%% Plotting L VS sigma
trn_sets = [trn_20, trn_200, trn_2000];
filenames = {'loglikelihood20.png', 'loglikelihood200.png', 'loglikelihood2000.png'};
for i = 1:3
    trnSet = trn_sets(i);
    x_A = x(trnSet.labels == 1);
    [DA.Mean, DA.Sigma] = mle_normal(x_A);
    
    sigmas = 700:1700;
    [L maximizerSigma maxL] = loglikelihood_sigma(x_A,DA,sigmas);

    % Plotting the likelihood as a function of Sigma
    figure,plot(sigmas,L),grid on, title 'Likelihood varing sigma class A';
    xlabel('\sigma');
    ylabel('L(\sigma)');
    hold on;
    plot(maximizerSigma, maxL,'r+','markersize',15);
    line([DA.Sigma DA.Sigma],[min(L) maxL],'Color','g');
    hold off;
    print(filenames{i}, '-dpng');
end

%% Ploting the aproximated density functions
limit = 4000;
numBins = 20;
dom = -limit : limit;
figureA = figure();
% Compute histograms
[hist_A, binCenters_A] = hist(x_A,numBins);
[hist_C, binCenters_C] = hist(x_C,numBins);
% Normalize histograms
hist_A = hist_A/(sum(hist_A)*(binCenters_A(2)-binCenters_A(1)));
hist_C = hist_C/(sum(hist_C)*(binCenters_C(2)-binCenters_C(1)));

% Plot histograms
hold on;
bar(binCenters_A, hist_A,'y');
plot(dom',[normpdf(dom,DA.Mean,DA.Sigma)'],'r','linewidth',3);
grid on, title 'Densities functions', hold off;

figureC = figure();
hold on;
bar(binCenters_C, hist_C,'y');
plot(dom',[normpdf(dom,DC.Mean,DC.Sigma)'],'r','linewidth',3);
grid on, title 'Densities functions', hold off;

trnSet = trn_200;

x_A = x(trnSet.labels == 1);
x_C = x(trnSet.labels == 2);

prior_A = estimate_prior(1,trnSet.labels);
prior_C = estimate_prior(2,trnSet.labels);

[DA.Mean DA.Sigma] = mle_normal(x_A);
[DC.Mean DC.Sigma] = mle_normal(x_C);
DA.Prior = prior_A;
DC.Prior = prior_C;

Distributions(3) = {DA};
Distributions(4) = {DC};

[hist_A binCenters_A] = hist(x_A,numBins);
[hist_C binCenters_C] = hist(x_C,numBins);
% Normalize histograms
hist_A = hist_A/(sum(hist_A)*(binCenters_A(2)-binCenters_A(1)));
hist_C = hist_C/(sum(hist_C)*(binCenters_C(2)-binCenters_C(1)));

figure(figureA);
% Plot histograms
hold on;
plot(dom',[normpdf(dom,DA.Mean,DA.Sigma)'],'g','linewidth',3);
grid on, title 'Densities functions', hold off;

figure(figureC)
hold on;
plot(dom',[normpdf(dom,DC.Mean,DC.Sigma)'],'g','linewidth',3);
grid on, title 'Densities functions', hold off;

trnSet = trn_20;
x_A = x(trnSet.labels == 1);
x_C = x(trnSet.labels == 2);

prior_A = estimate_prior(1,trnSet.labels);
prior_C = estimate_prior(2,trnSet.labels);

[DA.Mean, DA.Sigma] = mle_normal(x_A);
[DC.Mean, DC.Sigma] = mle_normal(x_C);
DA.Prior = prior_A;
DC.Prior = prior_C;

Distributions(5) = {DA};
Distributions(6) = {DC};

[hist_A binCenters_A] = hist(x_A,numBins);
[hist_C binCenters_C] = hist(x_C,numBins);
% Normalize histograms
hist_A = hist_A/(sum(hist_A)*(binCenters_A(2)-binCenters_A(1)));
hist_C = hist_C/(sum(hist_C)*(binCenters_C(2)-binCenters_C(1)));

figure(figureA);
hold on;
plot(dom',[normpdf(dom,DA.Mean,DA.Sigma)'],'b','linewidth',3);
grid on, title 'Densities functions';
legend('hist','trn2000','trn200', 'trn20');
hold off;
print('mle_estimatesA.png','-dpng');

figure(figureC);
hold on;
plot(dom',[normpdf(dom,DC.Mean,DC.Sigma)'],'b','linewidth',3);
grid on, title 'Densities functions';
legend('hist','trn2000','trn200', 'trn20');
hold off;
print('mle_estimatesC.png','-dpng');


...

%% Estimating the optimal bayesian strategy

...
filenames = {'mle_classif2000.png'; 'mle_classif200.png'; 'mle_classif20.png'};
for i = 1:3
    DA = Distributions{2*i -1};
    DC = Distributions{2*i};
    % Computing features vectors (test data)
    xtst = compute_measurement_lr_cont(tst.images);

    % Classify images
    q_x = find_strategy_2normal(DA,DC);

    % Classification error
    ClassError = classification_error_2normal(tst.images, tst.labels, q_x)

    % Displaying images

    show_classification(tst.images, classify_2normal(tst.images, q_x), 'AC')
    print(filenames{i}, '-dpng');
end;
