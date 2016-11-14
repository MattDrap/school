load data_33rpz_cv02

%%  discrete

W = [0 1;
     1 0];
% W = [0 5; 1 0];

q_discrete = find_strategy_discrete(discreteA, discreteC, W)

visualize_discrete(discreteA, discreteC, q_discrete)
R_discrete = bayes_risk_discrete(discreteA, discreteC, W, q_discrete)

print('classif_W1.png', '-dpng')

W2 = [0 5; 1 0];
q_discrete2 = find_strategy_discrete(discreteA, discreteC, W2);
visualize_discrete(discreteA, discreteC, q_discrete2)
R_discrete2 = bayes_risk_discrete(discreteA, discreteC, W2, q_discrete2)
print('classif_W2.png', '-dpng');

% result not used, inspect the values e.g. with hist function
measurements_discrete = compute_measurement_lr_discrete(images_test);

% result not used, inspect the values 
labels_estimated_discrete = classify_discrete(images_test, q_discrete);

error_discrete = classification_error_discrete(images_test, labels_test, q_discrete)

%% visualization
I_A = images_test(:,:,labels_estimated_discrete == 1);
I_C = images_test(:,:,labels_estimated_discrete == 2);
figure, subplot(1,2,1), montage(permute(I_A, [1 2 4 3])), title A;
subplot(1,2,2), montage(permute(I_C, [1 2 4 3])),title C;
print('decision_discrete.png', '-dpng');
%% continous

% we are searching for bayesian strategy for 2 normal distributions and
% zero-one cost function
% W = [0 1;
%      1 0];

% initialize stpr toolbox 
run('stprtool/stprpath.m')

% result not used, inspect the values e.g. with hist function
measurements_cont = compute_measurement_lr_cont(images_test);
%%
priors = 0:0.1:1;
r_opt = zeros(1:length(priors));
r = zeros(1:length(priors));
for i = 1:length(priors)

contA.Sigma = 2;
contA.Mean = -5;
contA.Prior = priors(i);

contC.Sigma = 5;
contC.Mean = 1;
contC.Prior = 1 - priors(i);

q_cont2 = find_strategy_2normal(contA, contC)
q_cont = find_strategy_2normal(contA, contC)
%visualize_2norm(contA, contC, q_cont)
print('thresholds.png', '-dpng');


q_cont.decision = [2, 1, 2];
q_cont.t1 = -8;
q_cont.t2 = -4.2;

R_cont = bayes_risk_2normal(contA, contC, q_cont);
R_cont2 = bayes_risk_2normal(contA, contC, q_cont2);

r_opt(i) = R_cont;
r(i) = R_cont2;
end

plot(priors, r_opt);
%%
% result not used, inspect the values 
labels_estimated_cont = classify_2normal(images_test, q_cont);

error_cont = classification_error_2normal(images_test, labels_test, q_cont)

%% visualization
I_A = images_test(:,:,labels_estimated_cont == 1);
I_C = images_test(:,:,labels_estimated_cont == 2);
figure, subplot(1,2,1), montage(permute(I_A, [1 2 4 3])), title A;
subplot(1,2,2), montage(permute(I_C, [1 2 4 3])),title C;
print('decision_2normal.png', '-dpng');