function [hes sigma]=sshessian_response(img)

   [ss,sigma]=scalespace(img,30,1.1);
   hes=zeros([size(img) length(sigma)]);
   
   for i=1:length(sigma)      
      dx = conv2(1, [1 0 -1],ss(:,:,i), 'same');      
      dxx = conv2(1, [1 -2 1],ss(:,:,i), 'same');
      dxy = conv2([1 0 -1], 1, dx, 'same')/4;
      dyy = conv2([1 -2 1], 1, ss(:,:,i), 'same');
      hes(:,:,i)=sigma(i).^4*(dxx.*dyy-dxy.*dxy);
   end;
   