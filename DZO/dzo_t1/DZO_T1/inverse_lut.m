function inv_lut = inverse_lut(lut)
% function inv_lut = inverse_lut(lut)
%
% returns the inverse of an input LUT.
h = linspace(0,1,length(lut));
[ll, in, inb] = unique(lut);
nh = h(in);
inv_lut = interp1(ll, nh, h);
