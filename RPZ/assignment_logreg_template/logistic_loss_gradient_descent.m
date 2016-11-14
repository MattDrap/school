function [w, wt, Et] = logistic_loss_gradient_descent(X, y, w_init, epsilon)
% [w, wt, Et] = logistic_loss_gradient_descent(X, y, w_init, epsilon)
%
%   Performs gradient descent optimization of the logistic loss function.
%
%   Parameters:
%       X - d-dimensional observations of size [d, number_of_observations]
%       y - labels of the observations of size [1, number_of_observations]
%       w_init - initial weights of size [d, 1]
%       epsilon - parameter of termination condition: norm(w_new - w_prev) <= epsilon
%
%   Return:
%       w - resulting weights
%       wt - progress of weights (of size [1, number_of_iterations])
%       Et - progress of logistic loss (of size [d, number_of_iterations])
w = w_init;
step_size = 1.0;
Et = logistic_loss(X, y, w);
wt = w;
g = logistic_loss_gradient(X,y, w);
w_prev = w - 100;

while(norm(w - w_prev)) > epsilon
    gn = logistic_loss_gradient(X,y, w - step_size * g);
    Enew = logistic_loss(X, y, w - step_size * g);
    if Enew <= Et(end)
        w_prev = w;
        w = w - step_size * g;
        Et = [Et, Enew];
        wt = [wt, w];
        g = gn;
        step_size = step_size * 2;
    else
        step_size = step_size / 2;
    end
end
