%% generation of data

% k1 is the number of used propositional variables
k1 = 6;
% k2 is the number of propositional variables used in the concept (target conjunction)
k2 = 2;
% We generate the examples, "examples" is a matrix where rows correspond to
% examples and columns correspond to propositional variables (i.e
% attributes). We use 1 for TRUE and -1 for FALSE. "labels" is a  vector of
% labels - 1 for positive examples, -1 for negative examples. "concept" is
% a conjunction which (if noise was set to zero) could correctly split the
% examples to positive and negative ones.
[examples labels concept] = generateExamples(k1, k2, 2000, 0.25);

% To make things simple, we will have 50-50 proportion of positive and negative examples
ecount = min([sum(labels == 1) sum(labels == -1)]);
positive_examples = examples(labels == 1,:);
positive_examples = positive_examples(1:ecount,:);
negative_examples = examples(labels == -1,:);
negative_examples = negative_examples(1:ecount,:);
examples = [positive_examples; negative_examples];
labels = [ones(1,ecount), -ones(1,ecount)];

positive_examples = positive_examples(randperm(size(positive_examples,1)),:);
negative_examples = negative_examples(randperm(size(negative_examples,1)),:);

% 100 positive examples and 100 negative examples are used for training, the rest for testing
train_set_size = 200;
pos = min([size(positive_examples,1) train_set_size/2]);
neg = min([size(negative_examples,1) train_set_size/2]);
positive_train_examples = positive_examples(1:pos,:);
negative_train_examples = negative_examples(1:neg,:);
train = [positive_train_examples; negative_train_examples];
positive_train_labels = ones(1,pos);
negative_train_labels = -ones(1,neg);
train_labels = [positive_train_labels, negative_train_labels];
positive_test = positive_examples((pos+1):end,:);
negative_test = negative_examples((neg+1):end,:);
test = [positive_test; negative_test];
test_labels = [ones(1,size(positive_test,1)), -ones(1,size(negative_test,1))];

%% bias-variance trade-off

figure;
title('Small number of learning examples');

% small = number of positive examples in the training set for b-v curve =
% number of negative examples in the training set for b-v curve
small = 10;

bvs_train_small = [];
bvs_test_small = [];

rperm1 = randperm(size(positive_train_examples,1));
rperm2 = randperm(size(negative_train_examples,1));
p_train = positive_train_examples(rperm1,:);
n_train = negative_train_examples(rperm2,:);

% we measure the bias-variance-tradeoff curve several times and then we 
% average the results
for i = 1:floor(train_set_size/2/small)
    
    from = 1+(i-1)*min([size(positive_train_examples,1) small]);
    to = i*min([size(positive_train_examples,1) small]);
    small_train = [p_train(from:to,:); n_train(from:to,:)];
    small_train_labels = [positive_train_labels(from:to) negative_train_labels(from:to)];
    
    % we use the function "conj_bias_variance" to compute the bias
    % variance-tradeoff-curve, the line below computes b-v curve for
    % test-set error...
    bv_errors_small = conj_bias_variance(k1, small_train, small_train_labels, test, test_labels);
    % whereas the next line computes the error on train set (which will be often over-optimistic)
    bv_train_errors_small = conj_bias_variance(k1, small_train, small_train_labels, small_train, small_train_labels);
    
    bvs_test_small = [bvs_test_small; bv_errors_small];
    bvs_train_small = [bvs_train_small; bv_train_errors_small];
end

% we plot the bias-variance-tradeoff curves
plot([[1:k1]' [1:k1]'], [[mean(bvs_test_small)/size(test,1)]' [mean(bvs_train_small)/size(small_train,1)]']);
legend('test-set error', 'train-set error');

%% learning curves

figure;
xs = [];
ys = [];
text_labels = {};
for i = 1:k1
    % the function "conj_learningCurve" constructs a learning curve as an
    % average of several learning curves
    lc = conj_learningCurve(@conj_bb, i, train, test, train_labels, test_labels);
    xs = [xs, ((1:length(lc))/length(lc))'];
    ys = [ys, lc'/size(test,1)];
    text_labels = [text_labels {['k = ' num2str(i)]}]
    plot(xs, ys);
    legend(text_labels);
end
