function pts=transnorm(img,x,y,s,opt)
   pts=affnorm(img,x,y,ones(size(x))*s,zeros(size(x)),zeros(size(x)),ones(size(x))*s,opt);
