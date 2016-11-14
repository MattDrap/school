X1 = rand(1,100);
X2 = [rand(1,50) - 0.7, rand(1,30) + 0.4];

X = [X1,X2];
labels = [-1*ones(1,100), ones(1,80)];

number_of_lifts = 7;
alphak = 0.1:(0.9-.1)/7:0.9;
figure();
hold on;
scatter(X1, zeros(size(X1)), 'g');
scatter(X2, ones(size(X2)), 'r');
tempx = -3.5:0.01:3.5;
for j = 1:number_of_lifts
    plot(tempx, atan(alphak(j+1) + alphak(1)*tempx));
end
hold off;

NX = ones(number_of_lifts + 1, size(X, 2));
for i = 1:size(X,2)
    for j = 1:number_of_lifts
        NX(j+1,i) = atan(alphak(j+1) + alphak(1)*X(i));
    end
end
w_init = randn(number_of_lifts + 1, 1);
epsilon = 1e-2;
[w, wt, Et] = logistic_loss_gradient_descent(NX, labels, w_init, epsilon);

figure();
hold on;
scatter(X1, zeros(size(X1)), 'g');
scatter(X2, ones(size(X2)), 'r');
tempx = -3.5:0.01:3.5;
tempy = zeros(number_of_lifts + 1, length(tempx));
for j = 1:number_of_lifts
    tempy(j, :) = w(j+1)* atan(alphak(j+1) + alphak(1)*tempx);
end
plot(tempx, 1/(number_of_lifts + 1)*sum(tempy));
hold off;

p1x = 1./(1+exp(-w'*NX));
figure();
hold on;
scatter(X1, zeros(size(X1)), 'g');
scatter(X2, ones(size(X2)), 'r');
[sortX, I] = sort(X);
sortedp1x = p1x(I);
plot(sortX, sortedp1x);
title('p1x');
hold off;

p2x = 1./(1+exp(w'*NX));
figure();
hold on;
scatter(X1, zeros(size(X1)), 'g');
scatter(X2, ones(size(X2)), 'r');
[sortX, I] = sort(X);
sortedp2x = p2x(I);
plot(sortX, sortedp2x);
title('p2x');
hold off;