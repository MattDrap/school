% classifies "example" using conjunction (1 is TRUE, -1 is FALSE), e.g.
% conj_classify([-1 0 1 1], [-1 -1 1 1]) returns 1 and conj_classify([-1 0
% 1 1], [-1 -1 -1 -1]) returns -1
function out = conj_classify(conjunction, example)
indices = (conjunction ~= 0);
if sum(conjunction(indices) == example(indices)) == sum(indices)
    out = 1;
else
    out = -1;
end