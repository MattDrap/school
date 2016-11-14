% Function for learning k-CNF expressions
% examples: a matrix, rows are examples, columns are attributes, 1 ...
% true, -1 ... false
% labels: class-labels of the examples, 1 ... positive examples, -1 ...
% negative examples
% k in k-CNF
function [ k_cnf ] = k_cnf_learn2( examples, labels, k )
    % Transform the dataset by adding new derived attributes
    % (correponding to k-disjunctions... you can use function 'transform') 
    % and then learn a monotone conjunction on the new representation.
    
    [ transformed_examples, masks ] = transform(examples, k);
    %...TODO
    k_cnf = {};
    pos_tr_ex = transformed_examples(labels == 1, :);
    size_vars = size(pos_tr_ex, 2);
    size_examples = size(pos_tr_ex, 1);
    
    hypothesis = [ones(1, size_vars); -1 * ones(1, size_vars)];
    
    for i = 1:size_examples
        for j = 1:size_vars
            if pos_tr_ex(i, j) == -1
                hypothesis(1, j) = 0;
            else
                hypothesis(2, j) = 0;
            end
        end
    end
    new_hyp = zeros(1, size_vars);
    for j = 1:size_vars
        if hypothesis(1, j) == 1 && hypothesis(2, j) == 0
            new_hyp(j) = 1;
        elseif hypothesis(1, j) == 0 && hypothesis(2, j) == 1
            new_hyp(j) = -1;
        elseif hypothesis(1, j) == 0 && hypothesis(2, j) == 0
            new_hyp(j) = 0;
        else
            return;
        end
    end
    % Check if the learned conjunction correctly separates the dataset 
    % (otherwise we can return an empty cell array or something to indicate that
    % it is impossible to split the dataset by any k-cnf expression for the given k) -
    % note that monotone conjunctions can be learned just taking into
    % account the positive examples so we also need to check whether the learned
    % conjunction does not cover a negative example
    %TEST
    tt = transformed_examples >= 1;
    ll = labels >= 1;
    for i = 1:size(transformed_examples, 1);
        is_t = true;
        for j = 1:size(transformed_examples, 2)
            if new_hyp(j) == 1
                is_t = is_t & tt(i, j);
            elseif new_hyp(j) == -1
                is_t = is_t & tt(i, j);
            end
        end
        
        if is_t ~= ll(i)
            return;
        end
    end
    
    for i = 1:size_vars
        if new_hyp(i) == 1
            pos = find(masks(i, :) >= 1);
            neg = find(masks(i, :) <= -1);
            k_cnf(end + 1) = {[-1*neg, pos]};
        end
    end
    
    %...TODO
    
    % The variable cnf should contain the learned cnf expression - it should be a cell array 
    % containing vectors of numbers. Positive numbers denote boolean 
    % attributes from the original data, negative numbers denote negated 
    % attributes from the original data.
    % Example: Let us have three variables - A, B, C, then {[1 -2], [3]}
    % represents the following formula: (A or not B) and C
    %k_cnf = {};
    
    %...TODO
end