function lut = lut_from_range(x_low, x_high, N)
% function lut = lut_from_range(x_low, x_high, N)
%
% creates LUT with N elements which: 
% 
% =0 for x<=x_low
% =1 for x>=x_high
% goes linearly from 0 to 1 between x_low and x_high

%=======================================================
% remove the following lines and implement the function.
% NOTE: use interp1 for implementing this function.
lut = linspace(0, 1, N);
lower = find(lut <= x_low);
upper = find(lut >= x_high);
lower_bound = max(lower);
upper_bound = min(upper);
interp = interp1([lut(lower_bound),lut(upper_bound)], [0,1],lut(lower_bound:upper_bound));
lut = [zeros(1, length(lower) - 1), interp, ones(1,length(upper) - 1)];