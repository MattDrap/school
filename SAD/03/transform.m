% This function transforms a dataset by adding to it derived attributes
% which correspond to all clauses with length k
% Output:
% transformed_examples ... the transformed examples
% masks ... a matrix where i-th row contains representation of the clause
% that gave rise to i-th attribute of transformed_examples, the rows are 
% indicator-vectors (where 1 at position i means that the i-th variable is 
% contained in the clause in its direct form, and -1 that it is 
% contained in negated form and 0 at position i means that the i-th 
% variable is not contained in the clause at all)
function [ transformed_examples, masks ] = transform( examples, k )
    num_attributes = size(examples, 2);
    transformed_examples = [];
    masks = [];
    indexes_noneg = combnk(1:num_attributes, k);
    for h=1:size(indexes_noneg, 1)
        comb = indexes_noneg(h,:);
        for i=0:k % negations
            negs = combnk(1:k, i);
            for j=1:size(negs, 1) % for each combination of negations
                neg = negs(j,:);
                noneg = setdiff(1:k, neg);
                mask = zeros(1, num_attributes);
                mask(comb(noneg)) = 1;
                mask_neg = zeros(1, num_attributes);
                mask_neg(comb(neg)) = 1;
                new_attribute = 2*((sum(examples(:,find(mask)) == 1, 2) > 0) | (sum(examples(:,find(mask_neg)) == -1, 2) > 0))-1;
                transformed_examples = [transformed_examples, new_attribute];
                masks = [masks; mask-mask_neg];
            end
        end
    end   
end