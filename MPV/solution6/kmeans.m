function [means, err]=kmeans(K, data)
% exact kmeans 
   
   num_data = size(data,2); max_iter = 20;
   % initialization
   means = data(:, floor(rand(1,K)*num_data)+1);
   
   err = inf;

   for i=1:max_iter
      tic;
      % assign
      [idxs dists] = nearest(means, data);
      t=toc; tic;
      % next iteration
      [c,r] = meshgrid(idxs, 1:size(data,1));
      counts = full(sparse(r,c,ones(size(r))));
      means = full(sparse(r,c,data))./counts;
      % replace unused means
      unused = (counts(1,:)==0);
      means(:,unused) = data(:, floor(rand(1,sum(unused))*num_data)+1);

      % termination
      newerr = sum(dists);     
      t1=toc;
      fprintf(1,'%02d. iteration, overall error: %.5f, %d unused means. Assignement: %0.3fsec, update: %0.3fsec.\n', ...
              i, newerr, sum(unused), t, t1);
      if (err/newerr < 1.0001)
         fprintf(1,'Terminating, improvement is under 0.01%%.\n')
         return;
      end;
      err = newerr;
   end;
   
   