function [Hbest,inl]=ransac_h(u,threshold,confidence)
%UNTITLED10 Summary of this function goes here
%  Detailed explanation goes here
  miterator = 1;
  num_of_miters = inf;
  number_of_inl = 0;
  number_of_points = size(u, 2);
  Hbest = zeros(3,3);
  inl = zeros(1, number_of_points);
  nthreshold = threshold*threshold;
  
  while miterator < num_of_miters
      sampled = sample(4, number_of_points);
      mpoints = u(:, sampled);
      Homo = u2h(mpoints);
      if isempty(Homo)
          continue;
      end
      
      distances = hdist(Homo, u);
      if (number_of_inl < sum(distances < nthreshold))
        Hbest = Homo;
        inl = distances < nthreshold;
        number_of_inl = sum(inl);       

        num_of_miters = nsamples(number_of_inl, number_of_points, 4, confidence);
      end;
      miterator = miterator+1;
  end