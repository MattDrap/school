function [Rb, tb,inlb, miterator]=ransac_p3p(X, u, K, threshold,confidence)
%UNTITLED10 Summary of this function goes here
%  Detailed explanation goes here
  miterator = 1;
  num_of_miters = inf;
  number_of_inl = 0;
  %number_of_rob = 0;
  nthreshold = threshold*threshold;
  number_of_points = size(u , 2);
  
  up = e2p(u);
  Xp = e2p(X);
  
  iK = inv(K);
  
  upiK = iK * up;
 
    while miterator < num_of_miters
        sampled = sample(3, number_of_points);
        res = p3p_grunert( Xp(:, sampled), upiK(:, sampled)); 
    
        for r =res
            Xc = r{1};
            [R, t] = XX2Rt_simple( Xp(:, sampled), Xc );
            
            P_full = K*[R t];
            in_front = getDepth(P_full, Xp) > 0;

            proj_Xp_inl = P_full*Xp(:, in_front);

            e = p2e(proj_Xp_inl) - p2e(up(:, in_front));
            err = sum(e.^2);

            inl = in_front;
            inl_inl = err <= nthreshold;
            i_in_front = find(inl);
            inl(i_in_front(~inl_inl)) = 0;

            %rob_e = 1 - (err(inl)/nthreshold);
            if (number_of_inl < sum(inl))
            %if (number_of_rob < sum(rob_e) / size(rob_e, 2))
                Rb = R;
                tb = t;
                inlb = inl;
                %
                number_of_inl = sum(inlb);
                %number_of_rob = sum(rob_e) / size(rob_e, 2);
                %number_of_inl = sum(inlb);


                num_of_miters = nsamples(number_of_inl, number_of_points, 3, confidence);
                sprintf('Iteration %d / %d', miterator, num_of_miters)
            end
        end
        miterator = miterator+1;
    end
    sprintf('Iteration %d / %d', miterator, num_of_miters)