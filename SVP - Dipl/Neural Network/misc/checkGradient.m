function numgrad = checkGradient(J, theta)
% Calculate numerical gradients
% theta: a vector of parameters
% J: a function that outputs a real-number. Calling y = J(theta) will 
% return the function value at theta.

numgrad = zeros(size(theta));
e = zeros(length(theta),1);
epsilon = 1e-4;

for i=1:length(theta)    
    e(i) = epsilon;
    numgrad(i) = (J(theta+e)-J(theta-e))/(2*epsilon);
    e(i) = 0;
end

end
