function [ Rules] = associationRules( frequent_itemsets, min_conf, database )
%ASSOCIATIONRULES Creates association rules from frequent itemsets
%   frequent_itemsets -- list of frequent itemsets from the output of
%   functino my_apriori
%   min_conf -- minimum confidence
%   database -- transaction database

frequent_itemsets = frequent_itemsets';
Rules = {};
ant = frequent_itemsets;
succ = cell(length(frequent_itemsets), 1);
while size(ant, 1) > 0
    [ant, succ] = newGenerationRules(ant, succ);
    supp_ant = compute_frequencies(ant, database);
    for k = 1:length(ant)
        orig = sort([ant{k},succ{k}]);
        supp_l = compute_frequencies({orig}, database);
        conf = supp_l ./ supp_ant(k);
        if(conf >= min_conf)
            Rules = [Rules; ...
                [ant(k), succ(k), supp_ant(k), conf] ];
        end
    end
end
end
function frequencies = compute_frequencies(itemsets, database)
    database_length = size(database,1);
    itemsets_count = length(itemsets);
    frequencies = ones(1,itemsets_count);
    for i = 1:itemsets_count
        itemset = itemsets{i};
        frequencies(i) = sum(all(database(:,itemset)==1,2))/database_length;
    end
end