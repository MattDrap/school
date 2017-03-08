function [W1 W2 b1 b2] = theta2params(theta, thetaSize)
% Converts vector theta of all model parameters to weights and biases.

% Assign the parameters of the row vector theta into W1, W2, b1, b2
W1 = theta(1:prod(thetaSize(1,:)));
W2 = theta(1+length(W1):sum(prod(thetaSize(1:2,:),2)));
b1 = theta(1+length(W1)+length(W2):sum(prod(thetaSize(1:3,:),2)));
b2 = theta(1+length(W1)+length(W2)+length(b1):end);

% Reshape the parameters
W1 = reshape(W1, thetaSize(1,1), thetaSize(1,2));
W2 = reshape(W2, thetaSize(2,1), thetaSize(2,2));
b1 = reshape(b1, thetaSize(3,1), thetaSize(3,2));
b2 = reshape(b2, thetaSize(4,1), thetaSize(4,2));

end