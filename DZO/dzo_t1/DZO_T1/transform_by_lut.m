function out = transform_by_lut(M, lut)
% function out = transform_by_lut(M, lut)
%
% performs transformation of matrix M by a look-up table LUT.

N = length(lut); 

% map value=0 to idx=1, and 
%     value=1 to idx=N

idx = round( M*(N-1)+1 ); 

% this would be needed if no values in M are <0 or >1:
idx(idx<1) = 1; 
idx(idx>N) = N; 

out = lut(idx); 


