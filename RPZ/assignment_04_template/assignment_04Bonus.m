% initialize stpr toolbox 
run('../stprtool/stprpath.m')

load data_33rpz_cv04.mat
trnSet = trn_2000;
features = compute_measurement_cont(trnSet.images);

prior_A = estimate_prior(1,trnSet.labels);
prior_C = estimate_prior(2,trnSet.labels);
%% Splitting the trainning data into into classes
indices = trnSet.labels == 1;
indices = repmat(indices, 2, 1);
x_A = features(indices);
x_A = reshape(x_A, 2, length(x_A)/2);
indices = trnSet.labels == 2;
indices = repmat(indices, 2, 1);
x_C = features(indices);
x_C = reshape(x_C, 2, length(x_C)/2);

%% Computing Gaussian models of Maximal Likelihood
[DA.Mean, DA.Cov] = mle_normalBi(x_A);
[DC.Mean, DC.Cov] = mle_normalBi(x_C);

DA.Prior = prior_A;
DC.Prior = prior_C;

figure;
hold on;
pgauss(DA);
P1.X = x_A;
scatter(x_A(1,:), x_A(2,:),1,'g');
pgauss(DC);
scatter(x_C(1,:), x_C(2,:),1,'r');
hold off;