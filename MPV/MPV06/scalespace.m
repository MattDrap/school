function [ss, sigma]=scalespace(in, levels, step)
   
   sigma=step.^[0:levels-1]; 
   ss=zeros([size(in) levels]);
   ss(:,:,1)=in;
   for i=2:levels, ss(:,:,i)=gaussfilter(in, sigma(i)); end;