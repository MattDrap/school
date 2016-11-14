function response=harris_response(img, sigmad, sigmai)
   [dx, dy] = gaussderiv(img, sigmad);
   
   dx2  = gaussfilter(dx.*dx, sigmai);
   dxdy = gaussfilter(dy.*dx, sigmai);
   dy2  = gaussfilter(dy.*dy, sigmai);
   
   response = (dx2.*dy2-dxdy.^2)-0.04*(dx2+dy2).^2;   
   