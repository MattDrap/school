% Converts CNF expressions to DNF
% cnf (input) and dnf (output) are cell arrays containing vectors of 
% numbers. Positive numbers denote boolean attributes, negative numbers denote negated 
% attributes.
% Example: Let us have three variables - A, B, C, then {[1 -2], [3]}
% represents the following cnf formula: (A or not B) and C or if it is
% treated as a dnf formula, it represnts: (A and not B) or C
function [dnf] = cnf2dnf(cnf)
    dnf = distribute(cnf);
end

function conjunctions = distribute(clauses)
    conjunctions = {};
    for i = clauses{1}
        conjunctions{end+1} = i;
    end
    for i = 2:length(clauses)
        new_conjunctions = {};
        for j = clauses{i}
            for k = 1:length(conjunctions)
                if sum(conjunctions{k} == -j) == 0
                    if sum(conjunctions{k} == j) == 0
                        new_conjunctions{end+1} = [conjunctions{k} j];
                    else
                        new_conjunctions{end+1} = conjunctions{k};
                    end
                end
            end
        end
        conjunctions = new_conjunctions;
        conjunctions = my_unique(conjunctions);
    end
end

function uniq = my_unique(cell_array)
    uniq = {};
    vectors_with_same_lengths = {};
    max_length = 0;
    for i = 1:length(cell_array)
        new_max_length = max([max_length length(cell_array{i})]);
        for j = (max_length+1):new_max_length
            vectors_with_same_lengths{j} = [];
        end
        vectors_with_same_lengths{length(cell_array{i})} = [vectors_with_same_lengths{length(cell_array{i})}; cell_array{i}];
        max_length = new_max_length;
    end
    % remove the same ones
    for i = 1:max_length
        if ~isempty(vectors_with_same_lengths{i})
            u = unique(vectors_with_same_lengths{i}, 'rows');
            for j = 1:size(u,1)
                uniq{end+1} = u(j,:);
            end
        end
    end
    % remove redundant ones
    redundant = zeros(1,length(uniq));
    for i = 1:length(uniq)
        for j = 1:length(uniq)
            if i ~= j
                if my_subset(uniq{i}, uniq{j})
                    redundant(j) = 1;
                end
            end
        end
    end
    uniq = uniq(find(1-redundant));
end

function subset = my_subset(a,b)
    subset = (length(a) == length(intersect(a,b)));
end