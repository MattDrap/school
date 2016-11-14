function [Rb, tb,inlb]=ransac_p3p(X, u, K, threshold,confidence)
%UNTITLED10 Summary of this function goes here
%  Detailed explanation goes here
  miterator = 1;
  num_of_miters = inf;
  number_of_inl = 0;
  number_of_rob = 0;
  nthreshold = threshold*threshold;
  number_of_points = size(u , 2);
  
  up = e2p(u);
  Xp = e2p(X);
  
  iK = inv(K);
  
  upiK = iK * up;
 
    while miterator < num_of_miters
        sampled = sample(3, number_of_points);
        res = p3p_grunert( Xp(:, sampled), upiK(:, sampled)); 
    
        for i = 1:size(res,2)
            Xc = res{1};
            [R, t] = XX2Rt_simple( Xp(:, sampled), Xc );
            P = [R t];
            P_full = K*[R t];

            proj_Xp = P_full*Xp;
            in_front = proj_Xp(3, :) > 0;

            e = p2e(proj_Xp) - p2e(up);
            err = sum(e.^2);

            inl = in_front & (err <= nthreshold);

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


                num_of_miters = nsamples(floor(number_of_inl), number_of_points, 3, confidence);
                sprintf('Iteration %d / %d', miterator, num_of_miters)
            end
        end
        miterator = miterator+1;
    end