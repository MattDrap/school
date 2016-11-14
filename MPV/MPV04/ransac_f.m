function [Fbest,inl]=ransac_f(u,threshold,confidence)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here
iterator = 1;
num_of_iters = 1000; %inf
number_of_inl = 0;
number_of_points = size(u, 2);
threshold = threshold * threshold;

while iterator < num_of_iters
    points = u(:, sample(7, number_of_points));
    Fs = u2f7(points);
    if isempty(Fs)
        continue;
    end
    for i=1:size(Fs,3)
        dists = fdist(Fs(:,:, i), u);
        if number_of_inl < sum(dists < threshold)
          Fbest = Fs(:, :, i);
          inl = dists < threshold;
          number_of_inl = sum(inl);

          num_of_iters = nsamples(number_of_inl, number_of_points, 7, confidence);
        end;
    end
    iterator = iterator+1;
end

end



