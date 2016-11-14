%
% sum_eigenvalues_graph(lambdas)
%
% Function for plotting the cumulative sum of eigenvalues
%
% Inputs:
%       lambdas - Eigenvalues corresponging to the PC (decreasing order), 
%                 the matrix of size [width*height, 1]
%

function sum_eigenvalues_graph(lambdas)
    
    % Compute the cumulative sum

	% HERE YOUR CODE
    cum_sum = cumsum(lambdas);
    
    % Locate the 65% and 90% of approximation
    lower_bound = find(cum_sum>0.65);
    lower_bound = lower_bound(1);
    upper_bound = find(cum_sum>0.9);
    upper_bound = upper_bound(1);
    
    % Plot boundaries (red lines) and graph of the cumulative sum
    figure, plot(cum_sum), grid on, hold on;
    line([lower_bound lower_bound], [0 cum_sum(lower_bound)],'color','r');
    line([upper_bound upper_bound], [0 cum_sum(upper_bound)],'color','r');
    line([0 lower_bound], [cum_sum(lower_bound) cum_sum(lower_bound)],'color','r');
    line([0 upper_bound], [cum_sum(upper_bound) cum_sum(upper_bound)],'color','r');
    axis([0 numel(lambdas) 0 1]);
    xlabel 'Number of eigenvalues'
    ylabel 'Cumsum of eigenvalues'
    
end
