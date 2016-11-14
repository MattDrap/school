function response=hessian_response(img, sigma)
   [dxx, dxy, dyy]=gaussderiv2(img, sigma);
   response = dxx.*dyy-dxy.*dxy;
   