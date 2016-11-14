function DB=createdb(vw, num_words)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
N = numel(vw);
ins_lengths = cellfun('length', vw);
in_file = zeros(1, sum(ins_lengths));
start = 1;
for i=1:N
   in_file(start:start-1 + ins_lengths(i)) = i;
   start = start + ins_lengths(i);
end
DB =sparse(in_file, double([vw{:}]), 1, N, num_words);
%%normalize
lens = sqrt(sum(DB.^2, 2));
lens = full(lens);
DB = bsxfun(@times, DB, 1./lens(:));