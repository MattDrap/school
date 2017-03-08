function [Ha,ainl, Hbbest, inl2, common_line]=ransac_h2(u,threshold,confidence)
%UNTITLED10 Summary of this function goes here
%  Detailed explanation goes here
  miterator = 1;
  num_of_miters = inf;
  number_of_inl = 0;
  nthreshold = threshold*threshold;
  [Ha, ainl] = ransac_h(u, threshold, confidence);
  
  
  u = u(:, ~ainl);
  
  number_of_points = size(u, 2);
  Hbbest = zeros(3,3);
  inl2 = zeros(1, number_of_points);
  
  iHa = inv(Ha);
  
 while miterator < num_of_miters
      sampled = sample(4, number_of_points);
      mpoints = u(:, sampled);
      Homo = u2h(mpoints);
      if isempty(Homo)
          continue;
      end
      
     Hm = iHa * Homo;
     if any(any(isnan(Hm))) || any(any(isinf(Hm)))
        miterator = miterator + 1;
        continue;
     end
     [x, l] = eig(Hm);
     l = diag(l)';
     l_shift = [abs(l(1)-l(2)) abs(l(1)-l(3)) abs(l(2)-l(3))];
     [val,ind] = min(l_shift);
     
      if val < 1e-3 && all(isreal(l))
        if ind == 1
            A = x(:,1);
            B = x(:,2);
        elseif ind == 2
            A = x(:,1);
            B = x(:,3);
        else
            A = x(:,2);
            B = x(:,3);
        end
        common_line = cross(A,B);
        distances = hdist(Homo, u);
        if (number_of_inl < sum(distances < nthreshold))
            Hbbest = Homo;
            inl2 = distances < nthreshold;
            number_of_inl = sum(inl2);
        

            num_of_miters = nsamples(number_of_inl, number_of_points, 4, confidence);
        end
      end
      miterator = miterator+1;
      sprintf('Inner %d / %d', miterator, num_of_miters)
  end