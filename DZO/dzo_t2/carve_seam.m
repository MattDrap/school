function data_carved = carve_seam(seam, data)
% Carve one vertical seam from MxNx3 matrix of double values or MxN matrix
% of logical values
%
% Input:
%   seam [Mx1] seam(i) = j iff the elements (i,j,1:3) (in case of MxNx3
%     input data matrix) or the element (i,j) (in case of MxN input) should
%     be carved out from the data matrix
%   data [MxNx3 (double) or MxN (logical)] data matrix from which the seam
%     should be carved
%
% Output:
%   data_carved [Mx(N-1)x3 (double) or Mx(N-1) (logical)] data matrix
%     having one vertical seam carved out; the data type of the matrix
%     should correspond to the type of the input matrix

[h, w, c] = size(data);

if islogical(data)
    data_carved = false(h, w - 1, c);
else
    data_carved = zeros(h, w - 1, c);
end
 
for i = 1:h
    rest = [data(i, 1:seam(i) - 1, :), data(i, seam(i)+1:end, :)];
    sq_rest = squeeze(rest);
    data_carved(i, :, :) = sq_rest;
end
end
