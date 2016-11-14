function pts=simnorm(img,x,y,s,opt)
   pts=affnorm(img,x,y,s,zeros(size(x)),zeros(size(x)),s,opt);
   
