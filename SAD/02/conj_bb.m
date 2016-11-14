% Branch-and-bound algorithm for finding conjunctions which minimize
% training error. "k" is the maximum size of conjunctions
function out = conj_bb(k, examples, labels)

% in order to see effects of overfitting, we need the algorithm to prefer
% longer conjunctions. 
prefer_long = 1;

front = priorityFront();

% we initialize the front with the empty conjunction
emptyConjunction = zeros(1, size(examples, 2));
front.add(conj_error(emptyConjunction, examples, labels), emptyConjunction);

bestConjunction = emptyConjunction;
besterror = conj_error(emptyConjunction, examples, labels);

% an ordinary implementation of best first search algorithm
iters = 0;
while ~front.isEmpty
    conjunction = front.smallest;
    conjunction = conjunction';
    error = conj_error(conjunction, examples, labels);
    lowerBound = conj_error(conjunction, examples(labels == 1,:), labels(labels == 1));
    if lowerBound < besterror || (prefer_long == 1 && lowerBound == besterror)
        if error < besterror || (error == besterror && ((prefer_long == 1 && sum(abs(conjunction)) > sum(abs(bestConjunction))) || (prefer_long == 0 && sum(abs(conjunction)) > sum(abs(bestConjunction)))))
            besterror = error;
            bestConjunction = conjunction;
        end
        if error == 0 && prefer_long == 0
            break;
        end
        expand(k, conjunction, examples, labels, front);
    end
    iters = iters+1;
end
out = bestConjunction;

% this is similar to how we expanded item-sets in one of the previous weeks
function expand(k, conj, examples, labels, front)
if sum(abs(conj)) < k
    conjs = allNextConjunctions(conj);
    for i = 1:size(conjs, 1)
        conj_i = conjs(i,:);
        front.add(conj_error(conj_i, examples, labels), conj_i);
    end
end

function conjs = allNextConjunctions(conj)
conjs = [];
usedLiterals = find(abs(conj));
startIndex = 1;
if usedLiterals ~= 0
    startIndex = usedLiterals(end)+1;
end
for i = startIndex:size(conj, 2)
    newConj1 = conj;
    newConj1(i) = 1;
    newConj2 = conj;
    newConj2(i) = -1;
    conjs = [conjs; newConj1; newConj2];
end