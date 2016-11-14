function [lineBest, inl]=ransac(u,threshold,confidence)
%UNTITLED10 Summary of this function goes here
%  Detailed explanation goes here
  miterator = 1;
  num_of_miters = inf;
  number_of_inl = 0;
  number_of_points = size(u, 2);
  inl = zeros(1, number_of_points);
  nthreshold = threshold*threshold;
  
  while miterator < num_of_miters
      sampled = sample(2, number_of_points);
      mpoints = u(:, sampled);
      
      line = cross(mpoints(:, 1), mpoints(:, 2));
      line = line / norm(line(1:2));
      
      distances = (line'*u).^2;
      if (number_of_inl < sum(distances < nthreshold))
        lineBest = line;
        inl = distances < nthreshold;
        number_of_inl = sum(inl);       

        num_of_miters = nsamples(number_of_inl, number_of_points, 2, confidence);
      end;
      miterator = miterator+1;
  end