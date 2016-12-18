function acc = classify(X, colors)
% CLASSIFY measure prediction accuracy of classification trees
%
% acc = classify(X, colors)
%
% X ... NxD matrix with N samples of D dimensions
% colors ... Nx1 matrix with class assignment
% acc ... number between 0 and 1 with prediction accuracy
%
% Note: Internaly, there is a 50-fold crossvalidation going on.

acc = 0;
folds = 50;

for i=0:(folds-1);
    from = floor(  i   * size(X,1) / folds) + 1;
    upto = ceil( (i+1) * size(X,1) / folds);
    
    m1 = [1:(from-1) (upto+1):size(X,1)];
    m2 = from:upto;
    
    tree = ClassificationTree.fit(X(m1,:), colors(m1,:));
    pred = predict(tree, X(m2,:));
    diff = pred - colors(m2,:);
    fine = diff == 0;
    
    acc = acc + sum(fine) / size(fine,1) / folds;
end
