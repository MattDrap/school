function pts=detect_and_describe(img, detpar, descpar)
   
   switch (detpar.type)
     case 'hessian'
       [x,y]=hessian(img, detpar.sigma, detpar.threshold);
       pts = transnorm(img, x, y, 25, descpar);
     case 'harris' 
       [x,y]=harris(img, detpar.sigmad, detpar.sigmai, detpar.threshold);
       pts = transnorm(img, x, y, 25, descpar);
     case 'sshessian'
       [x,y,s]=sshessian(img, detpar.threshold);
       pts = simnorm(img, x, y, s, descpar);
     case 'mser'
       [x,y,a11,a12,a21,a22]=mser_detector(img, detpar);
       pts = affnorm(img, x, y, a11, a12, a21, a22, descpar);
   end;
   
   pts = photonorm(pts);
   
   for i=1:numel(pts)
      switch (descpar.type)
        case 'dct'
          pts(i).desc=dctdesc(pts(i).patch, descpar.num_coeffs);
        case 'ghisto'
          pts(i).desc=ghistodesc(pts(i).patch, descpar.num_bins);
        case 'sift'
          pts(i).desc=siftdesc(pts(i).patch);
      end;
   end;