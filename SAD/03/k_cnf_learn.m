% Function for learning k-CNF expressions
% examples: a matrix, rows are examples, columns are attributes, 1 ...
% true, -1 ... false
% labels: class-labels of the examples, 1 ... positive examples, -1 ...
% negative examples
% k in k-CNF
function [ k_cnf ] = k_cnf_learn( examples, labels, k )
    % Transform the dataset by adding new derived attributes
    % (correponding to k-disjunctions... you can use function 'transform') 
    % and then learn a monotone conjunction on the new representation.
    
    [ transformed_examples, masks ] = transform(examples, k);
    %...TODO
    k_cnf = {};
    %transform only positive examples to 0 1 logic, bcs they are sufficient
    pos_tr_ex = transformed_examples(labels == 1, :);
    pos_tr_ex = pos_tr_ex >= 1;
    size_vars = size(pos_tr_ex, 2);
    size_examples = size(pos_tr_ex, 1);
    
    hypothesis = zeros(1, size_vars);
    
    %and throught examples and find hypothesis through it
    for j = 1:size_vars
        is_true = true;
        for i = 1:size_examples
            is_true = is_true & pos_tr_ex(i, j);
        end
        hypothesis(j) = is_true;
    end
    
    % Check if the learned conjunction correctly separates the dataset 
    % (otherwise we can return an empty cell array or something to indicate that
    % it is impossible to split the dataset by any k-cnf expression for the given k) -
    % note that monotone conjunctions can be learned just taking into
    % account the positive examples so we also need to check whether the learned
    % conjunction does not cover a negative example
    
    %TEST
    %transfrom examples and labels to 0 1 logic
    tt = transformed_examples >= 1;
    ll = labels >= 1;
    %for every example try if hypothesis satisfy
    for i = 1:size(transformed_examples, 1);
        is_t = true;
        for j = 1:size(transformed_examples, 2)
            if hypothesis(j) == 1
                is_t = is_t & tt(i, j);
            end
        end
        
        if is_t ~= ll(i)
            return;
        end
    end
    
    %transform back to k_cnf
    for i = 1:size_vars
        if hypothesis(i) == 1
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