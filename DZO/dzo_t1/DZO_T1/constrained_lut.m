function lut_out = constrained_lut(lut_in, max_slope, epsilon)
% function lut_out = constrained_lut(lut_in, max_slope, epsilon)
% 
% for an input LUT 'lut_in', this function computes 'lut_out'
% which:
%
% - has slope which is <= [max_slope * (1+epsilon)] everywhere
% - is close to lut_in
% - lut_in(end) = lut_out(end)
%
% The algorithm works by repeatedly redistributing mass from violating
% slopes to non-violating slopes. The iterations end when no slope 
% higher than [max_slope * (1+epsilon)]
%
% epsilon (>=0) does not have to be specified, in which case
%    epsilon = 0.01 is used as a default. 
%
% If epsilon=0 then the no slope is > max_slope. If epsilon is set
% to a small number (e.g. 0.01) then the algorithm produces almost
% the same result but in much smaller number of iterations. 

if nargin < 3
    epsilon = 0.01; 
end
h = linspace(0, 1, length(lut_in));
dx = h(end) - h(end-1);
slopes = (lut_in(2:end) - lut_in(1:end-1)) ./ dx;

violations = slopes >= (max_slope * (1 + epsilon));
while(sum(violations) > 0)
    to_redistr = slopes(slopes >= max_slope);
    to_redistr = to_redistr - max_slope;
    mass = sum(to_redistr);
    slopes(violations) = max_slope;
    mass_per_bin = mass/length(slopes(~violations));
    slopes(~violations) = slopes(~violations) + mass_per_bin;
    
    violations = slopes >= (max_slope * (1 + epsilon));
end

lut = slopes .* dx;
lut = cumsum(lut)/sum(lut);
lut = [lut_in(1), lut];
lut_out = lut;

