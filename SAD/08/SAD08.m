clear;
close all;
load('marketBasket.mat');
min_freq = 0.03;
[frequent_itemsets] = my_apriori(tranDb, min_freq);
%%
min_conf = 0.7;
rules = associationRules(frequent_itemsets, min_conf, tranDb);
temp = info(2:end);
[~, ind] = sort([rules{:, 4}], 'descend');
sorted_rules = rules(ind, :);
printRules(sorted_rules, temp, 'test.txt');