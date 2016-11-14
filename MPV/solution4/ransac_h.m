function [H inl]=ransac_h(u, th, conf)
   
   samples=0;
   num_samples=inf;
   num_pts = size(u,2);
   num_inl = 0;
   th = th*th;
   
   while samples<num_samples
      s = sample(4, num_pts);
      Hs = u2h(u(:,s));
      dst = hdist(Hs, u);
      if (num_inl < sum(dst<th))
         % remember inliers...
         H = Hs;
         inl = dst<th; num_inl = sum(inl);
         % local optimisation, take all precise points and reestimate
%          Hlo = u2h(u(:,dst<th/4));
%          dstlo = hdist(Hlo, u);
%          if (sum(dstlo<th) > num_inl)
%             % a better model was found
%             H=Hlo; inl = dstlo<th; num_inl = sum(inl);
%          end;
         num_samples = nsamples(num_inl, num_pts, 4, conf);
      end;
      samples=samples+1;
   end;
   