% function for generating learning examples, "dimension" is number of
% propositional variables, "juntaSize" is number of variables in the
% concept, "noOfExamples" is the number of examples to be generated,
% noiseRatio is the fraction of labels that should be inverted (i.e. corrupted)
function [examples, labels, concept] = generateExamples(dimension, juntaSize, noOfExamples, noiseRatio)

junta = zeros(1, juntaSize);
% we set a random subset of the propositional variables in the concept to 1
% (TRUE) and another random subset  to -1 (FALSE)
r = rand(1, juntaSize);
junta(r < 1/2) = -1;
junta(r >= 1/2) = 1;
concept = [junta zeros(1,dimension-juntaSize)];
concept = concept(randperm(size(concept,2)));

examples = rand(noOfExamples, dimension);
labels = zeros(1,noOfExamples);
thresholds = rand(1,dimension);

for i = 1:noOfExamples
    examples(i,:) = boolFromDouble(examples(i,:));
    % we compute label using the generated concept
    labels(i) = conj_classify(concept, examples(i,:));
    examples(i,:) = addCorrelation(examples(i,:), labels(i), concept, 0.9);
end
% finally, we randomly corrupt a noiseRatio-fraction of labels
corruptedLabels = rand(1,noOfExamples) < noiseRatio;
labels(corruptedLabels) = -labels(corruptedLabels);

% this function is used to introduce correlation of variables not contained
% in the concept with the class - in order to confuse the learner and make
% learning of the true concept harder. Note that this using this function
% we do not change the concept but merely the distribution of learning
% examples.
function out = addCorrelation(example, label, concept, prob)
out = example;
if label == 1
    for i = 1:length(concept)
        if concept(i) == 0 && rand(1,1) < prob
            out(i) = 1;
        end
    end
else
    for i = 1:length(concept)
        if concept(i) == 0 && rand(1,1) < prob
            out(i) = -1;
        end
    end
end

function out = boolFromDouble(r)
out = zeros(1, length(r));
out(r < 0.5) = -1;
out(r >= 0.5) = 1;