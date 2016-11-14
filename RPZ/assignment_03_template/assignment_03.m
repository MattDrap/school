load rpz_13_minimax

% initialize stpr toolbox 
run('../assignment_02_template/assignment_02_template/stprtool/stprpath.m')

% Copy needed files from previous assignment to this folder. 
% Adding path to the previous assignment is not sufficient. Upload system
% requires your code to be self contained.

% D1 priors
p_1 = 0:0.01:1;

%%  continuous


risk = zeros(size(p_1));
% fill your initials
D1 = cont.M;
D2 = cont.B;
letters = 'MB';

for i = 1 : length(p_1)
    D1.Prior = p_1(i);
    D2.Prior = 1 - p_1(i);
    risk(i) = bayes_risk_2normal(D1, D2, find_strategy_2normal(D1, D2));
end

plot(p_1,risk), grid, hold on;


D1.Prior = 0.25;
D2.Prior = 1 - D1.Prior;

risk_fix = risk_fix_q_cont(D1,D2,p_1,find_strategy_2normal(D1, D2));

plot(p_1,risk_fix, 'k');

%

worst_risk = worst_risk_cont(D1, D2, p_1);

plot(p_1,worst_risk,'r');
% ylim([0 0.1])
print('plots_cont.png', '-dpng');

[q_minimax_cont risk_minimax_cont] = minmax_strategy_cont(D1, D2)

[images_test_set labels_test_set] = create_test_set(images_test, letters);

labels_estimated_cont = classify_2normal(images_test_set, q_minimax_cont);

show_classification(images_test_set, labels_estimated_cont, letters)
print('minmax_classif_cont.png', '-dpng');
error_cont = classification_error_2normal(images_test_set, labels_test_set, q_minimax_cont);


%% Discrete

risk = zeros(size(p_1));
% fill your initials
D1 = discrete.M;
D2 = discrete.B;
letters = 'MB';

% zero one cost function (each error is penalised equally independent of the class)
W = [0 1; 1 0];

for i = 1 : length(p_1)
    D1.Prior = p_1(i);
    D2.Prior = 1 - p_1(i);
    risk(i) = bayes_risk_discrete(D1, D2, W, find_strategy_discrete(D1, D2, W));
end

figure;
plot(p_1,risk), grid, hold on;

%

D1.Prior = 0.25;
D2.Prior = 1 - D1.Prior;

risk_fix = risk_fix_q_discrete(D1,D2,p_1,find_strategy_discrete(D1, D2, W));

plot(p_1,risk_fix, 'k');

%

worst_risk = worst_risk_discrete(D1, D2, p_1);

plot(p_1,worst_risk,'r');

%ylim([0 0.2])
print('plots_discrete.png', '-dpng');

[q_minimax_discrete risk_minimax_discrete] = minmax_strategy_discrete(D1, D2)

[images_test_set labels_test_set] = create_test_set(images_test, letters);

labels_estimated_discrete = classify_discrete(images_test_set, q_minimax_discrete);

show_classification(images_test_set, labels_estimated_discrete, letters)
print('minmax_classif_discrete.png', '-dpng');
error_discrete = classification_error_discrete(images_test_set, labels_test_set, q_minimax_discrete);

