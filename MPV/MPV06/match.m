function corrs=match(pts1, pts2, par)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    mat_dist=zeros(numel(pts1), numel(pts2));
    right_mega_vec = [pts2.desc];   
    for i=1:numel(pts1)
        mat_dist(i,:) = sqrt(sum((repmat(pts1(i).desc, 1, numel(pts2)) - right_mega_vec).^2));
    end;
    
    switch (par.method)
     case 'mutual'
       [l_mins, l_inds] = min(mat_dist, [], 2);
       [t_mins, t_inds] = min(mat_dist, [], 1);
        
       num_mutual = 0;
       for i=1:numel(l_mins)
          if t_inds(l_inds(i)) == i && l_mins(i)<= par.threshold
             corrs(:,num_mutual+1) = [i; l_inds(i)];
             num_mutual=num_mutual+1;             
          end;
       end;
       
     case 'stable' 
       max_l_t=min(numel(pts1),numel(pts2));
       stable_corr_counter=1;
       for k=1:max_l_t
          [val, index]= min(mat_dist(:));
          [i, j]= ind2sub(size(mat_dist),index);
          if (val > par.threshold)             
             break;
          end;
          corrs(:,stable_corr_counter)= [i;j];
          stable_corr_counter = stable_corr_counter + 1;             
          mat_dist(i,:)=inf; mat_dist(:,j)=inf;
       end;
     case 'sclosest'
        sclosest_corr_counter=1;
        for i=1:numel(pts1)
            temp = mat_dist(i, :);
            [d1, i1]= min(temp);
            temp(i1) = Inf;
            d2 = min(temp);
            if (d1/d2 < 0.8)
                corrs(:,sclosest_corr_counter) = [i; i1];
                sclosest_corr_counter=sclosest_corr_counter+1;             
            end;
        end;
   end;

end

