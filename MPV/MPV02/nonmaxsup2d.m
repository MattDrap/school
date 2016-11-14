function maximg=nonmaxsup2d(response,thresh) 
%nonmaxsup2d function that marks 1 for maximum from 8 neighbourhood
%   Detailed explanation goes here

maximg = false(size(response));
maximg(2:end-1, 2:end-1) = response(2:end-1, 2:end-1) > thresh & ...
    response(2:end-1, 2:end-1) > response(1:end - 2, 1:end - 2) & ...
    response(2:end-1, 2:end-1) > response(1:end - 2, 2:end - 1) & ...
    response(2:end-1, 2:end-1) > response(1:end - 2, 3:end) & ...
    response(2:end-1, 2:end-1) > response(2:end - 1, 1:end - 2) & ...
    response(2:end-1, 2:end-1) > response(2:end - 1, 3:end) & ...
    response(2:end-1, 2:end-1) > response(3:end, 1:end - 2) & ...
    response(2:end-1, 2:end-1) > response(3:end, 2:end - 1) & ...
    response(2:end-1, 2:end-1) > response(3:end, 3:end);
end
