function [Rb, tb,Fb,inlb, best_err]=ransac_e(u,K, threshold,confidence)
%UNTITLED10 Summary of this function goes here
%  Detailed explanation goes here
  miterator = 1;
  num_of_miters = inf;
  number_of_inl = 0;
  nthreshold = threshold*threshold;
  number_of_points = size(u , 2);
  u1p = e2p(u(1:2, :));
  u2p = e2p(u(3:4, :));
  iK = inv(K);
  
  P1 = [eye(3,3), zeros(3,1)];
  
  u1piK = iK * u1p;
  u2piK = iK * u2p;
 while miterator < num_of_miters
      sampled = sample(5, number_of_points);
      Es = p5gb( u1piK(:, sampled), u2piK(:, sampled)); 
      
    for i = 1:size(Es,2)
      E = reshape( Es(:,i), 3, 3 )'; % row-ordered !
      F = iK' * E * iK;
      err = err_F_sampson(F, u1p, u2p);  
      inl = err < nthreshold;
      rob_e = 1 - (err(inl)/nthreshold);
      %if (number_of_inl < sum(err < nthreshold))
      if (number_of_inl < sum(rob_e))
         [R, t] = EutoRt(E, u1piK(:, sampled), u2piK(:, sampled));
         if ~isempty(R)
             
              P2 = R*[eye(3,3), t];
              X = Pu2X(P1, P2, u1piK(:, inl), u2piK(:, inl));
              
              z = getDepth(P1, X) > 0;
              z2 = getDepth(P2, X) > 0;
              
              ninl = z & z2;
              ind_inl = find(inl);
              inl( ind_inl( ~ninl) ) = 0;
              rob_e = 1 - (err(inl)/nthreshold);
              
              if (number_of_inl < sum(rob_e))
                Rb = R;
                tb = t;
                Fb = F;
                inlb = inl;
                %
                number_of_inl = sum(rob_e);
                best_err = rob_e;
                %number_of_inl = sum(inlb);


                num_of_miters = nsamples(floor(sum(inlb)), number_of_points, 5, confidence);
              end
          end
     end
    end
  miterator = miterator+1;
  sprintf('Iteration %d / %d', miterator, num_of_miters)
  end