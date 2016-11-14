function [F inl]=ransac_f(u, th, conf)
   
   samples=0;
   num_samples=inf;
   num_pts = size(u,2);
   num_inl = 0;
   th = th*th;
   
   while samples<num_samples
      s = sample(7, num_pts);
      Fs = u2f7(u(:,s));
      for i=1:size(Fs,3)
         dst = fds(Fs(:,:,i), u);
         if (num_inl < sum(dst<th))
            % remember inliers...
            inl = dst<th; num_inl = sum(inl);
            F=Fs(:,:,i);
            num_samples = nsamples(num_inl, num_pts, 7, conf);
         end;
      end;
      samples=samples+1;
   end;
   