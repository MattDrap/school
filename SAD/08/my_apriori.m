function [frequent_itemsets] = my_apriori(database, min_frequency)
    candidates = {};
    for i = 1:size(database,2)
        candidates{i} = [i];
    end
    candidates = prune_itemsets(candidates, database, min_frequency);
    frequent_itemsets = candidates;

    % Here, you should fill in the code of the apriori algorithm 
    % (see slides of the lecture: "APRIORI algorithm")
    L = frequent_itemsets;
    while(~isempty(L))
        Cn = apriori_gen(L', 1:size(database, 2));
        Ln = prune_itemsets(Cn, database, min_frequency);
        frequent_itemsets = [frequent_itemsets, Ln'];
        L = Ln';
    end
end

function nextWords = apriori_gen(words, sortedA)
%-----------------------------------------------------------
% created by Jan Hrdlicka, 16.9.2010
%-----------------------------------------------------------
% Generates next level words(itemsets).
% input is cell array "words" with words (arrays of items represented by numbers)
% and vector of sorted items "sortedA" with size 1xM, where M is number of
% items. 
% Size of the cell array "words" is Nx1, where N is number of words. Word
% is vector with size 1xI, where I is number of items in the current word.
    nextWords = {};
    for i = 1:size(words,1)
        actWord = words{i,1};
        ind = find(sortedA==actWord(end));
        if ind~=length(sortedA)
            for j = sortedA(ind+1:end)
                %We would have to check every N-1 subset
%                 sub = combnk(length([actWord j]), length([actWord j]) - 1);
%                 ww = [actWord j];
%                 dont = false;
%                 for possub = sub
%                     is_there = false;
%                     for wi = 1:length(words)
%                         if(words{wi} == ww(possub))
%                             is_there = true;
%                             break;
%                         end
%                     end
%                     if(~is_there)
%                         dont = true;
%                     end
%                 end
%                 if(~dont)
%                     nextWords{end+1,1} = [actWord j];
%                 end
                
                 nextWords{end+1,1} = [actWord j];
            end
        end
    end
end

function pruned_itemsets = prune_itemsets(itemsets, database, min_frequency)
    frequencies = compute_frequencies(itemsets, database);
    pruned_itemsets = itemsets(frequencies >= min_frequency);
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