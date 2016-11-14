function idf=getidf(vw, num_words)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
N = numel(vw);
ins_lengths = cellfun('length', vw);
in_file = zeros(1, sum(ins_lengths));
start = 1;
for i=1:N
   in_file(start:start-1 + ins_lengths(i)) = i;
   start = start + ins_lengths(i);
end
DB =sparse(in_file, double([vw{:}]), ones(1,sum(ins_lengths)), N, num_words);
df = sum(DB >= 1);

idf = log(N./df);
idf(df == 0) = 0;
end

