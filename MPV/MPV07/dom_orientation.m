function angle=dom_orientation(img)

   num_bins=72;

   % prepare windowing function
   hsz=floor(size(img,1)/2); g=zeros(size(img)); g(hsz+1,hsz+1)=1; g=gaussfilter(g,hsz/3);

   % gradient orientation and magnitude
   [dx,dy]=gaussderiv(img,1); ori = atan2(dy,dx); mag = sqrt(dx.^2+dy.^2).*g;

   % zero based bin ids
   bins = round(num_bins*(ori(:)+pi)/(2*pi)); vals = mag(:);

   % throw away invalid pixels
   vals(isnan(bins))=[]; bins(isnan(bins))=[]; bins(bins<0)=0; bins(bins>(num_bins-1))=num_bins-1;

   % simple voting
   bins = full(sparse([bins+1 ;1; num_bins], [ones(size(bins)); 1 ;1], [vals; 0 ;0]));
   kernel = [1 4 6 4 1]/16;
   bins=fliplr(cconv(kernel,fliplr(cconv(kernel, bins', num_bins)),num_bins));

   [x angle]=max(bins(:));
   angle=(((angle-1)/num_bins)*2*pi)-pi;
