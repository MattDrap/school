run('../stprtool/stprpath.m');
X = [0, 0, 2, 2, 4, 4;
     2, 1.7, 0,-0.3, 2.4,1.9];
y = [1,1,2,2,3,3];
disp(X);
disp(y);

% Run the perceptron algorithm with at most 100 iterations
[w b] = multiclassperceptron(X, y, 100);

if isnan(w)
    disp('The algorithm did not converge in given iteration limit.');
    return;
end

model.W = w';
model.b = b;
model.fun = 'linclass';
%Show the data and the resulting linear classifier
figure, ppatterns(X,y), hold on, title 'Perceptron algorithm';
pboundary(model);
%for i=1:size(w,1)
%    pline(w(i, :)',b(i));
%end